// webrtc one-to-many live video broadcasting with interactive features
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/alumni/shared/providers/notification_provider.dart';
import 'package:graduway/shared/services/classroom_service.dart';
import 'package:graduway/theme/app_colors.dart';
import 'dart:async';

class BroadcastStreamingPage extends StatefulWidget {
  final String streamId;

  const BroadcastStreamingPage({
    super.key,
    required this.streamId,
  });

  @override
  State<BroadcastStreamingPage> createState() => _BroadcastStreamingPageState();
}

class _BroadcastStreamingPageState extends State<BroadcastStreamingPage>
    with TickerProviderStateMixin {
  final ClassroomService _classroomService = ClassroomService();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  int _heartCount = 0;
  final List<Widget> _floatingHearts = [];
  final List<Map<String, String>> _comments = [];
  final TextEditingController _commentController = TextEditingController();

  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isMuted = false;
  bool _isCameraOff = false;
  String? _errorMessage;
  bool _isConnecting = true;
  String _hostName = "Loading...";

  @override
  void initState() {
    super.initState();
    _initWebRTC();
    _startTimer();
  }

  void _setupListeners() {
    _classroomService.onRemoteStreamAdded = (id, stream) {
      if (mounted) {
        setState(() {
          _remoteRenderer.srcObject = stream;
        });
      }
    };

    _classroomService.onMentorJoined = (id, name, {role}) {
      if (mounted) {
        setState(() {
          _hostName = name;
        });
      }
    };
    _classroomService.onChatMessage = (from, text) {
      if (mounted) {
        setState(() {
          _comments.add({'user': from, 'text': text});
        });
      }
    };

    _classroomService.onError = (message) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _errorMessage = message;
        });
      }
    };
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  Future<void> _initWebRTC() async {
    setState(() {
      _errorMessage = null;
      _isConnecting = true;
    });

    try {
      await _remoteRenderer.initialize();
      final auth = context.read<AuthProvider>();

      _setupListeners();

      await _classroomService
          .joinRoom(
        serverUrl: AuthProvider.getSignalingUrl(),
        roomId: widget.streamId,
        userName: auth.userName,
        role: ClassroomRole.student,
        useMedia: false, // Watcher doesn't share video/audio
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw 'SIGNALING_TIMEOUT';
      });

      if (mounted) {
        setState(() {
          _isConnecting = false;
        });

        if (!mounted) return;
        // Add a notification for the live stream
        context.read<NotificationProvider>().addNotification({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': 'Watching Live!',
          'body': 'You are now watching the live session: ${widget.streamId}',
          'time': 'Just now',
          'isRead': false,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          if (e == 'CAMERA_PERMISSION_DENIED') {
            _errorMessage =
                "Failed to start classroom: Unable to getUserMedia: NotAllowedError: Permission denied";
          } else if (e == 'SIGNALING_TIMEOUT' ||
              e.toString().contains('signaling')) {
            _errorMessage =
                "Signaling server unreachable at ${AuthProvider.getSignalingUrl()}";
          } else {
            _errorMessage = "An unexpected error occurred: $e";
          }
        });
      }
    }
  }

  @override
  void dispose() {
    // CRITICAL: Stop tracks synchronously so camera/mic releases immediately.
    _remoteRenderer.srcObject = null;
    _classroomService.stopLocalStream();
    _timer?.cancel();
    // Async teardown
    _cleanup();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _cleanup() async {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    // Null out srcObject BEFORE disposing the renderer.
    // This releases the browser's active hold on any media streams,
    // ensuring the camera indicator turns off when the student leaves.
    _remoteRenderer.srcObject = null;

    _classroomService.dispose();
    await _remoteRenderer.dispose();
  }

  void _addHeart() {
    setState(() {
      _heartCount++;
      _floatingHearts.add(_FloatingHeart(
        key: UniqueKey(),
        onComplete: (key) {
          if (mounted) {
            setState(() => _floatingHearts.removeWhere((h) => h.key == key));
          }
        },
      ));
    });
  }

  void _postComment() {
    if (_commentController.text.isNotEmpty) {
      final auth = context.read<AuthProvider>();
      _classroomService.sendMessage(_commentController.text, auth.userName);
      setState(() {
        _comments.add({
          'user': auth.userName,
          'text': _commentController.text,
        });
        _commentController.clear();
      });
    }
  }

  void _toggleMute() {
    // Watcher cannot share media
  }

  void _toggleCamera() {
    // Watcher cannot share media
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✋ Please use the 'EXIT' button to leave the stream."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Full-screen Video Layer
          _buildVideoLayer(),

          // 2. Gradient Overlays for readability
          _buildGradientOverlay(),

          // 3. Top Header Section
          _buildTopHeader(),

          // 4. Right-side Controls Sidebar
          _buildSideControls(),

          // 5. Interaction Layer (Comments & Input)
          _buildInteractionLayer(),

          // 6. Floating Hearts Animation Layer
          ..._floatingHearts,

          // 7. Loading/Error Overlay
          if (_isConnecting) _buildLoadingOverlay(),

          if (_errorMessage != null) _buildErrorOverlay(),
        ],
      ),
    ),
  );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text("Establishing secure connection...",
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: Color(0xFFF44336), // Matching the red in screenshot
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Action Required",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.white70, size: 20),
                    onPressed: () => setState(() => _errorMessage = null),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_errorMessage!.contains("Permission denied"))
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            () {}, // For web, might need to show instruction dialog
                        icon: const Icon(Icons.settings, color: Colors.white),
                        label: const Text("How to allow",
                            style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54)),
                      ),
                    ),
                  if (_errorMessage!.contains("Signaling server unreachable"))
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _initWebRTC,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry Connection"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFF44336),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Go Back",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoLayer() {
    return Container(
      color: Colors.black,
      child: _remoteRenderer.srcObject != null
          ? RTCVideoView(
              _remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_camera_back_outlined,
                      color: Colors.white24, size: 64),
                  SizedBox(height: 16),
                  Text("Waiting for streamer...",
                      style: TextStyle(color: Colors.white38)),
                ],
              ),
            ),
    );
  }

  Widget _buildGradientOverlay() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black54,
              Colors.transparent,
              Colors.transparent,
              Colors.black87,
            ],
            stops: const [0.0, 0.2, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Live Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text("LIVE",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
              // Exit Button
              TextButton(
                 onPressed: () async {
                  await _cleanup();
                  if (mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    Navigator.pop(context);
                  }
                },
                child: const Text("Exit",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideControls() {
    return const SizedBox.shrink(); // Moved to bottom bar in Image 1
  }

  Widget _buildInteractionButton(IconData icon, String label,
      {required VoidCallback onPressed}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }

  Widget _buildInteractionLayer() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Comments Panel
            SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width * 0.7,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _comments.length,
                reverse: true, // Newest at bottom
                itemBuilder: (context, index) {
                  final comment = _comments[_comments.length - 1 - index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment['user']!,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                              Text(comment['text']!,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Bottom Bar
            Row(
              children: [
                // Comment Button
                GestureDetector(
                  onTap: () {
                    // Show comment input dialog or similar
                  },
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        const Text("Comment",
                            style: TextStyle(color: Colors.white, fontSize: 14)),
                        const SizedBox(width: 8),
                        const Icon(Icons.more_vert, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Icon Controls
                _buildBottomIcon(Icons.help_outline),
                _buildBottomIcon(Icons.send_outlined),
                _buildBottomIcon(Icons.sentiment_satisfied_alt_outlined),
                _buildBottomIcon(Icons.favorite_border, onTap: _addHeart),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

class _FloatingHeart extends StatefulWidget {
  final Function(Key?) onComplete;
  const _FloatingHeart({super.key, required this.onComplete});

  @override
  State<_FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<_FloatingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late Animation<double> _alignment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)));
    _scale = Tween<double>(begin: 0.5, end: 1.5).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _alignment = Tween<double>(begin: 0.0, end: -0.5)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) => widget.onComplete(widget.key));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          bottom: 150 + (250 * (1 - _opacity.value)), // Float higher
          right: 30 + (40 * _alignment.value), // Drifts horizontally
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child:
                  const Icon(Icons.favorite, color: Colors.redAccent, size: 28),
            ),
          ),
        );
      },
    );
  }
}
