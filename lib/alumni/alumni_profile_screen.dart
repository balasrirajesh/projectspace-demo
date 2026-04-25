import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduway/providers/app_providers.dart';

class AlumniProfileScreen extends ConsumerWidget {
  final String alumniId;
  const AlumniProfileScreen({super.key, required this.alumniId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alumniAsync = ref.watch(alumniListProvider);

    return alumniAsync.when(
      data: (list) {
        final alumni = list.firstWhere((a) => a.id == alumniId, orElse: () => list.first);
        return Scaffold(
          body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: CustomScrollView(
          slivers: [
            // Hero header
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: AppColors.bgDark,
              leading: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.bgCard.withOpacity(0.8), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient bg
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary.withOpacity(0.7), AppColors.bgDark],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Profile content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Avatar
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary, width: 3),
                                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20)],
                                ),
                                child: CircleAvatar(radius: 45, backgroundImage: NetworkImage(alumni.photoUrl)),
                              ),
                              if (alumni.isVerified)
                                Positioned(
                                  right: 2, bottom: 2,
                                  child: Container(
                                    width: 22, height: 22,
                                    decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle, border: Border.all(color: AppColors.bgDark, width: 2)),
                                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Name info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(alumni.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                Text('${alumni.role} @ ${alumni.company}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textMuted),
                                    Text(' ${alumni.location}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.star_rounded, size: 12, color: AppColors.accent),
                                    Text(' ${alumni.rating}', style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info cards row
                    Row(
                      children: [
                        _InfoPill(label: 'Batch ${alumni.batch}', icon: Icons.school_rounded, color: AppColors.primary),
                        const SizedBox(width: 8),
                        _InfoPill(label: alumni.branch, icon: Icons.computer_rounded, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        _InfoPill(label: '₹${alumni.package}L', icon: Icons.currency_rupee_rounded, color: AppColors.success),
                      ],
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 24),

                    // Stats row
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _Stat(value: '${alumni.menteeCount}', label: 'Mentees', emoji: '👥'),
                          Container(width: 1, height: 36, color: AppColors.border),
                          _Stat(value: alumni.rating.toString(), label: 'Rating', emoji: '⭐'),
                          Container(width: 1, height: 36, color: AppColors.border),
                          _Stat(value: '${alumni.yearsOfExp}yr', label: 'Exp.', emoji: '💼'),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                    const SizedBox(height: 24),

                    // Their advice
                    _SectionHeader(title: '💡 Advice to You'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(radius: 16, backgroundImage: NetworkImage(alumni.photoUrl)),
                              const SizedBox(width: 8),
                              Text(alumni.name.split(' ').first, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryLight)),
                              const Spacer(),
                              const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 20),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(alumni.advice, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                    const SizedBox(height: 24),

                    // Placement story
                    _SectionHeader(title: '📖 Their Journey'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(alumni.story, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.7)),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 24),

                    // Skills
                    _SectionHeader(title: '🛠️ Skills That Got Them There'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: alumni.skills.map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)],
                        ),
                        child: Text(s, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                      )).toList(),
                    ).animate().fadeIn(delay: 350.ms),

                    const SizedBox(height: 24),

                    // Interview rounds
                    _SectionHeader(title: '🎯 Interview Process'),
                    const SizedBox(height: 12),
                    ...alumni.interviewRounds.asMap().entries.map((e) {
                      final i = e.key;
                      final round = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                              child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(round, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4))),
                          ],
                        ).animate(delay: Duration(milliseconds: 400 + i * 80)).fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Anonymous confession
                    _SectionHeader(title: '🤫 What They Really Felt'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.accent.withOpacity(0.25)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🤫', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Anonymous Confession', style: TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                const SizedBox(height: 6),
                                Text(alumni.anonConfession, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6, fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms),

                    const SizedBox(height: 32),

                    // Ask question button
                    GestureDetector(
                      onTap: () => context.go('/qa'),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Ask a Question', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0, delay: 600.ms),
            ],
          ),
              ),
            ),
          ],
        ),
        )
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error loading profile: $err'))),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary));
}

class _InfoPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _InfoPill({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label, emoji;
  const _Stat({required this.value, required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}
