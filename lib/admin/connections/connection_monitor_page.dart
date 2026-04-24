import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduway/admin/shared/providers/admin_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:graduway/widgets/custom_app_bar.dart';

class ConnectionMonitorPage extends StatefulWidget {
  const ConnectionMonitorPage({super.key});

  @override
  State<ConnectionMonitorPage> createState() => _ConnectionMonitorPageState();
}

class _ConnectionMonitorPageState extends State<ConnectionMonitorPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchConnections();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: const CustomAppBar(
        title: 'Mentorship Connections',
        showBackButton: true,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Mentorship Connections",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ).animate().fadeIn(),
                const SizedBox(height: 24),
                Expanded(
                  child: admin.isLoading && admin.connections.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () => admin.fetchConnections(),
                          child: ListView.builder(
                            itemCount: admin.connections.length,
                            itemBuilder: (context, index) {
                              final conn = admin.connections[index];
                              return _buildConnectionCard(context, admin, conn);
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectionCard(
      BuildContext context, AdminProvider admin, dynamic conn) {
    final statusColor = _getStatusColor(conn['status'] ?? 'pending');
    final studentName = conn['student']?['name'] ?? 'Unknown Student';
    final mentorName = conn['mentor']?['name'] ?? 'Not Assigned';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                        child: Text(
                      studentName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    )),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 14, color: Colors.grey),
                    ),
                    Flexible(
                        child: Text(
                      mentorName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                    conn['topics'] != null
                        ? "Topics: ${(conn['topics'] as List).join(', ')}"
                        : "Mentorship Request",
                    style:
                        TextStyle(color: Colors.blueGrey[400], fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              (conn['status'] as String).toUpperCase(),
              style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10),
            ),
          ),
          const SizedBox(width: 16),
          _buildActionMenu(context, admin, conn),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.05);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  Widget _buildActionMenu(
      BuildContext context, AdminProvider admin, dynamic conn) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_horiz_rounded, color: Colors.blueGrey),
      onSelected: (val) async {
        final success =
            await admin.updateConnectionStatus(conn['id'], val.toString());
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Connection status updated to $val"),
                backgroundColor: Colors.indigo),
          );
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
            value: 'accepted', child: Text("Force Connect (Accept)")),
        const PopupMenuItem(
            value: 'rejected',
            child: Text("Force Disconnect (Reject)",
                style: TextStyle(color: Colors.red))),
        const PopupMenuItem(
            value: 'completed', child: Text("Mark as Completed")),
      ],
    );
  }
}
