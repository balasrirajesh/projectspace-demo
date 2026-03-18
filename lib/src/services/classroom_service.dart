import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:developer' as dev;

/// Manages interactive classroom sessions with multiple participants.
/// Currently implements a Peer-to-Peer mesh (for small groups) 
/// using the room-based signaling server.
class ClassroomService {
  late IO.Socket socket;
  late String _roomId;
  late String _currentUserName;
  
  MediaStream? localStream;
  Map<String, RTCPeerConnection> peerConnections = {};
  Map<String, MediaStream> remoteStreams = {};
  
  Function(String participantId, MediaStream stream)? onRemoteStreamAdded;
  Function(String participantId)? onRemoteStreamRemoved;
  Function(List<String> participants)? onParticipantListChanged;
  Function(String from, String message)? onChatMessage;
  Function()? onHeartReceived;

  final Map<String, dynamic> _config = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ]
  };

  /// Initializes the service and joins a specific room.
  Future<void> joinRoom({
    required String serverUrl,
    required String roomId,
    required String userName,
  }) async {
    _roomId = roomId;
    _currentUserName = userName;

    socket = IO.io(serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .build());

    socket.connect();

    socket.onConnect((_) {
      dev.log('Connected to classroom server');
      socket.emit('join-room', _roomId);
    });

    socket.on('user-joined', (userId) async {
      dev.log('User joined: $userId');
      await _createNewPeerConnection(userId, true);
    });

    socket.on('offer', (data) async {
      final String from = data['from'];
      dev.log('Received offer from $from');
      await _handleOffer(from, data['offer']);
    });

    socket.on('answer', (data) async {
      final String from = data['from'];
      dev.log('Received answer from $from');
      await _handleAnswer(from, data['answer']);
    });

    socket.on('ice-candidate', (data) async {
      final String from = data['from'];
      dev.log('Received candidate from $from');
      await _handleIceCandidate(from, data['candidate']);
    });

    socket.on('new-message', (data) {
      onChatMessage?.call(data['userName'], data['text']);
    });

    socket.on('receive-heart', (_) {
      onHeartReceived?.call();
    });

    socket.on('user-left', (userId) {
      dev.log('User left: $userId');
      _removePeerConnection(userId);
    });

    // Initialize local media
    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });
  }

  Future<void> _createNewPeerConnection(String userId, bool isOffer) async {
    RTCPeerConnection pc = await createPeerConnection(_config);
    peerConnections[userId] = pc;

    localStream?.getTracks().forEach((track) {
      pc.addTrack(track, localStream!);
    });

    pc.onIceCandidate = (candidate) {
      socket.emit('ice-candidate', {
        'candidate': candidate.toMap(),
        'to': userId,
      });
    };

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteStreams[userId] = event.streams[0];
        onRemoteStreamAdded?.call(userId, event.streams[0]);
      }
    };

    if (isOffer) {
      RTCSessionDescription offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      socket.emit('offer', {
        'offer': offer.toMap(),
        'roomId': _roomId,
        'to': userId,
      });
    }
  }

  Future<void> _handleOffer(String from, dynamic offerData) async {
    if (!peerConnections.containsKey(from)) {
      await _createNewPeerConnection(from, false);
    }
    
    RTCPeerConnection pc = peerConnections[from]!;
    await pc.setRemoteDescription(
      RTCSessionDescription(offerData['sdp'], offerData['type'])
    );

    RTCSessionDescription answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);

    socket.emit('answer', {
      'answer': answer.toMap(),
      'to': from,
    });
  }

  Future<void> _handleAnswer(String from, dynamic answerData) async {
    RTCPeerConnection? pc = peerConnections[from];
    if (pc != null) {
      await pc.setRemoteDescription(
        RTCSessionDescription(answerData['sdp'], answerData['type'])
      );
    }
  }

  Future<void> _handleIceCandidate(String from, dynamic candidateData) async {
    RTCPeerConnection? pc = peerConnections[from];
    if (pc != null) {
      await pc.addCandidate(RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex'],
      ));
    }
  }

  void _removePeerConnection(String userId) {
    peerConnections[userId]?.dispose();
    peerConnections.remove(userId);
    remoteStreams.remove(userId);
    onRemoteStreamRemoved?.call(userId);
  }

  /// Sends a chat message to the room.
  void sendMessage(String text) {
    socket.emit('send-message', {
      'text': text,
      'roomId': _roomId,
      'userName': _currentUserName,
    });
  }

  /// Sends a heart reaction.
  void sendHeart() {
    socket.emit('send-heart', _roomId);
  }

  /// Toggles media tracks.
  void toggleAudio(bool enabled) {
    localStream?.getAudioTracks().forEach((track) => track.enabled = enabled);
  }

  void toggleVideo(bool enabled) {
    localStream?.getVideoTracks().forEach((track) => track.enabled = enabled);
  }

  /// Cleans up resources.
  void dispose() {
    localStream?.dispose();
    peerConnections.values.forEach((pc) => pc.dispose());
    socket.disconnect();
  }
}
