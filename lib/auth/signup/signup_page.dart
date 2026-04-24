import 'package:graduway/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/theme/app_theme.dart';
import 'package:graduway/alumni/shared/widgets/main_layout.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/student/shared/widgets/student_main_layout.dart';
import 'package:graduway/models/user_role.dart' as shared_role;

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _collegeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _signup() {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String college = _collegeController.text.trim();
    
    if (username.isEmpty || email.isEmpty || college.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields"))
      );
      return;
    }

    final auth = legacy_provider.Provider.of<AuthProvider>(context, listen: false);
    auth.enableSignupMode(email);
    auth.updateProfile(
      name: username,
      collegeName: college,
    );

    // SYNC: Update Riverpod authProvider
    final riverpodAuth = ref.read(authProvider.notifier);
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

    // GoRouter will handle the redirection automatically now that isLoggedIn is true
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Join Alumni Connect",
                    textAlign: TextAlign.center,
                    style: textTheme.displayLarge,
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                  const SizedBox(height: 12),
                  Text(
                    "Create your account in seconds",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  const SizedBox(height: 48),
                  _buildTextField(
                    controller: _usernameController,
                    hintText: "Username",
                    icon: Icons.person_outline_rounded,
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    hintText: "Email Address",
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _collegeController,
                    hintText: "College Name",
                    icon: Icons.school_outlined,
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),
                  const SizedBox(height: 40),
                  Container(
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
                      onPressed: _signup,
                      child: const Text("Create Account"),
                    ),
                  ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.95, 0.95)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?", style: textTheme.bodyMedium),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
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

