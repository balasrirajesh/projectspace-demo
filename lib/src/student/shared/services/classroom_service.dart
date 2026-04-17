import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:image_picker/image_picker.dart';
import 'dart:io' as dart_io;
import 'dart:convert';
import 'dart:developer' as dev;

/// Roles for the classroom:
/// - Mentor (Alumni/Faculty): Can start sessions, send offers.
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
  final Map<String, Map<String, String>> participants = {}; // socketId -> { role, userName }

  // Handlers for the UI
  Function(String participantId, MediaStream stream)? onRemoteStreamAdded;
  Function(String participantId)? onRemoteStreamRemoved;
  Function(String from, String text)? onChatMessage;
  Function(String from)? onHandRaised;
  Function(String mentorId, String userName, {String? role})? onMentorJoined;
  Function(String message)? onError;
  Function()? onConnected;
  Function(List<dynamic> rooms)? onRoomListUpdate;
  Function(Map<String, dynamic> data)? onAnnouncementReceived;

  // Robust WebRTC Configuration using STUN & Free TURN for NAT Traversal
  final Map<String, dynamic> _rtcConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
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
      // 1. Get Camera/Mic access with failsafe try-catch
      if (useMedia) {
        try {
          localStream = await navigator.mediaDevices.getUserMedia({
            'audio': true,
            'video': {'facingMode': 'user', 'width': 640, 'height': 480},
          });
        } catch (mediaErr) {
          dev.log('⚠️ [RTC] Media Denied: $mediaErr. Continuing with signaling only.');
        }
      }

      // 2. Setup or Reuse Socket.io
      if (_socket == null || !_socket!.connected) {
        dev.log('🔌 [RTC] Handshaking with server: $serverUrl');
        
        _socket = io.io(serverUrl, io.OptionBuilder()
            .setTransports(['websocket', 'polling']) 
            .setPath('/api/socket')
            .setQuery({'userName': userName})
            .enableAutoConnect()
            .setReconnectionAttempts(15)
            .setReconnectionDelay(2000)
            .build());
        
        _socket?.io.timeout = 45000;
        _registerBasicEvents(serverUrl, userName); 
        // Already connected, just join the room
        _socket!.emit('join-room', {
          'roomId': _roomId,
          'role': AuthProvider.isUserAdmin ? 'admin' : (_role == ClassroomRole.mentor ? 'mentor' : 'student'),
          'userName': userName,
          'title': title ?? roomId,
        });
        
        // Minor delay to allow room joining to register before calling onConnected
        Future.delayed(const Duration(milliseconds: 100), () => onConnected?.call());
      }
    } catch (e) {
      onError?.call('Critical Handshake Error: $e');
    }
  }

  void _registerBasicEvents(String serverUrl, String userName) {
    _socket!.onConnect((_) async {
      dev.log('✅ Connected to Signaling Server');
      await Future.delayed(const Duration(milliseconds: 300));
      
      _socket!.emit('join-room', {
        'roomId': _roomId,
        'role': AuthProvider.isUserAdmin ? 'admin' : (_role == ClassroomRole.mentor ? 'mentor' : 'student'),
        'userName': userName,
      });
      onConnected?.call();
    });

    _socket!.onConnectError((err) => dev.log('❌ Connection Error: $err'));
    
    _socket!.onError((err) {
      dev.log('❌ Handshake Error: $err');
      final errStr = err.toString();
      if (!errStr.contains('TransportError') && !errStr.contains('xhr poll error')) {
        onError?.call('Signal failure: $errStr');
      }
    });

    // --- Signaling Handshake (MESH Logic) ---

    _socket!.on('participant-list', (data) async {
      dev.log('👥 [RTC] Discovering participants: $data');
      final participantMap = Map<String, dynamic>.from(data as Map);
      
      participantMap.forEach((id, metadata) {
        if (id != _socket!.id) {
          participants[id] = Map<String, String>.from(metadata);
          
          // Initial Host Discovery: Notify UI so it stops "Waiting"
          final role = metadata['role'];
          if (role == 'mentor' || role == 'admin') {
            onMentorJoined?.call(id, metadata['userName'] ?? 'Host', role: role);
          }

          // MESH RULE: Joiner initiates to established members
          _createOffer(id, userName);
        }
      });
    });

    _socket!.on('participant-joined', (data) {
      final id = data['socketId'];
      dev.log('👋 [RTC] Participant entered: ${data['userName']} ($id)');
      participants[id] = {
        'role': data['role'],
        'userName': data['userName']
      };
      
      if (data['role'] == 'mentor' || data['role'] == 'admin') {
        onMentorJoined?.call(id, data['userName'], role: data['role']);
      }
    });

    _socket!.on('participant-left', (id) {
      dev.log('🚪 [RTC] Participant left: $id');
      participants.remove(id);
      _removePeer(id);
    });

    // Relay Listeners
    _socket!.on('offer', (data) async => await _handleOffer(data, userName));
    _socket!.on('answer', (data) async => await _handleAnswer(data));
    _socket!.on('ice-candidate', (data) async => await _handleIceCandidate(data));

    // Global Events
    _socket!.on('mentor-left', (_) => onError?.call('The educational session has ended.'));
    _socket!.on('new-message', (data) => onChatMessage?.call(data['userName'] ?? 'Unknown', data['text']));
    _socket!.on('user-raised-hand', (data) => onHandRaised?.call(data['userName'] ?? 'Someone'));
    _socket!.on('room-list', (data) => onRoomListUpdate?.call(data as List<dynamic>));
    _socket!.on('new-announcement', (data) => onAnnouncementReceived?.call(Map<String, dynamic>.from(data as Map)));

    if (!_socket!.connected) _socket!.connect();
  }

  // --- WebRTC Core ---

  Future<RTCPeerConnection> _createPeerConnection(String remoteId, String localName) async {
    RTCPeerConnection pc = await createPeerConnection(_rtcConfig);
    peerConnections[remoteId] = pc;

    localStream?.getTracks().forEach((track) => pc.addTrack(track, localStream!));

    pc.onIceCandidate = (candidate) {
      _socket!.emit('ice-candidate', {
        'target': remoteId,
        'candidate': candidate.toMap(),
        'fromName': localName,
      });
    };

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteStreams[remoteId] = event.streams[0];
        onRemoteStreamAdded?.call(remoteId, event.streams[0]);
      } else {
        _createFallbackStream(remoteId, event.track);
      }
    };

    return pc;
  }

  Future<void> _createFallbackStream(String remoteId, MediaStreamTrack track) async {
    if (remoteStreams.containsKey(remoteId)) {
      remoteStreams[remoteId]!.addTrack(track);
    } else {
      final stream = await createLocalMediaStream('remote_$remoteId');
      await stream.addTrack(track);
      remoteStreams[remoteId] = stream;
      onRemoteStreamAdded?.call(remoteId, stream);
    }
  }

  Future<void> _createOffer(String targetId, String localName) async {
    final pc = await _createPeerConnection(targetId, localName);
    RTCSessionDescription offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    _socket!.emit('offer', {
      'target': targetId,
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
    
  Future<void> sendImage(XFile image, String userName) async {
    final bytes = await dart_io.File(image.path).readAsBytes();
    final base64Image = base64Encode(bytes);
    _socket?.emit('send-image', {
      'image': base64Image,
      'roomId': _roomId,
      'userName': userName,
      'type': 'image'
    });
  }
    
  void raiseHand(String userName) => 
    _socket?.emit('raise-hand', {'roomId': _roomId, 'userName': userName});

  void toggleAudio(bool enabled) => localStream?.getAudioTracks().forEach((t) => t.enabled = enabled);
  void toggleVideo(bool enabled) => localStream?.getVideoTracks().forEach((t) => t.enabled = enabled);

  Future<void> switchCamera() async {
    if (localStream != null) {
      final videoTrack = localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
    }
  }

  Future<void> leaveRoom() async {
    _socket?.emit('leave-room', {'roomId': _roomId});

    localStream?.getTracks().forEach((t) => t.stop());
    await localStream?.dispose();
    localStream = null;
    
    for (var pc in peerConnections.values) {
      pc.dispose();
    }
    peerConnections.clear();
    remoteStreams.clear();
    participants.clear();
  }

  Future<void> dispose() async {
    await leaveRoom();
    _socket?.dispose();
    _socket = null;
  }
}
