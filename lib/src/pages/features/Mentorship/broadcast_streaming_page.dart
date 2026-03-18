import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import 'package:alumini_screen/src/providers/notification_provider.dart';
import '../../../services/broadcast_service.dart';

class BroadcastStreamingPage extends StatefulWidget {
  final bool isMentor;
  final String streamId;

  const BroadcastStreamingPage({
    super.key, 
    required this.isMentor, 
    required this.streamId,
  });

  @override
  State<BroadcastStreamingPage> createState() => _BroadcastStreamingPageState();
}

class _BroadcastStreamingPageState extends State<BroadcastStreamingPage> with TickerProviderStateMixin {
  final BroadcastService _broadcastService = BroadcastService();
  ChewieController? _chewieController;
  int _heartCount = 0;
  final List<Widget> _floatingHearts = [];
  final List<String> _comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  Future<void> _initStream() async {
    if (!widget.isMentor) {
      // Students watch HLS stream
      // NodeMediaServer default HLS path: http://ip:8000/live/STREAM_NAME/index.m3u8
      final String hlsUrl = 'http://localhost:8000/live/${widget.streamId}/index.m3u8';
      await _broadcastService.initPlayback(hlsUrl);
      
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _broadcastService.hlsController!,
          isLive: true,
          autoPlay: true,
          showControls: false,
        );
      });
    } else {
      // Mentor starts RTMP stream
      final String rtmpUrl = 'rtmp://localhost/live/${widget.streamId}';
      await _broadcastService.startStreaming(rtmpUrl);
    }

    // Add a notification for the live stream
    if (mounted) {
      context.read<NotificationProvider>().addNotification({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': widget.isMentor ? 'Streaming Live!' : 'Watching Live',
        'body': widget.isMentor 
            ? 'Your followers have been notified that you are live.' 
            : 'You are now watching the live stream: ${widget.streamId}',
        'time': 'Just now',
        'isRead': false,
      });
    }
  }

  @override
  void dispose() {
    _broadcastService.dispose();
    _chewieController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _addHeart() {
    setState(() {
      _heartCount++;
      _floatingHearts.add(_FloatingHeart(
        key: UniqueKey(),
        onComplete: (key) {
          setState(() => _floatingHearts.removeWhere((h) => h.key == key));
        },
      ));
    });
    // In real app, emit 'send-heart' via socket
  }

  void _postComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _comments.add(_commentController.text);
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Layer (HLS Player for Students, Camera Preview for Mentor)
          _buildVideoLayer(),

          // Gradient Overlay (Instagram style)
          _buildGradientOverlay(),

          // Top Info (Live Badge, Viewer Count)
          _buildTopHeader(),

          // Bottom Interaction (Comments & Hearts)
          _buildBottomUI(),

          // Floating Hearts Layer
          ..._floatingHearts,
        ],
      ),
    );
  }

  Widget _buildVideoLayer() {
    if (widget.isMentor) {
      // Mentor sees their own camera (simulated here with a placeholder)
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text("Broadcasting Live...", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    } else {
      // Students see HLS player
      return _chewieController != null
          ? Chewie(controller: _chewieController!)
          : const Center(child: CircularProgressIndicator(color: Colors.red));
    }
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
      top: 50,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text("LIVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.visibility, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text("1.2k", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomUI() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Comments List
            SizedBox(
              height: 150,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(text: "User: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                          TextSpan(text: _comments[index], style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Comment Input & Heart
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _postComment(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _addHeart,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 36),
                      if (_heartCount > 0)
                        Positioned(
                          top: -10,
                          child: Text("+$_heartCount", style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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

class _FloatingHeartState extends State<_FloatingHeart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late Animation<double> _alignment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)));
    _scale = Tween<double>(begin: 0.5, end: 1.5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _alignment = Tween<double>(begin: 0.0, end: -0.5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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
          bottom: 100 + (150 * (1 - _opacity.value)), // Float upwards
          right: 30 + (20 * _alignment.value), // Slight horizontal drift
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: const Icon(Icons.favorite, color: Colors.red, size: 24),
            ),
          ),
        );
      },
    );
  }
}
