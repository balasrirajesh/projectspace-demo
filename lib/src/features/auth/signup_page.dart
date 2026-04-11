import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:alumini_screen/src/core/theme/app_theme.dart';
import 'package:alumini_screen/src/features/dashboard/main_layout.dart';
import 'package:provider/provider.dart';
import 'package:alumini_screen/src/shared/providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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

    // Step 1: Initial Signup
    context.read<AuthProvider>().updateProfile(
      name: username,
      collegeName: college,
    );

    // Initial status is automatically set to 'incomplete' in AuthProvider
    
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: const MainLayout(),
        ),
      ),
      (Route<dynamic> route) => false,
    );
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
                          color: AppColors.primary.withValues(alpha: 0.2),
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

