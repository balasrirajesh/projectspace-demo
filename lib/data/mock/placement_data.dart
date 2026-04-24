import 'package:graduway/data/models/models.dart';

final List<PostModel> mockPosts = [
  PostModel(
    id: 'p001',
    alumniId: 'a001',
    alumniName: 'Ravi Kumar Reddy',
    alumniCompany: 'Amazon',
    alumniPhotoUrl: 'https://i.pravatar.cc/150?img=11',
    content:
        '🚀 To all 3rd year students: Start NOW. Not after exams. Not next semester. NOW. I see so many students saying "I\'ll start DSA after this exam." By the time you finish, your batch mate already solved 200 problems. LeetCode daily — even 1 problem — compounds over time.',
    type: 'advice',
    tags: ['DSA', 'Placements', 'Motivation'],
    likes: 234,
    saves: 89,
    isAnonymous: false,
    postedAt: DateTime(2025, 11, 15),
  ),
  PostModel(
    id: 'p002',
    alumniId: 'a012',
    alumniName: 'Ajay Kumar Thota',
    alumniCompany: 'Microsoft',
    alumniPhotoUrl: 'https://i.pravatar.cc/150?img=8',
    content:
        '💡 UNPOPULAR TRUTH: Your first package does NOT define your career. I started at 3.5 LPA in 2018 at TCS. Today at Microsoft: 42 LPA. The gap between 7 LPA and 40 LPA is not talent — it\'s information + consistent skill building. Your first job is just the starting line, not the finish.',
    type: 'story',
    tags: ['Career Growth', 'First Job', 'Motivation'],
    likes: 567,
    saves: 312,
    isAnonymous: false,
    postedAt: DateTime(2025, 12, 3),
  ),
  PostModel(
    id: 'p003',
    alumniId: 'a004',
    alumniName: 'Ananya Sri Durga',
    alumniCompany: 'Capgemini',
    alumniPhotoUrl: 'https://i.pravatar.cc/150?img=47',
    content:
        '🤫 Anonymous confession: I cried for 3 days after my 8th placement rejection. I had 11 rejections total before getting placed. If you\'re struggling — you\'re NOT alone. Every rejection is data, not a verdict on your worth.',
    type: 'confession',
    tags: ['Mental Health', 'Rejections', 'Reality'],
    likes: 891,
    saves: 445,
    isAnonymous: true,
    postedAt: DateTime(2025, 10, 28),
  ),
  PostModel(
    id: 'p004',
    alumniId: 'a002',
    alumniName: 'Priya Lakshmi Venkat',
    alumniCompany: 'Zoho',
    alumniPhotoUrl: 'https://i.pravatar.cc/150?img=5',
    content:
        '🧠 Skills that got me ₹12 LPA at Zoho as a fresher:\n✅ Django (backend)\n✅ React (frontend)\n✅ MySQL + Redis\n✅ 3 deployed projects on GitHub\n✅ Zero backlogs\n\nZoho cares about product thinking. Build things people can actually USE.',
    type: 'tip',
    tags: ['Zoho', 'Skills', 'Web Development'],
    likes: 445,
    saves: 178,
    isAnonymous: false,
    postedAt: DateTime(2025, 11, 22),
  ),
  PostModel(
    id: 'p005',
    alumniId: 'a014',
    alumniName: 'Chandra Sekhar Rao',
    alumniCompany: 'Mphasis',
    alumniPhotoUrl: 'https://i.pravatar.cc/150?img=33',
    content:
        '🤖 ML is not magic. I built a SIMPLE logistic regression model to predict placement outcomes using our college\'s placement data. That ONE project got me placed at Mphasis at ₹7.5 LPA. Don\'t copy Kaggle notebooks. Solve REAL problems from your surroundings.',
    type: 'advice',
    tags: ['Machine Learning', 'Projects', 'Data Science'],
    likes: 334,
    saves: 156,
    isAnonymous: false,
    postedAt: DateTime(2025, 12, 10),
  ),
];

final List<QAModel> mockQA = [
  QAModel(
    id: 'q001',
    question:
        'I am in 2nd year CSE with 6.8 CGPA. Should I focus on DSA or build web projects? I\'m confused about what companies actually want.',
    askedBy: 'Arjun Reddy',
    askedById: 's001',
    timestamp: DateTime(2025, 12, 1),
    upvotes: 145,
    tags: ['Skills', 'Career', 'DSA'],
    isAnswered: true,
    answers: [
      QAAnswer(
        id: 'qa001',
        alumniId: 'a001',
        alumniName: 'Ravi Kumar Reddy',
        alumniCompany: 'Amazon',
        alumniPhotoUrl: 'https://i.pravatar.cc/150?img=11',
        answer:
            'Great question! It depends on your target company type.\n\n🎯 FAANG/top product: DSA is NON-NEGOTIABLE. 300+ LeetCode problems is the minimum.\n🎯 Mid-product (Zoho, Freshworks, Postman): Projects matter MORE than DSA.\n🎯 Service companies (TCS, Infosys): Basic aptitude + communication wins.\n\nAt 2nd year, DO BOTH. 1 hour DSA + 1 hour project building daily. Compound interest works in skills too.',
        upvotes: 89,
        answeredAt: DateTime(2025, 12, 2),
        isBestAnswer: true,
      ),
    ],
  ),
  QAModel(
    id: 'q002',
    question:
        'ECE student here, 3rd year. All my friends in CSE are getting IT placements. What should I do as an ECE student?',
    askedBy: 'Kavitha Nair',
    askedById: 's002',
    timestamp: DateTime(2025, 11, 20),
    upvotes: 112,
    tags: ['ECE', 'Placements', 'IT'],
    isAnswered: true,
    answers: [
      QAAnswer(
        id: 'qa003',
        alumniId: 'a003',
        alumniName: 'Suresh Babu Naidu',
        alumniCompany: 'Infosys',
        alumniPhotoUrl: 'https://i.pravatar.cc/150?img=3',
        answer:
            'I was in your exact position — ECE, 3rd year, worried. Here\'s what worked:\n1. Mass recruiters (TCS, Infosys, Wipro) hire ECE. They only need basic Python + aptitude.\n2. Get AMCAT / eLitmus certified — it opens off-campus IT jobs too.\n3. If you want product companies, learn Python, SQL, and one web framework. That\'s enough.\n\nDon\'t compare with CSE friends. Your path is equally valid.',
        upvotes: 76,
        answeredAt: DateTime(2025, 11, 21),
      ),
    ],
  ),
  QAModel(
    id: 'q003',
    question:
        'What is the minimum CGPA required for Amazon off-campus? I have 7.2 CGPA in CSE and already have 250+ LeetCode problems.',
    askedBy: 'Rahul Sharma',
    askedById: 's003',
    timestamp: DateTime(2025, 12, 5),
    upvotes: 200,
    tags: ['Amazon', 'CGPA', 'FAANG'],
    isAnswered: true,
    answers: [
      QAAnswer(
        id: 'qa010',
        alumniId: 'a001',
        alumniName: 'Ravi Kumar Reddy',
        alumniCompany: 'Amazon',
        alumniPhotoUrl: 'https://i.pravatar.cc/150?img=11',
        answer:
            'Amazon\'s official cutoff is 6.5 CGPA for most roles. Your 7.2 is absolutely fine. The real filter is the OA (Online Assessment) — 2 coding problems, medium to hard, 90 minutes. Focus on:\n1. Arrays, trees, graphs (BFS/DFS), DP basics\n2. Leadership Principles — you WILL be asked these in interviews\n3. System Design (even for SDE-1, basic LLD is expected)\n\nWith 250+ LeetCode in the right categories, you\'re ready. Apply in August–September when Amazon opens campus.',
        upvotes: 134,
        answeredAt: DateTime(2025, 12, 6),
        isBestAnswer: true,
      ),
    ],
  ),
  QAModel(
    id: 'q004',
    question:
        'I want to learn Flutter and get placed in a company that works on mobile apps. What is the exact roadmap I should follow from scratch?',
    askedBy: 'Sai Kiran Reddy',
    askedById: 's004',
    timestamp: DateTime(2025, 12, 8),
    upvotes: 178,
    tags: ['Flutter', 'Mobile', 'Roadmap'],
    isAnswered: true,
    answers: [
      QAAnswer(
        id: 'qa011',
        alumniId: 'a005',
        alumniName: 'Deepika Rao',
        alumniCompany: 'Groww',
        alumniPhotoUrl: 'https://i.pravatar.cc/150?img=20',
        answer:
            'I got placed at Groww as a Flutter developer. Here\'s the exact path:\n\n**Month 1–2**: Dart basics (dart.dev), Flutter installation, widgets, layouts\n**Month 3**: State management — start with setState, then Provider, then Riverpod\n**Month 4**: APIs, HTTP package, JSON parsing, async/await\n**Month 5**: Firebase — Auth, Firestore, Storage\n**Month 6**: Publish an app on Play Store (even a simple one)\n\nProjects that get you hired: expense tracker, task manager, weather app with real API, e-commerce clone with Firebase backend.\n\nJoin r/FlutterDev and follow the Flutter YouTube channel. That\'s all you need.',
        upvotes: 92,
        answeredAt: DateTime(2025, 12, 9),
        isBestAnswer: true,
      ),
    ],
  ),
  QAModel(
    id: 'q005',
    question:
        'Is ServiceNow a good career option for CSE freshers? What certification should I start with and what salary can I expect?',
    askedBy: 'Bhavani Reddy',
    askedById: 's005',
    timestamp: DateTime(2025, 11, 28),
    upvotes: 95,
    tags: ['ServiceNow', 'Certification', 'Salary'],
    isAnswered: true,
    answers: [
      QAAnswer(
        id: 'qa012',
        alumniId: 'a007',
        alumniName: 'Venkat Sai',
        alumniCompany: 'Accenture',
        alumniPhotoUrl: 'https://i.pravatar.cc/150?img=14',
        answer:
            'ServiceNow is an UNDERRATED goldmine right now. Here\'s the reality:\n\n💰 Fresher with CSA cert: ₹4–7 LPA at service companies\n💰 With 1 year exp + CIS cert: ₹10–18 LPA\n💰 Architects with 5+ years: ₹30–50 LPA\n\n**Start here**:\n1. ServiceNow free personal developer instance (developer.servicenow.com)\n2. ServiceNow CSA (Certified System Administrator) — this is the first certification\n3. Learn: ITSM basics, tables, forms, workflows, scripting (JavaScript on ServiceNow)\n4. Build an incident management demo app\n5. Apply to TCS, Infosys, Accenture ServiceNow practices\n\nThe demand is huge because every large enterprise runs ServiceNow.',
        upvotes: 67,
        answeredAt: DateTime(2025, 11, 29),
        isBestAnswer: true,
      ),
    ],
  ),
  QAModel(
    id: 'q006',
    question:
        'How do I prepare for the Infosys InfyTQ and Smart Hiring assessment? What are the actual questions like?',
    askedBy: 'Pooja Devi',
    askedById: 's006',
    timestamp: DateTime(2025, 12, 3),
    upvotes: 143,
    tags: ['Infosys', 'Assessment', 'Service'],
    isAnswered: true,
    answers: [
      QAAnswer(
        id: 'qa013',
        alumniId: 'a003',
        alumniName: 'Suresh Babu Naidu',
        alumniCompany: 'Infosys',
        alumniPhotoUrl: 'https://i.pravatar.cc/150?img=3',
        answer:
            'I cleared InfyTQ and joined Infosys. Here\'s exactly what to prepare:\n\n**InfyTQ Exam Pattern:**\n- Logical Reasoning: 15 Qs, 25 min\n- Verbal Ability: 10 Qs, 20 min\n- Pseudocode/Programming Concepts: 10 Qs, 25 min\n- Data Interpretation: 10 Qs, 20 min\n\n**For Smart Hiring (SHL-based):**\n- Aptitude (quant + reasoning): Practice RS Aggarwal\n- Coding section: Hackerrank EasyMedium\n- Verbal: RC passages + grammar\n\n**Resources**: IndiaBix for aptitude, InfyTQ app itself has free mock tests. Score 3.5+ to qualify.',
        upvotes: 89,
        answeredAt: DateTime(2025, 12, 4),
        isBestAnswer: true,
      ),
    ],
  ),
  QAModel(
    id: 'q007',
    question:
        'I want to get into AWS cloud. Should I go for Solutions Architect Associate or Cloud Practitioner first? I have zero cloud background.',
    askedBy: 'Dilip Kumar',
    askedById: 's007',
    timestamp: DateTime(2025, 11, 25),
    upvotes: 167,
    tags: ['AWS', 'Cloud', 'Certification'],
    isAnswered: true,
    answers: [
      QAAnswer(
        id: 'qa014',
        alumniId: 'a009',
        alumniName: 'Harsha Vardhan',
        alumniCompany: 'Deloitte',
        alumniPhotoUrl: 'https://i.pravatar.cc/150?img=57',
        answer:
            'If you have ZERO cloud background — start with Cloud Practitioner (CLF-C02). It takes 3–4 weeks and gives you the foundation language and concepts.\n\nThen go for SAA-C03 (Solutions Architect Associate). This is the most valuable cert for getting hired.\n\n**Free Resources:**\n- AWS Skill Builder (free tier) — official course\n- FreeCodeCamp YouTube: "AWS Certified Cloud Practitioner 2024"\n- Stephane Maarek on Udemy (wait for sale, ₹500)\n- Adrian Cantrill for deep understanding\n\n**After certification**: Apply to AWS, Deloitte Cloud, Accenture AWS practice, TCS iON cloud teams.\n\nEntry-level: ₹6–10 LPA. Mid-level with 2 certs: ₹15–25 LPA.',
        upvotes: 112,
        answeredAt: DateTime(2025, 11, 26),
        isBestAnswer: true,
      ),
    ],
  ),
  QAModel(
    id: 'q008',
    question:
        'What should my resume look like as a CSE fresher with no internship experience? I have done 2 college projects.',
    askedBy: 'Mounika Singh',
    askedById: 's008',
    timestamp: DateTime(2025, 12, 7),
    upvotes: 122,
    tags: ['Resume', 'Fresher', 'Placements'],
    isAnswered: true,
    answers: [
      QAAnswer(
        id: 'qa015',
        alumniId: 'a002',
        alumniName: 'Priya Lakshmi Venkat',
        alumniCompany: 'Zoho',
        alumniPhotoUrl: 'https://i.pravatar.cc/150?img=5',
        answer:
            'I reviewed 200+ resumes as a hiring assistant at Zoho. Here\'s what works:\n\n✅ **1 page ONLY** — recruiters spend 7 seconds\n✅ **Contact, Education, Skills, Projects, Achievements** — in this order\n✅ **Projects** are your strongest section. Use this format:\n  - Project Name | Tech Stack used\n  - 2–3 bullet points: what problem it solves, what YOU built, the outcome/metric\n  - GitHub link + live demo link\n✅ **Skills**: List only what you can answer questions on\n✅ **No Objective statement** — waste of space\n✅ **No personal info** like DOB, father\'s name, address\n\nUse Jake\'s Resume template (search "Jake LaTeX resume"). Format it cleanly. No fancy colors.',
        upvotes: 87,
        answeredAt: DateTime(2025, 12, 8),
        isBestAnswer: true,
      ),
    ],
  ),
  QAModel(
    id: 'q009',
    question:
        'Is it worth doing MTech or should I just get placed? What are the long term salary differences?',
    askedBy: 'Teja Varma',
    askedById: 's009',
    timestamp: DateTime(2025, 11, 18),
    upvotes: 88,
    tags: ['Higher Studies', 'MTech', 'Career Advice'],
    isAnswered: false,
    answers: [],
  ),
  QAModel(
    id: 'q010',
    question:
        'I failed in 3 subjects in 2nd year and now have a backlog. Will companies reject me outright? Is placement still possible?',
    askedBy: 'Anonymous Student',
    askedById: 's010',
    timestamp: DateTime(2025, 12, 2),
    upvotes: 234,
    tags: ['Backlogs', 'CGPA', 'Moral Support'],
    isAnswered: true,
    answers: [
      QAAnswer(
        id: 'qa016',
        alumniId: 'a004',
        alumniName: 'Ananya Sri Durga',
        alumniCompany: 'Capgemini',
        alumniPhotoUrl: 'https://i.pravatar.cc/150?img=47',
        answer:
            'I had 2 active backlogs until 3rd year. I am now placed at Capgemini. So listen carefully.\n\nMass recruiters (TCS, Wipro, Cognizant, Capgemini) typically require: NO active backlog at time of joining + CGPA ≥ 6.0. CLEAR YOUR BACKLOGS FIRST. That is step 1.\n\nAfter clearing: Focus on aptitude + coding basics. These companies don\'t look at how many you failed — they look at your current state.\n\nProduct companies are tougher — most require no history of backlogs. But many mid-product ones only care about current standing.\n\nDon\'t give up. I know people placed at 5.8 CGPA. Skills and persistence beat scores every time.',
        upvotes: 189,
        answeredAt: DateTime(2025, 12, 3),
        isBestAnswer: true,
      ),
    ],
  ),
  QAModel(
    id: 'q011',
    question:
        'What is the difference between on-campus and off-campus placements? Is it worth applying off-campus if we don\'t get placed on campus?',
    askedBy: 'Kiran Teja',
    askedById: 's011',
    timestamp: DateTime(2025, 11, 30),
    upvotes: 76,
    tags: ['Off-Campus', 'Placements', 'Strategy'],
    isAnswered: false,
    answers: [],
  ),
  QAModel(
    id: 'q012',
    question:
        'How important is GitHub for freshers in 2025? What should I put on my GitHub to make recruiters notice me?',
    askedBy: 'Swetha Reddy',
    askedById: 's012',
    timestamp: DateTime(2025, 12, 9),
    upvotes: 134,
    tags: ['GitHub', 'Portfolio', 'Fresher'],
    isAnswered: true,
    answers: [
      QAAnswer(
        id: 'qa017',
        alumniId: 'a001',
        alumniName: 'Ravi Kumar Reddy',
        alumniCompany: 'Amazon',
        alumniPhotoUrl: 'https://i.pravatar.cc/150?img=11',
        answer:
            'GitHub matters a LOT. Here\'s how to make it count:\n\n🔥 **Profile README**: Add a good bio, your tech stack badges, and contribution stats\n🔥 **Pinned repos**: Only pin 4–6 best projects with clear README files\n🔥 **Each project README should have**: What it does, tech used, screenshots, how to run, live demo link\n🔥 **Consistent commits**: Even small daily commits show activity\n🔥 **Contribution graph**: Keep it green — even small fixes count\n\n**What NOT to have**: Tutorial follow-along projects, empty repos, "learning XYZ" repos with 1 file\n\nAt Amazon, we check GitHub link on every resume. A well-maintained GitHub with 2–3 real projects beats a blank profile with 500 LeetCode solutions any day.',
        upvotes: 98,
        answeredAt: DateTime(2025, 12, 10),
        isBestAnswer: true,
      ),
    ],
  ),
  QAModel(
    id: 'q013',
    question:
        'Is learning React Native better or Flutter for mobile development? Which one has more job opportunities in India right now?',
    askedBy: 'Nikhil Goud',
    askedById: 's013',
    timestamp: DateTime(2025, 12, 11),
    upvotes: 89,
    tags: ['Flutter', 'React Native', 'Mobile'],
    isAnswered: false,
    answers: [],
  ),
  QAModel(
    id: 'q014',
    question:
        'How do I crack the TCS NQT? What is the difficulty level of the coding section? I am a beginner in coding.',
    askedBy: 'Prasad Rao',
    askedById: 's014',
    timestamp: DateTime(2025, 11, 22),
    upvotes: 201,
    tags: ['TCS', 'NQT', 'Service Sector'],
    isAnswered: true,
    answers: [
      QAAnswer(
        id: 'qa018',
        alumniId: 'a008',
        alumniName: 'Ramesh Babu',
        alumniCompany: 'TCS',
        alumniPhotoUrl: 'https://i.pravatar.cc/150?img=62',
        answer:
            'I cracked TCS NQT with 85.6 percentile. Here\'s the complete breakdown:\n\n**Section-wise:**\n- Numerical Ability: 26 Qs, 40 min (practice RS Aggarwal chapters 1–15)\n- Verbal Ability: 24 Qs, 30 min (RC + grammar — practice daily on Grammarly blog)\n- Reasoning: 30 Qs, 50 min (standard logical reasoning patterns)\n- Coding: 2 problems, 60 min (1 easy + 1 medium)\n\n**For coding as beginner:**\n- Learn Python/C basics (loops, arrays, strings, functions)\n- Practice 30 easy LeetCode problems\n- Know: Fibonacci, factorial, prime check, array reversal, palindrome, string manipulation\n\nTCS focuses more on aptitude than coding. Strong aptitude = selection. Coding is just a plus.',
        upvotes: 145,
        answeredAt: DateTime(2025, 11, 23),
        isBestAnswer: true,
      ),
    ],
  ),
  QAModel(
    id: 'q015',
    question:
        'What is the best way to prepare for system design interviews as a fresher? All resources I find are for experienced people.',
    askedBy: 'Varun Tej',
    askedById: 's015',
    timestamp: DateTime(2025, 12, 6),
    upvotes: 156,
    tags: ['System Design', 'Interview', 'FAANG'],
    isAnswered: true,
    answers: [
      QAAnswer(
        id: 'qa019',
        alumniId: 'a012',
        alumniName: 'Ajay Kumar Thota',
        alumniCompany: 'Microsoft',
        alumniPhotoUrl: 'https://i.pravatar.cc/150?img=8',
        answer:
            'As a fresher, you only need BASIC system design for SDE-1 roles. Here\'s the roadmap:\n\n**First understand these concepts:**\n1. Client-server model, HTTP, REST APIs\n2. Databases: SQL vs NoSQL, when to use what\n3. Caching: Redis basics, why it matters\n4. Load balancing: Round robin, the concept\n5. Scalability: Vertical vs horizontal scaling\n\n**Resources for freshers:**\n- "System Design Primer" on GitHub (free, start here)\n- ByteByteGo YouTube channel (free, visual explanations)\n- Grokking System Design on Educative (affordable)\n\n**Practice by designing**: URL shortener, Instagram feed, WhatsApp chat storage, Netflix recommendation system.\n\nFor SDE-1 at Microsoft/Google, expect 1 LLD (low-level design) round, not full HLD. Focus on class diagrams and OOP principles.',
        upvotes: 112,
        answeredAt: DateTime(2025, 12, 7),
        isBestAnswer: true,
      ),
    ],
  ),
];

final List<EventModel> mockEvents = [
  EventModel(
    id: 'e001',
    title: 'How I Cracked Amazon: My Complete Journey',
    description:
        'Ravi Kumar Reddy (SDE-1 at Amazon) will walk you through his entire preparation strategy — OA, coding rounds, and behavioral interviews.',
    hostAlumniName: 'Ravi Kumar Reddy',
    hostCompany: 'Amazon',
    eventDate: DateTime(2026, 3, 5, 18, 0),
    type: 'career_talk',
    registeredCount: 234,
    isRsvped: false,
  ),
  EventModel(
    id: 'e002',
    title: 'System Design for Beginners',
    description:
        'Ajay Kumar Thota (Senior SWE at Microsoft) conducts a 2-hour live workshop on designing scalable systems from scratch.',
    hostAlumniName: 'Ajay Kumar Thota',
    hostCompany: 'Microsoft',
    eventDate: DateTime(2026, 3, 12, 10, 0),
    type: 'workshop',
    registeredCount: 412,
    isRsvped: false,
  ),
  EventModel(
    id: 'e003',
    title: 'Flutter Dev to Placement — Full Roadmap',
    description:
        'Deepika Rao shares her journey from zero Flutter knowledge to getting placed at Groww in 6 months.',
    hostAlumniName: 'Deepika Rao',
    hostCompany: 'Groww',
    eventDate: DateTime(2026, 3, 19, 17, 0),
    type: 'career_talk',
    registeredCount: 189,
    isRsvped: false,
  ),
  EventModel(
    id: 'e004',
    title: 'AWS Cloud Certification — Is It Worth It?',
    description:
        'Panel discussion with 3 AWS-certified alumni on real ROI, preparation strategy, and what companies actually pay for certified freshers.',
    hostAlumniName: 'Harsha Vardhan',
    hostCompany: 'Deloitte',
    eventDate: DateTime(2026, 3, 26, 18, 30),
    type: 'webinar',
    registeredCount: 301,
    isRsvped: false,
  ),
];

// All badges start LOCKED (isEarned: false) — earned through real student actions
final List<BadgeModel> mockBadges = [
  const BadgeModel(
      id: 'b001',
      title: 'First Connect',
      description: 'View your first alumni profile',
      icon: '🤝',
      isEarned: false,
      category: 'Social'),
  const BadgeModel(
      id: 'b002',
      title: 'Curious Mind',
      description: 'Ask your first question in Q&A',
      icon: '❓',
      isEarned: false,
      category: 'Engagement'),
  const BadgeModel(
      id: 'b003',
      title: 'Skill Seeker',
      description: 'Select your first career goal on roadmap',
      icon: '🎯',
      isEarned: false,
      category: 'Growth'),
  const BadgeModel(
      id: 'b004',
      title: 'Event Goer',
      description: 'RSVP to your first alumni webinar',
      icon: '🎓',
      isEarned: false,
      category: 'Events'),
  const BadgeModel(
      id: 'b005',
      title: 'Rising Star',
      description: 'Your question receives 10+ upvotes',
      icon: '⭐',
      isEarned: false,
      category: 'Community'),
  const BadgeModel(
      id: 'b006',
      title: 'Explorer',
      description: 'Browse all 4 sections of the app',
      icon: '🗺️',
      isEarned: false,
      category: 'Exploration'),
  const BadgeModel(
      id: 'b007',
      title: 'Network Builder',
      description: 'View 5 different alumni profiles',
      icon: '🌐',
      isEarned: false,
      category: 'Social'),
  const BadgeModel(
      id: 'b008',
      title: 'Community Hero',
      description: 'Ask 5 questions in the Q&A community',
      icon: '💬',
      isEarned: false,
      category: 'Engagement'),
  const BadgeModel(
      id: 'b009',
      title: 'Goal Setter',
      description: 'Complete your profile with name and bio',
      icon: '🏁',
      isEarned: false,
      category: 'Profile'),
  const BadgeModel(
      id: 'b010',
      title: 'Placement Ready',
      description: 'Achieve a career score above 50',
      icon: '🚀',
      isEarned: false,
      category: 'Milestone'),
];

final Map<String, List<Map<String, dynamic>>> skillPackageData = {
  'CSE': [
    {
      'skill': 'DSA + LeetCode 300+',
      'minPkg': 8.0,
      'maxPkg': 45.0,
      'count': 45
    },
    {
      'skill': 'Full Stack (React + Node)',
      'minPkg': 6.0,
      'maxPkg': 22.0,
      'count': 32
    },
    {
      'skill': 'Flutter / Mobile Dev',
      'minPkg': 5.5,
      'maxPkg': 18.0,
      'count': 18
    },
    {
      'skill': 'AWS Cloud Certified',
      'minPkg': 7.0,
      'maxPkg': 24.0,
      'count': 14
    },
    {'skill': 'ServiceNow Admin', 'minPkg': 4.5, 'maxPkg': 12.0, 'count': 22},
    {
      'skill': 'Basic (Aptitude Only)',
      'minPkg': 3.2,
      'maxPkg': 7.0,
      'count': 89
    },
  ],
  'ECE': [
    {
      'skill': 'Embedded Systems / VLSI',
      'minPkg': 5.0,
      'maxPkg': 16.0,
      'count': 12
    },
    {
      'skill': 'IT Track (Python + SQL)',
      'minPkg': 3.5,
      'maxPkg': 9.0,
      'count': 34
    },
    {'skill': 'IoT / Automation', 'minPkg': 4.0, 'maxPkg': 12.0, 'count': 8},
  ],
  'MECH': [
    {
      'skill': 'AutoCAD / SolidWorks',
      'minPkg': 3.5,
      'maxPkg': 8.0,
      'count': 20
    },
    {
      'skill': 'IT Track (fresher coding)',
      'minPkg': 3.2,
      'maxPkg': 7.0,
      'count': 15
    },
  ],
  'CIVIL': [
    {'skill': 'AutoCAD / STAAD Pro', 'minPkg': 3.0, 'maxPkg': 7.0, 'count': 18},
    {'skill': 'GIS / Remote Sensing', 'minPkg': 3.5, 'maxPkg': 8.0, 'count': 6},
  ],
};
