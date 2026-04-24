import 'package:graduway/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduway/alumni/shared/providers/notification_provider.dart';
import 'package:graduway/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationProvider>().clearAll(),
            child: const Text("Clear All",
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          final notifications = provider.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 80,
                      color: AppColors.textLight.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text("All caught up!",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const Text("You have no new notifications.",
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];
              final bool isRead = item['isRead'] ?? false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => provider.markAsRead(item['id']),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isRead
                          ? Colors.white
                          : AppColors.primary.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isRead
                            ? Colors.grey.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isRead
                                ? Colors.grey.withOpacity(0.1)
                                : AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isRead
                                ? Icons.notifications_outlined
                                : Icons.notifications_active_rounded,
                            color:
                                isRead ? Colors.grey : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['title'] ?? "Notification",
                                    style: TextStyle(
                                      fontWeight: isRead
                                          ? FontWeight.w600
                                          : FontWeight.bold,
                                      fontSize: 16,
                                      color: isRead
                                          ? AppColors.textPrimary
                                          : AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    item['time'] ?? "",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textLight),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['body'] ?? "",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05);
            },
          );
        },
      ),
    );
  }
}

