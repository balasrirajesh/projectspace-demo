import 'package:graduway/student/mentorship/sessions_page.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/alumni/dashboard/alumni_home_screen.dart';
import 'package:graduway/alumni/dashboard/server_settings_page.dart';
import 'package:graduway/alumni/mentorship/alumni_requests_page.dart';
import 'package:graduway/alumni/mentorship/broadcast_streaming_page.dart';
import 'package:graduway/alumni/mentorship/mentees_page.dart';
import 'package:graduway/alumni/notifications/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/alumni/shared/providers/mentorship_provider.dart';
import 'package:graduway/theme/app_theme.dart';
// import 'package:flutter_animate/flutter_animate.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildGreeting(),
                  const SizedBox(height: 32),
                  _buildSearchField(),
                  const SizedBox(height: 32),
                  _buildStatsGrid(context),
                  const SizedBox(height: 40),
                  _buildSectionTitle('Mentor Console'),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 40),
                  _buildSectionTitle('Network Activity'),
                  const SizedBox(height: 16),
                  _buildRecentActivityList(),
                  const SizedBox(height: 100), // Space for navbar
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) =>
            setState(() => _searchQuery = value.toLowerCase()),
        decoration: InputDecoration(
          hintText: "Search mentors, sessions, or job posts...",
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppColors.primary),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = "");
                  })
              : null,
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.background.withOpacity(0.8),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "Connect",
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ServerSettingsPage())),
        ),
        const SizedBox(width: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.textPrimary),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsPage())),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.accent, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildGreeting() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome back,",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${auth.userName}!",
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build consistent section headers.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  /// Builds a grid of four key performance indicators (stats).
  Widget _buildStatsGrid(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child: _buildStatCard(context, "Mentees Guided", "12",
                      Icons.people_outline, Colors.blue,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MenteesPage(
                                  initialShowActive: false))))),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard(context, "Sessions Held", "45",
                      Icons.event_available_outlined, Colors.green,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SessionsPage())))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Selector<MentorshipProvider, int>(
                selector: (_, p) => p.acceptedCount,
                builder: (context, count, _) => Expanded(
                    child: _buildStatCard(context, "Active Mentees",
                        count.toString(), Icons.school_outlined, Colors.orange,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MenteesPage())))),
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard(context, "Unresolved Queries", "3",
                      Icons.question_answer_outlined, Colors.purple,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const NotificationsPage())))), // Unresolved queries are alerts for now
            ],
          ),
        ),
      ],
    );
  }

  /// Helper to build an individual statistic card.
  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 12, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a horizontal list of quick actions for mentors.
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        "title": "Post Job",
        "icon": Icons.add_circle_outline,
        "color": Colors.blueAccent
      },
      {
        "title": "Events",
        "icon": Icons.event_note,
        "color": Colors.indigoAccent
      },
      {
        "title": "Start Stream",
        "icon": Icons.sensors,
        "color": Colors.redAccent
      },
      {
        "title": "Requests",
        "icon": Icons.pending_actions,
        "color": Colors.teal,
        "notif": true
      },
    ];

    final filteredActions = actions
        .where(
            (a) => (a['title'] as String).toLowerCase().contains(_searchQuery))
        .toList();

    if (filteredActions.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filteredActions.map((a) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildActionButton(
              context,
              a['title'] as String,
              a['icon'] as IconData,
              a['color'] as Color,
              hasNotification: a['notif'] == true,
              onTap: a['title'] == "Requests"
                  ? () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AlumniRequestsPage()));
                    }
                  : a['title'] == "Start Stream"
                      ? () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BroadcastStreamingPage(
                                      streamId:
                                          "alumni-stream-${DateTime.now().millisecondsSinceEpoch}")));
                        }
                      : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Helper to build a styled quick action button.
  Widget _buildActionButton(
      BuildContext context, String title, IconData icon, Color color,
      {VoidCallback? onTap, bool hasNotification = false}) {
    return Builder(
      builder: (context) => InkWell(
        onTap: onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Icon(icon, color: color, size: 20),
                  if (hasNotification)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a vertical list of recent mentoring activities.
  Widget _buildRecentActivityList() {
    final activities = [
      {
        "title": "Software Engineer Intern",
        "sub": "Google • Posted Yesterday",
        "icon": Icons.work,
        "color": Colors.blue
      },
      {
        "title": "Mentorship Request Accepted",
        "sub": "By Sarah Jenkins • 2 days ago",
        "icon": Icons.school,
        "color": Colors.orange
      },
      {
        "title": "Alumni Meetup 2026",
        "sub": "Event RSVP Confirmed • Last week",
        "icon": Icons.event,
        "color": Colors.indigo
      },
    ];

    final filteredActivities = activities.where((a) {
      return (a['title'] as String).toLowerCase().contains(_searchQuery) ||
          (a['sub'] as String).toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredActivities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text("No matching activities found.",
            style: TextStyle(color: Colors.grey[500])),
      );
    }

    return Column(
      children: filteredActivities.map((a) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildActivityItem(
            a['title'] as String,
            a['sub'] as String,
            a['icon'] as IconData,
            a['color'] as Color,
          ),
        );
      }).toList(),
    );
  }

  /// Builds an individual activity card.
  Widget _buildActivityItem(
      String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      color: Colors.white,
      child: Builder(
        builder: (context) => InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsPage(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


