import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/widgets/custom_app_bar.dart';
import 'package:graduway/data/models/models.dart';

class StudentQuestionsScreen extends ConsumerStatefulWidget {
  const StudentQuestionsScreen({super.key});

  @override
  ConsumerState<StudentQuestionsScreen> createState() => _StudentQuestionsScreenState();
}

class _StudentQuestionsScreenState extends ConsumerState<StudentQuestionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allQuestionsAsync = ref.watch(qaProvider);
    final alumni = ref.watch(authProvider).alumni;
    
    return allQuestionsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (allQuestions) {
        final unanswered = allQuestions.where((q) => !q.isAnswered).toList();
        final myAnswers = allQuestions.where((q) => q.answers.any((a) => a.alumniId == alumni?.id)).toList();

        return Scaffold(
          appBar: CustomAppBar(
            title: 'Student Questions',
            showBackButton: false,
          ),
          body: Column(
            children: [
              Container(
                color: AppColors.bgCard,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.alumni,
                  unselectedLabelColor: AppColors.textMuted,
                  indicatorColor: AppColors.alumni,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'Unanswered'),
                    Tab(text: 'My Answers'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _QuestionList(questions: unanswered, isUnansweredTab: true),
                    _QuestionList(questions: myAnswers, isUnansweredTab: false),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuestionList extends StatelessWidget {
  final List<QAModel> questions;
  final bool isUnansweredTab;
  const _QuestionList({required this.questions, required this.isUnansweredTab});

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 64, color: AppColors.textMuted.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              isUnansweredTab ? 'All caught up!' : 'No answers yet.',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, i) => _AlumniQuestionCard(
        question: questions[i],
        showReply: isUnansweredTab,
      ).animate().fadeIn(delay: Duration(milliseconds: i * 100)).slideX(begin: 0.1),
    );
  }
}

class _AlumniQuestionCard extends ConsumerWidget {
  final QAModel question;
  final bool showReply;
  const _AlumniQuestionCard({required this.question, required this.showReply});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                  child: Text(question.askedBy[0], style: const TextStyle(fontSize: 10, color: AppColors.secondary)),
                ),
                const SizedBox(width: 8),
                Text(
                  question.askedBy,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d').format(question.timestamp),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.question,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: question.tags.map((t) => Chip(
                label: Text(t, style: const TextStyle(fontSize: 10)),
                backgroundColor: AppColors.bgPage,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
            if (showReply) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _showReplySheet(context, ref, question),
                icon: const Icon(Icons.reply_rounded, size: 18),
                label: const Text('Write an Answer'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  foregroundColor: AppColors.alumni,
                  side: const BorderSide(color: AppColors.alumni),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              const Text('Your Answer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.alumni)),
              const SizedBox(height: 4),
              Text(
                question.answers.firstWhere((a) => a.alumniId == ref.read(authProvider).alumni?.id).answer,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReplySheet(BuildContext context, WidgetRef ref, QAModel question) {
    final TextEditingController controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Reply to Question', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              question.question,
              style: const TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Share your wisdom...',
                fillColor: AppColors.bgPage,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                final alumni = ref.read(authProvider).alumni;
                if (alumni == null) return;

                final answerMap = {
                  'id': 'ans_${DateTime.now().millisecondsSinceEpoch}',
                  'alumniId': alumni.id,
                  'alumniName': alumni.name,
                  'alumniCompany': alumni.company,
                  'alumniPhotoUrl': alumni.photoUrl,
                  'answer': controller.text.trim(),
                  'upvotes': 0,
                  'answeredAt': DateTime.now().toIso8601String(),
                };
                
                ref.read(apiServiceProvider).postAnswer(question.id, answerMap).then((success) {
                  if (success) {
                    ref.invalidate(qaProvider);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Answer posted! Thank you for helping juniors.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to post answer.')),
                      );
                    }
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alumni,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Post Answer'),
            ),
          ],
        ),
      ),
    );
  }
}

