import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduway/admin/shared/providers/admin_provider.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/widgets/interactive_classroom_page.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';

class SessionControlPage extends StatefulWidget {
  const SessionControlPage({super.key});

  @override
  State<SessionControlPage> createState() => _SessionControlPageState();
}

class _SessionControlPageState extends State<SessionControlPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchActiveSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => admin.fetchActiveSessions(),
                child: LayoutBuilder(builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 600;
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(isNarrow ? 20.0 : 40.0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(admin),
                        const SizedBox(height: 32),
                        _buildSuperiorControlPanel(admin),
                        const SizedBox(height: 32),
                        const Text(
                          "Live Monitor",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B)),
                        ).animate().fadeIn(delay: 400.ms),
                        const SizedBox(height: 16),
                        if (admin.error != null) _buildErrorState(admin),
                        if (admin.isLoading && admin.activeSessionsList.isEmpty)
                          const Center(
                              child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator())),
                        if (!admin.isLoading ||
                            admin.activeSessionsList.isNotEmpty)
                          _buildSessionsList(admin),
                      ],
                    ),
                  );
                }),
              ),
              if (admin.error != null)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: _buildErrorBanner(admin),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(AdminProvider admin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 48, color: Colors.orange.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text("Connection Interrupted",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
              "We're having trouble reaching the signaling server. Live monitor is currently offline.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey[400], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(AdminProvider admin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text("Sync failed: check server status",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => admin.fetchActiveSessions(),
            child: const Text("RETRY",
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ],
      ),
    ).animate().slideY(begin: 1.0, curve: Curves.easeOut);
  }

  Widget _buildHeader(AdminProvider admin) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20,
      runSpacing: 20,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Session Control Center",
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B)),
            ),
            Text(
              "Superior oversight of all active college classrooms",
              style: TextStyle(color: Colors.blueGrey[400], fontSize: 16),
            ),
          ],
        ),
        _buildLiveBadge(admin.activeSessionsCount),
      ],
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildLiveBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: count > 0
            ? Colors.red.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: count > 0
                ? Colors.red.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count > 0)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .fade(duration: 800.ms),
          const SizedBox(width: 8),
          Text(
            "$count SESSIONS LIVE",
            style: TextStyle(
              color: count > 0 ? Colors.red : Colors.grey,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuperiorControlPanel(AdminProvider admin) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 600;
      return Container(
        padding: EdgeInsets.all(isNarrow ? 24 : 32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF334155)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
                color: Colors.indigo.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 20)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Faculty Superior Mode",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
                if (!isNarrow) _buildStartBtn(),
              ],
            ),
            Text(
              "As a superior administrator, you have the authority to start official sessions or terminate any running class immediately.",
              style: TextStyle(color: Colors.blueGrey[200], fontSize: 14),
            ),
            if (isNarrow) ...[
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: _buildStartBtn()),
            ],
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95));
    });
  }

  Widget _buildStartBtn() {
    return ElevatedButton.icon(
      onPressed: () => _startAdminSession(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.add_to_queue_rounded),
      label: const Text("Start Official Session",
          style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSessionsList(AdminProvider admin) {
    if (admin.activeSessionsList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          children: [
            Icon(Icons.monitor_heart_rounded,
                size: 64, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text("No active sessions currently monitored",
                style: TextStyle(
                    color: Colors.blueGrey[200], fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 450,
        mainAxisExtent: 200,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: admin.activeSessionsList.length,
      itemBuilder: (context, index) {
        final session = admin.activeSessionsList[index];
        return _buildSessionCard(admin, session);
      },
    );
  }

  Widget _buildSessionCard(AdminProvider admin, dynamic session) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      InteractiveClassroomPage(roomId: session['id'])),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        session['title'] ?? 'Untitled Session',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildParticipantCount(session['participants'] ?? 0),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_pin_rounded,
                        size: 14, color: Colors.blueGrey[300]),
                    const SizedBox(width: 4),
                    Text(
                      "Host: ${session['mentor']}",
                      style:
                          TextStyle(color: Colors.blueGrey[400], fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _buildStartTime(session['startTime'])),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _confirmTerminate(admin, session['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const FittedBox(
                          child: Text("Superior Stop",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildParticipantCount(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_alt_rounded, size: 12, color: Colors.blue),
          const SizedBox(width: 4),
          Text(count.toString(),
              style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStartTime(String? startTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("STARTED",
            style: TextStyle(
                color: Colors.blueGrey[200],
                fontSize: 9,
                fontWeight: FontWeight.bold)),
        Text(
          startTime != null ? "Active for 12m" : "Just now",
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
        ),
      ],
    );
  }

  void _confirmTerminate(AdminProvider admin, String roomId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("SUPERIOR TERMINATION"),
        content: const Text(
            "You are about to forcefully disconnect all participants and terminate this session. This action cannot be undone. Proceed?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await admin.stopSession(roomId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Session terminated successfully."),
                      backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Terminate Session"),
          ),
        ],
      ),
    );
  }

  void _startAdminSession() {
    // Navigate to a Faculty Room (Simulated)
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.rocket_launch_rounded,
                size: 48, color: Colors.indigo),
            const SizedBox(height: 16),
            const Text("Official Session Dashboard",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                "You are now initializing an official Faculty-led classroom. This session will be broadcasted to all eligible students.",
                textAlign: TextAlign.center),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final roomId =
                    "FACULTY-${math.Random().nextInt(9999).toString().padLeft(4, '0')}";
                Navigator.pop(context); // Close sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          InteractiveClassroomPage(roomId: roomId)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Launch Live Broadcast"),
            ),
          ],
        ),
      ),
    );
  }
}
