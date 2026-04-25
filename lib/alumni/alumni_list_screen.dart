import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/data/models/alumni_model.dart';

class AlumniListScreen extends ConsumerStatefulWidget {
  const AlumniListScreen({super.key});

  @override
  ConsumerState<AlumniListScreen> createState() => _AlumniListScreenState();
}

class _AlumniListScreenState extends ConsumerState<AlumniListScreen> {
  final _branches = ['All', 'CSE', 'ECE', 'MECH', 'EEE', 'IT'];

  @override
  Widget build(BuildContext context) {
    final selectedBranch = ref.watch(selectedBranchProvider);
    final alumni = ref.watch(searchedAlumniProvider);
    final query = ref.watch(alumniSearchProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Our Alumni 👩‍💼',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary))
                        .animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 4),
                    Text('${alumni.length} verified professionals from Aditya College',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))
                        .animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 16),
                    // Search bar
                    TextField(
                      onChanged: (v) => ref.read(alumniSearchProvider.notifier).state = v,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search by name, company, skill...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 18),
                                onPressed: () => ref.read(alumniSearchProvider.notifier).state = '',
                              )
                            : null,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 14),
                    // Branch filter chips
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _branches.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final b = _branches[i];
                          final sel = selectedBranch == b;
                          return GestureDetector(
                            onTap: () => ref.read(selectedBranchProvider.notifier).state = b,
                            child: AnimatedContainer(
                              duration: 200.ms,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: sel ? AppColors.primaryGradient : null,
                                color: sel ? null : AppColors.bgCard,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: sel ? Colors.transparent : AppColors.border),
                              ),
                              child: Text(b,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: sel ? Colors.white : AppColors.textSecondary)),
                            ),
                          );
                        },
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Alumni list
              Expanded(
                child: ref.watch(alumniListProvider).when(
                  data: (_) {
                    final filtered = ref.watch(searchedAlumniProvider);
                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('🔍', style: TextStyle(fontSize: 48)),
                            SizedBox(height: 12),
                            Text('No alumni found',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _AlumniCard(alumni: filtered[i], index: i)
                          .animate(delay: Duration(milliseconds: i * 60))
                          .fadeIn(duration: 350.ms)
                          .slideX(begin: 0.15, end: 0, duration: 350.ms),
                    );
                  },
                  loading: () => _buildShimmer(),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.bgCard,
      highlightColor: AppColors.bgCardLight,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
            height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Alumni Card — overflow-safe layout
// ─────────────────────────────────────────────────────────────────────────────
class _AlumniCard extends StatelessWidget {
  final AlumniModel alumni;
  final int index;
  const _AlumniCard({required this.alumni, required this.index});

  @override
  Widget build(BuildContext context) {
    final branchColors = {
      'CSE': AppColors.primary,
      'ECE': AppColors.secondary,
      'MECH': AppColors.accent,
      'EEE': AppColors.error,
      'IT': AppColors.success,
    };
    final color = branchColors[alumni.branch] ?? AppColors.primary;

    return GestureDetector(
      onTap: () => context.push('/alumni/${alumni.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ───────────────────────────────────────────────────────
            Stack(
              children: [
                CircleAvatar(radius: 26, backgroundImage: NetworkImage(alumni.photoUrl)),
                if (alumni.isVerified)
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.bgCard, width: 2)),
                      child: const Icon(Icons.check, size: 9, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // ── Info (Expanded yields remaining space, never bigger than it) ─
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + branch chip: Flexible on name prevents pushing chip off-screen
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          alumni.name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                            color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text(alumni.branch,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${alumni.role} @ ${alumni.company}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'Batch ${alumni.batch} • ${alumni.location}',
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 6),
                  // Skills chips
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: alumni.skills.take(3).map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(s,
                          style: const TextStyle(fontSize: 9, color: AppColors.primaryLight),
                          overflow: TextOverflow.ellipsis),
                    )).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Package column — fixed width, never overflows ─────────────────
            SizedBox(
              width: 76,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: Text(
                      '₹${alumni.package}L',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 11, color: AppColors.accent),
                      Text(' ${alumni.rating}',
                          style: const TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text('${alumni.menteeCount} mentees',
                      style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
