import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:alumini_screen/src/core/theme/app_theme.dart';
import 'package:alumini_screen/src/features/auth/signup_page.dart';
import 'package:alumini_screen/src/features/dashboard/main_layout.dart';
import 'package:alumini_screen/src/features/dashboard/student_main_layout.dart';
import 'package:provider/provider.dart';
import 'package:alumini_screen/src/shared/providers/auth_provider.dart';
import 'package:alumini_screen/src/core/widgets/server_ip_dialog.dart';

/// A screen that allows users to log into the application.
/// 
/// This screen provides fields for email and password. For this demo,
/// it performs a mock authentication by extracting a name from the email
/// and updating the [AuthProvider] profile before navigating to the [MainLayout].
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailController.text, _passwordController.text);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome back, ${auth.userName}!"),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Widget nextScreen = auth.role == UserRole.student 
          ? const StudentMainLayout() 
          : const MainLayout();

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
            opacity: animation,
            child: nextScreen,
          ),
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
    final auth = context.watch<AuthProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient Pattern
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
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0),
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
                    AppColors.accent.withValues(alpha: 0.1),
                    AppColors.accent.withValues(alpha: 0),
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
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.settings_suggest_outlined),
                      onPressed: () => ServerIpDialog.show(context),
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.5),
                  ),
                  const SizedBox(height: 40),
                  
                  // Brand Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
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
                  
                  // Form Fields
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
                  
                  // Login Button
                  auth.isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
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
                        final success = await auth.login(_emailController.text, "guest", allowDemoFallback: true);
                        if (success && mounted) {
                           Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => 
                              auth.role == UserRole.student ? const StudentMainLayout() : const MainLayout()
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
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

