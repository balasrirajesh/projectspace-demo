import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/widgets/custom_app_bar.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/widgets/interactive_classroom_page.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:graduway/alumni/shared/providers/mentorship_provider.dart';
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _roomIdController = TextEditingController();

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  void _joinSession() {
    final roomId = _roomIdController.text.trim().toLowerCase().replaceAll(' ', '-');
    if (roomId.isNotEmpty) {
      context.push('/classroom/$roomId');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Room ID')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final student = auth.student;
    final displayName = auth.loginName.isNotEmpty ? auth.loginName : (student?.name ?? 'Student');

    return Scaffold(
      appBar: CustomAppBar(
        title: 'GraduWay',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => _showNotifications(context),
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(student?.photoUrl ?? 'https://i.pravatar.cc/150'),
            ),
            onPressed: () => context.push('/profile'),
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
                    '${_getGreeting()}, ${displayName.split(' ').first}! 👋',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ).animate().fadeIn().slideX(begin: -0.1),
                  const SizedBox(height: 4),
                  Text(
                    '${student?.branch ?? "CSE"} • Year ${student?.year ?? 3}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
            ),

            // Career Score Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 35,
                      lineWidth: 6,
                      percent: (student?.careerScore ?? 42) / 100,
                      center: Text(
                        '${student?.careerScore ?? 42}%',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      progressColor: Colors.white,
                      backgroundColor: Colors.white24,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Career Ready Score', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          const Text('Great progress! 🚀', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          const Text(
                            'Complete 2 more sessions to reach 50%',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            ),

            const SizedBox(height: 24),

            // ── Rajesh: Join Live Session Card ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.blue.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.sensors_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text('Join Live Session',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter the Room ID provided by your mentor.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _roomIdController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'e.g. math-class-101',
                          hintStyle: TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _joinSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('Join Session Now',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),

            const SizedBox(height: 32),

            // ── Rajesh: Live Classes List ──────────────────────────────────
            legacy.Consumer<MentorshipProvider>(
              builder: (context, provider, _) {
                final sessions = provider.webinars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Live Classes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      if (sessions.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.withOpacity(0.15)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.event_busy_rounded, size: 48, color: Colors.blueGrey.withOpacity(0.2)),
                              const SizedBox(height: 16),
                              const Text('No live or upcoming webinars.', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            children: sessions.map((s) {
                              final title = s['title'] ?? 'Unknown Class';
                              final attendees = s['attendees'] ?? 0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.sensors, color: Colors.redAccent, size: 18),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text("Active Session • $attendees attending", style: TextStyle(color: Colors.blueGrey[400], fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => context.push('/classroom/${title.toLowerCase().replaceAll(' ', '-')}'),
                                      child: const Text("JOIN"),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms);
              },
            ),

            const SizedBox(height: 32),

            // Quick Access
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Quick Access', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _QuickLink(
                    icon: Icons.quiz_rounded,
                    label: 'Ask AI/Alum',
                    color: AppColors.primary,
                    onTap: () {
                      ref.read(studentNavIndexProvider.notifier).state = 1;
                      context.go('/qa');
                    },
                  ),
                  _QuickLink(
                    icon: Icons.school_rounded,
                    label: 'Classroom',
                    color: Colors.deepPurple,
                    onTap: () => context.push('/classroom'),
                  ),
                  _QuickLink(
                    icon: Icons.handshake_rounded,
                    label: 'Mentorship',
                    color: Colors.orange,
                    onTap: () {
                      ref.read(studentNavIndexProvider.notifier).state = 2;
                      context.go('/mentorship');
                    },
                  ),
                  _QuickLink(
                    icon: Icons.map_rounded,
                    label: 'Roadmap',
                    color: AppColors.secondary,
                    onTap: () => context.push('/roadmap'),
                  ),
                  _QuickLink(icon: Icons.currency_rupee_rounded, label: 'Packages', color: AppColors.accent, onTap: () => context.push('/skill-package')),
                  _QuickLink(icon: Icons.history_edu_rounded, label: 'Stories', color: AppColors.error, onTap: () => context.push('/placement')),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 32),

            // Top Alumni
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Top Alumni', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  TextButton(
                    onPressed: () => context.push('/alumni'),
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ref.watch(alumniListProvider).when(
                data: (alumni) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: alumni.length > 5 ? 5 : alumni.length,
                  itemBuilder: (context, i) {
                    final alu = alumni[i];
                    return GestureDetector(
                      onTap: () => context.push('/alumni/${alu.id}'),
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(radius: 28, backgroundImage: NetworkImage(alu.photoUrl.isNotEmpty ? alu.photoUrl : 'https://i.pravatar.cc/150')),
                            const SizedBox(height: 12),
                            Text(alu.name.split(' ').first, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            Text(alu.company, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text('₹${alu.package}L', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 400 + (i * 100)));
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),

            const SizedBox(height: 32),

            // Trending Q&A
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Trending Q&A', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 16),
            ...ref.watch(trendingQAProvider).map((q) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Card(
                child: ListTile(
                  title: Text(q.question, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text('${q.answers.length} answers • ${q.upvotes} upvotes', style: const TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ref.read(studentNavIndexProvider.notifier).state = 1; // Assuming Q&A is at index 1
                    context.go('/qa');
                  },
                ),
              ),
            )).toList().animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌆';
  }

  void _showNotifications(BuildContext context) {
    final notifs = [
      _NotifData(icon: Icons.chat_bubble_rounded, color: AppColors.primary, title: 'Ravi Kumar answered your question', sub: 'Insights on FAANG prep & LeetCode strategy!', time: '2h ago'),
      _NotifData(icon: Icons.event_rounded, color: AppColors.secondary, title: 'Webinar tomorrow at 6 PM', sub: 'System Design with Priya Lakshmi', time: '5h ago'),
      _NotifData(icon: Icons.emoji_events_rounded, color: AppColors.accent, title: 'New Badge Earned! 🏆', sub: 'You earned "First Question Asked"', time: 'Yesterday'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            ),
            Row(
              children: [
                const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const Spacer(),
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Mark all read')),
              ],
            ),
            const SizedBox(height: 8),
            ...notifs.map((n) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: n.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(n.icon, color: n.color, size: 22),
              ),
              title: Text(n.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text(n.sub, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              trailing: Text(n.time, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            )),
          ],
        ),
      ),
    );
  }
}

class _NotifData {
  final IconData icon;
  final Color color;
  final String title, sub, time;
  const _NotifData({required this.icon, required this.color, required this.title, required this.sub, required this.time});
}


class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickLink({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
