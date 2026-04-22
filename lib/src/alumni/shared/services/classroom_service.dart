import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:developer' as dev;

enum ClassroomRole { mentor, student }

class ClassroomService {
  io.Socket? _socket;
  RTCPeerConnection? _peerConnection;
  MediaStream? localStream;
  String? _roomId;
  final Map<String, dynamic> participants = {};

  // Callbacks
  Function(String participantId, MediaStream stream)? onRemoteStreamAdded;
  Function(String participantId)? onRemoteStreamRemoved;
  Function(String from, String text)? onChatMessage;
  Function(String from, bool isRaised)? onHandRaised;
  Function(String mentorId, String userName, {String? role})? onMentorJoined;
  Function(String message)? onError;
  Function()? onConnected;
  Function(List<dynamic> rooms)? onRoomListUpdate;
  Function(Map<String, dynamic> data)? onAnnouncementReceived;

  Future<void> joinRoom({
    required String serverUrl,
    required String roomId,
    required String userName,
    required ClassroomRole role,
    String? title,
    bool useMedia = true,
  }) async {
    _roomId = roomId;
    
    // 1. Setup Socket
    _socket = io.io(serverUrl, {
      'transports': ['websocket', 'polling'],
      'autoConnect': true,
      'path': '/api/socket',
      'extraHeaders': {'userName': userName},
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 2000,
    });

    _socket!.onConnect((_) {
      dev.log('✅ [RTC] Connected to signaling server');
      _socket!.emit('join-room', {
        'roomId': roomId,
        'userName': userName,
        'role': role == ClassroomRole.mentor ? 'mentor' : 'student'
      });
      onConnected?.call();
    });

    _socket!.onConnectError((data) {
      dev.log('❌ [RTC] Connection Error: $data');
      onError?.call('Could not connect to the classroom server.');
    });

    // 2. Setup Listeners
    _socket!.on('participant-list', (data) {
      participants.clear();
      participants.addAll(Map<String, dynamic>.from(data));
    });

    _socket!.on('participant-joined', (data) {
      participants[data['socketId']] = data;
      if (data['role'] == 'mentor' || data['role'] == 'admin') {
        onMentorJoined?.call(data['socketId'], data['userName'], role: data['role']);
      }
      _startPeerConnection(data['socketId'], userName, isOffer: role == ClassroomRole.mentor);
    });

    _socket!.on('participant-left', (id) {
      participants.remove(id);
      onRemoteStreamRemoved?.call(id);
    });

    _socket!.on('offer', (data) async => await _handleOffer(data, userName));
    _socket!.on('answer', (data) async => await _handleAnswer(data));
    _socket!.on('ice-candidate', (data) async => await _handleIceCandidate(data));

    // Global Events
    _socket!.on('mentor-left', (_) => onError?.call('The educational session has ended.'));
    _socket!.on('new-message', (data) => onChatMessage?.call(data['userName'] ?? 'Unknown', data['text']));
    _socket!.on('user-raised-hand', (data) => onHandRaised?.call(data['userName'] ?? 'Someone', data['isRaised'] ?? true));
    _socket!.on('room-list', (data) => onRoomListUpdate?.call(data as List<dynamic>));
    _socket!.on('new-announcement', (data) => onAnnouncementReceived?.call(Map<String, dynamic>.from(data as Map)));

    // 3. Get Local Media
    if (useMedia) {
      try {
        localStream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
          'video': {
            'facingMode': 'user',
            'width': 640,
            'height': 480,
            'frameRate': 15,
          }
        });
      } catch (e) {
        dev.log('❌ [RTC] Media Error: $e');
        // Continue without local stream (view only mode)
      }
    }
  }

  Future<void> _startPeerConnection(String targetId, String localName, {required bool isOffer}) async {
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ]
    });

    _peerConnection!.onIceCandidate = (candidate) {
      _socket!.emit('ice-candidate', {
        'target': targetId,
        'candidate': candidate.toMap(),
        'fromName': localName
      });
    };

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        onRemoteStreamAdded?.call(targetId, event.streams[0]);
      }
    };

    localStream?.getAudioTracks().forEach((track) {
      _peerConnection!.addTrack(track, localStream!);
    });
    localStream?.getVideoTracks().forEach((track) {
      _peerConnection!.addTrack(track, localStream!);
    });

    if (isOffer) {
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      _socket!.emit('offer', {
        'target': targetId,
        'offer': offer.toMap(),
        'fromName': localName
      });
    }
  }

  Future<void> _handleOffer(Map<String, dynamic> data, String localName) async {
    if (_peerConnection == null) await _startPeerConnection(data['from'], localName, isOffer: false);
    
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(data['offer']['sdp'], data['offer']['type'])
    );
    
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    
    _socket!.emit('answer', {
      'target': data['from'],
      'answer': answer.toMap(),
      'fromName': localName
    });
  }

  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(data['answer']['sdp'], data['answer']['type'])
    );
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> data) async {
    if (data['candidate'] != null) {
      await _peerConnection!.addCandidate(
        RTCIceCandidate(
          data['candidate']['candidate'],
          data['candidate']['sdpMid'],
          data['candidate']['sdpMLineIndex'],
        )
      );
    }
  }

  Future<void> leaveRoom() async {
    _socket?.emit('leave-room', {'roomId': _roomId});
    localStream?.getAudioTracks().forEach((t) => t.stop());
    localStream?.getVideoTracks().forEach((t) => t.stop());
    await _peerConnection?.dispose();
    _socket?.disconnect();
    _socket?.dispose();
  }

  void sendMessage(String text, String userName) => 
    _socket?.emit('send-message', {'text': text, 'roomId': _roomId, 'userName': userName});

  Future<void> sendImage(XFile image, String userName) async {
    final bytes = await image.readAsBytes();
    final base64 = base64Encode(bytes);
    _socket?.emit('send-image', {
      'image': base64,
      'roomId': _roomId,
      'userName': userName,
      'type': 'image'
    });
  }

  void raiseHand(String userName, bool isRaised) => 
    _socket?.emit('raise-hand', {'roomId': _roomId, 'userName': userName, 'isRaised': isRaised});

  void toggleAudio(bool enabled) => localStream?.getAudioTracks().forEach((t) => t.enabled = enabled);
  void toggleVideo(bool enabled) => localStream?.getVideoTracks().forEach((t) => t.enabled = enabled);

  Future<void> switchCamera() async {
    if (localStream != null && localStream!.getVideoTracks().isNotEmpty) {
      await Helper.switchCamera(localStream!.getVideoTracks().first);
    }
  }

  void setSpeakerphoneOn(bool enabled) {
    if (enabled) {
      Helper.setSpeakerphoneOn(true);
    } else {
      Helper.setSpeakerphoneOn(false);
    }
  }

  Future<void> dispose() async {
    await leaveRoom();
  }
}
