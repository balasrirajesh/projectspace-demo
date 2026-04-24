import 'package:graduway/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfessionalPage extends StatelessWidget {
  const ProfessionalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Professional Profile",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: "Current Role",
              icon: Icons.rocket_launch_rounded,
              child: Column(
                children: [
                  _buildDetailRow(
                      Icons.business_center_rounded, "Company", auth.company),
                  _buildDetailRow(
                      Icons.badge_rounded, "Position", auth.techField),
                  _buildDetailRow(
                      Icons.account_balance_rounded, "Department", auth.branch),
                  _buildDetailRow(Icons.calendar_today_rounded, "Graduation",
                      auth.graduationYear),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: "Professional Network",
              icon: Icons.connect_without_contact_rounded,
              child: Column(
                children: [
                  if (auth.linkedInUrl.isNotEmpty)
                    _buildDetailRow(
                        Icons.link_rounded, "LinkedIn", auth.linkedInUrl),
                  if (auth.githubUrl.isNotEmpty)
                    _buildDetailRow(Icons.code_rounded, "GitHub / Research",
                        auth.githubUrl),
                  if (auth.portfolioUrl.isNotEmpty)
                    _buildDetailRow(
                        Icons.language_rounded, "Portfolio", auth.portfolioUrl),
                  if (auth.linkedInUrl.isEmpty &&
                      auth.githubUrl.isEmpty &&
                      auth.portfolioUrl.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text("No professional links provided.",
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: AppColors.textSecondary)),
                    ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: 0.2),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: "About / Bio",
              icon: Icons.description_outlined,
              child: Text(
                auth.bio.isNotEmpty ? auth.bio : "No bio provided.",
                style: GoogleFonts.inter(
                  height: 1.5,
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.2),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  )),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textLight),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500)),
                Text(value.isNotEmpty ? value : "N/A",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

