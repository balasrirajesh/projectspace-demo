import 'package:graduway/alumni/chat/chat_detail_page.dart';
import 'package:graduway/alumni/mentorship/mentorship_request_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduway/alumni/shared/models/mentorship_model.dart';
import 'package:graduway/alumni/shared/providers/mentorship_provider.dart';

/// A central hub for mentors to manage their incoming and active mentorships.
///
/// This page displays pending mentorship requests and active chat sessions
/// in a unified inbox view. It uses [CustomScrollView] for efficient
/// scrolling of mixed content types.
class MentorInboxPage extends StatelessWidget {
  const MentorInboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Inbox",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<MentorshipProvider>(
        builder: (context, provider, _) {
          final pendingRequests = provider.pendingRequests;
          final activeChats = provider.acceptedMentees;

          if (pendingRequests.isEmpty && activeChats.isEmpty) {
            return _buildEmptyState();
          }

          return CustomScrollView(
            slivers: [
              if (pendingRequests.isNotEmpty) ...[
                _buildHeader("Pending Requests", pendingRequests.length),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final request = pendingRequests[index];
                        return MentorshipRequestCard(
                          request: request,
                          onAccept: () => provider.acceptRequest(request.id),
                          onReject: () => provider.rejectRequest(request.id),
                        );
                      },
                      childCount: pendingRequests.length,
                    ),
                  ),
                ),
              ],
              if (activeChats.isNotEmpty) ...[
                _buildHeader("Active Chats", activeChats.length),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final chat = activeChats[index];
                        return _buildChatCard(context, chat);
                      },
                      childCount: activeChats.length,
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  /// Builds a section header with a title and a badge showing the count.
  Widget _buildHeader(String title, int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays a friendly screen when there are no requests or chats.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(Icons.forum_outlined,
                size: 64, color: Colors.blue.withOpacity(0.3)),
          ),
          const SizedBox(height: 32),
          const Text(
            "No mentorship requests yet",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            "Student queries and mentorship requests\nwill appear here. Your personal contact info\nremains private.",
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
          ),
        ],
      ),
    );
  }

  /// Builds a simplified card for an active chat session.
  Widget _buildChatCard(BuildContext context, MentorshipRequest chat) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[100]!, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailPage(mentorship: chat),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: Text(
                      chat.student.name[0],
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          chat.student.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "2m ago",
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat.reason,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
