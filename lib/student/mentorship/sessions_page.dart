import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/widgets/interactive_classroom_page.dart';
import 'package:graduway/student/mentorship/broadcast_streaming_page.dart' as student_broadcast;
import 'package:graduway/alumni/mentorship/broadcast_streaming_page.dart' as alumni_broadcast;
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduway/alumni/shared/providers/mentorship_provider.dart';
import 'package:graduway/models/user_role.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _joinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update FAB
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _joinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text("Sessions & live streams"),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            isScrollable: true,
            tabs: const [
              Tab(text: "1-on-1 Mentorship"),
              Tab(text: "Interactive Classes"),
              Tab(text: "Live Broadcasts"),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMentorshipTab(context),
              _buildInteractiveTab(context),
              _buildBroadcastsTab(context),
            ],
          ),
        ),
        floatingActionButton: _buildFAB(context),
      ),
    );
  }

  Widget? _buildFAB(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final isStudent = auth.role == UserRole.student;
    
    String label;
    IconData icon;
    VoidCallback onPressed;

    switch (_tabController.index) {
      case 0: // Mentorship
        label = isStudent ? "Request Session" : "Schedule Session";
        icon = Icons.calendar_today_rounded;
        onPressed = () => _showScheduleMentorshipDialog(context);
        break;
      case 1: // Interactive
        label = isStudent ? "Join Interactive" : "Create Interactive";
        icon = isStudent ? Icons.group_add_rounded : Icons.add_to_photos_rounded;
        onPressed = () => isStudent ? _showJoinClassDialog(context, isInteractive: true) : _showCreateClassDialog(context, isInteractive: true);
        break;
      case 2: // Broadcast
        label = isStudent ? "Join Broadcast" : "Start Live Stream";
        icon = isStudent ? Icons.live_tv_rounded : Icons.videocam_rounded;
        onPressed = () => isStudent ? _showJoinClassDialog(context, isInteractive: false) : _showCreateClassDialog(context, isInteractive: false);
        break;
      default:
        return null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: AppColors.primary,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }

  void _showScheduleMentorshipDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Scheduling feature coming soon!")),
    );
  }

  void _showJoinClassDialog(BuildContext context, {required bool isInteractive}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isInteractive ? "Join Interactive Class" : "Join Live Broadcast"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: isInteractive ? "Enter Room ID" : "Enter Stream ID",
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final id = controller.text.trim();
              if (id.isNotEmpty) {
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => isInteractive 
                      ? InteractiveClassroomPage(roomId: id.toLowerCase().replaceAll(' ', '-'))
                      : student_broadcast.BroadcastStreamingPage(streamId: id.toLowerCase().replaceAll(' ', '-')),
                  ),
                );
              }
            },
            child: const Text("Join Now"),
          ),
        ],
      ),
    );
  }

  void _showCreateClassDialog(BuildContext context, {required bool isInteractive}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isInteractive ? "Create Interactive Class" : "Start Live Broadcast"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: isInteractive ? "Enter Class Title" : "Enter Stream Title",
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                final provider = context.read<MentorshipProvider>();
                final idPrefix = isInteractive ? 'int-' : 'brd-';
                final streamId = '$idPrefix${title.toLowerCase().replaceAll(' ', '-')}';
                final success = await provider.startNewWebinar(title, streamId: streamId);
                if (!mounted) return;
                
                if (success) {
                  Navigator.pop(context);
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => isInteractive
                        ? InteractiveClassroomPage(roomId: streamId)
                        : alumni_broadcast.BroadcastStreamingPage(streamId: streamId),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to create session. Is the server running?")),
                  );
                }
              }
            },
            child: Text(isInteractive ? "Start Class" : "Go Live"),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorshipTab(BuildContext context) {
    return Consumer<MentorshipProvider>(
      builder: (context, provider, child) {
        final activeSessions = provider.acceptedMentees;
        if (activeSessions.isEmpty) return _buildEmptyState("No mentorship sessions planned.");

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: activeSessions.length,
          itemBuilder: (context, index) {
            final request = activeSessions[index];
            return _buildSessionCard(
              title: request.student.name,
              subtitle: "Weekly 1-on-1 Catchup",
              time: "Today, 4:00 PM",
              duration: "45 mins",
              isLive: false,
              index: index,
              onJoin: () {
                // Join 1-on-1 Mentorship session
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => InteractiveClassroomPage(
                      roomId: "mentorship-${request.id}",
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInteractiveTab(BuildContext context) {
    return Consumer<MentorshipProvider>(
      builder: (context, provider, child) {
        final webinars = provider.webinars.where((w) => !w['id'].toString().startsWith('brd-')).toList();
        final auth = context.read<AuthProvider>();
        final isStudent = auth.role == UserRole.student;

        return Column(
          children: [
            if (isStudent) _buildJoinRoomSection(context, isInteractive: true),
            Expanded(
              child: webinars.isEmpty 
                ? _buildEmptyState("No interactive classes available.")
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: webinars.length,
                    itemBuilder: (context, index) {
                      final webinar = webinars[index];
                      return _buildSessionCard(
                        title: webinar['title'],
                        subtitle: "Many-to-Many Interactive Class",
                        time: webinar['startTime'],
                        duration: "${webinar['attendees']} attending",
                        isLive: webinar['isLive'],
                        index: index,
                        icon: Icons.groups_rounded,
                        onJoin: () => Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (context) => InteractiveClassroomPage(
                              roomId: webinar['id'],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBroadcastsTab(BuildContext context) {
    return Consumer<MentorshipProvider>(
      builder: (context, provider, child) {
        // For demo, we show same webinars but with different interaction logic
        final webinars = provider.webinars.where((w) => w['id'].toString().startsWith('brd-')).toList();
        final auth = context.read<AuthProvider>();
        final isStudent = auth.role == UserRole.student;

        return Column(
          children: [
            if (isStudent) _buildJoinRoomSection(context, isInteractive: false),
            Expanded(
              child: webinars.isEmpty 
                ? _buildEmptyState("No live broadcasts at the moment.")
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: webinars.length,
                    itemBuilder: (context, index) {
                      final webinar = webinars[index];
                      return _buildSessionCard(
                        title: webinar['title'],
                        subtitle: "One-Way Live Stream",
                        time: webinar['startTime'],
                        duration: "${webinar['attendees']} watching",
                        isLive: webinar['isLive'],
                        index: index,
                        icon: Icons.podcasts_rounded,
                        onJoin: () => Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (context) => student_broadcast.BroadcastStreamingPage(
                              streamId: webinar['id'],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJoinRoomSection(BuildContext context, {required bool isInteractive}) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Join",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            "Enter a room name or ID to join a live session directly.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _joinController,
                    decoration: const InputDecoration(
                      hintText: "Enter room name...",
                      hintStyle: TextStyle(fontSize: 14, color: AppColors.textLight),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final roomId = _joinController.text.trim();
                    if (roomId.isNotEmpty) {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => isInteractive
                              ? InteractiveClassroomPage(
                                  roomId: roomId.toLowerCase().replaceAll(' ', '-'),
                                )
                              : student_broadcast.BroadcastStreamingPage(
                                  streamId: roomId.toLowerCase().replaceAll(' ', '-'),
                                ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Join"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard({
    required String title,
    required String subtitle,
    required String time,
    required String duration,
    required bool isLive,
    required int index,
    required VoidCallback onJoin,
    IconData icon = Icons.video_camera_front_rounded,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: isLive ? Border.all(color: AppColors.primary, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isLive ? Colors.red : AppColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: isLive ? Colors.red : AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("LIVE", style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInfoRow(Icons.calendar_today_rounded, time),
                    const SizedBox(width: 12),
                    _buildInfoRow(Icons.timer_outlined, duration),
                  ],
                ),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final isMentor = auth.role != UserRole.student;
                    return ElevatedButton(
                      onPressed: () {
                        if (isLive) {
                          onJoin();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Details coming soon")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLive ? (isMentor ? Colors.green : AppColors.primary) : null,
                      ),
                      child: Text(isLive ? (isMentor ? "Enter Room" : "Join Now") : "Details"),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textLight),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_rounded, size: 64, color: AppColors.textLight.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}





