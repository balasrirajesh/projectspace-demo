import 'package:graduway/student/mentorship/sessions_page.dart';
// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/widgets/custom_app_bar.dart';
import 'package:graduway/data/models/models.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/alumni/shared/providers/mentorship_provider.dart';
import 'package:graduway/alumni/mentorship/alumni_requests_page.dart';
import 'package:graduway/alumni/mentorship/broadcast_streaming_page.dart';
import 'package:graduway/alumni/mentorship/mentees_page.dart';
import 'package:graduway/alumni/notifications/notifications_page.dart' as rajesh_notif;

class AlumniHomeScreen extends ConsumerWidget {
  const AlumniHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final alumni = authState.alumni;
    final displayName = authState.loginName.isNotEmpty
        ? authState.loginName
        : (alumni?.name ?? 'Alumni');
    final unansweredCount = ref.watch(unansweredQAProvider).length;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Alumni Dashboard',
        showBackButton: false,
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundImage:
                  NetworkImage(alumni?.photoUrl ?? 'https://i.pravatar.cc/150'),
            ),
            onPressed: () => context.go('/alumni-profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,\n${displayName.split(' ').first}! 👋',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontSize: 24),
            ).animate().fadeIn().slideX(begin: -0.1),
            const SizedBox(height: 8),
            Text(
              '${alumni?.role ?? "SDE"} @ ${alumni?.company ?? "Aditya College"}',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 28),

            // Impact Stats
            const Text('Your Impact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Row(
              children: [
                _ImpactCard(
                    label: 'Mentees',
                    value: '${alumni?.menteeCount ?? 0}',
                    icon: Icons.people_outline,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                _ImpactCard(
                    label: 'Answers',
                    value: '42',
                    icon: Icons.question_answer_outlined,
                    color: AppColors.alumni),
                const SizedBox(width: 12),
                _ImpactCard(
                    label: 'Views',
                    value: '1.2k',
                    icon: Icons.remove_red_eye_outlined,
                    color: AppColors.secondary),
              ],
            )
                .animate()
                .fadeIn(delay: 400.ms)
                .scale(begin: const Offset(0.9, 0.9)),

            const SizedBox(height: 32),

            // Pending Questions Call to Action
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.alumniGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.alumni.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Help a Student!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                          'There are $unansweredCount pending questions in your expertise.',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(alumniNavIndexProvider.notifier).state =
                                1; // Go to Questions tab
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.alumni,
                            minimumSize: const Size(120, 40),
                          ),
                          child: const Text('View Questions'),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.psychology_outlined,
                      size: 80, color: Colors.white24),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

            const SizedBox(height: 32),

            const Text('Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _QuickActionTile(
              icon: Icons.edit_note_rounded,
              title: 'Post a Placement Tip',
              subtitle: 'Share your interview secrets',
              color: AppColors.admin,
              onTap: () => _showPostTipSheet(context),
            ),
            const SizedBox(height: 12),
            _QuickActionTile(
              icon: Icons.calendar_month_rounded,
              title: 'Host a Webinar',
              subtitle: 'Schedule a session with juniors',
              color: AppColors.alumni,
              onTap: () => _showHostWebinarSheet(context),
            ),

            const SizedBox(height: 32),

            // ── Rajesh: Mentor Console ─────────────────────────────────
            const Text('Mentor Console',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            legacy_provider.Consumer<MentorshipProvider>(
              builder: (context, mentorship, _) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MentorStatCard(
                          title: 'Mentees Guided',
                          value: '${mentorship.acceptedCount}',
                          icon: Icons.people_outline,
                          color: Colors.blue,
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const MenteesPage(initialShowActive: false))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MentorStatCard(
                          title: 'Sessions Held',
                          value: '45',
                          icon: Icons.event_available_outlined,
                          color: Colors.green,
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const SessionsPage())),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MentorStatCard(
                          title: 'Active Mentees',
                          value: '${mentorship.acceptedCount}',
                          icon: Icons.school_outlined,
                          color: Colors.orange,
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const MenteesPage())),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MentorStatCard(
                          title: 'Unresolved Queries',
                          value: '3',
                          icon: Icons.question_answer_outlined,
                          color: Colors.purple,
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const rajesh_notif.NotificationsPage())),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _MentorActionBtn(title: 'Requests', icon: Icons.pending_actions, color: Colors.teal, hasNotif: true,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlumniRequestsPage()))),
                  const SizedBox(width: 12),
                  _MentorActionBtn(
                    title: 'Start Stream',
                    icon: Icons.sensors,
                    color: Colors.redAccent,
                    onTap: () async {
                      final title = await _showStreamTitleDialog(context);
                      if (title != null && title.isNotEmpty) {
                        final mentorship = legacy_provider.Provider.of<MentorshipProvider>(context, listen: false);
                        final success = await mentorship.startNewWebinar(title);
                        if (success && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BroadcastStreamingPage(
                                streamId: title.toLowerCase().replaceAll(' ', '-'),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  _MentorActionBtn(title: 'My Mentees', icon: Icons.group, color: Colors.indigo,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MenteesPage()))),
                  const SizedBox(width: 12),
                  _MentorActionBtn(title: 'Sessions', icon: Icons.video_library_rounded, color: Colors.green,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionsPage()))),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showPostTipSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Post a Placement Tip',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Your experience will help juniors prepare better!',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const SizedBox(height: 20),
              TextField(
                controller: ctrl,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      'Share a tip, trick, or key insight from your placement journey...',
                  fillColor: AppColors.bgPage,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (ctrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('📌 Tip posted! Students will find it helpful.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.admin,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Post Tip',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }

  void _showHostWebinarSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime? selectedDate;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              0, 0, 0, MediaQuery.of(ctx2).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Host a Webinar',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx2)),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Webinar Title',
                    prefixIcon: const Icon(Icons.title_rounded),
                    fillColor: AppColors.bgPage,
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx2,
                      initialDate: DateTime.now().add(const Duration(days: 3)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null)
                      setModalState(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                        color: AppColors.bgPage,
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: AppColors.alumni, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate == null
                              ? 'Select Date'
                              : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          style: TextStyle(
                            color: selectedDate == null
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            fontWeight: selectedDate == null
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    prefixIcon: const Icon(Icons.notes_rounded),
                    fillColor: AppColors.bgPage,
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx2);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            '📅 Webinar scheduled! Students will be notified.'),
                        backgroundColor: AppColors.alumni,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.alumni,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Schedule Webinar',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 110),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _showStreamTitleDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start Live Stream'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Enter session title (e.g. Placement Prep)',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Go Live'),
          ),
        ],
      ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _ImpactCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}


class _MentorStatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MentorStatCard({required this.title, required this.value, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}


class _MentorActionBtn extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool hasNotif;
  const _MentorActionBtn({required this.title, required this.icon, required this.color, required this.onTap, this.hasNotif = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(children: [
              Icon(icon, color: color, size: 20),
              if (hasNotif) Positioned(right: 0, top: 0,
                child: Container(width: 7, height: 7,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
            ]),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

