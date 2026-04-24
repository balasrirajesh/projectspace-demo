import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/widgets/custom_app_bar.dart';

class RoadmapScreen extends ConsumerWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(careerGoalProvider);

    final goals = [
      const _GoalOption('Flutter', '📱', AppColors.primary),
      const _GoalOption('Web Dev', '🌐', AppColors.secondary),
      const _GoalOption('AWS Cloud', '☁️', Color(0xFFFF9900)),
      const _GoalOption('ServiceNow', '🔧', Color(0xFF81B5A1)),
      const _GoalOption('FAANG', '🧠', AppColors.error),
      const _GoalOption('Data Science', '📊', AppColors.accent),
      const _GoalOption('Cybersecurity', '🔒', Color(0xFF6C5CE7)),
      const _GoalOption('Service Sector', '🏢', AppColors.textSecondary),
    ];

    final roadmapData = _buildRoadmaps();
    final items = roadmapData[goal] ?? [];
    final effectiveGoal = goal.isEmpty ? null : goal;

    // Compute real progress: only locked items with progress == 0 means 0%
    // User can tap checkmark on each step to mark complete (future feature — for now 0%)
    const completedSteps = 0;
    final totalSteps = items.length;
    final overallPct = totalSteps > 0 ? (completedSteps / totalSteps) : 0.0;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Career Roadmap'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Your Path',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textMuted)),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: goals.map((g) {
                  final sel = goal == g.label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (!sel) {
                          ref.read(careerGoalProvider.notifier).state = g.label;
                          // Award Skill Seeker badge on first goal selection
                          ref
                              .read(studentProgressProvider.notifier)
                              .setTargetCareer(g.label);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? g.color : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                              color: sel ? g.color : AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(g.emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(g.label,
                                style: TextStyle(
                                  color: sel
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            if (effectiveGoal == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    Text('🗺️', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 16),
                    Text('Select a career path above',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    SizedBox(height: 6),
                    Text(
                        'Your personalized roadmap will appear here, curated by Aditya alumni who have walked this path.',
                        style:
                            TextStyle(color: AppColors.textMuted, fontSize: 13),
                        textAlign: TextAlign.center),
                  ],
                ),
              ).animate().fadeIn(),
            if (effectiveGoal != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$effectiveGoal Progress',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                              '$completedSteps of $totalSteps milestones completed',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMuted)),
                          const SizedBox(height: 10),
                          LinearPercentIndicator(
                            lineHeight: 8,
                            percent: overallPct,
                            backgroundColor: AppColors.border,
                            progressColor: AppColors.primary,
                            barRadius: const Radius.circular(4),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${(overallPct * 100).toInt()}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontSize: 18)),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 28),
              const Text('Milestone Roadmap',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                  '${items.length} steps • Curated by alumni at ${_getCompany(effectiveGoal)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 20),
              ...List.generate(items.length, (i) {
                final item = items[i];
                final isLast = i == items.length - 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: item.isComplete
                                  ? AppColors.success
                                  : AppColors.bgCard,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: item.isComplete
                                    ? AppColors.success
                                    : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: Center(
                                child: Text(item.emoji,
                                    style: const TextStyle(fontSize: 20))),
                          ),
                          if (!isLast)
                            Container(
                                width: 2,
                                height: 80,
                                color: AppColors.border.withValues(alpha: 0.5)),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 28),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(item.title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                          color: AppColors.bgPage,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Text(item.duration,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textMuted,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(item.description,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        height: 1.5)),
                                if (item.resources.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  const Divider(height: 1),
                                  const SizedBox(height: 10),
                                  const Text('📚 Resources',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textMuted)),
                                  const SizedBox(height: 6),
                                  ...item.resources.map((r) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2),
                                        child: Row(
                                          children: [
                                            const Text('• ',
                                                style: TextStyle(
                                                    color: AppColors.primary)),
                                            Expanded(
                                                child: Text(r,
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color: AppColors
                                                            .primary))),
                                          ],
                                        ),
                                      )),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: i * 120))
                      .slideX(begin: 0.1),
                );
              }),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _getCompany(String goal) {
    const map = {
      'Flutter': 'Groww, PhonePe, Meesho',
      'Web Dev': 'Zoho, Freshworks, Razorpay',
      'AWS Cloud': 'Amazon, Deloitte, Wipro',
      'ServiceNow': 'Accenture, TCS, Infosys',
      'FAANG': 'Google, Amazon, Microsoft',
      'Data Science': 'Mu Sigma, Fractal, Amazon',
      'Cybersecurity': 'Wipro, IBM, HCL',
      'Service Sector': 'TCS, Infosys, Cognizant',
    };
    return map[goal] ?? '';
  }

  Map<String, List<_RoadmapItem>> _buildRoadmaps() {
    return {
      'Flutter': [
        const _RoadmapItem(
            'Dart Language Foundations',
            'Learn variables, functions, OOP, null safety, async/await, streams. Dart is Flutter\'s backbone — master it first.',
            '3–4 weeks',
            '🎯', [
          'dart.dev/guides (official)',
          'Dart Bootcamp — YouTube (freeCodeCamp)',
          'Book: Dart Apprentice (raywenderlich)'
        ]),
        const _RoadmapItem(
            'Flutter Basics & Widgets',
            'Understand widget tree, stateless vs stateful widgets, MaterialApp, Scaffold, Row/Column/Stack, basic layouts.',
            '3–4 weeks',
            '📱', [
          'Flutter official docs (flutter.dev)',
          'Angela Yu: Flutter Bootcamp (Udemy)',
          'The Net Ninja Flutter Series (YouTube)'
        ]),
        const _RoadmapItem(
            'State Management',
            'Master Provider first, then Riverpod. Understand setState limitations. Use ChangeNotifier, StateNotifier patterns.',
            '3 weeks',
            '⚙️', [
          'Riverpod docs (riverpod.dev)',
          'Flutter Riverpod 2.0 — YouTube (CodeWithAndrea)',
          'Provider docs on pub.dev'
        ]),
        const _RoadmapItem(
            'Navigation & Routing',
            'Learn Navigator 2.0 and GoRouter for deep linking, named routes, and parameterized navigation in real apps.',
            '1–2 weeks',
            '🗺️', [
          'GoRouter official docs',
          'Flutter Nav 2.0 — YouTube (Fireship)',
          'Medium: GoRouter complete guide'
        ]),
        const _RoadmapItem(
            'REST APIs & Networking',
            'Use HTTP package and Dio for API calls. JSON serialization with json_serializable. Error handling, loading states.',
            '2 weeks',
            '🌐', [
          'Dio pub.dev documentation',
          'Flutter HTTP + JSON — YouTube (Reso Coder)',
          'JSONPlaceholder for practice APIs'
        ]),
        const _RoadmapItem(
            'Local Storage & Firebase',
            'SharedPreferences for simple data, Hive/SQLite for complex. Firebase: Auth, Firestore, Storage, Notifications.',
            '3–4 weeks',
            '🔥', [
          'Firebase Flutter docs',
          'Flutter & Firebase — YouTube (freeCodeCamp)',
          'Hive documentation (pub.dev)'
        ]),
        const _RoadmapItem(
            'Build 3 Portfolio Projects',
            'Expense Tracker (local DB + charts), Weather App (REST API + geolocation), E-Commerce Clone (Firebase backend + Stripe).',
            '6–8 weeks',
            '🏗️', [
          'GitHub: flutter-samples (official)',
          'FlutterFire GitHub examples',
          'Dribbble for UI inspiration'
        ]),
        const _RoadmapItem(
            'Publish to Google Play Store',
            'Sign APK, configure gradle, write Play Store listing, screenshots. Your published app is the best resume item.',
            '1 week',
            '🚀', [
          'Flutter deployment docs (official)',
          'YouTube: Publish Flutter App to Play Store',
          'Google Play Console (console.developers.google.com)'
        ]),
        const _RoadmapItem(
            'Testing & Performance',
            'Unit tests, widget tests, integration tests. Use Flutter DevTools to detect jank, optimize build methods.',
            '2 weeks',
            '🧪', [
          'Flutter Testing docs (official)',
          'Effective Dart: Testing',
          'Flutter DevTools tutorial (YouTube)'
        ]),
        const _RoadmapItem(
            'Interview Preparation',
            'Common Flutter questions: lifecycle, keys, streams vs futures, BuildContext, pub.dev package evaluation. Mock interviews.',
            '2 weeks',
            '🎤', [
          'Flutter Interview Questions — GitHub repos',
          'Dart Interview Questions — InterviewBit',
          'Pramp.com for mock interviews'
        ]),
      ],
      'Web Dev': [
        const _RoadmapItem(
            'HTML & CSS Mastery',
            'Semantic HTML5, CSS Flexbox, Grid, responsive design, CSS variables, animations. Build 5 static layouts from Figma/Dribbble.',
            '3 weeks',
            '🎨', [
          'MDN Web Docs (developer.mozilla.org)',
          'Kevin Powell CSS YouTube channel',
          'Frontend Mentor challenges (frontendmentor.io)'
        ]),
        const _RoadmapItem(
            'JavaScript Essentials',
            'ES6+, DOM manipulation, Promises, async/await, fetch API, closures, prototypes, event loop. Must be solid here.',
            '4–5 weeks',
            '🟨', [
          'javascript.info (best free resource)',
          'Eloquent JavaScript (free ebook)',
          'freeCodeCamp JS curriculum'
        ]),
        const _RoadmapItem(
            'React.js',
            'JSX, components, props/state, hooks (useState, useEffect, useContext, useReducer), React Router, forms, error boundaries.',
            '4–5 weeks',
            '⚛️', [
          'React official docs (react.dev)',
          'The Odin Project React path (free)',
          'Scrimba React course (interactive)'
        ]),
        const _RoadmapItem(
            'Node.js & Express',
            'REST API design, middleware, authentication, file uploads, environment variables. Build a complete backend for your React apps.',
            '4 weeks',
            '🟢', [
          'NodeJS official docs',
          'Server-side dev — MDN',
          'Traversy Media: Node.js Crash Course (YouTube)'
        ]),
        const _RoadmapItem(
            'Databases — SQL & NoSQL',
            'PostgreSQL: queries, joins, indexing. MongoDB with Mongoose: CRUD, aggregation pipelines, relationships. Know when to use each.',
            '3 weeks',
            '🗄️', [
          'PostgreSQL Tutorial (postgresqltutorial.com)',
          'MongoDB University (free courses)',
          'Prisma ORM docs (highly recommended for full-stack)'
        ]),
        const _RoadmapItem(
            'Authentication & Security',
            'JWT, session-based auth, OAuth (Google login), bcrypt password hashing, CORS, HTTPS, input sanitization, SQL injection prevention.',
            '2 weeks',
            '🔐', [
          'Auth0 docs (free tier)',
          'OWASP Top 10 (must read)',
          'Passport.js documentation'
        ]),
        const _RoadmapItem(
            'Building & Deploying',
            'Deploy to Vercel (frontend) + Render/Railway (backend). Docker basics, CI/CD with GitHub Actions. Configure custom domains.',
            '2 weeks',
            '🌍', [
          'Vercel docs (vercel.com)',
          'Railway.app documentation',
          'GitHub Actions quickstart'
        ]),
        const _RoadmapItem(
            '3 Complete Projects',
            'Project 1: Blog platform (CRUD + auth). Project 2: Job board with search/filter. Project 3: Real-time chat (Socket.io). All deployed live.',
            '8–10 weeks',
            '💼', [
          'Socket.io docs',
          'Full Stack Open course (University of Helsinki — free)',
          'YouTube: MERN Stack Projects'
        ]),
        const _RoadmapItem(
            'Web Dev Interview Prep',
            'HTTP/HTTPS, REST vs GraphQL, CORS, caching, performance (lazy loading, code splitting), CSS specificity, React reconciliation.',
            '2 weeks',
            '🎤', [
          'Frontend Interview Handbook (frontendinterviewhandbook.com, free)',
          'Grepper (codegrepper.com)',
          'Big Frontend podcast'
        ]),
      ],
      'AWS Cloud': [
        const _RoadmapItem(
            'Cloud Fundamentals',
            'What is cloud computing, IaaS/PaaS/SaaS, the difference between public/private/hybrid cloud. Why AWS dominates enterprise.',
            '1 week',
            '☁️', [
          'AWS Cloud Practitioner Essentials (free on Skill Builder)',
          'Cloud Computing in 100 Seconds — Fireship (YouTube)',
          'A Cloud Guru blog'
        ]),
        const _RoadmapItem(
            'AWS Cloud Practitioner (CLF-C02)',
            'IAM basics, EC2, S3, RDS, Lambda, pricing model, shared responsibility, AWS Well-Architected Framework. First cert.',
            '4–5 weeks',
            '📜', [
          'AWS Skill Builder CLF-C02 path (free)',
          'freeCodeCamp AWS Cloud Practitioner 2024 (YouTube, free)',
          'Examtopics practice exams (free tier)'
        ]),
        const _RoadmapItem(
            'Core Services Deep Dive',
            'EC2 instances, AMIs, security groups, VPC/subnets, S3 buckets with policies, CloudFront CDN, Route 53, Elastic Load Balancer.',
            '4 weeks',
            '⚡', [
          'AWS Documentation (official)',
          'Cantrill.io courses (deep but worth it)',
          'Tutorials Dojo cheat sheets'
        ]),
        const _RoadmapItem(
            'Databases on AWS',
            'RDS (MySQL/PostgreSQL), DynamoDB (NoSQL), ElastiCache (Redis), Aurora. Understand multi-AZ, read replicas, backup strategies.',
            '2 weeks',
            '🗄️', [
          'AWS Database services docs',
          'DynamoDB guide — Amazon',
          'YouTube: DynamoDB for beginners'
        ]),
        const _RoadmapItem(
            'Serverless & Lambda',
            'Build Lambda functions in Python/Node.js. API Gateway, Step Functions, SQS/SNS for event-driven architectures. Cost benefits.',
            '3 weeks',
            '⚡', [
          'AWS Lambda docs',
          'Serverless Framework (serverless.com)',
          'Build a serverless API — YouTube (AWS official)'
        ]),
        const _RoadmapItem(
            'Solutions Architect Associate (SAA-C03)',
            'Advanced networking, auto-scaling, disaster recovery, storage tiers, hybrid architectures, security services. The key cert.',
            '6–8 weeks',
            '🏆', [
          'Stephane Maarek SAA-C03 (Udemy — buy on sale ₹499)',
          'Practice exams: Tutorials Dojo',
          'AWS whitepapers: Well-Architected Framework'
        ]),
        const _RoadmapItem(
            'Infrastructure as Code',
            'CloudFormation and Terraform basics. Write YAML templates to create entire environments programmatically.',
            '3 weeks',
            '📄', [
          'AWS CloudFormation docs',
          'Terraform by HashiCorp — beginner tutorial',
          'freeCodeCamp: Terraform 12 hours (YouTube)'
        ]),
        const _RoadmapItem(
            'Real Project + Apply',
            'Deploy a full-stack app on AWS: React frontend (S3+CloudFront), Node backend (EC2+ELB), PostgreSQL (RDS), secrets in Secrets Manager.',
            '4–5 weeks',
            '🚀', [
          'AWS Getting Started hands-on labs (free)',
          'AWS Workshops (workshops.aws)',
          'GitHub: awesome-aws-samples'
        ]),
      ],
      'ServiceNow': [
        const _RoadmapItem(
            'ITSM Fundamentals',
            'IT Service Management concepts: Incident, Problem, Change, Request management. ITIL v4 framework basics. Why enterprises use ServiceNow.',
            '1–2 weeks',
            '📋', [
          'ITIL 4 Foundation — Axelos free resources',
          'ServiceNow ITSM overview (servicenow.com)',
          'YouTube: ITIL explained in 15 minutes'
        ]),
        const _RoadmapItem(
            'ServiceNow Platform Basics',
            'Get a free Personal Developer Instance (PDI). Navigate the platform: tables, forms, lists, fields, UI policies, business rules (concept level).',
            '2–3 weeks',
            '🖥️', [
          'developer.servicenow.com (free PDI)',
          'ServiceNow Developer Training — Now Learning (free)',
          'ServiceNow Docs (official)'
        ]),
        const _RoadmapItem(
            'Certified System Administrator (CSA)',
            'User management, data management, import sets, update sets, scheduled jobs, email notifications, SLA management. The foundational cert.',
            '6–8 weeks',
            '📜', [
          'Now Learning CSA path (free on developer portal)',
          'ServiceNow Mock Exams — NowLearning',
          'Mark Stanger CSA study guide'
        ]),
        const _RoadmapItem(
            'Scripting & Development',
            'JavaScript on ServiceNow: Business Rules, Client Scripts, Script Includes, UI Actions, Scheduled Jobs. GlideRecord API.',
            '4–5 weeks',
            '📝', [
          'ServiceNow Scripting API docs',
          'Now Learning Application Developer path',
          'YouTube: ServiceNow Scripting Crash Course'
        ]),
        const _RoadmapItem(
            'Flow Designer & Automation',
            'Build automated workflows using Flow Designer (no-code/low-code). Triggers, conditions, actions. Integration Hub for external APIs.',
            '3 weeks',
            '⚙️', [
          'ServiceNow Flow Designer docs',
          'Now Learning: Flow designer course (free)',
          'YouTube: Flow Designer tutorial'
        ]),
        const _RoadmapItem(
            'Certified Application Developer (CAD)',
            'Build scoped applications, tables, roles, ACLs, custom widgets. More advanced than CSA and makes you more hireable.',
            '6–8 weeks',
            '🏅', [
          'Now Learning CAD path',
          'ServiceNow GitHub (github.com/ServiceNow)',
          'SN Pro Tips YouTube channel'
        ]),
        const _RoadmapItem(
            'Apply to ServiceNow Practices',
            'Target TCS Digital, Infosys BPO, Accenture Technology, Deloitte. They all have ServiceNow CoEs hiring freshers with CSA certification.',
            '2 weeks',
            '🎯', [
          'LinkedIn: "ServiceNow fresher" jobs',
          'NowCommunity forums (community.servicenow.com)',
          'ServiceNow ecosystem blog'
        ]),
      ],
      'FAANG': [
        const _RoadmapItem(
            'DSA Fundamentals',
            'Arrays, strings, linked lists, stacks, queues, hashmaps. Solve 50 Easy problems on LeetCode. Build confidence before moving to medium.',
            '6–8 weeks',
            '🔢', [
          'LeetCode (leetcode.com)',
          'Neetcode.io (structured roadmap)',
          'Book: Cracking the Coding Interview (McDowell)'
        ]),
        const _RoadmapItem(
            'Core DSA — Trees & Graphs',
            'Binary trees (DFS/BFS), BST, heaps, tries. Graph: DFS, BFS, Dijkstra, Union-Find. These are the most tested at top companies.',
            '6–8 weeks',
            '🌳', [
          'Neetcode 150 playlist (YouTube)',
          'AlgoExpert (paid but worth it)',
          'Graph Theory lecture — Stanford (free)'
        ]),
        const _RoadmapItem(
            'Dynamic Programming',
            'All major DP patterns: 0/1 knapsack, LCS, LIS, grid DP, interval DP, bitmask DP. Solve 50+ medium/hard DP problems.',
            '6–8 weeks',
            '🧩', [
          'Aditya Verma DP playlist (YouTube, free)',
          'Neetcode DP section',
          'Book: Elements of Programming Interviews'
        ]),
        const _RoadmapItem(
            'CS Fundamentals',
            'OS: processes/threads, deadlock, memory management. Networks: TCP/IP, HTTP/HTTPS, REST. DBMS: indexing, transactions, normalization. All frequently asked at FAANG.',
            '4 weeks',
            '📚', [
          'OS GATE lectures — YouTube (Neso Academy)',
          'Computer Networks — Gate Smashers (YouTube)',
          'Book: Database System Concepts (Silberschatz)'
        ]),
        const _RoadmapItem(
            'System Design (LLD)',
            'Object-Oriented Design: design patterns (Singleton, Factory, Observer, Strategy). Design chess, parking lot, library system, ATM. Clean code principles.',
            '4–5 weeks',
            '🏗️', [
          'Head First Design Patterns (O\'Reilly)',
          'Refactoring Guru (refactoring.guru — free)',
          'NeetCode System Design playlist'
        ]),
        const _RoadmapItem(
            'System Design (HLD)',
            'Scalability, load balancing, caching (Redis), CDN, message queues (Kafka), database sharding, CAP theorem. Even SDE-1 gets basic HLD.',
            '4–5 weeks',
            '⚙️', [
          'System Design Primer (GitHub — free)',
          'ByteByteGo YouTube (free)',
          'Book: Designing Data-Intensive Applications (Kleppmann)'
        ]),
        const _RoadmapItem(
            'Behavioral + Leadership Principles',
            'Amazon LP, Google\'s Googliness, Microsoft GROWTH. STAR format stories from college projects. Must prepare 10–15 strong examples.',
            '2 weeks',
            '🎤', [
          'Jeff H Sipe: Amazon LP on YouTube',
          'Exponent.fm behavioral interview prep',
          'STAR interview template — Indeed.com'
        ]),
        const _RoadmapItem(
            'Mock Interviews & Apply',
            'Do 20+ mock interviews on Pramp.com (free). Track LeetCode biweekly contests. Apply via referrals, LinkedIn, direct career portals.',
            '4 weeks',
            '🚀', [
          'Pramp.com (free mock interviews)',
          'Interviewing.io (paid peer mocks)',
          'Blind app (for FAANG prep community)'
        ]),
      ],
      'Data Science': [
        const _RoadmapItem(
            'Python for Data Science',
            'Python basics, NumPy arrays, Pandas DataFrames, data cleaning, matplotlib/seaborn for visualization. This is the foundation everything else builds on.',
            '4–5 weeks',
            '🐍', [
          'Kaggle Python course (free)',
          'CS50P — Harvard Python (free, YouTube)',
          'Book: Python for Data Analysis (Wes McKinney)'
        ]),
        const _RoadmapItem(
            'Statistics & Math',
            'Descriptive statistics, probability distributions, hypothesis testing, p-values, confidence intervals, linear algebra basics. Without this, you\'ll never understand ML.',
            '4 weeks',
            '📐', [
          'Khan Academy Statistics (free)',
          'StatQuest with Josh Starmer (YouTube — best explains)',
          'Book: Think Stats (free online)'
        ]),
        const _RoadmapItem(
            'Machine Learning Fundamentals',
            'Supervised (regression, classification, SVM, decision trees, random forests, XGBoost) and unsupervised (clustering, PCA) algorithms. scikit-learn library.',
            '6–8 weeks',
            '🤖', [
          'Coursera: Andrew Ng ML Specialization (audit free)',
          'Kaggle Intro to ML course (free)',
          'Book: Hands-On ML with Scikit-Learn (Géron)'
        ]),
        const _RoadmapItem(
            'Deep Learning Basics',
            'Neural networks, backpropagation, CNNs (image classification), RNNs/LSTMs (sequence data). TensorFlow or PyTorch.',
            '6–8 weeks',
            '🧠', [
          'fast.ai (free, practical DL)',
          '3Blue1Brown: Neural Networks series (YouTube)',
          'PyTorch official tutorials (free)'
        ]),
        const _RoadmapItem(
            'Real Kaggle Project',
            'Join 3 Kaggle competitions (start with Titanic survival, House Prices, MNIST). Aim for Top 30% to show on resume. Document your EDA and modeling process.',
            '4–6 weeks',
            '🏆', [
          'Kaggle.com (free datasets + competitions)',
          'Abhishek Thakur Kaggle tutorials (YouTube)',
          'Kaggle kernels (learn from top solutions)'
        ]),
        const _RoadmapItem(
            'SQL for Data Science',
            'Window functions, CTEs, query optimization, analytical functions. Join data from multiple tables. Practice on real datasets.',
            '2–3 weeks',
            '🗄️', [
          'Mode Analytics SQL Tutorial (free)',
          'SQLZoo (interactive, free)',
          'LeetCode SQL 50 problems (free)'
        ]),
        const _RoadmapItem(
            'MLOps Basics',
            'MLflow for experiment tracking, Docker for containerizing models, REST API for model serving (FastAPI), model monitoring. Companies want this now.',
            '3–4 weeks',
            '⚙️', [
          'MLflow docs (mlflow.org)',
          'FastAPI tutorial (fastapi.tiangolo.com)',
          'YouTube: MLOps for beginners (Weights & Biases)'
        ]),
        const _RoadmapItem(
            'Apply to DS Roles',
            'Target: Mu Sigma, Fractal Analytics, Amazon (Analytics), Flipkart Data, Jio Platforms. Portfolio: 3 Kaggle notebooks + 1 real-world project on GitHub.',
            '2 weeks',
            '🚀', [
          'Analytics Vidhya jobs portal',
          'LinkedIn: "data scientist fresher" India',
          'AV competitions (machinelearning.analyticsvidhya.com)'
        ]),
      ],
      'Cybersecurity': [
        const _RoadmapItem(
            'Networking Fundamentals',
            'OSI model, TCP/IP, DNS, DHCP, HTTP/HTTPS, firewalls, VPN, subnetting. You cannot do security without understanding networking deeply.',
            '4–5 weeks',
            '🌐', [
          'Computer Networking — Cisco NetAcad (free)',
          'Professor Messer CompTIA Network+ (YouTube, free)',
          'TryHackMe: Pre-Security path (free)'
        ]),
        const _RoadmapItem(
            'Linux Essentials',
            'File system navigation, user permissions, bash scripting, process management, cron, SSH, package management. Most security tools run on Linux.',
            '3–4 weeks',
            '🐧', [
          'OverTheWire: Bandit (hands-on Linux wargame, free)',
          'Linux Journey (linuxjourney.com, free)',
          'The Linux Command Line (free ebook)'
        ]),
        const _RoadmapItem(
            'Ethical Hacking Basics',
            'Reconnaissance, scanning (Nmap), vulnerability assessment, basic exploitation concepts. Understand CVEs, CVSS scoring, what a pentester does.',
            '4–5 weeks',
            '🎭', [
          'TryHackMe Jr Pentester path (₹500/month)',
          'HackTheBox Starting Point (free)',
          'Book: The Hacker Playbook 3 (Peter Kim)'
        ]),
        const _RoadmapItem(
            'Security Tools',
            'Wireshark (packet analysis), Burp Suite (web app testing), Metasploit (exploitation framework), John the Ripper (password cracking), Kali Linux.',
            '3–4 weeks',
            '🛠️', [
          'TCM Security on YouTube (free extensive content)',
          'Burp Suite Academy (portswigger.net/web-security — free)',
          'Kali Linux docs (kali.org)'
        ]),
        const _RoadmapItem(
            'Web Application Security',
            'OWASP Top 10: SQL Injection, XSS, CSRF, IDOR, Broken Auth. Practice on DVWA, HackTheBox web challenges, PortSwigger labs.',
            '5–6 weeks',
            '🕸️', [
          'OWASP WebGoat (free lab)',
          'PortSwigger Web Security Academy (portswigger.net — free best labs)',
          'IppSec YouTube (HackTheBox walkthrough tutorials)'
        ]),
        const _RoadmapItem(
            'CTF Practice',
            'Capture The Flag competitions build real skills fast. Join PicoCTF (beginner), TryHackMe CTFs, and CTFtime.org listed events.',
            '4 weeks (ongoing)',
            '🚩', [
          'PicoCTF (free beginner CTF platform)',
          'CTFtime.org (event calendar)',
          'CTF 101 guide (ctf101.org)'
        ]),
        const _RoadmapItem(
            'Certification + Apply',
            'CompTIA Security+ is the entry-level cert recognized widely. CEH for penetration testing. Target: Wipro Cybersecurity CoE, IBM X-Force, HCL AppScan, CDOT.',
            '6–8 weeks',
            '🎓', [
          'CompTIA Security+ Darill Gibson (free resources)',
          'Professor Messer Security+ (YouTube, free)',
          'LinkedIn: cybersecurity analyst fresher India'
        ]),
      ],
      'Service Sector': [
        const _RoadmapItem(
            'Quantitative Aptitude',
            'Percentages, profits/loss, time-speed-distance, work-time, series, averages, ratios. All major service companies use aptitude as the primary filter.',
            '6–8 weeks',
            '📊', [
          'RS Aggarwal Quantitative Aptitude (book)',
          'IndiaBix.com (free practice problems)',
          'Quantum CAT (Sarvesh Kumar Verma)'
        ]),
        const _RoadmapItem(
            'Verbal Ability & Reading',
            'Reading comprehension, grammar (tenses, articles, prepositions), error detection, vocabulary, sentence correction. Tested heavily in TCS, Wipro, Cognizant.',
            '4–5 weeks',
            '📖', [
          'The Hindu editorial reading (daily habit)',
          'IndiaBix Verbal section',
          'Wren & Martin: High School English Grammar'
        ]),
        const _RoadmapItem(
            'Logical & Analytical Reasoning',
            'Puzzles, blood relations, syllogisms, seating arrangement, coding-decoding, directional sense, number series.',
            '4 weeks',
            '🧩', [
          'RS Aggarwal Verbal & Non-Verbal Reasoning',
          'IndiaBix Logical Reasoning (free)',
          'M4Maths.com (free practice tests)'
        ]),
        const _RoadmapItem(
            'Basic Programming',
            'C or Python basics: loops, arrays, strings, functions, file handling. Mass recruiters test basic coding — 1–2 easy problems in 30–45 min.',
            '4–5 weeks',
            '💻', [
          'GeeksforGeeks School (free)',
          'HackerRank Problem Solving 30 days (free)',
          'W3Schools Python Tutorial (free)'
        ]),
        const _RoadmapItem(
            'Company-Specific Preparation',
            'TCS: NQT (digital + prime). Infosys: InfyTQ + Smart Hiring. Wipro: NLTH. Accenture: Cognitive + Technical. Know the test pattern for each company you apply to.',
            '3–4 weeks',
            '🏢', [
          'PrepInsta TCS NQT preparation',
          'InfyTQ app (Infosys official)',
          'Accenture Mock Tests — Prepinsta (free)'
        ]),
      ],
    };
  }
}

class _GoalOption {
  final String label, emoji;
  final Color color;
  const _GoalOption(this.label, this.emoji, this.color);
}

class _RoadmapItem {
  final String title, description, duration, emoji;
  final List<String> resources;
  bool get isComplete => false;
  const _RoadmapItem(
      this.title, this.description, this.duration, this.emoji, this.resources);
}
