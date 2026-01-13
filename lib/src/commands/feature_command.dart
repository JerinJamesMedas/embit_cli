import 'dart:io';
import 'package:args/args.dart';
import 'package:embit_cli/src/commands/base_command.dart';
import 'package:embit_cli/src/models/feature_config.dart';
import 'package:embit_cli/src/validators/project_validator.dart';
import 'package:embit_cli/src/validators/feature_validator.dart';
import 'package:embit_cli/src/generators/feature_generator.dart';

class FeatureCommand extends BaseCommand {
  @override
  String get name => 'feature';
  
  @override
  String get description => 'Create a new feature with DI, Bloc, and routing';

  @override
  ArgParser get argParser => ArgParser()
    ..addOption('name', abbr: 'n', help: 'Name of the feature (snake_case)', mandatory: true)
    ..addFlag('force', abbr: 'f', help: 'Overwrite existing feature', negatable: false)
    ..addFlag('dry-run', help: 'Show what would be created', negatable: false)
    ..addFlag('with-example', help: 'Include example implementation', negatable: false)
    ..addFlag('skip-di', help: 'Skip DI registration', negatable: false)
    ..addFlag('skip-routes', help: 'Skip route registration', negatable: false);

  @override
  Future<void> execute(ArgResults results, {bool verbose = false}) async {
    final featureName = results['name'] as String;
    final force = results['force'] == true;
    final dryRun = results['dry-run'] == true;
    final withExample = results['with-example'] == true;
    
    print('🎯 Creating feature: $featureName\n');
    
    try {
      // Validate feature name
      FeatureValidator.validateOrThrow(featureName);
      
      // Validate project structure
      final projectPath = Directory.current.path;
      if (!ProjectValidator.validateProjectStructure(projectPath, verbose: verbose)) {
        stderr.writeln('❌ Project structure validation failed.');
        stderr.writeln('   Run `embit init` first to set up the architecture.');
        exit(1);
      }
      
      // Check for existing feature
      if (ProjectValidator.hasFeature(projectPath, featureName) && !force) {
        stderr.writeln('❌ Feature "$featureName" already exists.');
        stderr.writeln('   Use --force to overwrite or choose a different name.');
        exit(1);
      }
      
      // Get project name from pubspec
      final pubspec = File('pubspec.yaml');
      final pubspecContent = await pubspec.readAsString();
      final projectName = _extractProjectName(pubspecContent);
      
      // Create config
      final config = FeatureConfig(
        name: featureName,
        withExample: withExample,
        force: force,
        dryRun: dryRun,
        projectPath: projectName,
      );
      
      if (dryRun) {
        print('📋 DRY RUN - Would create feature: $featureName');
        print('   Project: $projectName');
        print('   Path: lib/features/$featureName');
        print('\n   Use --force to actually create the feature.');
        return;
      }
      
      // Generate feature
      final generator = FeatureGenerator(config);
      await generator.generate();
      
      print('\n🎉 Feature "$featureName" created successfully!');
      print('\n📋 Generated structure:');
      print('   lib/features/$featureName/');
      print('   ├── domain/              # Business logic');
      print('   ├── data/                # Data layer');
      print('   ├── presentation/        # UI layer');
      print('   ├── di/                  # Dependency injection');
      print('   └── routes/              # Navigation');
      
      print('\n📋 Next steps:');
      print('   1. Run `flutter pub get`');
      print('   2. Initialize DI in main.dart:');
      print('      await initDependencyInjection();');
      print('   3. Use the feature:');
      print('      Navigator.pushNamed(context, \'/${featureName}\');');
      
    } catch (e) {
      stderr.writeln('❌ Error creating feature: $e');
      exit(1);
    }
  }
  
  String _extractProjectName(String pubspecContent) {
    final match = RegExp(r'name:\s*(\w+)').firstMatch(pubspecContent);
    return match?.group(1) ?? 'my_app';
  }
}