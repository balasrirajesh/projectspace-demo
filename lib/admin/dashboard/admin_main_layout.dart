import 'package:graduway/admin/shared/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:graduway/admin/dashboard/admin_dashboard_page.dart';
import 'package:graduway/admin/users/user_management_page.dart';
import 'package:graduway/admin/connections/connection_monitor_page.dart';
import 'package:graduway/admin/sessions/session_control_page.dart';
import 'package:graduway/admin/announcements/announcements_page.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const UserManagementPage(),
    const ConnectionMonitorPage(),
    const SessionControlPage(),
    const AnnouncementsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        final selectedIndex = admin.currentTab;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              _getPageTitle(selectedIndex),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.grey),
                onPressed: () => context.read<AuthProvider>().logout(),
              ),
              const SizedBox(width: 16),
            ],
          ),
          drawer: _buildSideDrawer(context, selectedIndex),
          body: _pages[selectedIndex],
        );
      },
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return "Faculty Dashboard";
      case 1:
        return "User Management";
      case 2:
        return "Connections Monitor";
      case 3:
        return "Session Control";
      case 4:
        return "Announcements";
      default:
        return "Admin Panel";
    }
  }

  Widget _buildSideDrawer(BuildContext context, int selectedIndex) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.indigo),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.admin_panel_settings_rounded,
                      size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text("College Faculty",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(context.read<AuthProvider>().collegeName,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
          _buildDrawerItem(context, 0, "Dashboard",
              Icons.dashboard_customize_rounded, selectedIndex),
          _buildDrawerItem(context, 1, "User Management",
              Icons.manage_accounts_rounded, selectedIndex),
          _buildDrawerItem(context, 2, "Connection Monitor",
              Icons.connect_without_contact_rounded, selectedIndex),
          _buildDrawerItem(
              context, 3, "Live Sessions", Icons.stream_rounded, selectedIndex),
          _buildDrawerItem(context, 4, "Announcements", Icons.campaign_rounded,
              selectedIndex),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("v1.0.0 - Faculty Pro",
                style: TextStyle(color: Colors.grey, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, int index, String title,
      IconData icon, int selectedIndex) {
    final isSelected = selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.indigo : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
            color: isSelected ? Colors.indigo : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      ),
      selected: isSelected,
      onTap: () {
        if (!isSelected) {
          context.read<AdminProvider>().setTab(index);
        }
        Navigator.of(context).pop();
      },
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderPage({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const Text("Content implementation in progress",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
