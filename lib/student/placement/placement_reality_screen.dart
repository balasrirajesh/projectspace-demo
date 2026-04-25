import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduway/providers/app_providers.dart';

class PlacementRealityScreen extends ConsumerWidget {
  const PlacementRealityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(placementStoriesProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Placement Reality 🎭',
        showBackButton: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: storiesAsync.when(
            data: (rawStories) {
              final stories = rawStories.map((json) => _Story(
                name: json['name'] ?? 'Anonymous',
                company: json['company'] ?? 'Unknown',
                photoUrl: json['photoUrl'] ?? 'https://i.pravatar.cc/150',
                title: json['title'] ?? '',
                content: json['content'] ?? '',
                package: json['package'] ?? 'N/A',
                isAnon: json['isAnon'] ?? true,
              )).toList();

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                                  'No sugar-coating. Real stories from Aditya alumni.',
                                  style: TextStyle(
                                      fontSize: 13, color: AppColors.textSecondary))
                              .animate()
                              .fadeIn(delay: 100.ms),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.accent.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Text('⚠️', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'These are real experiences from Aditya College alumni. Some are anonymous to protect privacy.',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _StoryCard(story: stories[i], index: i),
                        childCount: stories.length,
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }
}

class _Story {
  final String name, company, photoUrl, title, content, package;
  final bool isAnon;
  const _Story(
      {required this.name,
      required this.company,
      required this.photoUrl,
      required this.title,
      required this.content,
      required this.package,
      required this.isAnon});
}

class _StoryCard extends StatefulWidget {
  final _Story story;
  final int index;
  const _StoryCard({required this.story, required this.index});

  @override
  State<_StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<_StoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.story;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: s.isAnon
                  ? AppColors.accent.withOpacity(0.3)
                  : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (s.isAnon)
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.accent.withOpacity(0.4)),
                          ),
                          child: const Center(
                              child:
                                  Text('🤫', style: TextStyle(fontSize: 22))),
                        )
                      else
                        CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(s.photoUrl)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            Text(s.company,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(s.package,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(s.title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  AnimatedCrossFade(
                    firstChild: Text(s.content,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.6),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis),
                    secondChild: Text(s.content,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.6)),
                    crossFadeState: _expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: 300.ms,
                  ),
                  const SizedBox(height: 8),
                  Text(_expanded ? 'Show less ▲' : 'Read full story ▼',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 100))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.1, end: 0, duration: 350.ms);
  }
}
