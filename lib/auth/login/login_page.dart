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

  Future<void> _login() async {
    final auth = legacy_provider.Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(_emailController.text, _passwordController.text);

    if (success && mounted) {
      // SYNC: Update Riverpod authProvider so the router knows we are logged in
      final riverpodAuth = ref.read(authProvider.notifier);
      final email = _emailController.text;
      
      if (auth.role == shared_role.UserRole.admin) {
        riverpodAuth.loginAsAdmin(email: email);
        if (mounted) context.go('/admin-home');
      } else if (auth.role == shared_role.UserRole.mentor || auth.role == shared_role.UserRole.alumni) {
        riverpodAuth.loginAsAlumni(email: email);
        if (mounted) context.go('/alumni-home');
      } else {
        riverpodAuth.loginAsStudent(email: email);
        if (mounted) context.go('/home');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome back, ${auth.userName}!"),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      // The router will now automatically redirect because isLoggedIn became true
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
                  const SizedBox(height: 60),
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.school_rounded, size: 50, color: Colors.white),
                    ).animate()
                      .fadeIn(duration: 800.ms)
                      .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Welcome Back",
                    textAlign: TextAlign.center,
                    style: textTheme.displayLarge,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                  const SizedBox(height: 12),
                  Text(
                    "Join the elite network of alumni and mentors",
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
                          child: const Text("Login"),
                        ),
                      ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.95, 0.95)),
                  const SizedBox(height: 16),
                  if (!auth.isLoading)
                    OutlinedButton(
                      onPressed: () async {
                        // For Guest/Demo, we assume Student role if no domain is matched
                        await auth.login(_emailController.text, "guest", allowDemoFallback: true);
                        if (mounted) _login(); // Re-trigger the sync logic
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: const Text("Continue as Guest"),
                    ).animate().fadeIn(delay: 800.ms),
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
                  const SizedBox(height: 20),
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
}

