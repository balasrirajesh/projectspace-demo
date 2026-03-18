import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:developer' as dev;

/// Service to manage WebRTC peer connections and signaling.
class WebrtcService {
  late IO.Socket socket;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  Function(MediaStream)? onRemoteStream;

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  /// Initializes the signaling connection and WebRTC.
  Future<void> init({required String serverUrl}) async {
    socket = IO.io(serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());

    socket.connect();

    socket.onConnect((_) => dev.log('Connected to signaling server'));

    socket.on('offer', (data) async {
      dev.log('Received offer');
      await _handleOffer(data);
    });

    socket.on('answer', (data) async {
      dev.log('Received answer');
      await _handleAnswer(data);
    });

    socket.on('ice-candidate', (data) async {
      dev.log('Received ice-candidate');
      await _handleIceCandidate(data);
    });
  }

  /// Starts a new call as the host.
  Future<void> startCall() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    _peerConnection = await createPeerConnection(_configuration);
    
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    _peerConnection!.onIceCandidate = (candidate) {
      socket.emit('ice-candidate', candidate.toMap());
    };

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        onRemoteStream?.call(event.streams[0]);
      }
    };

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    socket.emit('offer', offer.toMap());
  }

  Future<void> _handleOffer(dynamic data) async {
    if (_peerConnection == null) {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': true,
      });
      _peerConnection = await createPeerConnection(_configuration);
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      _peerConnection!.onIceCandidate = (candidate) {
        socket.emit('ice-candidate', candidate.toMap());
      };

      _peerConnection!.onTrack = (event) {
        if (event.streams.isNotEmpty) {
          onRemoteStream?.call(event.streams[0]);
        }
      };
    }

    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(data['sdp'], data['type'])
    );

    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    socket.emit('answer', answer.toMap());
  }

  Future<void> _handleAnswer(dynamic data) async {
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(data['sdp'], data['type'])
    );
  }

  Future<void> _handleIceCandidate(dynamic data) async {
    await _peerConnection!.addCandidate(
      RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex'])
    );
  }

  /// Disconnects the call and releases resources.
  void dispose() {
    _localStream?.dispose();
    _peerConnection?.dispose();
    socket.disconnect();
  }

  MediaStream? get localStream => _localStream;
}
