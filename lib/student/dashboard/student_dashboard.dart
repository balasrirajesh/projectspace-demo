import 'package:graduway/widgets/interactive_classroom_page.dart';
import 'package:graduway/student/mentorship/broadcast_streaming_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/alumni/shared/providers/mentorship_provider.dart' as legacy_mentorship;
import 'package:provider/provider.dart' as legacy_provider;
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/widgets/custom_app_bar.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  final TextEditingController _roomIdController = TextEditingController();

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  void _joinSession(String roomId) {
    if (roomId.isNotEmpty) {
      final clean = roomId.trim().toLowerCase().replaceAll(' ', '-');
      final formattedId = clean.startsWith('int-') || clean.startsWith('brd-') || clean.startsWith('mentorship-')
          ? clean
          : 'int-$clean';
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => formattedId.startsWith('brd-')
              ? BroadcastStreamingPage(streamId: formattedId)
              : InteractiveClassroomPage(roomId: formattedId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid Room ID")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final student = authState.student;
    final displayName = authState.loginName.isNotEmpty 
        ? authState.loginName 
        : (student?.name ?? 'Student');

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: CustomAppBar(
        title: 'Student Dashboard',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(student?.photoUrl ?? 'https://i.pravatar.cc/150'),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $displayName! ✨',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ).animate().fadeIn().slideX(begin: -0.1),
                  const SizedBox(height: 4),
                  const Text(
                    'Ready to accelerate your career today?',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
            ),

            // Live Session Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.sensors_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text('Join Live Lab', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter the unique Room ID provided for your interactive session.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _roomIdController,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          hintText: "e.g. system-design-101",
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _joinSession(_roomIdController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('Connect to Classroom', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 32),

            // Active Webinars
            legacy_provider.Consumer<legacy_mentorship.MentorshipProvider>(
              builder: (context, provider, _) {
                final sessions = provider.webinars;
                if (sessions.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Live Classes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      ...sessions.map((s) => _buildLiveRoomCard(context, s)),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),

            // Mentor List (Static Data)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text('Top Mentors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 16),
            ref.watch(alumniListProvider).when(
              data: (mentors) => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: mentors.length > 8 ? 8 : mentors.length,
                itemBuilder: (context, i) {
                  final m = mentors[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(m.photoUrl.isNotEmpty ? m.photoUrl : 'https://i.pravatar.cc/150?u=$i'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              Text('${m.role} @ ${m.company}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Online', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 10)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 300 + (i * 50)));
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showJoinClassDialog(context),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.cast_connected_rounded, color: Colors.white),
        label: const Text('Join by ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ).animate().fadeIn(delay: 800.ms),
    );
  }

  Widget _buildLiveRoomCard(BuildContext context, Map<String, dynamic> room) {
    final title = room['title'] ?? 'Untitled Class';
    final attendees = room['attendees'] ?? 0;
    final roomId = room['id'] ?? title.toLowerCase().replaceAll(' ', '-');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: AppColors.error.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.sensors_rounded, color: AppColors.error, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text('$attendees participating now', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final isBroadcast = roomId.toString().startsWith('brd-');
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => isBroadcast 
                    ? BroadcastStreamingPage(streamId: roomId)
                    : InteractiveClassroomPage(roomId: roomId),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('JOIN'),
          ),
        ],
      ),
    );
  }

  void _showJoinClassDialog(BuildContext context) {
    final TextEditingController dialogController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Join Session"),
        content: TextField(
          controller: dialogController,
          decoration: const InputDecoration(hintText: "Enter room ID", border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _joinSession(dialogController.text);
            },
            child: const Text("Join Now"),
          ),
        ],
      ),
    );
  }
}

