import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/widgets/custom_app_bar.dart';
import 'package:graduway/data/models/roadmap_item.dart';

class RoadmapScreen extends ConsumerWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(careerGoalProvider);
    final roadmapAsync = ref.watch(roadmapDataProvider);

    final goals = [
      const _GoalOption('Flutter', '📱', AppColors.primary),
      const _GoalOption('Web Dev', '🌐', AppColors.secondary),
      const _GoalOption('AWS Cloud', '☁️', Color(0xFFFF9900)),
      const _GoalOption('ServiceNow', '🔧', Color(0xFF81B5A1)),
      const _GoalOption('FAANG', '🧠', AppColors.error),
      const _GoalOption('Data Science', '📊', AppColors.accent),
      const _GoalOption('Cybersecurity', '🔒', Color(0xFF6C5CE7)),
      const _GoalOption('Service Sector', '🏢', AppColors.textSecondary),
    ];

    final effectiveGoal = goal.isEmpty ? null : goal;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Career Roadmap'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Your Path',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textMuted)),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: goals.map((g) {
                  final sel = goal == g.label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (!sel) {
                          ref.read(careerGoalProvider.notifier).state = g.label;
                          ref.read(studentProgressProvider.notifier).setTargetCareer(g.label);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? g.color : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                              color: sel ? g.color : AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(g.emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(g.label,
                                style: TextStyle(
                                  color: sel
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            if (effectiveGoal == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    Text('🗺️', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 16),
                    Text('Select a career path above',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    SizedBox(height: 6),
                    Text(
                        'Your personalized roadmap will appear here, curated by Aditya alumni who have walked this path.',
                        style:
                            TextStyle(color: AppColors.textMuted, fontSize: 13),
                        textAlign: TextAlign.center),
                  ],
                ),
              ).animate().fadeIn()
            else
              roadmapAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(child: Text('No data found for this path.'));
                  }
                  
                  final completedSteps = items.where((i) => i.isComplete).length;
                  final totalSteps = items.length;
                  final overallPct = totalSteps > 0 ? (completedSteps / totalSteps) : 0.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            const Text('⚡', style: TextStyle(fontSize: 32)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$effectiveGoal Progress',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text(
                                      '$completedSteps of $totalSteps milestones completed',
                                      style: const TextStyle(
                                          fontSize: 12, color: AppColors.textMuted)),
                                  const SizedBox(height: 10),
                                  LinearPercentIndicator(
                                    lineHeight: 8,
                                    percent: overallPct,
                                    backgroundColor: AppColors.border,
                                    progressColor: AppColors.primary,
                                    barRadius: const Radius.circular(4),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('${(overallPct * 100).toInt()}%',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                    fontSize: 18)),
                          ],
                        ),
                      ).animate().fadeIn().slideY(begin: 0.1),
                      const SizedBox(height: 28),
                      const Text('Milestone Roadmap',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(
                          '${items.length} steps • Curated by alumni experts',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(height: 20),
                      ...List.generate(items.length, (i) {
                        final item = items[i];
                        final isLast = i == items.length - 1;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: item.isComplete
                                          ? AppColors.success
                                          : AppColors.bgCard,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: item.isComplete
                                            ? AppColors.success
                                            : AppColors.border,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                        child: Text(item.emoji,
                                            style: const TextStyle(fontSize: 20))),
                                  ),
                                  if (!isLast)
                                    Container(
                                        width: 2,
                                        height: 80,
                                        color: AppColors.border.withOpacity(0.5)),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 28),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgCard,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Text(item.title,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 14))),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                  color: AppColors.bgPage,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Text(item.duration,
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: AppColors.textMuted,
                                                      fontWeight: FontWeight.w600)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(item.description,
                                            style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                                height: 1.5)),
                                        if (item.resources.isNotEmpty) ...[
                                          const SizedBox(height: 10),
                                          const Divider(height: 1),
                                          const SizedBox(height: 10),
                                          const Text('📚 Resources',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textMuted)),
                                          const SizedBox(height: 6),
                                          ...item.resources.map((r) => Padding(
                                                padding:
                                                    const EdgeInsets.only(bottom: 2),
                                                child: Row(
                                                  children: [
                                                    const Text('• ',
                                                        style: TextStyle(
                                                            color: AppColors.primary)),
                                                    Expanded(
                                                        child: Text(r,
                                                            style: const TextStyle(
                                                                fontSize: 11,
                                                                color: AppColors
                                                                    .primary))),
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .fadeIn(delay: Duration(milliseconds: i * 120))
                              .slideX(begin: 0.1),
                        );
                      }),
                    ],
                  );
                },
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: CircularProgressIndicator(),
                )),
                error: (err, _) => Center(child: Text('Error loading roadmap: $err')),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _GoalOption {
  final String label, emoji;
  final Color color;
  const _GoalOption(this.label, this.emoji, this.color);
}
