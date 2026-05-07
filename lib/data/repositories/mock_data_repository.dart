import 'package:graduway/data/models/alumni_model.dart';
import 'package:graduway/data/models/student_model.dart';
import 'package:graduway/data/models/models.dart';

class MockDataRepository {
  static List<AlumniModel> getAlumni() {
    return [
      AlumniModel(
        id: '1',
        name: 'Ravi Teja',
        company: 'Google',
        role: 'Senior Software Engineer',
        photoUrl: 'https://i.pravatar.cc/150?u=1',
        package: 45,
        branch: 'CSE',
        skills: ['Flutter', 'Go', 'Cloud Architecture'],
        menteeCount: 12,
      ),
      AlumniModel(
        id: '2',
        name: 'Priya Sharma',
        company: 'Microsoft',
        role: 'Product Manager',
        photoUrl: 'https://i.pravatar.cc/150?u=2',
        package: 38,
        branch: 'ECE',
        skills: ['Product Strategy', 'UI/UX', 'Agile'],
        menteeCount: 8,
      ),
      AlumniModel(
        id: '3',
        name: 'Sandeep Kumar',
        company: 'Amazon',
        role: 'SDE-2',
        photoUrl: 'https://i.pravatar.cc/150?u=3',
        package: 32,
        branch: 'IT',
        skills: ['Java', 'AWS', 'Microservices'],
        menteeCount: 15,
      ),
      AlumniModel(
        id: '4',
        name: 'Anjali Devi',
        company: 'Adobe',
        role: 'Full Stack Developer',
        photoUrl: 'https://i.pravatar.cc/150?u=4',
        package: 28,
        branch: 'CSE',
        skills: ['React', 'Node.js', 'System Design'],
        menteeCount: 5,
      ),
      AlumniModel(
        id: '5',
        name: 'Karthik Raja',
        company: 'Zomato',
        role: 'Backend Engineer',
        photoUrl: 'https://i.pravatar.cc/150?u=5',
        package: 24,
        branch: 'MECH',
        skills: ['Python', 'Django', 'PostgreSQL'],
        menteeCount: 10,
      ),
    ];
  }

  static List<StudentModel> getStudents() {
    return [
      StudentModel(id: 's1', name: 'Arjun Reddy', branch: 'CSE', year: 4, email: 'arjun@aditya.in', rollNumber: '21P31A0501'),
      StudentModel(id: 's2', name: 'Meghana S', branch: 'ECE', year: 3, email: 'meghana@aditya.in', rollNumber: '22P31A0402'),
      StudentModel(id: 's3', name: 'Rahul Varma', branch: 'IT', year: 2, email: 'rahul@aditya.in', rollNumber: '23P31A1205'),
    ];
  }

  static List<QAModel> getQA() {
    return [
      QAModel(
        id: 'q1',
        question: 'How to prepare for Google SDE-1 interviews from a Tier-2 college?',
        askedBy: 'Arjun Reddy',
        askedById: 's1',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        upvotes: 45,
        tags: ['Interview', 'Google', 'Placements'],
        isAnswered: true,
        answers: [
          QAAnswer(
            id: 'a1',
            alumniId: '1',
            alumniName: 'Ravi Teja',
            alumniCompany: 'Google',
            alumniPhotoUrl: 'https://i.pravatar.cc/150?u=1',
            answer: 'Focus on DSA mastery (LeetCode 300+ medium/hard). Ensure your projects are unique — don\'t just make clones. Networking via LinkedIn is key to getting referrals.',
            upvotes: 82,
            answeredAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      QAModel(
        id: 'q2',
        question: 'What is the current demand for Flutter developers in India?',
        askedBy: 'Meghana S',
        askedById: 's2',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        upvotes: 32,
        tags: ['Skills', 'Flutter', 'Career'],
        isAnswered: true,
        answers: [
          QAAnswer(
            id: 'a2',
            alumniId: '4',
            alumniName: 'Anjali Devi',
            alumniCompany: 'Adobe',
            alumniPhotoUrl: 'https://i.pravatar.cc/150?u=4',
            answer: 'The demand is booming, especially in startups (Unicorns like Groww, Swiggy use it). Focus on state management (Riverpod) and high-fidelity animations.',
            upvotes: 54,
            answeredAt: DateTime.now().subtract(const Duration(days: 4)),
          ),
        ],
      ),
    ];
  }

  static List<EventModel> getEvents() {
    return [
      EventModel(
        id: 'e1',
        title: 'Mock Interview Marathon',
        description: 'Get interviewed by seniors at top tech firms. Highly recommended for 3rd and 4th year students.',
        hostAlumniName: 'Sandeep Kumar',
        hostCompany: 'Amazon',
        eventDate: DateTime.now().add(const Duration(days: 3)),
        type: 'mock_interview',
        registeredCount: 156,
        isRsvped: false,
      ),
      EventModel(
        id: 'e2',
        title: 'System Design 101',
        description: 'Building scalable backends for millions of users using microservices architecture.',
        hostAlumniName: 'Anjali Devi',
        hostCompany: 'Adobe',
        eventDate: DateTime.now().add(const Duration(days: 7)),
        type: 'workshop',
        registeredCount: 89,
        isRsvped: true,
      ),
      EventModel(
        id: 'e3',
        title: 'Career Talk: Product Management',
        description: 'Exploring non-coding roles in big tech and how to transition.',
        hostAlumniName: 'Priya Sharma',
        hostCompany: 'Microsoft',
        eventDate: DateTime.now().add(const Duration(days: 10)),
        type: 'career_talk',
        registeredCount: 210,
        isRsvped: false,
      ),
    ];
  }

  static List<BadgeModel> getBadges() {
    return [
      const BadgeModel(id: 'b1', title: 'Top Contributor', description: 'Answered 10+ questions', icon: '🏆', isEarned: true, category: 'Community'),
      const BadgeModel(id: 'b2', title: 'Early Adopter', description: 'Joined in the first week', icon: '🚀', isEarned: true, category: 'General'),
      const BadgeModel(id: 'b3', title: 'Code Master', description: 'Solved 100+ DSA problems', icon: '💻', isEarned: false, category: 'Skills'),
      const BadgeModel(id: 'b4', title: 'First Connect', description: 'Viewed an alumni profile', icon: '🤝', isEarned: true, category: 'Networking'),
    ];
  }

  static List<Map<String, dynamic>> getPlacementStories() {
    return [
      {
        'name': 'Aditya K',
        'company': 'ServiceNow',
        'package': '12 LPA',
        'title': 'Focused preparation works!',
        'content': 'I started my prep in 3rd year. I followed the ServiceNow roadmap to the letter. Getting the CSA cert was the key. Don\'t ignore the fundamentals of ITIL.',
        'photoUrl': 'https://i.pravatar.cc/150?u=10',
        'isAnon': false,
      },
      {
        'name': 'Anonymous Student',
        'company': 'TCS Ninja',
        'package': '3.3 LPA',
        'title': 'The reality of mass hiring',
        'content': 'I didn\'t have great skills, but I practiced aptitude every day for 2 months. TCS was my only offer. It\'s a start, but I wish I had learned a proper tech stack like Flutter or React earlier.',
        'photoUrl': 'https://i.pravatar.cc/150?u=11',
        'isAnon': true,
      }
    ];
  }

  static Map<String, dynamic> getSkillPackages() {
    return {
      'CSE': [
        {'skill': 'Full Stack', 'minPkg': 6, 'maxPkg': 28, 'count': 45},
        {'skill': 'Data Science', 'minPkg': 8, 'maxPkg': 32, 'count': 22},
        {'skill': 'Flutter', 'minPkg': 7, 'maxPkg': 24, 'count': 15},
        {'skill': 'Cybersecurity', 'minPkg': 5, 'maxPkg': 18, 'count': 10},
      ],
      'ECE': [
        {'skill': 'VLSI', 'minPkg': 6, 'maxPkg': 22, 'count': 30},
        {'skill': 'Embedded Systems', 'minPkg': 5, 'maxPkg': 15, 'count': 25},
        {'skill': 'IT Services', 'minPkg': 3.5, 'maxPkg': 7, 'count': 60},
      ],
      'MECH': [
        {'skill': 'Core Engineering', 'minPkg': 3, 'maxPkg': 8, 'count': 40},
        {'skill': 'Design (CAD/CAM)', 'minPkg': 4, 'maxPkg': 12, 'count': 20},
        {'skill': 'IT Pivot', 'minPkg': 3.5, 'maxPkg': 10, 'count': 35},
      ],
    };
  }
}
