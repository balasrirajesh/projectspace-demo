import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:graduway/alumni/shared/providers/mentorship_provider.dart';
import 'package:graduway/widgets/interactive_classroom_page.dart';
import 'package:graduway/admin/sessions/session_control_page.dart';
import 'package:graduway/admin/announcements/announcements_page.dart';
import 'package:graduway/admin/connections/connection_monitor_page.dart';
import 'package:graduway/admin/users/user_management_page.dart';

import 'package:graduway/admin/shared/providers/admin_provider.dart';

class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final admin = legacy.Provider.of<AdminProvider>(context, listen: false);
      admin.fetchStats();
      admin.fetchActiveSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return legacy.Consumer<AdminProvider>(
      builder: (context, admin, _) => Scaffold(
        appBar: const CustomAppBar(
          title: 'Admin Console',
          showBackButton: false,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await admin.fetchStats();
            await admin.fetchActiveSessions();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Platform Status', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),
                
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(label: 'Total Students', value: admin.totalStudents.toString(), icon: Icons.school_rounded, color: AppColors.primary),
                    _StatCard(label: 'Verified Alumni', value: admin.verifiedAlumni.toString(), icon: Icons.verified_user_rounded, color: AppColors.alumni),
                    _StatCard(label: 'Active Q&A', value: admin.activeQA.toString(), icon: Icons.forum_rounded, color: AppColors.secondary),
                    _StatCard(label: 'Upcoming Events', value: admin.upcomingEvents.toString(), icon: Icons.event_available_rounded, color: AppColors.admin),
                  ],
                ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),

            const SizedBox(height: 32),

            const Text('Registration Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2), FlSpot(3, 5), FlSpot(4, 3), FlSpot(5, 7), FlSpot(6, 8),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 32),

            const Text('System Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _ReportTile(
              title: 'New Alumni Requests',
              count: '5',
              color: AppColors.alumni,
              icon: Icons.person_add_rounded,
              onTap: () => context.go('/admin-users'),
            ),
            const SizedBox(height: 12),
            _ReportTile(
              title: 'Reported Content',
              count: '2',
              color: AppColors.error,
              icon: Icons.flag_rounded,
              onTap: () => _showReportedContentSheet(context),
            ),
            const SizedBox(height: 32),

            // Live Classroom Oversight
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Live Classroom Oversight",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 16),
                if (admin.activeSessionsList.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text('No active sessions currently.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      children: admin.activeSessionsList
                          .map((s) => _buildLiveSessionRow(context, s))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ).animate().fadeIn(delay: 500.ms),

            // ── Rajesh: Admin Quick Actions ─────────────────────────────
            const Text('Admin Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _AdminActionTile(
                  icon: Icons.campaign_rounded,
                  label: 'Announcements',
                  color: Colors.indigo,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementsPage())),
                ),
                _AdminActionTile(
                  icon: Icons.video_library_rounded,
                  label: 'Live Sessions',
                  color: Colors.redAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionControlPage())),
                ),
                _AdminActionTile(
                  icon: Icons.people_alt_rounded,
                  label: 'Connections',
                  color: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectionMonitorPage())),
                ),
                _AdminActionTile(
                  icon: Icons.manage_accounts_rounded,
                  label: 'Manage Users',
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementPage())),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _showCreateClassDialog(context),
      backgroundColor: const Color(0xFF1E293B),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text("Create Live Lab",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ).animate().fadeIn(delay: 800.ms),
  ),
);
}

  void _showReportedContentSheet(BuildContext context) {
    final reports = [
      {'user': 'Anon Student', 'content': 'Inappropriate comment in Q&A thread', 'time': '2h ago'},
      {'user': 'Alumni X', 'content': 'Misleading salary data in profile', 'time': '1 day ago'},
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
                const Text('Reported Content', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            ...reports.map((r) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flag_rounded, color: AppColors.error, size: 16),
                        const SizedBox(width: 8),
                        Text(r['user']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const Spacer(),
                        Text(r['time']!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(r['content']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Dismiss'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Content removed.'), backgroundColor: AppColors.error),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            child: const Text('Remove'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
  void _showCreateClassDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Faculty Session"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter Lab Name (e.g. System Audit)",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                final provider = legacy.Provider.of<MentorshipProvider>(context, listen: false);
                provider.startNewWebinar(title);
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InteractiveClassroomPage(
                      roomId: title.toLowerCase().replaceAll(' ', '-'),
                    ),
                  ),
                );
              }
            },
            child: const Text("Start Session"),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSessionRow(BuildContext context, Map<String, dynamic> session) {
    final title = session['title'] ?? 'Unknown Class';
    final attendees = session['attendees'] ?? 0;

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
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text("Active Session • $attendees attending",
                    style:
                        TextStyle(color: Colors.blueGrey[400], fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InteractiveClassroomPage(
                    roomId: title.toLowerCase().replaceAll(' ', '-'),
                  ),
                ),
              );
            },
            child: const Text("JOIN"),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final String title, count;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  const _ReportTile({required this.title, required this.count, required this.color, required this.icon, this.onTap});

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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
              child: Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
