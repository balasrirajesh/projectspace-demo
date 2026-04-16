// webrtc multi-participant interactive video session with engagement tools
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:alumini_screen/src/alumni/shared/services/classroom_service.dart';
import 'package:alumini_screen/src/alumni/shared/providers/auth_provider.dart';
import 'package:alumini_screen/src/alumni/shared/providers/notification_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:ui';

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

    _classroomService.onMentorJoined = (mentorId, userName) {
      if (mounted) {
        setState(() {
          _connectionState = "Mentor ($userName) Joined! Connecting...";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("👨‍🏫 Mentor $userName has joined the session!"),
            backgroundColor: Colors.green,
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
    await _classroomService.leaveRoom();
  }

  void _sendMessage() {
    if (_chatController.text.isNotEmpty) {
      final auth = context.read<AuthProvider>();
      _classroomService.sendMessage(_chatController.text, auth.userName);
      _chatController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.sensors, color: Colors.redAccent, size: 16),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Room: ${widget.roomId}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: (_connectionState.contains("Live") || _connectionState.contains("Session") || _connectionState.contains("Connected")) ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_connectionState.contains("Live") || _connectionState.contains("Session") || _connectionState.contains("Connected")) ? Colors.green.withOpacity(0.5) : Colors.orange.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _connectionState.toUpperCase(), 
                      style: const TextStyle(
                        color: Colors.white70, 
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      )
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _buildParticipantCount(),
          const SizedBox(width: 8),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _showChat ? Colors.blueAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showChat ? Icons.chat_bubble : Icons.chat_bubble_outline, 
                color: _showChat ? Colors.blueAccent : Colors.white,
                size: 20
              ),
            ),
            onPressed: () => setState(() => _showChat = !_showChat),
          ),
          const SizedBox(width: 12),
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

  Widget _buildParticipantCount() {
    final count = 1 + _remoteRenderers.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_outline, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text("$count", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildResponsiveChat(BoxConstraints constraints) {
    double chatWidth = constraints.maxWidth > 900 ? 380 : constraints.maxWidth * 0.45;
    if (constraints.maxWidth < 600) chatWidth = constraints.maxWidth;

    return Positioned(
      right: 0,
      top: 0,
      bottom: 85,
      width: chatWidth,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: _buildChatOverlay(),
        ),
      ),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 1 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isSmallScreen ? 1.3 : 1.2,
      ),
      itemCount: allParticipants.length,
      itemBuilder: (context, index) {
        final p = allParticipants[index];
        final isHost = p['isMentor'] == true;
        final isLocal = p['id'] == 'local';
        
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isHost ? Colors.amber.withOpacity(0.5) : Colors.white.withOpacity(0.05),
              width: isHost ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isHost ? Colors.amber.withOpacity(0.1) : Colors.black.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                RTCVideoView(
                  p['renderer'] as RTCVideoRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: isLocal,
                ),
                // Gradient Overlay for better legibility
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.0, 0.2, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
                // Name Tag with Role
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isHost) ...[
                              const Icon(Icons.verified, color: Colors.blueAccent, size: 16),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              p['name'] as String,
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 13, 
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Status Icons
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    children: [
                      if (isHost)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("MENTOR", style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900)),
                        ),
                      const SizedBox(width: 8),
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.black45,
                        child: Icon(Icons.mic, color: Colors.greenAccent, size: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image != null) {
      final auth = context.read<AuthProvider>();
      await _classroomService.sendImage(image, auth.userName);
    }
  }

  Widget _buildChatOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        border: Border(left: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_rounded, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 12),
                const Text(
                  "CLASSROOM CHAT", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2)
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: () => setState(() => _showChat = false),
                )
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['from'] == context.read<AuthProvider>().userName;
                final isImage = msg['type'] == 'image';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isMe) Text(msg['from']!, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 10)),
                          const SizedBox(width: 8),
                          const Text("Just now", style: TextStyle(color: Colors.white24, fontSize: 9)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (isImage)
                        Container(
                          constraints: const BoxConstraints(maxWidth: 250),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              base64Decode(msg['image']!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blueAccent : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 16),
                            ),
                          ),
                          child: Text(
                            msg['text']!, 
                            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3)
                          ),
                        ),
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
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white54, size: 22),
            onPressed: _pickImage,
          ),
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
      bottom: 24,
      left: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildControlBtn(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  active: !_isMuted,
                  activeColor: Colors.blueAccent,
                  onPressed: () {
                    setState(() => _isMuted = !_isMuted);
                    _classroomService.toggleAudio(!_isMuted);
                  },
                ),
                _buildControlBtn(
                  icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                  active: !_isCameraOff,
                  activeColor: Colors.blueAccent,
                  onPressed: () {
                    setState(() => _isCameraOff = !_isCameraOff);
                    _classroomService.toggleVideo(!_isCameraOff);
                  },
                ),
                _buildControlBtn(
                  icon: Icons.front_hand,
                  active: false,
                  onPressed: () {
                    final auth = context.read<AuthProvider>();
                    _classroomService.raiseHand(auth.userName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("You raised your hand! ✋"),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.blueAccent,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.call_end, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text("LEAVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon, 
    required bool active, 
    required VoidCallback onPressed,
    Color? activeColor,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: active ? (activeColor ?? Colors.greenAccent) : Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon, 
          color: active ? Colors.white : Colors.white70, 
          size: 22
        ),
      ),
    );
  }
}


