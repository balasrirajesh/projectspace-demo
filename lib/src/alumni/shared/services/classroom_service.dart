import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:developer' as dev;

/// Roles for the classroom:
/// - Mentor (Alumni): Can start sessions, send offers.
/// - Student: Joins sessions, sends answers.
enum ClassroomRole { mentor, student }

class ClassroomService {
  // Singleton pattern for unified signaling
  static final ClassroomService _instance = ClassroomService._internal();
  factory ClassroomService() => _instance;
  ClassroomService._internal();

  io.Socket? _socket;
  String _roomId = '';
  ClassroomRole _role = ClassroomRole.student;

  // WebRTC core objects
  MediaStream? localStream;
  final Map<String, RTCPeerConnection> peerConnections = {};
  final Map<String, MediaStream> remoteStreams = {};

  // Handlers for the UI
  Function(String participantId, MediaStream stream)? onRemoteStreamAdded;
  Function(String participantId)? onRemoteStreamRemoved;
  Function(String from, String text)? onChatMessage;
  Function(String from)? onHandRaised;
  Function(String mentorId, String userName)? onMentorJoined;
  Function(String message)? onError;
  Function()? onConnected;
  Function(List<dynamic> rooms)? onRoomListUpdate;

  // Robust WebRTC Configuration using STUN & Free TURN for NAT Traversal
  final Map<String, dynamic> _rtcConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      // Free Community TURN servers from Open Relay Project
      {
        'urls': [
          'stun:openrelay.metered.ca:80',
          'turn:openrelay.metered.ca:80',
          'turn:openrelay.metered.ca:443?transport=tcp',
        ],
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
    ],
    'iceTransportPolicy': 'all',
    'sdpSemantics': 'unified-plan',
  };

  /// Main entry point to join a live class
  Future<void> joinRoom({
    required String serverUrl,
    required String roomId,
    required String userName,
    required ClassroomRole role,
    String? title,
    bool useMedia = true,
  }) async {
    _roomId = roomId;
    _role = role;

    try {
      // 1. Get Camera/Mic access ONLY if requested (don't start cam for lobby)
      if (useMedia) {
        localStream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
          'video': {'facingMode': 'user', 'width': 640, 'height': 480},
        });
      }

      // 2. Setup or Reuse Socket.io
      if (_socket == null || !_socket!.connected) {
        dev.log('🔌 [RTC] Initiating Handshake with server: $serverUrl');
        
        _socket = io.io(serverUrl, io.OptionBuilder()
            .setTransports(['websocket', 'polling']) // Prioritize WebSocket for speed, fallback to polling
            .setPath('/api/socket')
            .setQuery({'userName': userName})
            .enableAutoConnect()
            .setReconnectionAttempts(20)
            .setReconnectionDelay(2000)
            .setReconnectionDelayMax(5000)
            .setRandomizationFactor(0.5)
            .build());
        
        // Increase socket timeout to 45s for OpenShift cold-starts
        _socket?.io.timeout = 45000;
        _registerBasicEvents(serverUrl, userName); 
      } else {
        // Already connected, just join the new room
        _socket!.emit('join-room', {
          'roomId': _roomId,
          'role': _role == ClassroomRole.mentor ? 'mentor' : 'student',
          'userName': userName,
          'title': title ?? roomId,
        });
        onConnected?.call();
      }
    } catch (e) {
      onError?.call('Critical Error: $e');
    }
  }

  void _registerBasicEvents(String serverUrl, String userName) {
    _socket!.onConnect((_) async {
      dev.log('✅ Connected to Signaling Server: $serverUrl');
      await Future.delayed(const Duration(milliseconds: 500));
      
      _socket!.emit('join-room', {
        'roomId': _roomId,
        'role': _role == ClassroomRole.mentor ? 'mentor' : 'student',
        'userName': userName,
      });
      onConnected?.call();
    });

    _socket!.onConnectError((err) {
      dev.log('❌ Connection Error ($serverUrl): $err');
      // DO NOT call onError here — socket will automatically retry via reconnection.
      // Only report to UI after all reconnection attempts are exhausted.
    });

    _socket!.onReconnectAttempt((attempt) => dev.log('🔄 Reconnect attempt: $attempt'));
    _socket!.onReconnectError((err) => dev.log('❌ Reconnect Error: $err'));

    _socket!.onReconnectFailed((_) {
      // Only reached after ALL reconnection attempts have failed
      dev.log('💀 All reconnection attempts failed. Reporting error to UI.');
      onError?.call('Unable to connect to classroom after multiple attempts. Please check your network and try again.');
    });

    _socket!.onError((err) {
      dev.log('❌ [RTC] Socket Error Details: $err');
      
      final errStr = err.toString();
      // Handle the dreaded timeout specifically
      if (errStr.contains('timeout')) {
        dev.log('⏳ [RTC] Connection Handshake timed out. Escalating to UI.');
        onError?.call('Classroom connection timed out. Please verify your internet and try again.');
        return;
      }

      // Ignore standard transport layer noise that auto-reconnect handles
      if (!errStr.contains('TransportError') && !errStr.contains('xhr poll error')) {
        onError?.call('Handshake failed: $errStr');
      }
    });

    _socket!.on('error', (msg) {
      dev.log('⚠️ Server Error: $msg');
      onError?.call(msg);
    });

    // Listen for global room updates
    _socket!.on('room-list', (data) {
      onRoomListUpdate?.call(data as List<dynamic>);
    });

    // --- Signaling Handshake ---
    
    // When a new student joins, the Mentor creates an OFFER
    _socket!.on('user-joined', (studentId) async {
      if (_role == ClassroomRole.mentor) {
        await _createOffer(studentId, userName);
      }
    });

    // When an OFFER arrives (usually for Students)
    _socket!.on('offer', (data) async {
      if (_role == ClassroomRole.student) {
        await _handleOffer(data, userName);
      }
    });

    // When an ANSWER arrives (usually for Mentors)
    _socket!.on('answer', (data) async => await _handleAnswer(data));

    // When an ICE candidate arrives (Both)
    _socket!.on('ice-candidate', (data) async => await _handleIceCandidate(data));

    // Cleanup when someone leaves
    _socket!.on('user-left', (id) => _removePeer(id));
    _socket!.on('mentor-left', (_) => onError?.call('Mentor has ended the session.'));

    // Chat & Engagement
    _socket!.on('new-message', (data) => onChatMessage?.call(data['userName'] ?? 'Unknown', data['text']));
    
    // Media Relay (Images)
    _socket!.on('new-image', (data) {
      dev.log('🖼️ [RTC] Visual media received from ${data['userName']}');
      // Mix image messages into chat with a type flag
      onChatMessage?.call(data['userName'] ?? 'Unknown', '[IMAGE]');
      // We also update the messages list directly in the UI via the standard handler
      // but the UI needs to know it's an image.
      // For simplicity, we can extend the message map in the UI.
    });

    _socket!.on('user-raised-hand', (data) => onHandRaised?.call(data['userName'] ?? 'Someone'));

    _socket!.on('mentor-joined', (data) {
      dev.log('👨‍🏫 [RTC] Mentor joined: ${data['userName']}');
      onMentorJoined?.call(data['mentorId'], data['userName']);
    });

    // 4. Connect
    if (!_socket!.connected) _socket!.connect();
  }

  // --- WebRTC Logic ---

  Future<RTCPeerConnection> _createPeerConnection(String remoteId, String localName) async {
    RTCPeerConnection pc = await createPeerConnection(_rtcConfig);
    peerConnections[remoteId] = pc;

    // Send local tracks to the remote peer
    localStream?.getTracks().forEach((track) => pc.addTrack(track, localStream!));

    // Send ICE candidates to the signaling server
    pc.onIceCandidate = (candidate) {
      dev.log('❄️ [RTC] New local ICE candidate for $remoteId');
      _socket!.emit('ice-candidate', {
        'target': remoteId,
        'candidate': candidate.toMap(),
        'fromName': localName,
      });
    };

    // Receive remote video/audio tracks
    pc.onTrack = (event) {
      dev.log('📡 [RTC] Track received: ${event.track.kind} from $remoteId');
      
      if (event.streams.isNotEmpty) {
        remoteStreams[remoteId] = event.streams[0];
        onRemoteStreamAdded?.call(remoteId, event.streams[0]);
      } else {
        // Fallback for some unified-plan implementations where streams might be empty
        dev.log('⚠️ [RTC] Stream array empty, creating fallback stream for track');
        _createFallbackStream(remoteId, event.track);
      }
    };

    pc.onIceConnectionState = (state) {
      dev.log('❄️ [RTC] ICE Connection State ($remoteId): ${state.name}');
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        dev.log('❌ [RTC] ICE connection failed. NAT traversal failed. A TURN server may be required.');
        onError?.call('Connection failed: NAT traversal issue. Check your network.');
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        dev.log('✅ [RTC] ICE connection established with $remoteId');
      }
    };

    pc.onConnectionState = (state) {
      dev.log('🔗 [RTC] Global Connection State ($remoteId): ${state.name}');
    };

    // Compatibility fallback for older WebRTC implementations
    pc.onAddStream = (stream) {
      dev.log('📡 [RTC] Stream added (legacy fallback): $remoteId');
      remoteStreams[remoteId] = stream;
      onRemoteStreamAdded?.call(remoteId, stream);
    };

    return pc;
  }

  Future<void> _createFallbackStream(String remoteId, MediaStreamTrack track) async {
    // If we already have a stream for this remote user, just add the track
    if (remoteStreams.containsKey(remoteId)) {
      remoteStreams[remoteId]!.addTrack(track);
    } else {
      // Create a brand new stream and add the track
      final stream = await createLocalMediaStream('remote_$remoteId');
      await stream.addTrack(track);
      remoteStreams[remoteId] = stream;
      onRemoteStreamAdded?.call(remoteId, stream);
    }
  }

  Future<void> _createOffer(String studentId, String localName) async {
    final pc = await _createPeerConnection(studentId, localName);
    RTCSessionDescription offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    _socket!.emit('offer', {
      'target': studentId,
      'offer': offer.toMap(),
      'fromName': localName,
    });
  }

  Future<void> _handleOffer(dynamic data, String localName) async {
    final String from = data['from'].toString();
    final pc = await _createPeerConnection(from, localName);
    
    await pc.setRemoteDescription(RTCSessionDescription(data['offer']['sdp'], data['offer']['type']));
    
    RTCSessionDescription answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);

    _socket!.emit('answer', {
      'target': from,
      'answer': answer.toMap(),
      'fromName': localName,
    });
  }

  Future<void> _handleAnswer(dynamic data) async {
    final pc = peerConnections[data['from']];
    if (pc != null) {
      await pc.setRemoteDescription(RTCSessionDescription(data['answer']['sdp'], data['answer']['type']));
    }
  }

  Future<void> _handleIceCandidate(dynamic data) async {
    final pc = peerConnections[data['from']];
    if (pc != null) {
      await pc.addCandidate(RTCIceCandidate(
        data['candidate']['candidate'],
        data['candidate']['sdpMid'],
        data['candidate']['sdpMLineIndex'],
      ));
    }
  }

  void _removePeer(String id) {
    peerConnections[id]?.dispose();
    peerConnections.remove(id);
    remoteStreams.remove(id);
    onRemoteStreamRemoved?.call(id);
  }

  // Messaging Helpers
  void sendMessage(String text, String userName) => 
    _socket?.emit('send-message', {'text': text, 'roomId': _roomId, 'userName': userName});
    
  /// Relays an image file via Socket.io as a base64 string
  Future<void> sendImage(XFile file, String userName) async {
    try {
      final bytes = await File(file.path).readAsBytes();
      final base64String = base64Encode(bytes);
      
      dev.log('📸 [RTC] Relaying image from $userName (${bytes.length} bytes)');
      
      _socket?.emit('send-image', {
        'image': base64String,
        'roomId': _roomId,
        'userName': userName,
        'type': 'image'
      });
    } catch (e) {
      dev.log('❌ [RTC] Failed to send image: $e');
    }
  }

  void raiseHand(String userName) => 
    _socket?.emit('raise-hand', {'roomId': _roomId, 'userName': userName});

  void toggleAudio(bool enabled) => localStream?.getAudioTracks().forEach((t) => t.enabled = enabled);
  void toggleVideo(bool enabled) => localStream?.getVideoTracks().forEach((t) => t.enabled = enabled);

  Future<void> switchCamera() async {
    if (localStream != null && localStream!.getVideoTracks().isNotEmpty) {
      await Helper.switchCamera(localStream!.getVideoTracks()[0]);
    }
  }

  Future<void> leaveRoom() async {
    // Explicitly notify server so it can cleanup the room object immediately
    _socket?.emit('leave-room', {'roomId': _roomId});

    localStream?.getTracks().forEach((t) => t.stop());
    await localStream?.dispose();
    localStream = null;
    
    for (var pc in peerConnections.values) {
      pc.dispose();
    }
    peerConnections.clear();
    remoteStreams.clear();
    
    // Switch back to lobby instead of fully disconnecting
    _socket!.emit('join-room', {
      'roomId': 'global-lobby',
      'role': 'student',
      'userName': 'Discovery-Return',
    });
  }

  Future<void> dispose() async {
    await leaveRoom();
    
    // Explicitly clean up stream references
    localStream = null;
    remoteStreams.clear();
    
    _socket?.dispose();
    _socket = null;
  }
}
