import 'package:alumini_screen/src/shared/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alumini_screen/src/shared/providers/mentorship_provider.dart';
import 'package:alumini_screen/src/core/theme/app_theme.dart';
import 'package:alumini_screen/src/features/mentorship/interactive_classroom_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

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
    if (auth.role == UserRole.student) return null;

    return FloatingActionButton.extended(
      onPressed: () => _showCreateClassDialog(context),
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text("Create Live Class", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        if (webinars.isEmpty) return _buildEmptyState("No live or upcoming webinars.");

        return ListView.builder(
          padding: const EdgeInsets.all(24),
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
        );
      },
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
