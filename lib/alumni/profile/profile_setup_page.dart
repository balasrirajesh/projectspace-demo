import 'package:graduway/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalSteps = 4;

  // controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _branchController = TextEditingController();
  final _gradYearController = TextEditingController();
  final _bioController = TextEditingController();
  final _jobController = TextEditingController();
  final _companyController = TextEditingController();
  final _skillsController = TextEditingController();

  // Social/Academic Link Controllers
  final _linkedInController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();

  List<String> _selectedSkills = [];
  final List<String> _suggestedSkills = [
    "Flutter",
    "Dart",
    "System Design",
    "Backend",
    "React",
    "Cloud",
    "UI/UX",
    "Data Science",
    "Python",
    "Java",
    "Node.js",
    "AWS",
    "Docker",
    "Kubernetes",
    "Machine Learning",
    "Product Management"
  ];

  // Verification State
  String _selectedVerificationMethod = "id"; // Default to ID upload
  String? _selectedFileName;
  bool _isUploading = false;

  static const List<String> _departments = [
    "Computer Science & Engineering",
    "Information Technology",
    "Electronics & Communication",
    "Electrical Engineering",
    "Mechanical Engineering",
    "Civil Engineering",
    "Chemical Engineering",
    "Aeronautical Engineering",
    "Biotechnology",
    "Management Studies",
    "Other"
  ];

  static final List<String> _graduationYears = List.generate(
      45, (index) => (DateTime.now().year + 4 - index).toString());

  void _nextPage() {
    if (_currentPage < _totalSteps - 1) {
      _pageController.nextPage(duration: 600.ms, curve: Curves.easeInOutCubic);
    } else {
      _finishSetup();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: 600.ms, curve: Curves.easeInOutCubic);
    }
  }

  void _finishSetup() async {
    final auth = context.read<AuthProvider>();

    // Simulate a premium verification scan
    _showVerificationOverlay();

    // Give some time for the scan animation to feel premium
    await Future.delayed(const Duration(seconds: 3));

    await auth.updateProfile(
      fullName: _fullNameController.text,
      phoneNumber: _phoneController.text,
      branch: _branchController.text,
      graduationYear: _gradYearController.text,
      bio: _bioController.text,
      currentJob: _jobController.text,
      company: _companyController.text,
      skills: _selectedSkills,
      linkedInUrl: _linkedInController.text,
      githubUrl: _githubController.text,
      portfolioUrl: _portfolioController.text,
    );

    await auth.submitForVerification();

    if (mounted) {
      // Close scan dialog
      Navigator.pop(context);
      // Navigate to Home/Dashboard (Assuming '/' or '/dashboard')
      // For now, using Navigator.pushReplacement to main app view
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  void _showVerificationOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PremiumVerificationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildPersonalStep(),
                  _buildProfessionalStep(),
                  _buildSocialStep(),
                  _buildVerificationStep(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Step ${_currentPage + 1} of $_totalSteps",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
              Text(
                "${((_currentPage + 1) / _totalSteps * 100).toInt()}% Complete",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedContainer(
                duration: 400.ms,
                height: 6,
                width: MediaQuery.of(context).size.width *
                        ((_currentPage + 1) / _totalSteps) -
                    48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalStep() {
    return _buildStepLayout(
      title: "Tell us about yourself",
      subtitle: "Let's start with the basics of your profile.",
      children: [
        _buildAnimatedField(
          index: 0,
          child: _buildInputField(
              "Full Name", _fullNameController, Icons.person_outline_rounded),
        ),
        _buildAnimatedField(
          index: 1,
          child: _buildInputField(
              "Phone Number", _phoneController, Icons.phone_android_rounded,
              keyboardType: TextInputType.phone),
        ),
        _buildAnimatedField(
          index: 2,
          child: _buildInputField("Bio / Mentoring Philosophy", _bioController,
              Icons.description_outlined,
              maxLines: 3),
        ),
      ],
    );
  }

  Widget _buildProfessionalStep() {
    return _buildStepLayout(
      title: "Professional Record",
      subtitle: "Students look for mentors with specific expertise.",
      children: [
        _buildAnimatedField(
          index: 0,
          child: _buildDropdownField(
            "Branch / Department",
            _branchController,
            Icons.account_balance_rounded,
            _departments,
          ),
        ),
        _buildAnimatedField(
          index: 1,
          child: _buildDropdownField(
            "Graduation Year",
            _gradYearController,
            Icons.calendar_today_rounded,
            _graduationYears,
          ),
        ),
        _buildAnimatedField(
            index: 2,
            child: _buildInputField(
                "Current Company", _companyController, Icons.business_rounded)),
        _buildAnimatedField(
            index: 3,
            child: _buildInputField("Current Job Title", _jobController,
                Icons.work_outline_rounded)),
        const SizedBox(height: 24),
        _buildAnimatedField(
          index: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Expertise & Skills",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const Spacer(),
                  Text("${_selectedSkills.length} selected",
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _suggestedSkills.map((skill) {
                    final isSelected = _selectedSkills.contains(skill);
                    return AnimatedContainer(
                      duration: 200.ms,
                      child: FilterChip(
                        label: Text(skill),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            if (val)
                              _selectedSkills.add(skill);
                            else
                              _selectedSkills.remove(skill);
                          });
                        },
                        backgroundColor: Colors.grey[50],
                        selectedColor: AppColors.primary,
                        checkmarkColor: Colors.white,
                        elevation: isSelected ? 4 : 0,
                        pressElevation: 8,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey[300]!,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialStep() {
    return _buildStepLayout(
      title: "Education & Professional Links",
      subtitle: "These links are mandatory for academic verification.",
      children: [
        _buildAnimatedField(
          index: 0,
          child: _buildInputField(
              "LinkedIn Profile URL", _linkedInController, Icons.link_rounded),
        ),
        _buildAnimatedField(
          index: 1,
          child: _buildInputField("GitHub / ResearchGate URL",
              _githubController, Icons.code_rounded),
        ),
        _buildAnimatedField(
          index: 2,
          child: _buildInputField("Personal Portfolio / Official Webpage",
              _portfolioController, Icons.language_rounded),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Providing valid professional links helps in faster verification and builds more trust with students.",
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildVerificationStep() {
    return _buildStepLayout(
      title: "Join the verified group",
      subtitle: "Secure your spot in the premium alumni directory.",
      children: [
        _buildAnimatedField(
          index: 0,
          child: GestureDetector(
            onTap: () => setState(() => _selectedVerificationMethod = 'email'),
            child: _buildVerificationCard(
              "College Email",
              "Automatic verification via .edu or official email.",
              Icons.alternate_email_rounded,
              isSelected: _selectedVerificationMethod == 'email',
            ),
          ),
        ),
        _buildAnimatedField(
          index: 1,
          child: GestureDetector(
            onTap: () => setState(() => _selectedVerificationMethod = 'id'),
            child: _buildVerificationCard(
              "Upload ID / Degree",
              "Manual review of your credentials by our admin team.",
              Icons.badge_rounded,
              isSelected: _selectedVerificationMethod == 'id',
            ),
          ),
        ),
        const SizedBox(height: 32),
        if (_selectedVerificationMethod == 'id')
          _buildAnimatedField(
            index: 2,
            child: GestureDetector(
              onTap: _isUploading
                  ? null
                  : () async {
                      setState(() => _isUploading = true);
                      await Future.delayed(
                          const Duration(seconds: 1)); // Simulate picker
                      setState(() {
                        _selectedFileName = "degree_certificate.pdf";
                        _isUploading = false;
                      });
                    },
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _selectedFileName != null
                          ? Colors.green
                          : Colors.grey[300]!,
                      width: 1.5,
                      style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isUploading)
                      const CircularProgressIndicator(strokeWidth: 2)
                    else if (_selectedFileName != null)
                      const Icon(Icons.check_circle_rounded,
                          size: 40, color: Colors.green)
                    else
                      const Icon(Icons.cloud_upload_outlined,
                          size: 40, color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text(
                        _isUploading
                            ? "Uploading..."
                            : (_selectedFileName ?? "Tap to upload document"),
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: _selectedFileName != null
                                ? Colors.green
                                : AppColors.textPrimary)),
                    if (_selectedFileName == null && !_isUploading)
                      const Text("PDF, JPG, PNG (Max 5MB)",
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textLight)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStepLayout(
      {required String title,
      required String subtitle,
      required List<Widget> children}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold, height: 1.2))
              .animate()
              .fadeIn()
              .slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textSecondary))
              .animate()
              .fadeIn(delay: 200.ms)
              .slideX(begin: -0.1),
          const SizedBox(height: 40),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAnimatedField({required int index, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: child
          .animate()
          .fadeIn(delay: (400 + (index * 100)).ms)
          .slideY(begin: 0.1),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, IconData icon,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller,
      IconData icon, List<String> items) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          controller.text = newValue!;
        });
      },
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
    );
  }

  Widget _buildVerificationCard(String title, String desc, IconData icon,
      {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: isSelected ? 2 : 1.5),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textLight),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle,
                color: AppColors.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                child: const Text("Back"),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _nextPage,
              child: Text(_currentPage == _totalSteps - 1
                  ? "Complete Setup"
                  : "Continue"),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumVerificationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _ScanningAnimation(),
            const SizedBox(height: 24),
            Text(
              "Verifying Identity",
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "We are running a security scan on your professional credentials.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}

class _ScanningAnimation extends StatefulWidget {
  const _ScanningAnimation();

  @override
  State<_ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<_ScanningAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        children: [
          const Icon(Icons.verified_user_outlined,
              size: 100, color: Colors.grey),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                top: _controller.value * 100,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

