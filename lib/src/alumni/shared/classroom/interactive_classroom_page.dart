// webrtc multi-participant interactive video session with engagement tools
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  bool _isSpeakerOn = true;
  bool _showChat = false;
  bool _isInitialized = false;
  bool _hasHost = false; 
  bool _isLocalHandRaised = false;
  final Set<String> _raisedHands = {};
  String _connectionState = "Connecting to classroom handshake...";

  final ScrollController _scrollController = ScrollController();
  
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
        final myName = context.read<AuthProvider>().userName;
        if (from == myName) return; // Avoid duplicate from echo
        
        setState(() {
          _messages.add({'from': from, 'text': message});
        });
        _scrollToBottom();
        
        // Show prominent popup notification for EVERY participant
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.chat_bubble, color: Colors.white, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      children: [
                        TextSpan(text: "$from: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: message),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.blueAccent.withOpacity(0.9),
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            action: SnackBarAction(
              label: "VIEW",
              textColor: Colors.white,
              onPressed: () => setState(() => _showChat = true),
            ),
          ),
        );
      }
    };

    _classroomService.onHandRaised = (from, isRaised) {
      if (mounted) {
        setState(() {
          if (isRaised) {
            _raisedHands.add(from);
          } else {
            _raisedHands.remove(from);
          }
        });

        if (isRaised) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$from raised their hand! ✋"),
              backgroundColor: Colors.blueAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            ),
          );
        }
      }
    };

    _classroomService.onMentorJoined = (mentorId, userName, {role}) {
      if (mounted) {
        final hostLabel = (role == 'admin') ? 'Faculty' : 'Alumnus';
        setState(() {
          _hasHost = true;
          _connectionState = "$hostLabel ($userName) Joined! Connecting...";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("👨‍🏫 $hostLabel $userName has joined the session!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    };

    final classroomRole = (auth.role == UserRole.mentor || auth.role == UserRole.admin)
        ? ClassroomRole.mentor
        : ClassroomRole.student;

    _classroomService.onConnected = () {
      if (mounted) {
        final hostLabel = (auth.role == UserRole.admin) ? "students" : "students"; // Host label context
        setState(() {
          _connectionState = classroomRole == ClassroomRole.mentor 
            ? "Live: Waiting for students..." 
            : "Connected: Waiting for host...";
        });
      }
    };

    _classroomService.onError = (message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ $message'),
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'LEAVE',
              textColor: Colors.white,
              onPressed: () {
                if (mounted) Navigator.pop(context);
              },
            ),
          ),
        );
        if (message.contains('multiple attempts')) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        }
      }
    };

    // --- Connection Watchdog ---
    final connectionWatchdog = Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _connectionState == "Connecting to classroom handshake...") {
        dev.log('⚠️ [CLASS] Handshake timed out after 15s');
        _classroomService.onError?.call('Connection timeout. Please check your network or server status.');
      }
    });

    await _classroomService.joinRoom(
      serverUrl: AuthProvider.getSignalingUrl(),
      roomId: widget.roomId,
      userName: auth.userName,
      role: classroomRole,
    );

    if (mounted) {
      context.read<NotificationProvider>().addNotification({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': 'You are Live!',
        'body': 'Your students can now join the session: ${widget.roomId}',
        'time': 'Just now',
        'isRead': false,
      });
    }

    if (mounted) {
      setState(() {
        if (_classroomService.localStream != null) {
          _localRenderer.srcObject = _classroomService.localStream;
        }
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cleanup();
    _chatController.dispose();
    _scrollController.dispose();
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
    if (_chatController.text.trim().isNotEmpty) {
      final auth = context.read<AuthProvider>();
      final text = _chatController.text.trim();
      
      setState(() {
        _messages.add({'from': auth.userName, 'text': text});
      });
      
      _classroomService.sendMessage(text, auth.userName);
      _chatController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Room: ${widget.roomId}", 
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: (_connectionState.contains("Live") || _connectionState.contains("Session") || _connectionState.contains("Connected")) ? Colors.green : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _connectionState.toUpperCase(), 
                          style: const TextStyle(
                            color: Colors.white70, 
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
            final auth = context.read<AuthProvider>();
            
            return Stack(
              children: [
                // 1. MAIN PRODUCTIVE AREA (Responsive Column)
                Column(
                  children: [
                    Expanded(
                      child: _buildVideoGrid(isSmallScreen),
                    ),
                    if (!_showChat) _buildControls(),
                  ],
                ),
                
                // 2. CHAT OVERLAY (Takes precedence when open)
                if (auth.role == UserRole.student && !_hasHost)
                  _buildWaitingRoomOverlay(),
                if (_showChat)
                  _buildResponsiveChat(constraints),
                
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildWaitingRoomOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_clock_rounded, color: Colors.amber, size: 80).animate().shake(delay: 500.ms),
                const SizedBox(height: 24),
                const Text(
                  "Waiting for Faculty",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "This educational session will begin as soon as a mentor or administrator arrives. Please stay on this screen.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(color: Colors.amber),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantCount() {
    final count = 1 + _remoteRenderers.length;
    return InkWell(
      onTap: _showAttendeesList,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
      ),
    );
  }

  void _showAttendeesList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final auth = context.read<AuthProvider>();
        final attendees = [
          {
            'name': auth.userName,
            'role': auth.role == UserRole.student ? 'Student' : (auth.role == UserRole.admin ? 'Faculty' : 'Alumnus'),
            'isMe': true
          },
          ..._remoteRenderers.entries.map((e) {
            final name = _classroomService.participants[e.key] ?? 'Participant';
            return {
              'name': name,
              'role': 'Member',
              'isMe': false
            };
          })
        ];

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "In the Classroom (${attendees.length})",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: attendees.length,
                  itemBuilder: (context, index) {
                    final p = attendees[index];
                    final isMe = p['isMe'] as bool;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isMe ? Colors.blueAccent : Colors.white10,
                        child: Text(
                          p['name'].toString().substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        isMe ? "${p['name']} (You)" : p['name'].toString(),
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: isMe ? FontWeight.bold : FontWeight.normal
                        ),
                      ),
                      subtitle: Text(
                        p['role'].toString(),
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      trailing: const Icon(Icons.circle, color: Colors.green, size: 8),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
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
        'name': isStudent 
            ? 'You (Student)' 
            : (auth.role == UserRole.admin ? 'You (Faculty Host)' : 'You (Alumni)'), 
        'role': auth.role.name,
        'isHost': !isStudent
      },
      ..._remoteRenderers.entries.map((e) {
        final meta = _classroomService.participants[e.key] ?? {};
        final role = meta['role'] ?? 'student';
        final name = meta['userName'] ?? 'Participant';
        final isRemoteHost = (role == 'mentor' || role == 'admin');
        
        return {
          'id': e.key, 
          'renderer': e.value, 
          'name': isRemoteHost 
              ? (role == 'admin' ? 'Faculty: $name' : 'Alumni: $name')
              : name, 
          'role': role,
          'isHost': isRemoteHost
        };
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
        final isHost = p['isHost'] == true;
        final isHandRaised = (p['id'] == 'local' && _isLocalHandRaised) || _raisedHands.contains(p['name']);
        
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
                if (_localRenderer.srcObject != null && p['renderer'] == _localRenderer)
                  RTCVideoView(
                    _localRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    mirror: true,
                  )
                else if (p['renderer'] != _localRenderer && (p['renderer'] as RTCVideoRenderer).srcObject != null)
                  RTCVideoView(
                    p['renderer'] as RTCVideoRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    mirror: false,
                  )
                else
                  Container(
                    color: Colors.black87,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.videocam_off, color: Colors.white24, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            p['name'] as String,
                            style: const TextStyle(color: Colors.white24, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    children: [
                      if (isHost)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: p['role'] == 'admin' ? Colors.blueAccent : Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p['role'] == 'admin' ? "FACULTY" : "ALUMNUS", 
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)
                          ),
                        ),
                      if (isHandRaised)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.front_hand, color: Colors.white, size: 14),
                        ).animate().shake(),
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
              controller: _scrollController,
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
                            color: isMe ? Colors.blueAccent : Colors.white.withOpacity(0.15),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white54, size: 22),
              onPressed: _pickImage,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _chatController,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(color: Colors.black45, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
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
                    
                    // Audio Output Selection Menu
                    PopupMenuButton<String>(
                      offset: const Offset(0, -180),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: const Color(0xFF1E1E1E),
                      icon: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isSpeakerOn ? Colors.amber : Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isSpeakerOn ? Icons.volume_up : Icons.volume_down, 
                          color: Colors.white, 
                          size: 20
                        ),
                      ),
                      onSelected: (String value) {
                        setState(() {
                          if (value == 'speaker') {
                            _isSpeakerOn = true;
                            _classroomService.setSpeakerphoneOn(true);
                          } else {
                            _isSpeakerOn = false;
                            _classroomService.setSpeakerphoneOn(false);
                          }
                        });
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'speaker',
                          child: Row(
                            children: [
                              Icon(Icons.volume_up, color: _isSpeakerOn ? Colors.amber : Colors.white70, size: 20),
                              const SizedBox(width: 12),
                              const Text('External Speaker', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'earpiece',
                          child: Row(
                            children: [
                              Icon(Icons.phone_in_talk, color: !_isSpeakerOn ? Colors.amber : Colors.white70, size: 20),
                              const SizedBox(width: 12),
                              const Text('Phone Earpiece', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'bluetooth',
                          child: Row(
                            children: [
                              const Icon(Icons.bluetooth, color: Colors.blueAccent, size: 20),
                              const SizedBox(width: 12),
                              const Text('Bluetooth Device', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
            
                    // Hand Raise Toggle
                    _buildControlBtn(
                      icon: Icons.front_hand,
                      active: _isLocalHandRaised,
                      activeColor: Colors.amber.shade700,
                      onPressed: () {
                        setState(() {
                          _isLocalHandRaised = !_isLocalHandRaised;
                          final auth = context.read<AuthProvider>();
                          _classroomService.raiseHand(auth.userName, _isLocalHandRaised);
                        });
                        
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isLocalHandRaised ? "You raised your hand! ✋" : "You lowered your hand."),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: _isLocalHandRaised ? Colors.blueAccent : Colors.grey[800],
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                            Icon(Icons.call_end, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text("LEAVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
