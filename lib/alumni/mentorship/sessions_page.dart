
import 'package:flutter/material.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/alumni/shared/providers/mentorship_provider.dart';
import 'package:graduway/models/user_role.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/widgets/interactive_classroom_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  final TextEditingController _joinController = TextEditingController();

  @override
  void dispose() {
    _joinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text("Sessions & Classes"),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: "1-on-1 Mentorship"),
              Tab(text: "Webinars & Classes"),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _buildMentorshipTab(context),
              _buildWebinarsTab(context),
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

    return FloatingActionButton.extended(
      onPressed: () => isStudent ? _showJoinClassDialog(context) : _showCreateClassDialog(context),
      backgroundColor: AppColors.primary,
      icon: Icon(isStudent ? Icons.login_rounded : Icons.add_rounded, color: Colors.white),
      label: Text(
        isStudent ? "Join Live Class" : "Create Live Class", 
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
      ),
    );
  }

  void _showJoinClassDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Join Live Class"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter Room Name (e.g. flutter-basics)",
            border: OutlineInputBorder(),
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
              final roomId = controller.text.trim();
              if (roomId.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InteractiveClassroomPage(
                      roomId: roomId.toLowerCase().replaceAll(' ', '-'),
                    ),
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

  void _showCreateClassDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Live Class"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter Class Title (e.g. Flutter Basics)",
            border: OutlineInputBorder(),
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
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                final provider = context.read<MentorshipProvider>();
                provider.startNewWebinar(title);
                Navigator.pop(context);
                
                // Navigate to the newly created room
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InteractiveClassroomPage(
                      roomId: title.toLowerCase().replaceAll(' ', '-'),
                    ),
                  ),
                );
              }
            },
            child: const Text("Start Class"),
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
            );
          },
        );
      },
    );
  }

  Widget _buildWebinarsTab(BuildContext context) {
    return Consumer<MentorshipProvider>(
      builder: (context, provider, child) {
        final webinars = provider.webinars;
        final auth = context.read<AuthProvider >();
        final isStudent = auth.role == UserRole.student;

        return Column(
          children: [
            if (isStudent) _buildJoinRoomSection(context),
            Expanded(
              child: webinars.isEmpty 
                ? _buildEmptyState("No live or upcoming webinars.")
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: webinars.length,
                    itemBuilder: (context, index) {
                      final webinar = webinars[index];
                      return _buildSessionCard(
                        title: webinar['title'],
                        subtitle: "Live Stream Class",
                        time: webinar['startTime'],
                        duration: "${webinar['attendees']} attending",
                        isLive: webinar['isLive'],
                        index: index,
                        icon: Icons.cast_for_education_rounded,
                      );
                    },
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJoinRoomSection(BuildContext context) {
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
                      hintStyle: TextStyle(fontSize: 14, color: AppColors.bgCardAlt),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InteractiveClassroomPage(
                            roomId: roomId.toLowerCase().replaceAll(' ', '-'),
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
                          Navigator.push(
                            context ,
                            MaterialPageRoute(
                              builder: (context) => InteractiveClassroomPage(
                                roomId: title.toLowerCase().replaceAll(' ', '-'),
                              ),
                            ),
                          );
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


