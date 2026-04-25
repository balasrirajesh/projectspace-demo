import 'package:flutter/material.dart';
import 'package:graduway/alumni/shared/models/mentorship_model.dart';
import 'package:graduway/student/shared/services/mentorship_service.dart';

/// A bottom-sheet form that allows students to submit a mentorship request.
///
/// The form includes fields for selecting topics, providing a reason/message,
/// and specifying a preferred schedule. It also includes mock AI logic
/// to automatically select topics based on the reason provided.
class MentorshipRequestForm extends StatefulWidget {
  const MentorshipRequestForm({super.key});

  @override
  State<MentorshipRequestForm> createState() => _MentorshipRequestFormState();
}

class _MentorshipRequestFormState extends State<MentorshipRequestForm> {
  final _reasonController = TextEditingController();
  final _scheduleController = TextEditingController();
  final List<String> _selectedTopics = [];

  /// Predefined list of topics that the user can choose from.
  final List<String> _availableTopics = [
    "DSA Interview Preparation",
    "Resume & Portfolio Review",
    "Career Guidance & Coaching",
    "Flutter Best Practices",
    "System Design",
    "Product Management",
  ];

  /// Validates the form and submits the request to the [MentorshipService].
  void _submit() {
    if (_reasonController.text.isEmpty || _selectedTopics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Please provide a reason and select at least one topic.")),
      );
      return;
    }

    final request = MentorshipRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      student: Student(
        id: "s1",
        name: "John Doe",
        branch: "Computer Science",
        year: "3rd Year",
        skills: ["Flutter", "Dart"],
      ),
      reason: _reasonController.text,
      topics: _selectedTopics,
      preferredSchedule:
          _scheduleController.text.isEmpty ? null : _scheduleController.text,
      createdAt: DateTime.now(),
    );

    MentorshipService().submitRequest(request);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Mentorship request submitted successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Mock AI Recommendation Logic: Automatically selects relevant topics
  /// based on keywords found in the reason text.
  void _onReasonChanged(String text) {
    if (text.toLowerCase().contains("dsa") ||
        text.toLowerCase().contains("coding")) {
      if (!_selectedTopics.contains("DSA Interview Preparation")) {
        setState(() => _selectedTopics.add("DSA Interview Preparation"));
      }
    }
    if (text.toLowerCase().contains("resume") ||
        text.toLowerCase().contains("job")) {
      if (!_selectedTopics.contains("Resume & Portfolio Review")) {
        setState(() => _selectedTopics.add("Resume & Portfolio Review"));
      }
    }
    if (text.toLowerCase().contains("flutter") ||
        text.toLowerCase().contains("app")) {
      if (!_selectedTopics.contains("Flutter Best Practices")) {
        setState(() => _selectedTopics.add("Flutter Best Practices"));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 124,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Request Mentorship",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Tell Alex how they can help you grow.",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildLabel("Topics (Select all that apply)"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTopics.map((topic) {
                final isSelected = _selectedTopics.contains(topic);
                return FilterChip(
                  label: Text(topic),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTopics.add(topic);
                      } else {
                        _selectedTopics.remove(topic);
                      }
                    });
                  },
                  selectedColor: Colors.orange.withOpacity(0.2),
                  checkmarkColor: Colors.orange,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.orange : Colors.grey[700],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.grey[100],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide.none),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _buildLabel("Reason for mentorship"),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              onChanged: _onReasonChanged,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    "E.g., I'm preparing for my first Flutter interview...",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel("Preferred schedule (Optional)"),
            const SizedBox(height: 12),
            TextField(
              controller: _scheduleController,
              decoration: InputDecoration(
                hintText: "E.g., Weekends after 5 PM",
                prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("Submit Request",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a stylized label for form sections.
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }
}
