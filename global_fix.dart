import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final libDir = Directory('lib');
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  final replacements = {
    // 1. Package name and structural cleanup
    'package:alumini_screen/': 'package:graduway/',
    'package:graduway/src/': 'package:graduway/',
    'package:graduway/features/': 'package:graduway/',
    'package:graduway/core/': 'package:graduway/',
    
    // 2. Theme and Shared
    'package:graduway/shared/core/theme/app_theme.dart': 'package:graduway/theme/app_theme.dart',
    'package:graduway/shared/core/theme/app_colors.dart': 'package:graduway/theme/app_colors.dart',
    'package:graduway/student/core/theme/app_theme.dart': 'package:graduway/theme/app_theme.dart',
    'package:graduway/alumni/shared/core/theme/app_theme.dart': 'package:graduway/theme/app_theme.dart',
    'package:graduway/shared/widgets/': 'package:graduway/widgets/',
    'package:graduway/shared/models/': 'package:graduway/models/',
    'package:graduway/shared/services/': 'package:graduway/services/',
    'package:graduway/shared/providers/': 'package:graduway/providers/',
    
    // 3. Specific Provider Renames
    'LegacyAuthProvider': 'AuthProvider',
    '_LegacyAuthProvider': '_authProvider',
    
    // 4. Broken paths for common pages
    'package:graduway/shared/pages/sessions_page.dart': 'package:graduway/student/mentorship/sessions_page.dart',
    'package:graduway/shared/pages/mentorship_page.dart': 'package:graduway/student/profile/mentorship_page.dart',
    'package:graduway/shared/pages/mentorship_request_form.dart': 'package:graduway/widgets/mentorship_request_form.dart',
    'package:graduway/shared/widgets/interactive_classroom_page.dart': 'package:graduway/widgets/interactive_classroom_page.dart',
    
    // 5. Cleanup of common mismatches
    'package:graduway/alumni/shared/classroom/interactive_classroom_page.dart': 'package:graduway/widgets/interactive_classroom_page.dart',
    'package:graduway/alumni/shared/providers/': 'package:graduway/alumni/shared/providers/', // Stays for now if not moved
  };

  for (var file in dartFiles) {
    var content = file.readAsStringSync();
    var originalContent = content;

    replacements.forEach((oldText, newText) {
      content = content.replaceAll(oldText, newText);
    });

    // Special fix for AppColors -> LegacyAppColors if needed, but we found AppColors is the new one.
    // However, some files might still use LegacyAppColors. Let's unify to AppColors.
    content = content.replaceAll('LegacyAppColors', 'AppColors');

    if (content != originalContent) {
      file.writeAsStringSync(content);
      print('Fixed: ${file.path}');
    }
  }

  print('Global fix complete!');
}
