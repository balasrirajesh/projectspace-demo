import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/data/mock/placement_data.dart';
import 'package:graduway/widgets/custom_app_bar.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final Set<String> _rsvped = {'e002'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Events & Webinars 📅',
        showBackButton: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Upcoming sessions hosted by Aditya alumni', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final event = mockEvents[i];
                      final isRsvped = _rsvped.contains(event.id);
                      final typeEmojis = {'webinar': '📡', 'workshop': '🛠️', 'career_talk': '🎤', 'mockinterview': '🎯'};
                      final typeColors = {'webinar': AppColors.success, 'workshop': AppColors.secondary, 'career_talk': AppColors.primary, 'mockinterview': AppColors.accent};
                      final color = typeColors[event.type] ?? AppColors.primary;
                      final emoji = typeEmojis[event.type] ?? '📅';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: AppColors.cardGradient,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isRsvped ? AppColors.success.withOpacity(0.4) : AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with type
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48, height: 48,
                                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                          child: Text(event.type.replaceAll('_', ' ').toUpperCase(), style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(event.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(event.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  const Icon(Icons.person_rounded, size: 14, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text('${event.hostAlumniName} • ${event.hostCompany}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('d MMM y • h:mm a').format(event.eventDate),
                                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.people_rounded, size: 13, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text('${event.registeredCount} registered', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: GestureDetector(
                                onTap: () => setState(() => isRsvped ? _rsvped.remove(event.id) : _rsvped.add(event.id)),
                                child: AnimatedContainer(
                                  duration: 250.ms,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: isRsvped ? null : AppColors.primaryGradient,
                                    color: isRsvped ? AppColors.success.withOpacity(0.15) : null,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isRsvped ? Border.all(color: AppColors.success.withOpacity(0.4)) : null,
                                    boxShadow: isRsvped ? [] : [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10)],
                                  ),
                                  child: Center(
                                    child: Text(
                                      isRsvped ? '✅ RSVP\'d — See you there!' : 'RSVP for Free →',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isRsvped ? AppColors.success : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate(delay: Duration(milliseconds: i * 100))
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.15, end: 0, duration: 400.ms);
                    },
                    childCount: mockEvents.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
