import 'package:graduway/admin/shared/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduway/admin/shared/providers/admin_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _targetGroup = 'All Users';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Broadcast Announcement",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Send an urgent notification to your college network",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            _buildComposeCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildComposeCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 40)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Target Audience",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _targetGroup,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
            items: ['All Users', 'Students Only', 'Alumni Only']
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (val) => setState(() => _targetGroup = val!),
          ),
          const SizedBox(height: 24),
          const Text("Title", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: "Urgent Update: Campus Closure...",
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          const Text("Message Body",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Enter the details of your announcement here...",
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _sendBroadcast,
              icon: const Icon(Icons.send_rounded),
              label: const Text("Send Broadcast Now"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  void _sendBroadcast() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) return;

    final success = await context
        .read<AdminProvider>()
        .broadcastAnnouncement(title, message, _targetGroup);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Announcement broadcasted successfully!")),
      );
      _titleController.clear();
      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to send broadcast. Check connection.")),
      );
    }
  }
}
