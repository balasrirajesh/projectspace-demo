import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduway/admin/shared/providers/admin_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          return Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildFilterBar(admin),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 40,
                            offset: const Offset(0, 10)),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: admin.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _buildUserTable(admin)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "User Administration",
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B)),
        ).animate().fadeIn().slideX(begin: -0.1),
        Text(
          "Monitor and control member access across the platform",
          style: TextStyle(color: Colors.blueGrey[400], fontSize: 15),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildFilterBar(AdminProvider admin) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => admin.fetchUsers(
                  search: val,
                  role: _selectedRole == 'all' ? null : _selectedRole),
              decoration: InputDecoration(
                hintText: "Search by name, email or college...",
                prefixIcon:
                    const Icon(Icons.search_rounded, color: Colors.indigo),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        _buildRoleFilter(admin),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildRoleFilter(AdminProvider admin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _filterChip("All", 'all', admin),
          _filterChip("Students", 'student', admin),
          _filterChip("Alumni", 'mentor', admin),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value, AdminProvider admin) {
    final isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedRole = value);
        admin.fetchUsers(
            role: value == 'all' ? null : value,
            search: _searchController.text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blueGrey[400],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildUserTable(AdminProvider admin) {
    if (admin.users.isEmpty) {
      return const Center(child: Text("No users found matching filters"));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
        dataRowHeight: 80,
        horizontalMargin: 32,
        columns: const [
          DataColumn(label: Text("USER")),
          DataColumn(label: Text("ROLE")),
          DataColumn(label: Text("COLLEGE")),
          DataColumn(label: Text("STATUS")),
          DataColumn(label: Text("ACTIONS")),
        ],
        rows: admin.users
            .map((user) => _buildUserRow(context, admin, user))
            .toList(),
      ),
    );
  }

  DataRow _buildUserRow(
      BuildContext context, AdminProvider admin, dynamic user) {
    final statusColor = _getStatusColor(user['status'] ?? 'pending');

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.indigo.withOpacity(0.1),
                child: Text(user['name']?[0] ?? '?',
                    style: const TextStyle(
                        color: Colors.indigo, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['name'] ?? 'Unknown',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B))),
                  Text(user['email'] ?? '',
                      style:
                          TextStyle(color: Colors.blueGrey[400], fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: (user['role'] == 'student' ? Colors.blue : Colors.purple)
                  .withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user['role']?.toUpperCase() ?? '',
              style: TextStyle(
                  color:
                      user['role'] == 'student' ? Colors.blue : Colors.purple,
                  fontSize: 10,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ),
        DataCell(Text(user['collegeName'] ?? 'Not Specified',
            style: const TextStyle(fontSize: 13))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user['status']?.toUpperCase() ?? 'PENDING',
              style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                  onPressed: () => _showUserDetail(context, admin, user),
                  icon: const Icon(Icons.edit_note_rounded,
                      color: Colors.blueGrey, size: 20)),
              _buildActionDropdown(admin, user),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'rejected':
      case 'blocked':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildActionDropdown(AdminProvider admin, dynamic user) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_horiz_rounded, color: Colors.blueGrey),
      itemBuilder: (context) => [
        if (user['status'] != 'verified')
          const PopupMenuItem(
              value: 'verified', child: Text("Approve & Verify")),
        const PopupMenuItem(
            value: 'blocked',
            child: Text("Block User", style: TextStyle(color: Colors.red))),
        const PopupMenuItem(value: 'student', child: Text("Set as Student")),
        const PopupMenuItem(value: 'mentor', child: Text("Set as Alumni")),
      ],
      onSelected: (val) => admin.updateUserStatus(user['id'], val.toString()),
    );
  }

  void _showUserDetail(
      BuildContext context, AdminProvider admin, dynamic user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.indigo.withOpacity(0.1),
                  child: Text(user['name']?[0] ?? '?',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo)),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['name'] ?? 'User Profile',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(user['email'] ?? '',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 32),
            const Text("Administrative Controls",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ListTile(
              leading:
                  const Icon(Icons.verified_user_rounded, color: Colors.green),
              title: const Text("Verify Account"),
              subtitle: const Text("Grant full platform access"),
              onTap: () {
                admin.updateUserStatus(user['id'], 'verified');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_flipped, color: Colors.red),
              title: const Text("Restrict Access"),
              subtitle: const Text("Block user from all college rooms"),
              onTap: () {
                admin.updateUserStatus(user['id'], 'blocked');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.swap_horiz_rounded, color: Colors.indigo),
              title: const Text("Toggle Role"),
              subtitle: Text("Current: ${user['role']?.toUpperCase()}"),
              onTap: () {
                final newRole =
                    user['role'] == 'student' ? 'mentor' : 'student';
                admin.updateUserStatus(user['id'],
                    newRole); // We use status update endpoint for role too in this demo
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            Text("User ID: ${user['id']}",
                style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
