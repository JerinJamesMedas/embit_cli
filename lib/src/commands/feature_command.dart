import 'dart:io';

import 'package:args/args.dart';

import '../generators/feature_generator.dart';
import '../models/feature_config.dart';
import '../validators/feature_validator.dart';
import '../validators/project_validator.dart';
import 'base_command.dart';

class FeatureCommand extends BaseCommand {
  @override
  String get name => 'feature';

  @override
  String get description => 'Create a new feature with Clean Architecture structure';

  @override
  ArgParser get argParser => ArgParser()
    ..addOption(
      'name',
      abbr: 'n',
      help: 'Name of the feature (snake_case)',
      mandatory: true,
    )
    ..addFlag(
      'force',
      abbr: 'f',
      help: 'Overwrite existing feature',
      negatable: false,
    )
    ..addFlag(
      'dry-run',
      help: 'Show what would be created without actually creating files',
      negatable: false,
    );

  @override
  Future<void> execute(ArgResults results, {bool verbose = false}) async {
    final featureName = results['name'] as String;
    final force = results['force'] == true;
    final dryRun = results['dry-run'] == true;

    print('🎯 Creating feature: $featureName\n');

    try {
      // Validate feature name
      FeatureValidator.validateOrThrow(featureName);

      // Validate project structure
      final projectPath = Directory.current.path;
      if (!ProjectValidator.validateProjectStructure(projectPath, verbose: verbose)) {
        stderr.writeln('❌ Project structure validation failed.');
        stderr.writeln('   Make sure you are in a Flutter Starter Kit project.');
        exit(1);
      }

      // Check for existing feature
      if (ProjectValidator.hasFeature(projectPath, featureName) && !force) {
        stderr.writeln('❌ Feature "$featureName" already exists.');
        stderr.writeln('   Use --force to overwrite or choose a different name.');
        exit(1);
      }

      // Get project name from pubspec
      final projectName = await _getProjectName();

      // Create config
      final config = FeatureConfig(
        name: featureName,
        force: force,
        dryRun: dryRun,
        projectName: projectName,
        projectPath: projectPath,
      );

      if (dryRun) {
        _printDryRun(config);
        return;
      }

      // Generate feature
      final generator = FeatureGenerator(config, verbose: verbose);
      await generator.generate();

      _printSuccess(featureName);
    } catch (e) {
      stderr.writeln('❌ Error: $e');
      exit(1);
    }
  }

  Future<String> _getProjectName() async {
    final pubspec = File('pubspec.yaml');
    if (!pubspec.existsSync()) {
      return 'my_app';
    }

    final content = await pubspec.readAsString();
    final match = RegExp(r'name:\s*(\w+)').firstMatch(content);
    return match?.group(1) ?? 'my_app';
  }

  void _printDryRun(FeatureConfig config) {
    print('📋 DRY RUN - Would create feature: ${config.name}');
    print('   Project: ${config.projectName}');
    print('\n   Files that would be created:');
    print('   lib/features/${config.name}/');
    print('   ├── domain/');
    print('   │   ├── entities/${config.snakeCase}_entity.dart');
    print('   │   ├── repositories/${config.snakeCase}_repository.dart');
    print('   │   └── usecases/');
    print('   │       ├── get_${config.snakeCase}_usecase.dart');
    print('   │       ├── get_all_${config.snakeCase}s_usecase.dart');
    print('   │       ├── create_${config.snakeCase}_usecase.dart');
    print('   │       ├── update_${config.snakeCase}_usecase.dart');
    print('   │       └── delete_${config.snakeCase}_usecase.dart');
    print('   ├── data/');
    print('   │   ├── models/${config.snakeCase}_model.dart');
    print('   │   ├── datasources/');
    print('   │   │   ├── ${config.snakeCase}_remote_datasource.dart');
    print('   │   │   └── ${config.snakeCase}_local_datasource.dart');
    print('   │   └── repositories/${config.snakeCase}_repository_impl.dart');
    print('   └── presentation/');
    print('       ├── bloc/');
    print('       │   ├── ${config.snakeCase}_bloc.dart');
    print('       │   ├── ${config.snakeCase}_event.dart');
    print('       │   └── ${config.snakeCase}_state.dart');
    print('       ├── pages/');
    print('       │   ├── ${config.snakeCase}_page.dart');
    print('       │   └── ${config.snakeCase}_detail_page.dart');
    print('       └── widgets/');
    print('           ├── ${config.snakeCase}_list_widget.dart');
    print('           └── ${config.snakeCase}_item_widget.dart');
    print('\n   Files that would be modified:');
    print('   • lib/core/di/injection_container.dart');
    print('   • lib/navigation/route_names.dart');
    print('   • lib/navigation/app_router.dart');
    print('   • lib/core/constants/api_endpoints.dart');
    print('\n   Use without --dry-run to actually create the feature.');
  }

  void _printSuccess(String featureName) {
    print('\n' + '═' * 50);
    print('🎉 Feature "$featureName" created successfully!');
    print('═' * 50);
    print('\n📋 What was created:');
    print('   • Entity, Model');
    print('   • Repository interface & implementation');
    print('   • 5 Use cases (Get, GetAll, Create, Update, Delete)');
    print('   • BLoC with Events and States');
    print('   • Pages (List & Detail) and Widgets');
    print('   • DI registration');
    print('   • Route registration');
    print('\n📋 Next steps:');
    print('   1. Review the generated code');
    print('   2. Customize entity fields as needed');
    print('   3. Update API endpoints in the remote datasource');
    print('   4. Run: flutter pub get');
    print('   5. Navigate to: /$featureName');
  }
}