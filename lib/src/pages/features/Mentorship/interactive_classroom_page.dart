import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import '../../../services/classroom_service.dart';
import 'package:alumini_screen/src/providers/auth_provider.dart';
import 'package:alumini_screen/src/providers/notification_provider.dart';

class InteractiveClassroomPage extends StatefulWidget {
  final String roomId;
  final bool isMentor;

  const InteractiveClassroomPage({
    super.key, 
    required this.roomId, 
    this.isMentor = false,
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
      setState(() {
        _remoteRenderers[id] = renderer;
      });
    };

    _classroomService.onRemoteStreamRemoved = (id) {
      setState(() {
        _remoteRenderers[id]?.dispose();
        _remoteRenderers.remove(id);
      });
    };

    _classroomService.onChatMessage = (from, message) {
      setState(() {
        _messages.add({'from': from, 'text': message});
      });
    };

    // Replace with your local IP if testing on physical devices
    await _classroomService.joinRoom(
      serverUrl: 'http://localhost:3000',
      roomId: widget.roomId,
      userName: auth.userName,
    );

    // Add a notification for the live session
    if (mounted) {
      context.read<NotificationProvider>().addNotification({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': widget.isMentor ? 'You are Live!' : 'Joined Class',
        'body': widget.isMentor 
            ? 'Your students can now join the session: ${widget.roomId}' 
            : 'You have joined the interactive class: ${widget.roomId}',
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
    _localRenderer.dispose();
    _remoteRenderers.values.forEach((r) => r.dispose());
    _classroomService.dispose();
    _chatController.dispose();
    super.dispose();
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
        title: Text("Class: ${widget.roomId}", style: const TextStyle(color: Colors.white)),
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
      body: Stack(
        children: [
          // Video Grid
          _buildVideoGrid(),

          // Chat Overlay
          if (_showChat) _buildChatOverlay(),

          // Meeting Controls
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    final allParticipants = [
      {'id': 'local', 'renderer': _localRenderer, 'name': 'You', 'isMentor': widget.isMentor},
      ..._remoteRenderers.entries.map((e) => {'id': e.key, 'renderer': e.value, 'name': 'Guest', 'isMentor': !widget.isMentor}),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
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
                color: Colors.black.withOpacity(0.3),
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
                      color: Colors.black.withOpacity(0.6),
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
    return Positioned(
      right: 0,
      top: 0,
      bottom: 80,
      width: 280,
      child: Container(
        color: Colors.black87,
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
                // Raise hand logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Hand raised!")),
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
