import 'package:graduway/alumni/shared/providers/auth_provider.dart';
// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduway/models/user_role.dart';
import 'package:graduway/auth/splash/splash_screen.dart';
import 'package:graduway/auth/onboarding/onboarding_screen.dart';
import 'package:graduway/auth/login/login_page.dart';
import 'package:graduway/auth/signup/signup_page.dart';
import 'package:graduway/student/home/home_screen.dart';
import 'package:graduway/alumni/alumni_list_screen.dart';
import 'package:graduway/alumni/alumni_profile_screen.dart';
import 'package:graduway/student/qa/qa_screen.dart';
import 'package:graduway/student/roadmap/roadmap_screen.dart';
import 'package:graduway/student/placement/placement_reality_screen.dart';
import 'package:graduway/student/skill_package/skill_package_screen.dart';
import 'package:graduway/student/events/events_screen.dart';
import 'package:graduway/student/gamification/badges_screen.dart';
import 'package:graduway/profile/profile_screen.dart';
import 'package:graduway/routing/shells/student_shell.dart';
import 'package:graduway/routing/shells/alumni_shell.dart';
import 'package:graduway/routing/shells/admin_shell.dart';
import 'package:graduway/alumni/dashboard/alumni_home_screen.dart';
import 'package:graduway/alumni/dashboard/student_questions_screen.dart';
import 'package:graduway/admin/admin_overview_screen.dart';
import 'package:graduway/admin/admin_users_screen.dart';
import 'package:graduway/providers/app_providers.dart';

// Rajesh Feature Imports
import 'package:graduway/widgets/interactive_classroom_page.dart';
import 'package:graduway/student/mentorship/sessions_page.dart';
import 'package:graduway/student/profile/mentorship_page.dart';
import 'package:graduway/alumni/mentorship/alumni_requests_page.dart' as alumni_requests;
import 'package:graduway/alumni/chat/mentor_inbox_page.dart' as alumni_chat;
import 'package:graduway/alumni/profile/profile_page.dart' as rajesh_alumni_profile;
import 'package:graduway/admin/dashboard/admin_main_layout.dart';
import 'package:graduway/admin/sessions/session_control_page.dart';
import 'package:graduway/admin/connections/connection_monitor_page.dart';
import 'package:graduway/admin/announcements/announcements_page.dart';
import 'package:graduway/admin/users/user_management_page.dart';

// Routes that do NOT require login
const _publicRoutes = ['/splash', '/onboarding', '/login'];

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final hasSeenOnboarding = ref.read(hasSeenOnboardingProvider);
      final isPublic =
          _publicRoutes.any((r) => state.matchedLocation.startsWith(r));

      // 1. If not logged in and not on a public route, go to splash or login
      if (!isLoggedIn && !isPublic) return '/login';

      // 2. If trying to go to onboarding but already seen it, go to login
      if (state.matchedLocation == '/onboarding' && hasSeenOnboarding) {
        return isLoggedIn ? null : '/login';
      }

      // 3. If logged in and on login/onboarding, go to role-specific home
      if (isLoggedIn &&
          (state.matchedLocation == '/login' ||
              state.matchedLocation == '/onboarding')) {
        if (authState.role == UserRole.student) return '/home';
        if (authState.role == UserRole.alumni || authState.role == UserRole.mentor) return '/alumni-home';
        if (authState.role == UserRole.admin) return '/admin-home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

      // ─── Student Shell ──────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => StudentShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/qa', builder: (_, __) => const QAScreen()),
          GoRoute(
              path: '/mentorship',
              builder: (_, __) => const MentorshipPage()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Student Top-Level Routes (Pushed from Dashboard cards)
      GoRoute(path: '/alumni', builder: (_, __) => const AlumniListScreen()),
      GoRoute(path: '/roadmap', builder: (_, __) => const RoadmapScreen()),
      GoRoute(path: '/badges', builder: (_, __) => const BadgesScreen()),
      GoRoute(path: '/sessions', builder: (_, __) => const SessionsPage()),
      GoRoute(path: '/classroom', builder: (_, __) => const SessionsPage()),

      // Interactive Classroom
      GoRoute(
        path: '/classroom/:id',
        builder: (context, state) => InteractiveClassroomPage(
          roomId: state.pathParameters['id']!,
        ),
      ),

      // ─── Alumni Shell ───────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AlumniShell(child: child),
        routes: [
          GoRoute(
              path: '/alumni-home',
              builder: (_, __) => const AlumniHomeScreen()),
          GoRoute(
              path: '/alumni-chat',
              builder: (_, __) => const alumni_chat.MentorInboxPage()),
          GoRoute(
              path: '/alumni-requests',
              builder: (_, __) => const alumni_requests.AlumniRequestsPage()),
          GoRoute(
              path: '/alumni-profile',
              builder: (_, __) => const rajesh_alumni_profile.ProfileScreen()),
        ],
      ),

      // Alumni Top-Level Routes
      GoRoute(
          path: '/alumni-questions',
          builder: (_, __) => const StudentQuestionsScreen()),
      GoRoute(
          path: '/alumni-sessions',
          builder: (_, __) => const SessionsPage()),
      GoRoute(
          path: '/alumni-mentorship',
          builder: (_, __) => const MentorshipPage()),

      // ─── Admin Shell (NagaSai bottom-nav + Rajesh drawer pages) ──────────
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          // NagaSai routes
          GoRoute(
              path: '/admin-home',
              builder: (_, __) => const AdminOverviewScreen()),
          GoRoute(
              path: '/admin-users',
              builder: (_, __) => const AdminUsersScreen()),
          GoRoute(
              path: '/admin-profile',
              builder: (_, __) => const ProfileScreen()),

          // Rajesh routes (accessible from drawer)
          GoRoute(
              path: '/admin-sessions',
              builder: (_, __) => const SessionControlPage()),
          GoRoute(
              path: '/admin-connections',
              builder: (_, __) => const ConnectionMonitorPage()),
          GoRoute(
              path: '/admin-announcements',
              builder: (_, __) => const AnnouncementsPage()),
          GoRoute(
              path: '/admin-user-management',
              builder: (_, __) => const UserManagementPage()),
        ],
      ),

      // ─── Sub-screens (accessible by all/specific roles) ───────────────
      GoRoute(
        path: '/alumni/:id',
        builder: (context, state) {
          final alumniId = state.pathParameters['id']!;
          return AlumniProfileScreen(alumniId: alumniId);
        },
      ),
      GoRoute(path: '/events', builder: (_, __) => const EventsScreen()),
      GoRoute(
          path: '/placement',
          builder: (_, __) => const PlacementRealityScreen()),
      GoRoute(
          path: '/skill-package',
          builder: (_, __) => const SkillPackageScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),

      // ─── Fullscreen session routes (no shell / no navbar) ─────────────
      GoRoute(
        path: '/classroom/:roomId',
        builder: (context, state) => InteractiveClassroomPage(
          roomId: state.pathParameters['roomId'] ?? 'lobby',
        ),
      ),
      GoRoute(
        path: '/alumni-classroom/:roomId',
        builder: (context, state) => InteractiveClassroomPage(
          roomId: state.pathParameters['roomId'] ?? 'lobby',
        ),
      ),
    ],
  );
});

