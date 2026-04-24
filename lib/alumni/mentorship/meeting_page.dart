// webrtc direct peer-to-peer video meeting and session hosting
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:graduway/alumni/shared/services/classroom_service.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';

import 'dart:developer' as dev;

import 'package:provider/provider.dart';

/// A page for hosting and joining video meetings.
class MeetingPage extends StatefulWidget {
  final String roomId;
  const MeetingPage({super.key, required this.roomId});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final ClassroomService _classroomService = ClassroomService();

  bool _isMuted = false;
  bool _isCameraOff = false;

  @override
  void initState() {
    super.initState();
    _initWebRTC();
  }

  Future<void> _initWebRTC() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    final auth = context.read<AuthProvider>();

    _classroomService.onRemoteStreamAdded = (id, stream) {
      if (mounted) {
        setState(() {
          _remoteRenderer.srcObject = stream;
        });
      }
    };

    _classroomService.onError = (message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        Navigator.pop(context);
      }
    };

    await _classroomService.joinRoom(
      serverUrl: AuthProvider.getSignalingUrl(),
      roomId: widget.roomId,
      userName: auth.userName,
      role: ClassroomRole
          .mentor, // Defaulting to mentor for this direct meeting page
    );

    if (mounted) {
      setState(() {
        _localRenderer.srcObject = _classroomService.localStream;
      });
    }
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  Future<void> _cleanup() async {
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
    await _classroomService.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _classroomService.toggleAudio(!_isMuted);
    });
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOff = !_isCameraOff;
      _classroomService.toggleVideo(!_isCameraOff);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote Video (Full Screen)
          Center(
            child: _remoteRenderer.srcObject != null
                ? RTCVideoView(_remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                : const Text("Waiting for remote stream...",
                    style: TextStyle(color: Colors.white)),
          ),

          // Local Video (Overlay)
          Positioned(
            right: 20,
            top: 50,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _localRenderer.srcObject != null
                    ? RTCVideoView(_localRenderer,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                    : const Center(
                        child: Icon(Icons.person, color: Colors.white)),
              ),
            ),
          ),

          // Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.red : Colors.white24,
                  onPressed: _toggleMute,
                ),
                _buildActionButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onPressed: () => Navigator.pop(context),
                ),
                _buildActionButton(
                  icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                  color: _isCameraOff ? Colors.red : Colors.white24,
                  onPressed: _toggleCamera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onPressed}) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: color,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
