import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/widgets/custom_app_bar.dart';
import 'package:graduway/data/models/models.dart';

class QAScreen extends ConsumerStatefulWidget {
  const QAScreen({super.key});

  @override
  ConsumerState<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends ConsumerState<QAScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedTags = [];
  bool _showSearch = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _questionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(qaProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Q&A Community',
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.search_off_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Live search bar
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _showSearch ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              color: AppColors.bgCard,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search questions or tags...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          }),
                        )
                      : null,
                  fillColor: AppColors.bgPage,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Question list
          Expanded(
            child: questionsAsync.when(
              data: (questions) {
                final filtered = _searchQuery.isEmpty
                    ? questions
                    : questions
                        .where((q) =>
                            q.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            q.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase())))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty ? 'No questions yet' : 'No results for "$_searchQuery"',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
                        ),
                      ],
                    ).animate().fadeIn(),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    return _QuestionCard(question: filtered[i])
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: i * 100))
                        .slideY(begin: 0.1);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () => _showAskModal(context),
          label: const Text('Ask Question'),
          icon: const Icon(Icons.add_rounded),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ).animate().scale(delay: 500.ms),
      ),
    );
  }

  void _showAskModal(BuildContext context) {
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
                const Text('Ask Alumni', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Your question will be visible to all verified alumni.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: _questionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'What would you like to know about placements, skills, or career path?',
                fillColor: AppColors.bgPage,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Tags', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['Placements', 'Skills', 'Interview', 'Companies', 'Resumes'].map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) _selectedTags.add(tag);
                      else _selectedTags.remove(tag);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () async {
                if (_questionController.text.trim().isEmpty) return;
                
                final auth = ref.read(authProvider);
                final userId = auth.student?.rollNumber ?? 'unknown';
                final userName = auth.loginName;
                
                final success = await ref.read(apiServiceProvider).postQuestion(
                  _questionController.text.trim(),
                  userId,
                  userName,
                );

                if (success) {
                  ref.refresh(qaProvider);
                  _questionController.clear();
                  _selectedTags.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Question posted! Alumni will notify you once answered.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to post question. Please try again.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Post Question'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QAModel question;
  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
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
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(question.askedBy[0], style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Text(question.askedBy, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const Spacer(),
                Text(DateFormat('MMM d').format(question.timestamp), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.question,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: question.tags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.bgPage, borderRadius: BorderRadius.circular(8)),
                child: Text('#$t', style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
            if (question.answers.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 14, backgroundImage: NetworkImage(question.answers.first.alumniPhotoUrl)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${question.answers.first.alumniName} • ${question.answers.first.alumniCompany}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.alumni),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.answers.first.answer,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (question.answers.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 40),
                  child: Text('+ ${question.answers.length - 1} more answers', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
            ] else ...[
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.hourglass_empty_rounded, size: 14, color: AppColors.textMuted),
                  SizedBox(width: 6),
                  Text('Waiting for alumni response...', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

