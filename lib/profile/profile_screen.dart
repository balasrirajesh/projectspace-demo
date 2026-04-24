import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduway/models/user_role.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/widgets/custom_app_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final progress = ref.watch(studentProgressProvider);
    final isStudent = authState.role == UserRole.student;
    final isAlumni = authState.role == UserRole.alumni;

    // Always use the email and name from what the user typed at login
    final name = authState.loginName.isNotEmpty
        ? authState.loginName
        : (isStudent ? (progress.displayName.isNotEmpty ? progress.displayName : 'User') : 'User');
    final email = authState.loginEmail.isNotEmpty ? authState.loginEmail : 'user@email.com';
    final photoUrl = isStudent ? authState.student?.photoUrl : (isAlumni ? authState.alumni?.photoUrl : null);
    final localPhotoPath = isStudent ? progress.localPhotoPath : null;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profile',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: const BoxDecoration(
                color: AppColors.bgCard,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  // Avatar with camera overlay
                  GestureDetector(
                    onTap: isStudent ? () => _showPhotoOptions(context, ref) : null,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          backgroundImage: localPhotoPath != null
                              ? FileImage(File(localPhotoPath)) as ImageProvider
                              : (photoUrl != null ? NetworkImage(photoUrl) : null),
                          child: (localPhotoPath == null && photoUrl == null)
                              ? const Icon(Icons.person_rounded, size: 50, color: AppColors.primary)
                              : null,
                        ).animate().scale(curve: Curves.elasticOut),
                        if (isStudent)
                          Positioned(
                            right: 0, bottom: 0,
                            child: Container(
                              width: 28, height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _RoleBadge(role: authState.role),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _ProfileSettingTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profile',
                    onTap: () => _showEditProfileSheet(context, ref, name, authState.bio),
                  ),
                  _ProfileSettingTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () => _showNotificationsSheet(context),
                  ),
                  _ProfileSettingTile(
                    icon: Icons.security_outlined,
                    title: 'Account Security',
                    onTap: () => _showSecuritySheet(context),
                  ),
                  _ProfileSettingTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    onTap: () => _showHelpSheet(context),
                  ),
                  const SizedBox(height: 24),
                  _ProfileSettingTile(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    color: AppColors.error,
                    onTap: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const Text('Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              ),
              title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (file != null) {
                  ref.read(studentProgressProvider.notifier).updateProfilePhoto(file.path);
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.secondary),
              ),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (file != null) {
                  ref.read(studentProgressProvider.notifier).updateProfilePhoto(file.path);
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.delete_rounded, color: AppColors.error),
              ),
              title: const Text('Remove Photo', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error)),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(studentProgressProvider.notifier).updateProfilePhoto(null);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, WidgetRef ref, String? currentName, String currentBio) {
    final nameCtrl = TextEditingController(text: currentName ?? '');
    final bioCtrl = TextEditingController(text: currentBio.isNotEmpty ? currentBio : 'Passionate about tech and learning 🚀');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
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
                  const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  fillColor: AppColors.bgPage,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: bioCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                  fillColor: AppColors.bgPage,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final newName = nameCtrl.text.trim();
                  final newBio = bioCtrl.text.trim();
                  if (newName.isNotEmpty) {
                    // Persist the updated name and bio for all roles
                    ref.read(authProvider.notifier).updateUserProfile(
                      name: newName,
                      bio: newBio,
                    );
                    // Also update studentProgressProvider for backward compat
                    ref.read(studentProgressProvider.notifier).updateProfile(newName, newBio);
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Profile updated successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    final notifs = [
      _NotifItem(icon: Icons.chat_bubble_rounded, color: AppColors.primary, title: 'Ravi Kumar answered your question', sub: 'Check out insights on FAANG prep!', time: '2h ago'),
      _NotifItem(icon: Icons.event_rounded, color: AppColors.secondary, title: 'Webinar tomorrow at 6 PM', sub: 'System Design with Priya Lakshmi — WebDev track', time: '5h ago'),
      _NotifItem(icon: Icons.emoji_events_rounded, color: AppColors.accent, title: 'New Badge Earned! 🏆', sub: 'You earned "First Question Asked"', time: 'Yesterday'),
      _NotifItem(icon: Icons.people_rounded, color: AppColors.alumni, title: 'Alumni Ajay started following your progress', sub: 'He\'s available for mentorship!', time: '2 days ago'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: ctrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: notifs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final n = notifs[i];
                    return ListTile(
                      leading: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: n.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                        child: Icon(n.icon, color: n.color, size: 22),
                      ),
                      title: Text(n.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text(n.sub, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      trailing: Text(n.time, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSecuritySheet(BuildContext context) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
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
                  const Text('Change Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 20),
              _PasswordField(controller: oldCtrl, label: 'Current Password'),
              const SizedBox(height: 14),
              _PasswordField(controller: newCtrl, label: 'New Password'),
              const SizedBox(height: 14),
              _PasswordField(controller: confirmCtrl, label: 'Confirm New Password'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🔐 Password changed successfully!'), backgroundColor: AppColors.success),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Change Password', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpSheet(BuildContext context) {
    final faqs = [
      ['How do I ask a question?', 'Go to the Q&A tab and tap the "Ask Question" button at the bottom right. Fill in your question and select relevant tags.'],
      ['How are alumni verified?', 'Alumni submit their offer letter and employee ID. Our admin team manually verifies each profile within 48 hours.'],
      ['Can I book a 1-on-1 session?', 'Select any alumni profile and tap "Ask a Question". Alumni who accept mentorship will schedule a call through the platform.'],
      ['How is my Career Score calculated?', 'It factors in Q&A participation, events attended, mentorship sessions, and roadmap progress.'],
      ['How do I report incorrect info?', 'Tap the "..." menu on any profile or post and select "Report". Our team reviews all reports within 24 hours.'],
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Help & FAQ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: ctrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: faqs.length,
                  itemBuilder: (_, i) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ExpansionTile(
                      title: Text(faqs[i][0], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        Text(faqs[i][1], style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final Color color;
  final String title, sub, time;
  const _NotifItem({required this.icon, required this.color, required this.title, required this.sub, required this.time});
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  const _PasswordField({required this.controller, required this.label});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        fillColor: AppColors.bgPage,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final color = role == UserRole.student
        ? AppColors.primary
        : (role == UserRole.alumni ? AppColors.alumni : AppColors.admin);
    final label = role.name.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }
}

class _ProfileSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const _ProfileSettingTile({
    required this.icon,
    required this.title,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color ?? AppColors.textPrimary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: color?.withOpacity(0.5) ?? AppColors.textMuted),
      ),
    );
  }
}

