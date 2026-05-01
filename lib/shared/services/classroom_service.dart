import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:image_picker/image_picker.dart';
import 'dart:io' as dart_io;
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:permission_handler/permission_handler.dart';

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
  Function(String from, bool isRaised)? onHandRaised;
  Function(String mentorId, String userName, {String? role})? onMentorJoined;
  Function(String message)? onError;
  Function()? onConnected;
  Function(List<dynamic> rooms)? onRoomListUpdate;
  Function(Map<String, dynamic> data)? onAnnouncementReceived;
  Function(bool canAccessMic, bool canAccessVideo)? onPermissionUpdate;

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
          'turn:openrelay.metered.ca:443?transport=udp'
        ],
        'username': 'openrelay',
        'credential': 'openrelay'
      }
    ],
    'sdpSemantics': 'unified-plan'
  };

  /// Main entry point to join a classroom or the global lobby.
  Future<void> joinRoom({
    required String serverUrl,
    required String roomId,
    required String userName,
    ClassroomRole role = ClassroomRole.student,
    bool useMedia = true,
    bool startWithMedia = true,
  }) async {
    _roomId = roomId;
    _role = role;

    // --- Media Setup ---
    if (useMedia && startWithMedia) {
      try {
        if (!kIsWeb) {
          final camStatus = await Permission.camera.request();
          final micStatus = await Permission.microphone.request();

          if (camStatus != PermissionStatus.granted ||
              micStatus != PermissionStatus.granted) {
            dev.log('❌ [RTC] Permissions denied: Cam=$camStatus, Mic=$micStatus');
            onError?.call('Camera/Microphone permissions are required.');
            return; // Stop if permissions not granted
          }
        }

        localStream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
          'video': {
            'facingMode': 'user',
            'width': 640,
            'height': 480,
          }
        });
        dev.log('📹 [RTC] Local stream initialized for $userName');
      } catch (e) {
        dev.log('❌ [RTC] Media error: $e');
        onError?.call('Could not access camera/microphone.');
      }
    }

    // --- Socket Setup ---
    if (_socket != null && _socket!.connected) {
      _socket!.disconnect();
    }

    dev.log('📡 [SOCKET] Connecting to: $serverUrl/api/socket');
    
    _socket = io.io(serverUrl, io.OptionBuilder()
        .setTransports(['websocket', 'polling']) 
        .setPath('/api/socket')
        .setQuery({'userName': userName})
        .disableAutoConnect()
        .setReconnectionAttempts(15)
        .setReconnectionDelay(2000)
        .build());

    _registerBasicEvents(userName);
    _socket!.connect();
  }

  void _registerBasicEvents(String userName) {
    _socket!.onConnect((_) {
      dev.log('✅ [SOCKET] Connected to signaling server');
      onConnected?.call();
      _socket!.emit('join-room', {
        'roomId': _roomId,
        'role': _role.name,
        'userName': userName,
        'title': _roomId
      });
    });

    _socket!.onDisconnect((_) => dev.log('❌ [SOCKET] Disconnected'));
    _socket!.onConnectError((data) {
      dev.log('⚠️ [SOCKET] Connection Error: $data');
      onError?.call('Could not connect to signaling server. Please check your internet or server status.');
    });
    _socket!.on('connect_timeout', (data) {
      dev.log('⚠️ [SOCKET] Connection Timeout: $data');
      onError?.call('Signaling server connection timed out.');
    });
    _socket!.on('error', (msg) => onError?.call(msg.toString()));

    // --- Signaling Handshake (MESH Logic) ---

    _socket!.on('participant-list', (data) async {
      dev.log('👥 [RTC] Discovering participants: $data');
      final Map<dynamic, dynamic> participantMap = data as Map;
      
      participantMap.forEach((id, metadata) {
        if (id != _socket!.id) {
          final Map<String, String> meta = {};
          if (metadata is Map) {
            metadata.forEach((key, value) {
              meta[key.toString()] = value.toString();
            });
          }
          participants[id.toString()] = meta;
          
          final role = meta['role'];
          if (role == 'mentor' || role == 'admin') {
            onMentorJoined?.call(id.toString(), meta['userName'] ?? 'Host', role: role);
          }

          // MESH RULE: Joiner initiates to established members
          _createOffer(id.toString(), userName);
        }
      });
    });

    _socket!.on('participant-joined', (data) {
      final id = data['socketId'].toString();
      dev.log('👋 [RTC] Participant entered: ${data['userName']} ($id)');
      
      final Map<String, String> meta = {
        'role': data['role']?.toString() ?? 'student',
        'userName': data['userName']?.toString() ?? 'Anonymous'
      };
      participants[id] = meta;
      
      if (meta['role'] == 'mentor' || meta['role'] == 'admin') {
        onMentorJoined?.call(id, meta['userName']!, role: meta['role']);
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
    _socket!.on('user-raised-hand', (data) => onHandRaised?.call(data['userName'] ?? 'Someone', data['isRaised'] ?? true));
    _socket!.on('room-list', (data) => onRoomListUpdate?.call(data as List<dynamic>));
    _socket!.on('new-announcement', (data) => onAnnouncementReceived?.call(Map<String, dynamic>.from(data as Map)));
    
    _socket!.on('media-permission-updated', (data) {
      if (data['targetId'] == _socket!.id || data['targetId'] == 'all') {
        onPermissionUpdate?.call(data['mic'] ?? false, data['video'] ?? false);
      }
    });

    if (!_socket!.connected) _socket!.connect();
  }

  // --- WebRTC Core ---

  Future<RTCPeerConnection> _createPeerConnection(String remoteId, String localName) async {
    RTCPeerConnection pc = await createPeerConnection(_rtcConfig);
    peerConnections[remoteId] = pc;

    // SAFE TRACK ADDITION: Only add if media is actually active
    if (localStream != null) {
      for (var track in localStream!.getTracks()) {
        pc.addTrack(track, localStream!);
      }
    }

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
    RTCSessionDescription offer = await pc.createOffer({
      'offerToReceiveAudio': 1,
      'offerToReceiveVideo': 1,
    });
    await pc.setLocalDescription(offer);

    _socket!.emit('offer', {
      'target': targetId,
      'offer': offer.toMap(),
      'fromName': localName,
    });
  }

  Future<void> _handleOffer(dynamic data, String localName) async {
    final String from = data['from'].toString();
    final String fromName = data['fromName'] ?? 'Remote';
    dev.log('📩 [RTC] Offer from $fromName ($from)');

    final pc = await _createPeerConnection(from, localName);
    await pc.setRemoteDescription(RTCSessionDescription(data['offer']['sdp'], data['offer']['type']));
    
    RTCSessionDescription answer = await pc.createAnswer({
      'offerToReceiveAudio': 1,
      'offerToReceiveVideo': 1,
    });
    await pc.setLocalDescription(answer);

    _socket!.emit('answer', {
      'target': from,
      'answer': answer.toMap(),
      'fromName': localName,
    });
  }

  Future<void> _handleAnswer(dynamic data) async {
    final String from = data['from'].toString();
    dev.log('📨 [RTC] Answer from $from');
    final pc = peerConnections[from];
    if (pc != null) {
      await pc.setRemoteDescription(RTCSessionDescription(data['answer']['sdp'], data['answer']['type']));
    }
  }

  Future<void> _handleIceCandidate(dynamic data) async {
    final String from = data['from'].toString();
    final pc = peerConnections[from];
    if (pc != null) {
      await pc.addCandidate(RTCIceCandidate(
          data['candidate']['candidate'], data['candidate']['sdpMid'], data['candidate']['sdpMLineIndex']));
    }
  }

  void _removePeer(String id) {
    peerConnections[id]?.close();
    peerConnections.remove(id);
    remoteStreams.remove(id);
    onRemoteStreamRemoved?.call(id);
  }

  // --- UI Actions ---

  void sendMessage(String text, String userName) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('send-message', {'roomId': _roomId, 'text': text, 'userName': userName});
    }
  }

  void raiseHand(String userName, bool isRaised) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('raise-hand', {'roomId': _roomId, 'userName': userName, 'isRaised': isRaised});
    }
  }

  void toggleAudio(bool enabled) {
    localStream?.getAudioTracks().forEach((track) {
      track.enabled = enabled;
    });
  }

  void toggleVideo(bool enabled) {
    localStream?.getVideoTracks().forEach((track) {
      track.enabled = enabled;
    });
  }

  Future<void> setSpeakerphoneOn(bool enabled) async {
    try {
      // ignore: deprecated_member_use
      await Helper.setSpeakerphoneOn(enabled);
      dev.log('🔊 [RTC] Speakerphone: $enabled');
    } catch (e) {
      dev.log('⚠️ [RTC] Speakerphone error: $e');
    }
  }

  Future<void> sendImage(XFile image, String userName) async {
    final bytes = await dart_io.File(image.path).readAsBytes();
    final base64Image = base64Encode(bytes);
    _socket!.emit('send-image', {
      'roomId': _roomId,
      'userName': userName,
      'text': '[Image]',
      'image': base64Image
    });
  }

  Future<void> switchCamera() async {
    if (localStream != null && localStream!.getVideoTracks().isNotEmpty) {
      final videoTrack = localStream!.getVideoTracks().first;
      // ignore: deprecated_member_use
      await Helper.switchCamera(videoTrack);
    }
  }

  void updateStudentPermission(String studentId, bool mic, bool video) {
    if (_role == ClassroomRole.mentor && _socket != null) {
      _socket!.emit('update-media-permission', {
        'roomId': _roomId,
        'targetId': studentId,
        'mic': mic,
        'video': video,
      });
    }
  }

  void updateAllStudentsPermission(bool mic, bool video) {
    if (_role == ClassroomRole.mentor && _socket != null) {
      _socket!.emit('update-media-permission', {
        'roomId': _roomId,
        'targetId': 'all',
        'mic': mic,
        'video': video,
      });
    }
  }

  Future<void> startLocalStream() async {
    try {
      final camStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      if (camStatus == PermissionStatus.granted && micStatus == PermissionStatus.granted) {
        localStream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
          'video': {
            'facingMode': 'user',
            'width': 640,
            'height': 480,
          }
        });
        
        // Add tracks to existing peer connections
        peerConnections.forEach((id, pc) {
          localStream!.getTracks().forEach((track) {
            pc.addTrack(track, localStream!);
          });
        });
        
        dev.log('📹 [RTC] Local stream started after permission granted');
      }
    } catch (e) {
      dev.log('❌ [RTC] Error starting local stream: $e');
    }
  }

  void stopLocalStream() {
    if (localStream != null) {
      dev.log('🔇 [RTC] Explicitly stopping ${localStream!.getTracks().length} tracks');
      for (var track in localStream!.getTracks()) {
        track.enabled = false;
        track.stop();
      }
      localStream!.dispose();
      localStream = null;
      dev.log('✅ [RTC] Local stream fully disposed');
    }
  }

  Future<void> leaveRoom() async {
    dev.log('🚪 [RTC] Leaving room $_roomId');
    if (_socket != null && _socket!.connected) {
      _socket!.emit('leave-room', {'roomId': _roomId});
      _socket!.disconnect();
    }
    dispose();
  }

  void dispose() {
    dev.log('🧹 [RTC] Disposing ClassroomService instance');
    stopLocalStream();
    
    peerConnections.forEach((id, pc) {
      dev.log('🔌 [RTC] Closing peer connection: $id');
      pc.close();
    });
    peerConnections.clear();
    remoteStreams.clear();
    participants.clear();
    
    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
    }
    dev.log('✨ [RTC] ClassroomService disposal complete');
  }
}
