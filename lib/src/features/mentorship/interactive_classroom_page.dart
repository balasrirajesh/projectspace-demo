// webrtc multi-participant interactive video session with engagement tools
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:alumini_screen/src/shared/services/classroom_service.dart';
import 'package:alumini_screen/src/shared/providers/auth_provider.dart';
import 'package:alumini_screen/src/shared/providers/notification_provider.dart';
import 'dart:developer' as dev;

class InteractiveClassroomPage extends StatefulWidget {
  final String roomId;

  const InteractiveClassroomPage({
    super.key, 
    required this.roomId,
  });

  @override
  State<InteractiveClassroomPage> createState() => _InteractiveClassroomPageState();
}

class _InteractiveClassroomPageState extends State<InteractiveClassroomPage> {
  final ClassroomService _classroomService = ClassroomService();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  final List<Map<String, String>> _messages = [];
  final TextEditingController _chatController = TextEditingController();

  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _showChat = false;
  String _connectionState = "Connecting...";

  @override
  void initState() {
    super.initState();
    _initClassroom();
  }

  Future<void> _initClassroom() async {
    await _localRenderer.initialize();
    
    final auth = context.read<AuthProvider>();
    
    _classroomService.onRemoteStreamAdded = (id, stream) async {
      final renderer = RTCVideoRenderer();
      await renderer.initialize();
      renderer.srcObject = stream;
      if (mounted) {
        setState(() {
          _remoteRenderers[id] = renderer;
          _connectionState = "Connected: ${id.substring(0, 4)} joined";
          // Change to "Session Active" if we want a generic one
          _connectionState = "Session Active";
        });
      }
    };

    _classroomService.onRemoteStreamRemoved = (id) {
      setState(() {
        _remoteRenderers[id]?.dispose();
        _remoteRenderers.remove(id);
      });
    };

    _classroomService.onChatMessage = (from, message) {
      if (mounted) {
        setState(() {
          _messages.add({'from': from, 'text': message});
        });
      }
    };

    _classroomService.onHandRaised = (from) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$from raised their hand! ✋"),
            backgroundColor: Colors.blueAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    };

    // Security check: only users with mentor role in AuthProvider can be mentors
    final classroomRole = auth.role == UserRole.student
        ? ClassroomRole.student
        : ClassroomRole.mentor;

    _classroomService.onConnected = () {
      if (mounted) {
        setState(() {
          _connectionState = classroomRole == ClassroomRole.mentor ? "Live: Waiting for students..." : "Connected: Waiting for mentor...";
        });
      }
    };

    _classroomService.onError = (message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ $message'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.pop(context);
      }
    };

    dev.log('🚪 [CLASS] Joining room ${widget.roomId} as ${classroomRole.name}');

    await _classroomService.joinRoom(
      serverUrl: AuthProvider.getSignalingUrl(),
      roomId: widget.roomId,
      userName: auth.userName,
      role: classroomRole,
    );

    // Add a notification for the live session
    if (mounted) {
      context.read<NotificationProvider>().addNotification({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': 'You are Live!',
        'body': 'Your students can now join the session: ${widget.roomId}',
        'time': 'Just now',
        'isRead': false,
      });
    }

    setState(() {
      _localRenderer.srcObject = _classroomService.localStream;
    });
  }

  @override
  void dispose() {
    _cleanup();
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _cleanup() async {
    await _localRenderer.dispose();
    for (var renderer in _remoteRenderers.values) {
      await renderer.dispose();
    }
    await _classroomService.dispose();
  }

  void _sendMessage() {
    if (_chatController.text.isNotEmpty) {
      _classroomService.sendMessage(_chatController.text);
      _chatController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Class: ${widget.roomId}", style: const TextStyle(color: Colors.white, fontSize: 16)),
            Row(
              children: [
                Text(
                  _connectionState, 
                  style: TextStyle(
                    color: (_connectionState.contains("Live") || _connectionState.contains("Session") || _connectionState.contains("Connected")) ? Colors.green : Colors.orange, 
                    fontSize: 11,
                    fontWeight: FontWeight.bold
                  )
                ),
                if (_connectionState == "Connecting...") ...[
                  const SizedBox(width: 8),
                  Text("(${AuthProvider.serverIp})", style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ]
              ],
            ),
          ],
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showChat ? Icons.chat_bubble : Icons.chat_bubble_outline),
            onPressed: () => setState(() => _showChat = !_showChat),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 700;
            
            return Stack(
              children: [
                // Video Grid
                _buildVideoGrid(isSmallScreen),
      
                // Chat Overlay (Responsive)
                if (_showChat) 
                  _buildResponsiveChat(constraints),
      
                // Meeting Controls
                _buildControls(),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildResponsiveChat(BoxConstraints constraints) {
    double chatWidth = constraints.maxWidth > 800 ? 350 : constraints.maxWidth * 0.4;
    if (constraints.maxWidth < 600) chatWidth = constraints.maxWidth; // Full width on very small

    return Positioned(
      right: 0,
      top: 0,
      bottom: 80, // Above controls
      width: chatWidth,
      child: _buildChatOverlay(),
    );
  }
  Widget _buildVideoGrid(bool isSmallScreen) {
    final auth = context.read<AuthProvider>();
    final isStudent = auth.role == UserRole.student;
    
    final allParticipants = [
      {
        'id': 'local', 
        'renderer': _localRenderer, 
        'name': isStudent ? 'You (Student)' : 'You (Mentor)', 
        'isMentor': !isStudent
      },
      ..._remoteRenderers.entries.map((e) => {
        'id': e.key, 
        'renderer': e.value, 
        'name': isStudent ? 'Mentor' : 'Student', 
        'isMentor': isStudent // Inverted because it's the remote user
      }),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 1 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isSmallScreen ? 1.4 : 1.1,
      ),
      itemCount: allParticipants.length,
      itemBuilder: (context, index) {
        final p = allParticipants[index];
        final isHost = p['isMentor'] == true;
        
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                RTCVideoView(
                  p['renderer'] as RTCVideoRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: p['id'] == 'local',
                ),
                // Overlay Name Tag
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isHost) ...[
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          p['name'] as String,
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 12, 
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Audio Status Indicator
                const Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.black45,
                    child: Icon(Icons.mic, color: Colors.green, size: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("Live Chat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg['from']!, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(msg['text']!, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildChatInput(),
          ],
        ),
      );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[900],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent, size: 20),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.black,
          boxShadow: [BoxShadow(color: Colors.black, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlBtn(
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              color: _isMuted ? Colors.red : Colors.grey[800]!,
              onPressed: () {
                setState(() => _isMuted = !_isMuted);
                _classroomService.toggleAudio(!_isMuted);
              },
            ),
            _buildControlBtn(
              icon: Icons.call_end,
              color: Colors.red,
              onPressed: () => Navigator.pop(context),
            ),
            _buildControlBtn(
              icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
              color: _isCameraOff ? Colors.red : Colors.grey[800]!,
              onPressed: () {
                setState(() => _isCameraOff = !_isCameraOff);
                _classroomService.toggleVideo(!_isCameraOff);
              },
            ),
            _buildControlBtn(
              icon: Icons.front_hand,
              color: Colors.grey[800]!,
              onPressed: () {
                _classroomService.raiseHand();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("You raised your hand! ✋")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBtn({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: color,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
