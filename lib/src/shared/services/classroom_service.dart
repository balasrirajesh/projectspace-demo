import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:developer' as dev;

/// Roles for the classroom:
/// - Mentor (Alumni): Can start sessions, send offers.
/// - Student: Joins sessions, sends answers.
enum ClassroomRole { mentor, student }

class ClassroomService {
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
  Function(String from, String message)? onChatMessage;
  Function(String from)? onHandRaised;
  Function(String message)? onError;
  Function()? onConnected;
  Function(List<dynamic> rooms)? onRoomListUpdate;

  // Standard WebRTC Configuration using multiple reliable STUN servers
  final Map<String, dynamic> _rtcConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {'urls': 'stun:stun3.l.google.com:19302'},
      {'urls': 'stun:stun4.l.google.com:19302'},
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

      // 2. Setup Socket.io
      _socket = io.io(serverUrl, io.OptionBuilder()
          .setTransports(['polling', 'websocket']) 
          .setQuery({'userName': userName})
          .enableAutoConnect()
          .build());

      // 3. Register Events
      _socket!.onConnect((_) async {
        dev.log('✅ Connected to Signaling Server: $serverUrl');
        
        // Brief delay before joining to ensure backend socket state is fully established
        await Future.delayed(const Duration(milliseconds: 500));
        
        _socket!.emit('join-room', {
          'roomId': _roomId,
          'role': _role == ClassroomRole.mentor ? 'mentor' : 'student',
          'userName': userName,
          'title': title ?? roomId,
        });
        onConnected?.call();
      });

      _socket!.onConnectError((err) {
        dev.log('❌ Connection Error ($serverUrl): $err');
        // On mobile, this often means SSL handshake failed
      });

      _socket!.onReconnectAttempt((attempt) => dev.log('🔄 Reconnect attempt: $attempt'));
      _socket!.onReconnectError((err) => dev.log('❌ Reconnect Error: $err'));

      _socket!.onError((err) {
        dev.log('❌ Socket Error: $err');
        onError?.call('Socket Connection failed. Error: $err');
      });

      _socket!.on('error', (msg) {
        dev.log('⚠️ Server Error: $msg');
        onError?.call(msg);
      });

      // Listen for global room updates
      _socket!.on('room-list', (data) {
        onRoomListUpdate?.call(data);
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
      _socket!.on('user-raised-hand', (data) => onHandRaised?.call(data['userName'] ?? 'Someone'));

      // 4. Connect
      if (!_socket!.connected) _socket!.connect();
    } catch (e) {
      onError?.call('Critical Error: $e');
    }
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
      }
    };

    pc.onIceConnectionState = (state) {
      dev.log('❄️ [RTC] ICE Connection State ($remoteId): ${state.name}');
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        dev.log('❌ [RTC] ICE connection failed. NAT traversal failed.');
      }
    };

    pc.onConnectionState = (state) {
      dev.log('🔗 [RTC] Connection State ($remoteId): ${state.name}');
    };

    return pc;
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
    
  void raiseHand(String userName) => 
    _socket?.emit('raise-hand', {'roomId': _roomId, 'userName': userName});

  void toggleAudio(bool enabled) => localStream?.getAudioTracks().forEach((t) => t.enabled = enabled);
  void toggleVideo(bool enabled) => localStream?.getVideoTracks().forEach((t) => t.enabled = enabled);

  Future<void> switchCamera() async {
    if (localStream != null && localStream!.getVideoTracks().isNotEmpty) {
      await Helper.switchCamera(localStream!.getVideoTracks()[0]);
    }
  }

  Future<void> dispose() async {
    localStream?.getTracks().forEach((t) => t.stop());
    await localStream?.dispose();
    for (var pc in peerConnections.values) {
      pc.dispose();
    }
    _socket?.dispose();
    _socket = null;
  }
}
