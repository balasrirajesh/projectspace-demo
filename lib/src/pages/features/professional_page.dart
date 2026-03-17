import 'package:flutter/material.dart';

class ProfessionalPage extends StatelessWidget {
  const ProfessionalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text("Professional Details"),
        backgroundColor: const Color(0xFF64B5F6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: "Current Role",
              child: Column(
                children: [
                  _buildDetailRow(Icons.business, "Company", "Google"),
                  _buildDetailRow(Icons.work_outline, "Position", "Software Engineer"),
                  _buildDetailRow(Icons.category_outlined, "Industry", "Mobile Development"),
                  _buildDetailRow(Icons.history, "Experience", "3 Years"),
                  _buildDetailRow(Icons.location_on_outlined, "Location", "Hyderabad"),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: "Previous Companies",
              child: Column(
                children: [
                  _buildHistoryRow("Infosys", "Software Engineer", "2022 – 2023"),
                  _buildHistoryRow("Tech Startups Inc.", "Intern", "2021 – 2022"),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: "Professional Links",
              child: Column(
                children: [
                  _buildDetailRow(Icons.link, "LinkedIn", "linkedin.com/in/alex-dev"),
                  _buildDetailRow(Icons.language, "Portfolio", "alexportfolio.dev"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[300]),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String company, String role, String period) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.history, size: 20, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(company, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text("$role • $period", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}
