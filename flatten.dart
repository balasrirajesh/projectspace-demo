import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final libDir = Directory('lib');
  
  // 1. Force delete old shadow directories to remove duplicates
  _deleteDir('lib/screens');
  _deleteDir('lib/src');
  
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  // 2. Compute flatten moves
  final fileMoves = <String, String>{}; 
  final newFiles = <File>[]; 

  for (var file in dartFiles) {
    final relativeToLib = p.relative(file.path, from: 'lib').replaceAll('\\', '/');
    final newRelative = getFlattenedPath(relativeToLib);
    fileMoves[relativeToLib] = newRelative;
  }

  // 3. Move files
  for (var file in dartFiles) {
    final oldRelative = p.relative(file.path, from: 'lib').replaceAll('\\', '/');
    final newRelative = fileMoves[oldRelative]!;
    
    final newPath = p.join('lib', newRelative);
    final newFile = File(newPath);
    
    if (oldRelative != newRelative) {
      newFile.parent.createSync(recursive: true);
      // If target exists, delete it first (overwrite)
      if (newFile.existsSync()) newFile.deleteSync();
      
      final movedFile = file.renameSync(newPath);
      newFiles.add(movedFile);
    } else {
      newFiles.add(file);
    }
  }

  // 4. Update imports to reflect flattened structure
  for (var file in newFiles) {
    var content = file.readAsStringSync();
    var originalContent = content;
    
    // We need to replace ANY package:graduway/ reference to the new flattened paths
    // First, let's update any 'features/admin' to just 'admin' etc.
    fileMoves.forEach((oldRelative, newRelative) {
      if (oldRelative != newRelative) {
        content = content.replaceAll(
          "package:graduway/$oldRelative",
          "package:graduway/$newRelative",
        );
      }
    });

    // Also handle cases where imports might have been 'features/admin/...' but now they are 'admin/...'
    // This is important because the user might have already updated some imports to the 'features/' structure.
    content = content.replaceAll('package:graduway/features/', 'package:graduway/');
    content = content.replaceAll('package:graduway/core/', 'package:graduway/');
    content = content.replaceAll('package:graduway/shared/widgets/', 'package:graduway/widgets/');
    content = content.replaceAll('package:graduway/shared/models/', 'package:graduway/models/');
    content = content.replaceAll('package:graduway/shared/services/', 'package:graduway/services/');

    if (content != originalContent) {
      file.writeAsStringSync(content);
    }
  }

  // Cleanup
  _deleteDir('lib/features');
  _deleteDir('lib/core');
  _deleteDir('lib/shared');
  
  print('Flattening complete!');
}

String getFlattenedPath(String path) {
  if (path.startsWith('features/')) return path.replaceFirst('features/', '');
  if (path.startsWith('core/')) return path.replaceFirst('core/', '');
  if (path.startsWith('shared/widgets/')) return path.replaceFirst('shared/widgets/', 'widgets/');
  if (path.startsWith('shared/models/')) return path.replaceFirst('shared/models/', 'models/');
  if (path.startsWith('shared/services/')) return path.replaceFirst('shared/services/', 'services/');
  return path;
}

void _deleteDir(String path) {
  final dir = Directory(path);
  if (dir.existsSync()) {
    dir.deleteSync(recursive: true);
  }
}
