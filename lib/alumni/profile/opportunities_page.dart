// import 'package:flutter/material.dart';

// class OpportunitiesPage extends StatelessWidget {
//   const OpportunitiesPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: AppBar(
//         title: const Text("Opportunities Posted"),
//         backgroundColor: const Color(0xFFBA68C8),
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           _buildJobCard(
//             "Flutter Developer Intern",
//             "ABC Technologies",
//             "Remote",
//             "12 Applicants",
//             ["Flutter", "Dart", "Firebase"],
//             "Jun 30, 2025",
//           ),
//           const SizedBox(height: 16),
//           _buildJobCard(
//             "Junior Fullstack Dev",
//             "Tech Innovators",
//             "Hyderabad",
//             "24 Applicants",
//             ["Node.js", "React", "MongoDB"],
//             "Jul 15, 2025",
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildJobCard(String title, String company, String location, String applicants, List<String> skills, String deadline) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     Text(company, style: TextStyle(fontSize: 14, color: Colors.purple[300], fontWeight: FontWeight.w600)),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.purple[50],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(location, style: TextStyle(color: Colors.purple[400], fontSize: 12, fontWeight: FontWeight.bold)),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           const Text("Required Skills:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8,
//             children: skills.map((skill) => Text("• $skill", style: const TextStyle(fontSize: 13, color: Colors.black87))).toList(),
//           ),
//           const Divider(height: 32),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.people_outline, size: 16, color: Colors.grey[400]),
//                   const SizedBox(width: 4),
//                   Text(applicants, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
//                 ],
//               ),
//               Text("Deadline: $deadline", style: TextStyle(color: Colors.red[300], fontSize: 13, fontWeight: FontWeight.w500)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
