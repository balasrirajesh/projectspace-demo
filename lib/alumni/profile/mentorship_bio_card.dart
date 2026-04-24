import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';

class MentorshipBioCard extends StatelessWidget {
  const MentorshipBioCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_quote_rounded,
                    color: Colors.indigoAccent[400], size: 24),
                const SizedBox(width: 8),
                const Text(
                  "Professional Bio",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigoAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              auth.bio.isEmpty
                  ? "No bio provided. Update your profile to tell students about your mentoring philosophy."
                  : auth.bio,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontStyle:
                    auth.bio.isEmpty ? FontStyle.italic : FontStyle.normal,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

