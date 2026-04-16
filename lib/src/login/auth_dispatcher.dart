import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alumini_screen/src/alumni/shared/providers/auth_provider.dart';
import 'package:alumini_screen/src/login/login_page.dart';
import 'package:alumini_screen/src/alumni/profile/profile_setup_page.dart' as alumni;
import 'package:alumini_screen/src/student/profile/profile_setup_page.dart' as student;
import 'package:alumini_screen/src/alumni/shared/widgets/main_layout.dart';
import 'package:alumini_screen/src/student/shared/widgets/student_main_layout.dart';
import 'package:alumini_screen/src/admin/dashboard/admin_main_layout.dart';

/// A widget that decides which screen to show based on the current authentication state.
/// 
/// It handles:
/// 1. Not Authenticated -> LoginScreen
/// 2. Profile Incomplete -> ProfileSetupPage (Role-specific)
/// 3. Authenticated & Complete -> MainLayout (Role-specific)
class AuthDispatcher extends StatelessWidget {
  const AuthDispatcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // 1. Check Authentication
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }

        // 2. Direct Admin immediately (Bypass all setup)
        if (auth.role == UserRole.admin) {
          return const AdminMainLayout();
        }

        // 3. Check Profile Setup (ONLY if we are in signup/force mode)
        if (auth.forceSetup && auth.status == UserStatus.incomplete) {
          return auth.role == UserRole.student 
              ? const student.ProfileSetupPage() 
              : const alumni.ProfileSetupPage();
        }

        // 4. Fallback to Dashboard
        return auth.role == UserRole.student 
            ? StudentMainLayout() 
            : MainLayout();
      },
    );
  }
}
