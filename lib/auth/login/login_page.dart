import 'package:graduway/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/theme/app_theme.dart';
import 'package:graduway/auth/signup/signup_page.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/models/user_role.dart' as shared_role;
import 'package:graduway/alumni/core/widgets/server_ip_dialog.dart';

/// A screen that allows users to log into the application.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = legacy_provider.Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(_emailController.text, _passwordController.text);

    if (success && mounted) {
      final riverpodAuth = ref.read(authProvider.notifier);
      final email = _emailController.text;
      final role = auth.role;

      if (role == shared_role.UserRole.admin) {
        riverpodAuth.loginAsAdmin(email: email);
      } else if (role == shared_role.UserRole.mentor || role == shared_role.UserRole.alumni) {
        riverpodAuth.loginAsAlumni(email: email);
      } else {
        riverpodAuth.loginAsStudent(email: email);
      }

      Future.microtask(() {
        if (!mounted) return;
        if (role == shared_role.UserRole.admin) {
          context.go('/admin-home');
        } else if (role == shared_role.UserRole.mentor || role == shared_role.UserRole.alumni) {
          context.go('/alumni-home');
        } else {
          context.go('/home');
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome back, ${auth.userName}!"),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? "Login failed"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = legacy_provider.Provider.of<AuthProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings_ethernet_rounded, color: AppColors.textMuted),
          onPressed: () => showDialog(context: context, builder: (_) => const ServerIpDialog()),
        ),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.info_outline_rounded, color: AppColors.textMuted),
              onPressed: () {
                if (_overlayEntry == null) {
                  _overlayEntry = _createOverlayEntry(ctx);
                  Overlay.of(ctx).insert(_overlayEntry!);
                } else {
                  _removeOverlay();
                }
              },
            ),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.1),
                    AppColors.accent.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.school_rounded, size: 42, color: Colors.white),
                    ).animate()
                      .fadeIn(duration: 800.ms)
                      .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Welcome to GraduWay",
                    textAlign: TextAlign.center,
                    style: textTheme.displayLarge?.copyWith(fontSize: 26),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                  const SizedBox(height: 12),
                  Text(
                    "Bridging the gap between students and success.",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                  const SizedBox(height: 56),
                  _buildTextField(
                    controller: _emailController,
                    hintText: "Email Address",
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    icon: Icons.lock_person_outlined,
                    obscureText: true,
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text("Forgot Password?"),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 32),
                  auth.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _login,
                          child: const Text("Sign In"),
                        ),
                      ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.95, 0.95)),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("New here?", style: textTheme.bodyMedium),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                        child: const Text("Create Account", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ).animate().fadeIn(delay: 900.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, size: 22),
      ),
    );
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + size.height + 10,
        right: 20,
        width: 280,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: _removeOverlay,
            child: const _CredentialHintCard(),
          ),
        ),
      ),
    );
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _CredentialHintCard extends StatelessWidget {
  const _CredentialHintCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE3FF), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'How to Login',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _HintRow(
            icon: Icons.school_outlined,
            role: 'Student',
            color: AppColors.primary,
            lines: const [
              'Email ending with  @stud.com',
              'e.g.  yourname@stud.com',
              'Password: anything',
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Color(0xFFDDE3FF)),
          _HintRow(
            icon: Icons.work_outline_rounded,
            role: 'Alumni',
            color: AppColors.alumni,
            lines: const [
              'Email ending with  @alum.com',
              'e.g.  yourname@alum.com',
              'Password: anything',
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Color(0xFFDDE3FF)),
          _HintRow(
            icon: Icons.admin_panel_settings_outlined,
            role: 'Admin',
            color: AppColors.admin,
            lines: const [
              'Email ending with  @admin.com',
              'e.g.  yourname@admin.com',
              'Password: anything',
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }
}

class _HintRow extends StatelessWidget {
  final IconData icon;
  final String role;
  final Color color;
  final List<String> lines;

  const _HintRow({
    required this.icon,
    required this.role,
    required this.color,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Login as $role',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              ...lines.map((line) => Text(
                    line,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
