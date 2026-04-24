import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/alumni/profile/active_mentees_section.dart';
import 'package:graduway/alumni/profile/mentorship_bio_card.dart';
import 'package:graduway/alumni/profile/profile_dashboard_grid.dart';
import 'package:flutter/material.dart';
import 'package:graduway/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MentorshipBioCard(),
                  const SizedBox(height: 32),
                  const SizedBox(height: 32),
                  const ProfileDashboardGrid(),
                  const SizedBox(height: 32),
                  const ActiveMenteesSection(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  _buildHeaderAction(
                      context, Icons.settings_outlined, "Settings"),
                ],
              ),
              const SizedBox(height: 40),
              Consumer<AuthProvider>(
                builder: (context, auth, _) => Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4), width: 1.5),
                        image: auth.profilePictureUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(auth.profilePictureUrl),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: auth.profilePictureUrl.isEmpty
                          ? const Icon(Icons.person_rounded,
                              color: Colors.white, size: 40)
                          : null,
                    ).animate().scale(delay: 200.ms),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.fullName.isEmpty
                                ? auth.userName
                                : auth.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            "${auth.branch} • ${auth.collegeName}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Class of ${auth.graduationYear}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStatusBadge(auth.status),
                        ],
                      ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
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

  Widget _buildStatusBadge(UserStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case UserStatus.verified:
        color = Colors.greenAccent[400]!;
        text = "Verified Alumni";
        icon = Icons.verified_rounded;
        break;
      case UserStatus.pending:
        color = Colors.orangeAccent;
        text = "Verification Pending";
        icon = Icons.hourglass_top_rounded;
        break;
      case UserStatus.rejected:
        color = Colors.redAccent;
        text = "ID Rejected";
        icon = Icons.cancel_rounded;
        break;
      default:
        color = Colors.white.withOpacity(0.3);
        text = "Profile Incomplete";
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(BuildContext context, IconData icon, String title) {
    return InkWell(
      onTap: () => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$title coming soon"))),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

