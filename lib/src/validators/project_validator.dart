/// Project Validator
/// 
/// Validates that the current project is a valid Flutter Starter Kit project.
/// Checks for required structure, files, and dependencies.
library;

import 'dart:io';

import 'package:yaml/yaml.dart';

/// Result of project validation
class ProjectValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final ProjectInfo? projectInfo;

  const ProjectValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.projectInfo,
  });

  factory ProjectValidationResult.invalid(List<String> errors, [List<String> warnings = const []]) {
    return ProjectValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
    );
  }

  factory ProjectValidationResult.valid(ProjectInfo info, [List<String> warnings = const []]) {
    return ProjectValidationResult(
      isValid: true,
      projectInfo: info,
      warnings: warnings,
    );
  }
}

/// Project information extracted from pubspec.yaml
class ProjectInfo {
  final String name;
  final String description;
  final String version;
  final String path;
  final List<String> existingFeatures;
  final bool hasAuthFeature;
  final bool hasProfileFeature;

  const ProjectInfo({
    required this.name,
    required this.description,
    required this.version,
    required this.path,
    required this.existingFeatures,
    required this.hasAuthFeature,
    required this.hasProfileFeature,
  });
}

/// Project structure validator
class ProjectValidator {
  /// Required directories for the starter kit
  static const List<String> requiredDirectories = [
    'lib',
    'lib/core',
    'lib/core/di',
    'lib/core/errors',
    'lib/core/network',
    'lib/core/storage',
    'lib/features',
    'lib/navigation',
  ];

  /// Required core files
  static const List<String> requiredCoreFiles = [
    'lib/core/di/injection_container.dart',
    'lib/core/errors/failures.dart',
    'lib/core/errors/exceptions.dart',
    'lib/navigation/route_names.dart',
    'lib/navigation/app_router.dart',
  ];

  /// Required dependencies in pubspec.yaml
  static const List<String> requiredDependencies = [
    'flutter_bloc',
    'equatable',
    'get_it',
    'dartz',
    'go_router',
    'dio',
  ];

  /// Optional but recommended dependencies
  static const List<String> recommendedDependencies = [
    'connectivity_plus',
    'shared_preferences',
  ];

  /// Validates the project structure at the given path
  /// 
  /// Returns a [ProjectValidationResult] with validation status,
  /// errors, warnings, and project info if valid.
  static Future<ProjectValidationResult> validate(
    String projectPath, {
    bool verbose = false,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];

    // Check if it's a Flutter project
    final pubspecFile = File('$projectPath/pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      return ProjectValidationResult.invalid([
        'Not a Flutter project: pubspec.yaml not found in $projectPath',
      ]);
    }

    // Parse pubspec.yaml
    final pubspecContent = await pubspecFile.readAsString();
    final YamlMap pubspec;
    try {
      pubspec = loadYaml(pubspecContent) as YamlMap;
    } catch (e) {
      return ProjectValidationResult.invalid([
        'Invalid pubspec.yaml: $e',
      ]);
    }

    // Check if it's a Flutter project
    if (!pubspec.containsKey('flutter')) {
      errors.add('Not a Flutter project: "flutter" key not found in pubspec.yaml');
    }

    // Extract project name
    final projectName = pubspec['name'] as String? ?? '';
    if (projectName.isEmpty) {
      errors.add('Project name not found in pubspec.yaml');
    }

    // Check required dependencies
    final dependencies = pubspec['dependencies'] as YamlMap? ?? YamlMap();
    for (final dep in requiredDependencies) {
      if (!dependencies.containsKey(dep)) {
        errors.add('Missing required dependency: $dep');
      }
    }

    // Check recommended dependencies
    for (final dep in recommendedDependencies) {
      if (!dependencies.containsKey(dep)) {
        warnings.add('Missing recommended dependency: $dep');
      }
    }

    // Check required directories
    for (final dir in requiredDirectories) {
      final directory = Directory('$projectPath/$dir');
      if (!directory.existsSync()) {
        if (dir == 'lib/features') {
          // Features directory is required but can be empty
          errors.add('Missing required directory: $dir');
        } else if (dir.startsWith('lib/core') || dir == 'lib/navigation') {
          errors.add('Missing required directory: $dir (Run "embit init" first)');
        }
      }
    }

    // Check required core files
    for (final file in requiredCoreFiles) {
      final coreFile = File('$projectPath/$file');
      if (!coreFile.existsSync()) {
        warnings.add('Missing core file: $file (Will be created by "embit init")');
      }
    }

    // Validate injection_container.dart structure
    final injectionFile = File('$projectPath/lib/core/di/injection_container.dart');
    if (injectionFile.existsSync()) {
      final content = await injectionFile.readAsString();
      if (!content.contains('final sl = GetIt.instance')) {
        warnings.add('injection_container.dart may not follow starter kit pattern (expected "final sl = GetIt.instance")');
      }
      if (!content.contains('Future<void> initDependencies()')) {
        warnings.add('injection_container.dart missing initDependencies() function');
      }
    }

    // Get existing features
    final existingFeatures = getExistingFeatures(projectPath);
    final hasAuthFeature = existingFeatures.contains('auth');
    final hasProfileFeature = existingFeatures.contains('profile');

    // Validate existing feature structures
    for (final feature in existingFeatures) {
      final featureErrors = validateFeatureStructure(projectPath, feature);
      if (featureErrors.isNotEmpty && verbose) {
        for (final error in featureErrors) {
          warnings.add('Feature "$feature": $error');
        }
      }
    }

    // Return result
    if (errors.isNotEmpty) {
      return ProjectValidationResult.invalid(errors, warnings);
    }

    final projectInfo = ProjectInfo(
      name: projectName,
      description: pubspec['description'] as String? ?? '',
      version: pubspec['version'] as String? ?? '1.0.0',
      path: projectPath,
      existingFeatures: existingFeatures,
      hasAuthFeature: hasAuthFeature,
      hasProfileFeature: hasProfileFeature,
    );

    return ProjectValidationResult.valid(projectInfo, warnings);
  }

  /// Quick validation check (for commands that just need to know if it's valid)
  static bool validateProjectStructure(String projectPath, {bool verbose = false}) {
    // Check pubspec.yaml exists and is a Flutter project
    final pubspecFile = File('$projectPath/pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      if (verbose) {
        stderr.writeln('❌ Error: Not a Flutter project');
        stderr.writeln('   pubspec.yaml not found in $projectPath');
      }
      return false;
    }

    final pubspecContent = pubspecFile.readAsStringSync();
    if (!pubspecContent.contains('flutter:')) {
      if (verbose) {
        stderr.writeln('❌ Error: Not a Flutter project');
        stderr.writeln('   "flutter:" key not found in pubspec.yaml');
      }
      return false;
    }

    // Check lib directory exists
    final libDir = Directory('$projectPath/lib');
    if (!libDir.existsSync()) {
      if (verbose) {
        stderr.writeln('❌ Error: lib directory not found');
      }
      return false;
    }

    // Check core structure (optional for init command)
    final coreDir = Directory('$projectPath/lib/core');
    final featuresDir = Directory('$projectPath/lib/features');
    
    if (!coreDir.existsSync() || !featuresDir.existsSync()) {
      if (verbose) {
        stderr.writeln('⚠️  Warning: Starter kit structure not initialized');
        stderr.writeln('   Run "embit init" to set up the project structure');
      }
      // Still return true - init command can set this up
    }

    return true;
  }

  /// Checks if it's a Flutter project
  static bool isFlutterProject(String projectPath) {
    final pubspecFile = File('$projectPath/pubspec.yaml');
    if (!pubspecFile.existsSync()) return false;

    final content = pubspecFile.readAsStringSync();
    return content.contains('flutter:');
  }

  /// Checks if starter kit is initialized
  static bool isStarterKitInitialized(String projectPath) {
    final requiredForInit = [
      'lib/core/di/injection_container.dart',
      'lib/core/errors/failures.dart',
      'lib/features',
      'lib/navigation/route_names.dart',
    ];

    for (final path in requiredForInit) {
      final entity = path.endsWith('.dart') 
          ? File('$projectPath/$path') as FileSystemEntity
          : Directory('$projectPath/$path');
      if (!entity.existsSync()) {
        return false;
      }
    }

    return true;
  }

  /// Checks if a feature exists
  static bool hasFeature(String projectPath, String featureName) {
    final featureDir = Directory('$projectPath/lib/features/$featureName');
    return featureDir.existsSync();
  }

  /// Gets list of existing features
  static List<String> getExistingFeatures(String projectPath) {
    final featuresDir = Directory('$projectPath/lib/features');
    if (!featuresDir.existsSync()) return [];

    return featuresDir
        .listSync()
        .whereType<Directory>()
        .map((dir) => dir.path.split(Platform.pathSeparator).last)
        .where((name) => !name.startsWith('.')) // Ignore hidden directories
        .toList()
      ..sort();
  }

  /// Validates feature structure (data, domain, presentation only)
  static List<String> validateFeatureStructure(String projectPath, String featureName) {
    final errors = <String>[];
    final featurePath = '$projectPath/lib/features/$featureName';

    // Required feature directories (only these 3!)
    final requiredFeatureDirs = ['data', 'domain', 'presentation'];
    
    for (final dir in requiredFeatureDirs) {
      if (!Directory('$featurePath/$dir').existsSync()) {
        errors.add('Missing directory: $dir');
      }
    }

    // Domain layer structure
    final domainSubDirs = ['entities', 'repositories', 'usecases'];
    for (final dir in domainSubDirs) {
      if (!Directory('$featurePath/domain/$dir').existsSync()) {
        errors.add('Missing domain subdirectory: domain/$dir');
      }
    }

    // Data layer structure
    final dataSubDirs = ['datasources', 'models', 'repositories'];
    for (final dir in dataSubDirs) {
      if (!Directory('$featurePath/data/$dir').existsSync()) {
        errors.add('Missing data subdirectory: data/$dir');
      }
    }

    // Presentation layer structure
    final presentationSubDirs = ['bloc', 'pages', 'widgets'];
    for (final dir in presentationSubDirs) {
      if (!Directory('$featurePath/presentation/$dir').existsSync()) {
        errors.add('Missing presentation subdirectory: presentation/$dir');
      }
    }

    return errors;
  }

  /// Checks if a feature has complete bloc structure
  static bool hasCompleteBloc(String projectPath, String featureName) {
    final blocPath = '$projectPath/lib/features/$featureName/presentation/bloc';
    
    final requiredFiles = [
      '${featureName}_bloc.dart',
      '${featureName}_event.dart',
      '${featureName}_state.dart',
    ];

    for (final file in requiredFiles) {
      if (!File('$blocPath/$file').existsSync()) {
        return false;
      }
    }

    return true;
  }

  /// Extracts project name from pubspec.yaml
  static String getProjectName(String projectPath) {
    final pubspecFile = File('$projectPath/pubspec.yaml');
    if (!pubspecFile.existsSync()) return 'my_app';

    final content = pubspecFile.readAsStringSync();
    final match = RegExp(r'name:\s*(\w+)').firstMatch(content);
    return match?.group(1) ?? 'my_app';
  }

  /// Gets the package import path for a project
  static String getPackagePath(String projectPath) {
    return 'package:${getProjectName(projectPath)}';
  }

  /// Checks if injection_container.dart has a specific feature registered
  static Future<bool> isFeatureRegisteredInDI(
    String projectPath,
    String featureName,
  ) async {
    final diFile = File('$projectPath/lib/core/di/injection_container.dart');
    if (!diFile.existsSync()) return false;

    final content = await diFile.readAsString();
    final pascalCase = _toPascalCase(featureName);
    
    // Check for feature initialization function call
    return content.contains('_init${pascalCase}Feature()') ||
           content.contains('init${pascalCase}Feature()');
  }

  /// Checks if route_names.dart has routes for a specific feature
  static Future<bool> isFeatureRegisteredInRoutes(
    String projectPath,
    String featureName,
  ) async {
    final routeNamesFile = File('$projectPath/lib/navigation/route_names.dart');
    if (!routeNamesFile.existsSync()) return false;

    final content = await routeNamesFile.readAsString();
    
    // Check for feature route constant
    return content.contains("'/$featureName'") ||
           content.contains('/$featureName');
  }

  /// Validates that a feature name doesn't conflict with existing features
  static FeatureNameValidation validateFeatureName(
    String projectPath,
    String featureName,
  ) {
    // Check if feature already exists
    if (hasFeature(projectPath, featureName)) {
      return FeatureNameValidation(
        isValid: false,
        error: 'Feature "$featureName" already exists',
        suggestion: 'Use --force to overwrite or choose a different name',
      );
    }

    // Check for reserved names
    const reservedNames = ['core', 'common', 'shared', 'app', 'main', 'test'];
    if (reservedNames.contains(featureName)) {
      return FeatureNameValidation(
        isValid: false,
        error: '"$featureName" is a reserved name',
        suggestion: 'Choose a different feature name',
      );
    }

    return const FeatureNameValidation(isValid: true);
  }

  /// Converts string to PascalCase
  static String _toPascalCase(String input) {
    return input.split('_').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join();
  }
}

/// Result of feature name validation
class FeatureNameValidation {
  final bool isValid;
  final String? error;
  final String? suggestion;

  const FeatureNameValidation({
    required this.isValid,
    this.error,
    this.suggestion,
  });
}

/// Extension for printing validation results
extension ProjectValidationResultPrinter on ProjectValidationResult {
  void printResult({bool verbose = false}) {
    if (isValid) {
      print('✅ Project validation passed');
      if (projectInfo != null) {
        print('   Project: ${projectInfo!.name}');
        print('   Features: ${projectInfo!.existingFeatures.isEmpty ? 'None' : projectInfo!.existingFeatures.join(', ')}');
      }
    } else {
      print('❌ Project validation failed');
      for (final error in errors) {
        print('   • $error');
      }
    }

    if (verbose && warnings.isNotEmpty) {
      print('\n⚠️  Warnings:');
      for (final warning in warnings) {
        print('   • $warning');
      }
    }
  }
}