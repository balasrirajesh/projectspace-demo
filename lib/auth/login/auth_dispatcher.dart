import 'package:graduway/models/user_role.dart';
import 'package:graduway/auth/login/login_page.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart'; // import 'package:graduway/alumni/profile/profile_setup_page.dart' as alumni; // import 'package:graduway/student/profile/profile_setup_page.dart' as student;
import 'package:graduway/alumni/shared/widgets/main_layout.dart';
import 'package:graduway/student/shared/widgets/student_main_layout.dart';
import 'package:graduway/admin/dashboard/admin_main_layout.dart';

/// A widget that decides which screen to show based on the current authentication state.
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

        // 2. Direct Admin immediately
        if (auth.role == UserRole.admin) {
          return const AdminMainLayout();
        }

        // 3. Fallback to Dashboard
        return auth.role == UserRole.student
            ? StudentMainLayout()
            : MainLayout();
      },
    );
  }
}
