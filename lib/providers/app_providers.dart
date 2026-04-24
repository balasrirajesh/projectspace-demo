import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduway/data/models/alumni_model.dart';
import 'package:graduway/data/models/models.dart';
import 'package:graduway/data/models/student_model.dart';
import 'package:graduway/data/mock/alumni_data.dart';
import 'package:graduway/data/mock/placement_data.dart';
import 'package:graduway/models/user_role.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth State
// ─────────────────────────────────────────────────────────────────────────────

class AuthState {
  final UserRole role;
  final bool isLoggedIn;
  final StudentModel? student;
  final AlumniModel? alumni;

  /// The email the user typed at login
  final String loginEmail;

  /// Name derived from email (part before @), or updated via Edit Profile
  final String loginName;

  /// Bio set via Edit Profile
  final String bio;

  const AuthState({
    this.role = UserRole.guest,
    this.isLoggedIn = false,
    this.student,
    this.alumni,
    this.loginEmail = '',
    this.loginName = '',
    this.bio = '',
  });

  AuthState copyWith({
    UserRole? role,
    bool? isLoggedIn,
    StudentModel? student,
    AlumniModel? alumni,
    String? loginEmail,
    String? loginName,
    String? bio,
  }) {
    return AuthState(
      role: role ?? this.role,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      student: student ?? this.student,
      alumni: alumni ?? this.alumni,
      loginEmail: loginEmail ?? this.loginEmail,
      loginName: loginName ?? this.loginName,
      bio: bio ?? this.bio,
    );
  }
}

/// Extracts the part before @ from an email, capitalised nicely.
String _nameFromEmail(String email) {
  final local = email.split('@').first;
  // Replace dots/underscores/digits with spaces, then title-case each word
  final words = local.replaceAll(RegExp(r'[._\-]+'), ' ').split(' ');
  return words.map((w) {
    if (w.isEmpty) return '';
    return w[0].toUpperCase() + w.substring(1);
  }).join(' ');
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void loginAsStudent({required String email}) {
    final name = _nameFromEmail(email);
    state = AuthState(
      role: UserRole.student,
      isLoggedIn: true,
      loginEmail: email,
      loginName: name,
      student: StudentModel(
        id: 's_current',
        name: name,
        email: email,
        branch: 'CSE',
        year: 3,
        targetCareer: '',
        skills: const [],
        careerScore: 0,
        earnedBadges: const [],
        questionsAsked: 0,
        mentorSessionsAttended: 0,
        photoUrl: 'https://i.pravatar.cc/150?img=52',
        rollNumber: '21K81A0512',
      ),
    );
  }

  void loginAsAlumni({required String email}) {
    final name = _nameFromEmail(email);
    final loggedInAlumni = mockAlumni.first;
    state = AuthState(
      role: UserRole.alumni,
      isLoggedIn: true,
      loginEmail: email,
      loginName: name,
      alumni: loggedInAlumni,
    );
  }

  void loginAsAdmin({required String email}) {
    final name = _nameFromEmail(email);
    state = AuthState(
      role: UserRole.admin,
      isLoggedIn: true,
      loginEmail: email,
      loginName: name,
    );
  }

  /// Save name and bio edits from the Edit Profile sheet (works for all roles).
  void updateUserProfile({required String name, required String bio}) {
    state = state.copyWith(loginName: name, bio: bio);
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Student Live State — real progress tracking
// ─────────────────────────────────────────────────────────────────────────────

class StudentProgressState {
  final int questionsAsked;
  final int eventsAttended;
  final int mentorSessions;
  final int alumniProfilesViewed;
  final List<String> viewedAlumniIds;
  final List<String> earnedBadgeIds;
  final List<_BadgeNotification> pendingNotifications;
  final String? localPhotoPath; // profile photo from device
  final String displayName;
  final String bio;
  final String targetCareer;

  const StudentProgressState({
    this.questionsAsked = 0,
    this.eventsAttended = 0,
    this.mentorSessions = 0,
    this.alumniProfilesViewed = 0,
    this.viewedAlumniIds = const [],
    this.earnedBadgeIds = const [],
    this.pendingNotifications = const [],
    this.localPhotoPath,
    this.displayName = 'Arjun Reddy',
    this.bio = '',
    this.targetCareer = '',
  });

  int get careerScore {
    final base = (questionsAsked * 5) +
        (eventsAttended * 10) +
        (mentorSessions * 15) +
        (earnedBadgeIds.length * 8);
    return base.clamp(0, 100);
  }

  StudentProgressState copyWith({
    int? questionsAsked,
    int? eventsAttended,
    int? mentorSessions,
    int? alumniProfilesViewed,
    List<String>? viewedAlumniIds,
    List<String>? earnedBadgeIds,
    List<_BadgeNotification>? pendingNotifications,
    String? localPhotoPath,
    String? displayName,
    String? bio,
    String? targetCareer,
    bool clearPhoto = false,
  }) {
    return StudentProgressState(
      questionsAsked: questionsAsked ?? this.questionsAsked,
      eventsAttended: eventsAttended ?? this.eventsAttended,
      mentorSessions: mentorSessions ?? this.mentorSessions,
      alumniProfilesViewed: alumniProfilesViewed ?? this.alumniProfilesViewed,
      viewedAlumniIds: viewedAlumniIds ?? this.viewedAlumniIds,
      earnedBadgeIds: earnedBadgeIds ?? this.earnedBadgeIds,
      pendingNotifications: pendingNotifications ?? this.pendingNotifications,
      localPhotoPath:
          clearPhoto ? null : (localPhotoPath ?? this.localPhotoPath),
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      targetCareer: targetCareer ?? this.targetCareer,
    );
  }
}

class _BadgeNotification {
  final String badgeId;
  final String title;
  final String emoji;
  const _BadgeNotification(this.badgeId, this.title, this.emoji);
}

class StudentProgressNotifier extends StateNotifier<StudentProgressState> {
  StudentProgressNotifier() : super(const StudentProgressState());

  /// Call after student posts a question
  void incrementQuestionsAsked() {
    final newCount = state.questionsAsked + 1;
    var newState = state.copyWith(questionsAsked: newCount);
    // Award badge: first question
    if (newCount == 1)
      newState = _awardBadge(newState, 'b002', 'Curious Mind', '❓');
    // Award badge: 5 questions
    if (newCount == 5)
      newState = _awardBadge(newState, 'b008', 'Community Hero', '💬');
    state = newState;
  }

  /// Call when student RSVPs to an event
  void attendEvent() {
    final newCount = state.eventsAttended + 1;
    var newState = state.copyWith(eventsAttended: newCount);
    if (newCount == 1)
      newState = _awardBadge(newState, 'b004', 'Event Goer', '🎓');
    state = newState;
  }

  /// Call when student views an alumni profile
  void trackAlumniView(String alumniId) {
    if (state.viewedAlumniIds.contains(alumniId)) return; // already counted
    final newIds = [...state.viewedAlumniIds, alumniId];
    var newState = state.copyWith(
      alumniProfilesViewed: newIds.length,
      viewedAlumniIds: newIds,
    );
    if (newIds.length == 1)
      newState = _awardBadge(newState, 'b001', 'First Connect', '🤝');
    if (newIds.length == 5)
      newState = _awardBadge(newState, 'b007', 'Network Builder', '🌐');
    state = newState;
  }

  /// Call when student picks a career goal on roadmap
  void setTargetCareer(String career) {
    var newState = state.copyWith(targetCareer: career);
    if (!state.earnedBadgeIds.contains('b003')) {
      newState = _awardBadge(newState, 'b003', 'Skill Seeker', '🎯');
    }
    state = newState;
  }

  /// Call after profile score crosses 50
  void checkPlacementReady() {
    if (state.careerScore >= 50 && !state.earnedBadgeIds.contains('b010')) {
      state = _awardBadge(state, 'b010', 'Placement Ready', '🚀');
    }
  }

  void updateProfile(String name, String bio) {
    state = state.copyWith(displayName: name, bio: bio);
    if (name.isNotEmpty &&
        bio.isNotEmpty &&
        !state.earnedBadgeIds.contains('b009')) {
      state = _awardBadge(state, 'b009', 'Goal Setter', '🏁');
    }
  }

  void updateProfilePhoto(String? path) {
    if (path == null) {
      state = state.copyWith(clearPhoto: true);
    } else {
      state = state.copyWith(localPhotoPath: path);
    }
  }

  void clearNotification(String badgeId) {
    state = state.copyWith(
      pendingNotifications: state.pendingNotifications
          .where((n) => n.badgeId != badgeId)
          .toList(),
    );
  }

  StudentProgressState _awardBadge(
      StudentProgressState s, String id, String title, String emoji) {
    if (s.earnedBadgeIds.contains(id)) return s;
    return s.copyWith(
      earnedBadgeIds: [...s.earnedBadgeIds, id],
      pendingNotifications: [
        ...s.pendingNotifications,
        _BadgeNotification(id, title, emoji)
      ],
    );
  }
}

final studentProgressProvider =
    StateNotifierProvider<StudentProgressNotifier, StudentProgressState>(
  (ref) => StudentProgressNotifier(),
);

// Convenience derived
final careerScoreProvider =
    Provider<int>((ref) => ref.watch(studentProgressProvider).careerScore);

// ─────────────────────────────────────────────────────────────────────────────
// Shared Q&A State
// ─────────────────────────────────────────────────────────────────────────────

class QANotifier extends StateNotifier<List<QAModel>> {
  QANotifier() : super(mockQA);

  void addQuestion(QAModel question) {
    state = [question, ...state];
  }

  void upvoteQuestion(String questionId) {
    state = state.map((q) {
      if (q.id == questionId) {
        return QAModel(
          id: q.id,
          question: q.question,
          askedBy: q.askedBy,
          askedById: q.askedById,
          timestamp: q.timestamp,
          upvotes: q.upvotes + 1,
          tags: q.tags,
          answers: q.answers,
          isAnswered: q.isAnswered,
        );
      }
      return q;
    }).toList();
  }

  void addAnswer(String questionId, QAAnswer answer) {
    state = state.map((q) {
      if (q.id == questionId) {
        return QAModel(
          id: q.id,
          question: q.question,
          askedBy: q.askedBy,
          askedById: q.askedById,
          timestamp: q.timestamp,
          upvotes: q.upvotes,
          tags: q.tags,
          answers: [...q.answers, answer],
          isAnswered: true,
        );
      }
      return q;
    }).toList();
  }
}

final qaProvider = StateNotifierProvider<QANotifier, List<QAModel>>(
  (ref) => QANotifier(),
);

final unansweredQAProvider = Provider<List<QAModel>>((ref) {
  return ref.watch(qaProvider).where((q) => !q.isAnswered).toList();
});

final trendingQAProvider = Provider<List<QAModel>>((ref) {
  final all = ref.watch(qaProvider);
  final sorted = [...all]..sort((a, b) => b.upvotes.compareTo(a.upvotes));
  return sorted.take(5).toList();
});

// ─────────────────────────────────────────────────────────────────────────────
// Alumni Filtering & Search
// ─────────────────────────────────────────────────────────────────────────────

final alumniSearchProvider = StateProvider<String>((ref) => '');
final selectedBranchProvider = StateProvider<String>((ref) => 'All');

final searchedAlumniProvider = Provider<List<AlumniModel>>((ref) {
  final query = ref.watch(alumniSearchProvider).toLowerCase();
  final branch = ref.watch(selectedBranchProvider);
  return mockAlumni.where((a) {
    final matchesBranch = branch == 'All' || a.branch == branch;
    final matchesQuery = query.isEmpty ||
        a.name.toLowerCase().contains(query) ||
        a.company.toLowerCase().contains(query) ||
        a.skills.any((s) => s.toLowerCase().contains(query));
    return matchesBranch && matchesQuery;
  }).toList();
});

// ─────────────────────────────────────────────────────────────────────────────
// Career Goal State (Roadmap)
// ─────────────────────────────────────────────────────────────────────────────

final careerGoalProvider = StateProvider<String>((ref) => '');

// ─────────────────────────────────────────────────────────────────────────────
// Navigation tab index per role
// ─────────────────────────────────────────────────────────────────────────────

final studentNavIndexProvider = StateProvider<int>((ref) => 0);
final alumniNavIndexProvider = StateProvider<int>((ref) => 0);
final adminNavIndexProvider = StateProvider<int>((ref) => 0);

// Global flag to ensure onboarding is only seen once per app session/install
final hasSeenOnboardingProvider = StateProvider<bool>((ref) => false);

