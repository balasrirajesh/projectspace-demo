// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/data/models/alumni_model.dart';
import 'package:graduway/data/models/student_model.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/widgets/custom_app_bar.dart';
import 'package:graduway/data/models/alumni_model.dart';
import 'package:graduway/data/models/student_model.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'User Management',
        showBackButton: false,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.bgCard,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, roll no, or company...',
                prefixIcon: const Icon(Icons.search_rounded),
                fillColor: AppColors.bgPage,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Students'),
              Tab(text: 'Alumni'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _UserListView(role: 'Student'),
                _UserListView(role: 'Alumni'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserListView extends ConsumerWidget {
  final String role;
  const _UserListView({required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = role == 'Student' 
        ? ref.watch(studentListProvider) 
        : ref.watch(alumniListProvider);

    return listAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No users found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final user = items[i];
            String name = '';
            String sub = '';
            
            if (user is StudentModel) {
              name = user.name;
              sub = '${user.rollNumber} • ${user.branch}';
            } else if (user is AlumniModel) {
              name = user.name;
              sub = '${user.company} • ${user.role}';
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(name.isNotEmpty ? name[0] : '?',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  itemBuilder: (context) => [
                    const PopupMenuItem(child: Text('View Profile')),
                    const PopupMenuItem(child: Text('Edit Details')),
                    const PopupMenuItem(child: Text('Reset Password')),
                    const PopupMenuItem(child: Text('Ban User', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: i * 50)).slideY(begin: 0.1);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
