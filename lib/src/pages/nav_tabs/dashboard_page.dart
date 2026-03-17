import 'package:flutter/material.dart';
import 'package:alumini_screen/src/pages/features/Common/detail_page.dart';
import 'package:alumini_screen/src/pages/features/Mentorship/alumni_requests_page.dart';
import 'package:alumini_screen/src/pages/nav_tabs/placeholder_page.dart';

import 'package:provider/provider.dart';
import 'package:alumini_screen/src/providers/auth_provider.dart';
import 'package:alumini_screen/src/providers/mentorship_provider.dart';

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
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildGreeting(),
                  const SizedBox(height: 24),
                  _buildSearchField(),
                  const SizedBox(height: 24),
                  _buildStatsGrid(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Quick Actions'),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Recent Activity'),
                  const SizedBox(height: 16),
                  _buildRecentActivityList(),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
        decoration: InputDecoration(
          hintText: "Search requests or events...",
          prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () {
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
      expandedHeight: 70.0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white60 ,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          "Alumni Portal",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DetailPage(
                  title: "Notifications",
                  icon: Icons.notifications_none_rounded,
                  themeColor: Colors.blue,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildGreeting() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello, ${auth.userName}!",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Text(
              auth.techField,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Here is what's happening in your network today.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildStatsGrid(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildStatCard(context, "Jobs Posted", "5", Icons.work_outline, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(context, "Applications", "18", Icons.people_outline, Colors.green)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer<MentorshipProvider>(
                builder: (context, mentor, _) => 
                  Expanded(child: _buildStatCard(context, "Mentorships", mentor.acceptedCount.toString(), Icons.school_outlined, Colors.orange)),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(context, "New Messages", "6", Icons.chat_bubble_outline, Colors.purple)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              title: title,
              icon: icon,
              themeColor: color,
            ),
          ),
        );
      },
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
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[400]),
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

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {"title": "Post Job", "icon": Icons.add_circle_outline, "color": Colors.blueAccent},
      {"title": "Events", "icon": Icons.event_note, "color": Colors.indigoAccent},
      {"title": "Requests", "icon": Icons.pending_actions, "color": Colors.teal, "notif": true},
    ];

    final filteredActions = actions.where((a) => (a['title'] as String).toLowerCase().contains(_searchQuery)).toList();

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
              onTap: a['title'] == "Requests" ? () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AlumniRequestsPage()));
              } : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, Color color, {VoidCallback? onTap, bool hasNotification = false}) {
    return Builder(
      builder: (context) => InkWell(
        onTap: onTap ?? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(
                title: title,
                icon: icon,
                themeColor: color,
              ),
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

  Widget _buildRecentActivityList() {
    final activities = [
      {"title": "Software Engineer Intern", "sub": "Google • Posted Yesterday", "icon": Icons.work, "color": Colors.blue},
      {"title": "Mentorship Request Accepted", "sub": "By Sarah Jenkins • 2 days ago", "icon": Icons.school, "color": Colors.orange},
      {"title": "Alumni Meetup 2026", "sub": "Event RSVP Confirmed • Last week", "icon": Icons.event, "color": Colors.indigo},
    ];

    final filteredActivities = activities.where((a) {
      return (a['title'] as String).toLowerCase().contains(_searchQuery) ||
             (a['sub'] as String).toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredActivities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text("No matching activities found.", style: TextStyle(color: Colors.grey[500])),
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

  Widget _buildActivityItem(String title, String subtitle, IconData icon, Color color) {
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
                builder: (context) => DetailPage(
                  title: title,
                  icon: icon,
                  themeColor: color,
                ),
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
