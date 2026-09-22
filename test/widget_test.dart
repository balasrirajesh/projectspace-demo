import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graduway/models/user_role.dart';
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/data/repositories/mock_data_repository.dart';
import 'package:graduway/widgets/custom_app_bar.dart';

void main() {
  group('AuthNotifier Tests', () {
    test('initial state is unauthenticated guest', () {
      final notifier = AuthNotifier();
      expect(notifier.state.isLoggedIn, false);
      expect(notifier.state.role, UserRole.guest);
    });

    test('loginAsStudent sets correct state', () {
      final notifier = AuthNotifier();
      notifier.loginAsStudent(email: 'john.doe@stud.com');
      expect(notifier.state.isLoggedIn, true);
      expect(notifier.state.role, UserRole.student);
      expect(notifier.state.loginEmail, 'john.doe@stud.com');
      expect(notifier.state.loginName, 'John Doe');
      expect(notifier.state.student, isNotNull);
      expect(notifier.state.student?.name, 'John Doe');
    });

    test('loginAsAlumni sets mentor role', () {
      final notifier = AuthNotifier();
      notifier.loginAsAlumni(email: 'jane.smith@alumni.com');
      expect(notifier.state.isLoggedIn, true);
      expect(notifier.state.role, UserRole.mentor);
      expect(notifier.state.alumni, isNotNull);
      expect(notifier.state.alumni?.email, 'jane.smith@alumni.com');
    });

    test('loginAsAdmin sets admin role', () {
      final notifier = AuthNotifier();
      notifier.loginAsAdmin(email: 'admin@admin.com');
      expect(notifier.state.isLoggedIn, true);
      expect(notifier.state.role, UserRole.admin);
      expect(notifier.state.loginName, 'Admin');
    });

    test('logout resets state', () {
      final notifier = AuthNotifier();
      notifier.loginAsStudent(email: 'test@stud.com');
      notifier.logout();
      expect(notifier.state.isLoggedIn, false);
      expect(notifier.state.role, UserRole.guest);
    });
  });

  group('StudentProgressNotifier Tests', () {
    test('careerScore calculates correctly with events and questions', () {
      final notifier = StudentProgressNotifier();
      expect(notifier.state.careerScore, 0);

      notifier.incrementQuestionsAsked();
      expect(notifier.state.questionsAsked, 1);
      expect(notifier.state.earnedBadgeIds.contains('b002'), true);

      notifier.attendEvent();
      expect(notifier.state.eventsAttended, 1);
      expect(notifier.state.earnedBadgeIds.contains('b004'), true);

      notifier.trackAlumniView('ALU-001');
      expect(notifier.state.alumniProfilesViewed, 1);
      expect(notifier.state.earnedBadgeIds.contains('b001'), true);

      // Score: 1*5 + 1*10 + 0*15 + 3*8 = 39
      expect(notifier.state.careerScore, 39);
    });
  });

  group('MockDataRepository Tests', () {
    test('getAlumni returns non-empty list of alumni', () {
      final alumni = MockDataRepository.getAlumni();
      expect(alumni.isNotEmpty, true);
      expect(alumni.first.name.isNotEmpty, true);
    });

    test('getStudents returns valid student profiles', () {
      final students = MockDataRepository.getStudents();
      expect(students.isNotEmpty, true);
      expect(students.first.branch.isNotEmpty, true);
    });

    test('getQA returns community questions with tags', () {
      final qas = MockDataRepository.getQA();
      expect(qas.isNotEmpty, true);
      expect(qas.first.tags.isNotEmpty, true);
    });
  });

  group('Widget Tests', () {
    testWidgets('CustomAppBar renders title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              title: 'GraduWay Portal',
              showBackButton: false,
            ),
          ),
        ),
      );

      expect(find.text('GraduWay Portal'), findsOneWidget);
    });
  });
}
