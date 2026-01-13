import 'dart:io';

class ProjectValidator {
  static bool validateProjectStructure(String projectPath, {bool verbose = false}) {
    if (!_isFlutterProject(projectPath)) {
      stderr.writeln('❌ Error: Not a Flutter project');
      stderr.writeln('   Expected pubspec.yaml in $projectPath');
      return false;
    }

    final requiredDirs = [
      'lib',
      'lib/core',
      'lib/features',
    ];

    for (final dir in requiredDirs) {
      if (!Directory('$projectPath/$dir').existsSync()) {
        if (verbose) {
          stderr.writeln('⚠️  Missing directory: $dir');
        }
      }
    }

    return true;
  }

  static bool _isFlutterProject(String path) {
    final pubspec = File('$path/pubspec.yaml');
    if (!pubspec.existsSync()) return false;

    final content = pubspec.readAsStringSync();
    return content.contains('flutter:');
  }

  static bool hasFeature(String projectPath, String featureName) {
    final featureDir = Directory('$projectPath/lib/features/$featureName');
    return featureDir.existsSync();
  }

  static List<String> getExistingFeatures(String projectPath) {
    final featuresDir = Directory('$projectPath/lib/features');
    if (!featuresDir.existsSync()) return [];

    return featuresDir
        .listSync()
        .whereType<Directory>()
        .map((dir) => dir.path.split('/').last)
        .toList();
  }
}