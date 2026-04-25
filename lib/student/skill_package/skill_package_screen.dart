import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduway/providers/app_providers.dart';

class SkillPackageScreen extends ConsumerStatefulWidget {
  const SkillPackageScreen({super.key});

  @override
  ConsumerState<SkillPackageScreen> createState() => _SkillPackageScreenState();
}

class _SkillPackageScreenState extends ConsumerState<SkillPackageScreen> {
  String _selectedBranch = 'CSE';

  @override
  Widget build(BuildContext context) {
    final skillDataAsync = ref.watch(skillPackageProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Skill → Package Map 💰',
        showBackButton: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: skillDataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
            data: (allData) {
              final data = (allData[_selectedBranch] ?? allData['CSE'] ?? []) as List<dynamic>;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Only Aditya College placement data. 100% real.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))
                              .animate().fadeIn(delay: 100.ms),
                          const SizedBox(height: 20),

                          // Branch selector
                          Row(
                            children: ['CSE', 'ECE', 'MECH'].map((b) {
                              final sel = _selectedBranch == b;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedBranch = b),
                                  child: AnimatedContainer(
                                    duration: 200.ms,
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: sel ? AppColors.primaryGradient : null,
                                      color: sel ? null : AppColors.bgCard,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: sel ? Colors.transparent : AppColors.border),
                                    ),
                                    child: Text(b, style: TextStyle(fontSize: 13, color: sel ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              );
                            }).toList(),
                          ).animate().fadeIn(delay: 200.ms),

                          const SizedBox(height: 28),

                          // Bar chart
                          const Text('Package Range by Skill Set', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          const Text('Min–Max package range (LPA) from Aditya alumni data', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 16),

                          Container(
                            height: 220,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: data.isEmpty ? const Center(child: Text('No data for this branch')) : BarChart(
                              BarChartData(
                                maxY: 50,
                                alignment: BarChartAlignment.spaceEvenly,
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 0.5),
                                ),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (v, _) {
                                        if (v.toInt() >= data.length) return const SizedBox();
                                        final label = (data[v.toInt()]['skill'] as String).split(' ').first;
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(label, style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                barGroups: data.asMap().entries.map((e) {
                                  final i = e.key;
                                  final d = e.value;
                                  return BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: (d['maxPkg'] is int ? (d['maxPkg'] as int).toDouble() : (d['maxPkg'] as double)),
                                        fromY: (d['minPkg'] is int ? (d['minPkg'] as int).toDouble() : (d['minPkg'] as double)),
                                        width: 18,
                                        borderRadius: BorderRadius.circular(4),
                                        gradient: AppColors.primaryGradient,
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              swapAnimationDuration: 600.ms,
                              swapAnimationCurve: Curves.easeInOut,
                            ),
                          ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                          const SizedBox(height: 28),
                          const Text('Skill Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final d = data[i];
                          final skill = d['skill'] as String;
                          final min = (d['minPkg'] is int ? (d['minPkg'] as int).toDouble() : (d['minPkg'] as double));
                          final max = (d['maxPkg'] is int ? (d['maxPkg'] as int).toDouble() : (d['maxPkg'] as double));
                          final count = d['count'] as int;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: AppColors.cardGradient,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(skill, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                      const SizedBox(height: 4),
                                      Text('Based on $count Aditya alumni', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('₹$min – ₹${max}L', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.success)),
                                    const Text('per annum', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                          )
                              .animate(delay: Duration(milliseconds: 400 + i * 80))
                              .fadeIn(duration: 300.ms)
                              .slideX(begin: 0.15, end: 0, duration: 300.ms);
                        },
                        childCount: data.length,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
