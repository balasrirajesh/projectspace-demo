import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('Run this from the project root.');
    return;
  }

  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  print('Found ${dartFiles.length} dart files.');

  // 1. Convert all relative imports to absolute package imports
  final importRegex = RegExp(r'''(import|export)\s+['"]([^'"]+)['"](.*);''');
  
  for (var file in dartFiles) {
    var content = file.readAsStringSync();
    var newContent = content.replaceAllMapped(importRegex, (match) {
      final keyword = match.group(1)!;
      final importPath = match.group(2)!;
      final rest = match.group(3)!;
      
      if (importPath.startsWith('package:') || importPath.startsWith('dart:')) {
        return match.group(0)!; // leave alone
      }
      
      // It's a relative import.
      final fileDir = file.parent.path;
      final resolvedPath = p.normalize(p.join(fileDir, importPath));
      
      final parts = p.split(resolvedPath);
      final libIndex = parts.indexOf('lib');
      if (libIndex != -1) {
        final packagePath = parts.sublist(libIndex + 1).join('/');
        return "$keyword 'package:graduway/$packagePath'$rest;";
      }
      return match.group(0)!;
    });
    
    if (content != newContent) {
      file.writeAsStringSync(newContent);
    }
  }

  print('Phase 1: Converted relative imports to absolute.');

  // 2. Compute Moves
  final fileMoves = <String, String>{}; // old path relative to lib -> new path relative to lib
  final newFiles = <File>[]; // Store the new file objects to update imports later
  
  for (var file in dartFiles) {
    final relativeToLib = p.relative(file.path, from: 'lib').replaceAll('\\', '/');
    final newRelative = getNewPath(relativeToLib);
    
    fileMoves[relativeToLib] = newRelative;
  }

  // Ensure directories exist and move files
  for (var file in dartFiles) {
    final oldRelative = p.relative(file.path, from: 'lib').replaceAll('\\', '/');
    final newRelative = fileMoves[oldRelative]!;
    
    if (oldRelative != newRelative) {
      final newPath = p.join('lib', newRelative);
      final newFile = File(newPath);
      newFile.parent.createSync(recursive: true);
      
      final movedFile = file.renameSync(newPath);
      newFiles.add(movedFile);
    } else {
      newFiles.add(file);
    }
  }

  print('Phase 2: Moved files.');

  // 3. Update absolute imports with new paths
  for (var file in newFiles) {
    var content = file.readAsStringSync();
    var originalContent = content;
    
    fileMoves.forEach((oldRelative, newRelative) {
      if (oldRelative != newRelative) {
        content = content.replaceAll(
          "package:graduway/$oldRelative",
          "package:graduway/$newRelative",
        );
      }
    });
    
    if (content != originalContent) {
      file.writeAsStringSync(content);
    }
  }

  print('Phase 3: Updated absolute imports.');
  
  // Cleanup empty directories
  _deleteEmptyDirs(libDir);
  print('Done!');
}

String getNewPath(String oldPath) {
  var path = oldPath;
  
  // Core
  if (path.startsWith('theme/')) return 'core/' + path;
  if (path.startsWith('routing/')) return 'core/' + path;
  if (path.startsWith('providers/')) return 'core/' + path;
  if (path.startsWith('screens/shell/')) return path.replaceFirst('screens/shell/', 'core/routing/shells/');
  
  // Shared
  if (path.startsWith('widgets/')) return 'shared/' + path;
  if (path.startsWith('src/shared/')) return path.replaceFirst('src/shared/', 'shared/');
  
  // Auth
  if (path.startsWith('screens/auth/')) return path.replaceFirst('screens/', 'features/');
  if (path.startsWith('screens/onboarding/')) return path.replaceFirst('screens/', 'features/auth/');
  if (path.startsWith('screens/splash/')) return path.replaceFirst('screens/', 'features/auth/');
  if (path.startsWith('src/login/')) return path.replaceFirst('src/', 'features/auth/');
  if (path.startsWith('src/signup/')) return path.replaceFirst('src/', 'features/auth/');
  
  // Admin
  if (path.startsWith('screens/admin/')) return path.replaceFirst('screens/', 'features/');
  if (path.startsWith('src/admin/')) return path.replaceFirst('src/', 'features/');
  
  // Alumni
  if (path.startsWith('screens/alumni_dashboard/')) return path.replaceFirst('screens/alumni_dashboard/', 'features/alumni/dashboard/');
  if (path.startsWith('screens/alumni/')) return path.replaceFirst('screens/', 'features/');
  if (path.startsWith('src/alumni/')) return path.replaceFirst('src/', 'features/');
  
  // Student
  if (path.startsWith('screens/home/')) return path.replaceFirst('screens/', 'features/student/');
  if (path.startsWith('screens/qa/')) return path.replaceFirst('screens/', 'features/student/');
  if (path.startsWith('screens/roadmap/')) return path.replaceFirst('screens/', 'features/student/');
  if (path.startsWith('screens/badges/')) return path.replaceFirst('screens/', 'features/student/');
  if (path.startsWith('screens/events/')) return path.replaceFirst('screens/', 'features/student/');
  if (path.startsWith('screens/skill_package/')) return path.replaceFirst('screens/', 'features/student/');
  if (path.startsWith('screens/placement/')) return path.replaceFirst('screens/', 'features/student/');
  if (path.startsWith('src/student/')) return path.replaceFirst('src/', 'features/');
  
  // Profile
  if (path.startsWith('screens/profile/')) return path.replaceFirst('screens/', 'features/');
  
  return path;
}

void _deleteEmptyDirs(Directory dir) {
  for (var entity in dir.listSync()) {
    if (entity is Directory) {
      _deleteEmptyDirs(entity);
      if (entity.listSync().isEmpty) {
        entity.deleteSync();
      }
    }
  }
}
