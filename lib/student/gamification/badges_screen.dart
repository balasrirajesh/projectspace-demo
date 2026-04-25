import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/providers/app_providers.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(studentProgressProvider);
    final careerScore = progress.careerScore;
    final earnedIds = progress.earnedBadgeIds;

    // Listen for new badge notifications and show them
    ref.listen<StudentProgressState>(studentProgressProvider, (prev, next) {
      final prevNotifs = prev?.pendingNotifications ?? [];
      for (final notif in next.pendingNotifications) {
        if (!prevNotifs.any((n) => n.badgeId == notif.badgeId)) {
          _showBadgeNotification(context, ref, notif.title, notif.emoji, notif.badgeId);
        }
      }
    });

    final String motivationText;
    final String hintText;
    if (careerScore == 0) {
      motivationText = '🌱 Just Getting Started!';
      hintText = 'Ask a question or view an alumni profile to earn your first badge and points.';
    } else if (careerScore < 25) {
      motivationText = '🚀 Building Momentum!';
      hintText = 'Keep engaging — attend events, ask more questions!';
    } else if (careerScore < 50) {
      motivationText = '⭐ Great Progress!';
      hintText = 'You\'re halfway to Placement Ready. Keep going!';
    } else if (careerScore < 80) {
      motivationText = '🔥 Almost There!';
      hintText = 'Senior alumni recruiters notice students with high scores.';
    } else {
      motivationText = '🏆 Placement Ready!';
      hintText = 'Excellent! You\'re among the top engaged students.';
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Your Progress 🏆', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                const Text('Career readiness score & badge collection', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ],
                            ).animate().fadeIn(duration: 400.ms),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Career score hero
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 12))],
                        ),
                        child: Column(
                          children: [
                            CircularPercentIndicator(
                              radius: 70,
                              lineWidth: 10,
                              percent: (careerScore / 100).clamp(0.0, 1.0),
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('$careerScore', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                                  const Text('/100', style: TextStyle(fontSize: 12, color: Colors.white70)),
                                ],
                              ),
                              progressColor: Colors.white,
                              backgroundColor: Colors.white24,
                              circularStrokeCap: CircularStrokeCap.round,
                              animation: true,
                              animationDuration: 1500,
                            ),
                            const SizedBox(height: 16),
                            const Text('Career Ready Score', style: TextStyle(fontSize: 14, color: Colors.white70, letterSpacing: 0.5)),
                            const SizedBox(height: 6),
                            Text(motivationText, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(hintText, style: const TextStyle(fontSize: 11, color: Colors.white70), textAlign: TextAlign.center),
                          ],
                        ),
                      ).animate().fadeIn(delay: 150.ms, duration: 600.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), delay: 150.ms),

                      const SizedBox(height: 28),

                      // Progress breakdown — real data
                      Row(
                        children: [
                          _ProgressStat(label: 'Questions Asked', value: '${progress.questionsAsked}', max: '10', progress: (progress.questionsAsked / 10).clamp(0.0, 1.0), color: AppColors.primary),
                          const SizedBox(width: 12),
                          _ProgressStat(label: 'Events Attended', value: '${progress.eventsAttended}', max: '5', progress: (progress.eventsAttended / 5).clamp(0.0, 1.0), color: AppColors.secondary),
                          const SizedBox(width: 12),
                          _ProgressStat(label: 'Alumni Viewed', value: '${progress.alumniProfilesViewed}', max: '5', progress: (progress.alumniProfilesViewed / 5).clamp(0.0, 1.0), color: AppColors.accent),
                        ],
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 28),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text('Your Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ).animate().fadeIn(delay: 350.ms),
                      const SizedBox(height: 16),

                      ref.watch(badgesProvider).when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                        data: (badges) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                earnedIds.isEmpty
                                    ? 'No badges yet — start engaging to unlock!'
                                    : '${earnedIds.length}/${badges.length} earned',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ).animate().fadeIn(delay: 400.ms),
                              const SizedBox(height: 16),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.1,
                                ),
                                itemCount: badges.length,
                                itemBuilder: (context, i) {
                                  final badge = badges[i];
                                  final id = badge['id'] ?? '';
                                  final icon = badge['icon'] ?? '🏅';
                                  final title = badge['title'] ?? 'Badge';
                                  final description = badge['description'] ?? '';
                                  final isEarned = earnedIds.contains(id);
                                  
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: isEarned ? AppColors.primaryGradient : null,
                                      color: isEarned ? null : AppColors.bgCard,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: isEarned ? Colors.transparent : AppColors.border),
                                      boxShadow: isEarned
                                          ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12)]
                                          : [],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            icon,
                                            style: const TextStyle(fontSize: 26),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            title,
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isEarned ? Colors.white : AppColors.textMuted),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            description,
                                            style: TextStyle(fontSize: 9, color: isEarned ? Colors.white70 : AppColors.textMuted),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (!isEarned) ...[
                                            const SizedBox(height: 3),
                                            const Icon(Icons.lock_rounded, size: 11, color: AppColors.textMuted),
                                          ],
                                        ],
                                      ),
                                    ),
                                  )
                                      .animate(delay: Duration(milliseconds: 450 + i * 60))
                                      .fadeIn(duration: 350.ms)
                                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), delay: Duration(milliseconds: 450 + i * 60), curve: Curves.elasticOut);
                                },
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBadgeNotification(BuildContext context, WidgetRef ref, String title, String emoji, String badgeId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Badge Unlocked! 🎉', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13)),
                  Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) ref.read(studentProgressProvider.notifier).clearNotification(badgeId);
    });
  }
}

class _ProgressStat extends StatelessWidget {
  final String label, value, max;
  final double progress;
  final Color color;
  const _ProgressStat({required this.label, required this.value, required this.max, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text('$value/$max', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(value: progress, backgroundColor: color.withOpacity(0.2), valueColor: AlwaysStoppedAnimation(color), minHeight: 3),
            ),
          ],
        ),
      ),
    );
  }
}
