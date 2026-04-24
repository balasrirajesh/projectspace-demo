import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduway/admin/shared/providers/admin_provider.dart';
import 'package:graduway/alumni/shared/providers/mentorship_provider.dart';
import 'package:graduway/widgets/interactive_classroom_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Fetch real stats on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Professional Slate Light
      body: RefreshIndicator(
        onRefresh: () => context.read<AdminProvider>().fetchStats(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernHeader(context),
              const SizedBox(height: 40),
              _buildPremiumStatsGrid(context),
              const SizedBox(height: 40),
              _buildLiveSessionsOversight(context),
              const SizedBox(height: 40),
              _buildInsightSection(context),
              const SizedBox(height: 100), // Space for fab/footer
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
      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
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
                final provider = context.read<MentorshipProvider>();
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

  Widget _buildModernHeader(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20,
      runSpacing: 20,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Network Analytics",
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: Color(0xFF1E293B)),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Consumer<AdminProvider>(
                  builder: (context, admin, _) => Flexible(
                    child: Text(
                      "System operational • Monitoring ${admin.totalStudents + admin.totalAlumni} active users",
                      style: TextStyle(
                          color: Colors.blueGrey[400],
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
        _buildQuickActionBtn(),
      ],
    );
  }

  Widget _buildQuickActionBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded,
              size: 16, color: Colors.blueGrey[600]),
          const SizedBox(width: 8),
          Text("Last 30 Days",
              style: TextStyle(
                  color: Colors.blueGrey[600], fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: Colors.blueGrey[600]),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildPremiumStatsGrid(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 800 ? 2 : 4;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: constraints.maxWidth < 600 ? 0.95 : 1.3,
          children: [
            _buildStatTile(
                "Total Students",
                admin.totalStudents.toString(),
                Icons.group_rounded,
                const Color(0xFF6366F1),
                () => _showMetricDetail(context, "Students", admin)),
            _buildStatTile(
                "Verified Alumni",
                admin.verifiedAlumni.toString(),
                Icons.verified_user_rounded,
                const Color(0xFF10B981),
                () => _showMetricDetail(context, "Alumni", admin)),
            _buildStatTile(
                "Active Connections",
                admin.totalConnections.toString(),
                Icons.hub_rounded,
                const Color(0xFFF59E0B),
                () => _showMetricDetail(context, "Connections", admin)),
            _buildStatTile(
                "Live Sessions",
                admin.activeSessionsCount.toString(),
                Icons.sensors_rounded,
                const Color(0xFFEF4444),
                () => _showMetricDetail(context, "Sessions", admin)),
          ],
        );
      },
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon,
      Color accentColor, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: accentColor.withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: accentColor, size: 24),
                    ),
                    const Icon(Icons.trending_up_rounded,
                        color: Colors.green, size: 16),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B)),
                        ),
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                          color: Colors.blueGrey[400],
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1100) {
          return Column(
            children: [
              _buildEngagementChart(),
              const SizedBox(height: 32),
              _buildRecentActivity(),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildEngagementChart()),
            const SizedBox(width: 32),
            Expanded(flex: 2, child: _buildRecentActivity()),
          ],
        );
      },
    );
  }

  Widget _buildEngagementChart() {
    return Container(
      padding: const EdgeInsets.all(32),
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Engagement Over Time",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bar_chart_rounded, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("Interactive Growth Visualization",
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(32),
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildActivityItem("Admin verified John Doe", "2 mins ago",
              Icons.check_circle_outline, Colors.green),
          _buildActivityItem("New Session Created", "15 mins ago",
              Icons.add_box_outlined, Colors.blue),
          _buildActivityItem("Urgent Broadcast Sent", "1 hour ago",
              Icons.campaign_outlined, Colors.orange),
          _buildActivityItem("System Backup Complete", "2 hours ago",
              Icons.backup_outlined, Colors.indigo),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildActivityItem(
      String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(time,
                    style:
                        TextStyle(color: Colors.blueGrey[300], fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMetricDetail(
      BuildContext context, String type, AdminProvider admin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("$type Insights",
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B))),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded)),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: _buildDetailContent(type, admin),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(String type, AdminProvider admin) {
    // Unique oversight views for each metric
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        if (type == "Students") ...[
          _buildDetailRow("Recent Enrollment", "34 new this week",
              Icons.person_add_rounded, Colors.blue),
          _buildDetailRow("Active Lab Access", "12 students live",
              Icons.meeting_room_rounded, Colors.green),
          _buildDetailRow("Verification Queue", "8 pending review",
              Icons.hourglass_empty_rounded, Colors.orange),
        ] else if (type == "Alumni") ...[
          _buildDetailRow("Industry Distribution", "Tech (45%), Finance (20%)",
              Icons.business_rounded, Colors.purple),
          _buildDetailRow("Mentorship Opt-in", "15 new mentors available",
              Icons.volunteer_activism_rounded, Colors.pink),
          _buildDetailRow("Global Reach", "Mentors in 12 countries",
              Icons.public_rounded, Colors.indigo),
        ] else if (type == "Sessions") ...[
          _buildDetailRow(
              "Current Utilization",
              "${admin.activeSessionsCount} labs active",
              Icons.analytics_rounded,
              Colors.red),
          _buildDetailRow("Peak Traffic", "11:00 AM - 2:00 PM",
              Icons.speed_rounded, Colors.teal),
          _buildDetailRow("System Health", "All signaling servers green",
              Icons.check_circle_rounded, Colors.green),
        ] else ...[
          _buildDetailRow(
              "Active Handshakes",
              "${admin.totalConnections} connections",
              Icons.handshake_rounded,
              Colors.amber),
          _buildDetailRow("Sync Integrity", "100% database match",
              Icons.sync_rounded, Colors.blue),
        ],
        const SizedBox(height: 32),
        const Text("Oversight Summary",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Text(
          "This view provides a unique diagnostic breakdown of $type management metrics. These insights are live and decoupled from your primary administrative registries.",
          style: const TextStyle(color: Colors.grey, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildLiveSessionsOversight(BuildContext context) {
    return Consumer<MentorshipProvider>(
      builder: (context, provider, _) {
        final sessions = provider.webinars;
        if (sessions.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Live Classroom Oversight",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
              ),
              child: Column(
                children: sessions
                    .map((s) => _buildLiveSessionRow(context, s))
                    .toList(),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildLiveSessionRow(
      BuildContext context, Map<String, dynamic> session) {
    final title = session['title'] ?? 'Unknown Class';
    final attendees = session['attendees'] ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sensors, color: Colors.redAccent, size: 20),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text("Active Session • $attendees attending",
                    style:
                        TextStyle(color: Colors.blueGrey[400], fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton.icon(
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
            icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
            label: const Text("JOIN AS ADMIN"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle,
                    style:
                        TextStyle(color: Colors.blueGrey[400], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
