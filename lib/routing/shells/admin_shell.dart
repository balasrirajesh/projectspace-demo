import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/admin/shared/providers/admin_provider.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(adminNavIndexProvider);

    // ── NagaSai bottom-nav tabs ──────────────────────────────────────────
    final tabs = [
      _NavTab(icon: Icons.analytics_rounded,        label: 'Overview',      path: '/admin-home'),
      _NavTab(icon: Icons.manage_accounts_rounded,  label: 'Users',         path: '/admin-user-management'),
      _NavTab(icon: Icons.sensors_rounded,          label: 'Sessions',      path: '/admin-sessions'),
      _NavTab(icon: Icons.campaign_rounded,         label: 'Announce',      path: '/admin-announcements'),
      _NavTab(icon: Icons.hub_rounded,              label: 'Connections',   path: '/admin-connections'),
    ];

    return Scaffold(
      // ── Rajesh: side drawer ────────────────────────────────────────────
      drawer: Drawer(
        child: legacy.Consumer<AdminProvider>(
          builder: (ctx, admin, _) => Column(
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
                      const Text('Admin Console',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        legacy.Provider.of<AuthProvider>(ctx, listen: false).collegeName,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              _DrawerItem(
                icon: Icons.analytics_rounded,
                label: 'Overview',
                path: '/admin-home',
                index: 0,
                currentIndex: currentIndex,
                ref: ref,
              ),
              _DrawerItem(
                icon: Icons.manage_accounts_rounded,
                label: 'User Management',
                path: '/admin-user-management',
                index: 1,
                currentIndex: currentIndex,
                ref: ref,
              ),
              _DrawerItem(
                icon: Icons.sensors_rounded,
                label: 'Live Sessions',
                path: '/admin-sessions',
                index: 2,
                currentIndex: currentIndex,
                ref: ref,
              ),
              _DrawerItem(
                icon: Icons.campaign_rounded,
                label: 'Announcements',
                path: '/admin-announcements',
                index: 3,
                currentIndex: currentIndex,
                ref: ref,
              ),
              _DrawerItem(
                icon: Icons.hub_rounded,
                label: 'Connection Monitor',
                path: '/admin-connections',
                index: 4,
                currentIndex: currentIndex,
                ref: ref,
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('v1.0.0 · GraduWay Admin Pro',
                    style: TextStyle(color: Colors.grey, fontSize: 10)),
              ),
            ],
          ),
        ),
      ),

      body: child,

      // ── NagaSai: bottom navigation bar ────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.admin.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(tabs.length, (i) {
                final isSelected = currentIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(adminNavIndexProvider.notifier).state = i;
                      context.go(tabs[i].path);
                    },
                    child: AnimatedContainer(
                      duration: 250.ms,
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tabs[i].icon,
                            size: isSelected ? 24 : 22,
                            color: isSelected ? AppColors.admin : AppColors.textMuted,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tabs[i].label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.admin : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final String label, path;
  const _NavTab({required this.icon, required this.label, required this.path});
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label, path;
  final int index, currentIndex;
  final WidgetRef ref;
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.index,
    required this.currentIndex,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.indigo : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.indigo : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.indigo.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        ref.read(adminNavIndexProvider.notifier).state = index;
        Navigator.of(context).pop(); // close drawer
        context.go(path);
      },
    );
  }
}
