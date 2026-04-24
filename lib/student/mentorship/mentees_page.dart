import 'package:graduway/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduway/alumni/shared/providers/mentorship_provider.dart';
import 'package:graduway/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:graduway/alumni/shared/models/mentorship_model.dart';

class MenteesPage extends StatefulWidget {
  final bool initialShowActive;
  const MenteesPage({super.key, this.initialShowActive = true});

  @override
  State<MenteesPage> createState() => _MenteesPageState();
}

class _MenteesPageState extends State<MenteesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialShowActive ? 0 : 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Your Mentees"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: "Active Connects"),
            Tab(text: "Alumni Network"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMenteesList(isActive: true),
          _buildMenteesList(isActive: false),
        ],
      ),
    );
  }

  Widget _buildMenteesList({required bool isActive}) {
    return Consumer<MentorshipProvider>(
      builder: (context, provider, child) {
        final mentees = isActive
            ? provider.acceptedMentees
            : provider.allRequests
                .where((r) => r.status == MentorshipStatus.ended)
                .toList();

        if (mentees.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                    isActive
                        ? Icons.people_outline_rounded
                        : Icons.history_rounded,
                    size: 80,
                    color: AppColors.textLight.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(isActive ? "No active mentees" : "No mentorship history",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                Text(
                    isActive
                        ? "Accept a request to start mentoring!"
                        : "Your past mentorships will appear here.",
                    style:
                        const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          itemCount: mentees.length,
          itemBuilder: (context, index) {
            final request = mentees[index];
            final student = request.student;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        student.name[0].toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.name,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                          Text("${student.branch} • ${student.year}",
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            children: student.skills
                                .take(2)
                                .map((s) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent
                                            .withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(s,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.accent,
                                              fontWeight: FontWeight.w600)),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                            color: AppColors.primary),
                        onPressed: () {
                          // In a real app, this would navigate to the chat session
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Connecting to secure chat session...")));
                        },
                      ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
          },
        );
      },
    );
  }
}

