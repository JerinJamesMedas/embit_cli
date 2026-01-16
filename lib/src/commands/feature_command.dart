// import 'dart:io';

// import 'package:args/args.dart';

// import '../generators/feature_generator.dart';
// import '../models/feature_config.dart';
// import '../validators/feature_validator.dart';
// import '../validators/project_validator.dart';
// import 'base_command.dart';

// class FeatureCommand extends BaseCommand {
//   @override
//   String get name => 'feature';

//   @override
//   String get description => 'Create a new feature with Clean Architecture structure';

//   @override
//   ArgParser get argParser => ArgParser()
//     ..addOption(
//       'name',
//       abbr: 'n',
//       help: 'Name of the feature (snake_case)',
//       mandatory: true,
//     )
//     ..addFlag(
//       'force',
//       abbr: 'f',
//       help: 'Overwrite existing feature',
//       negatable: false,
//     )
//     ..addFlag(
//       'dry-run',
//       help: 'Show what would be created without actually creating files',
//       negatable: false,
//     );

//   @override
//   Future<void> execute(ArgResults results, {bool verbose = false}) async {
//     final featureName = results['name'] as String;
//     final force = results['force'] == true;
//     final dryRun = results['dry-run'] == true;

//     print('🎯 Creating feature: $featureName\n');

//     try {
//       // Validate feature name
//       FeatureValidator.validateOrThrow(featureName);

//       // Validate project structure
//       final projectPath = Directory.current.path;
//       if (!ProjectValidator.validateProjectStructure(projectPath, verbose: verbose)) {
//         stderr.writeln('❌ Project structure validation failed.');
//         stderr.writeln('   Make sure you are in a Flutter Starter Kit project.');
//         exit(1);
//       }

//       // Check for existing feature
//       if (ProjectValidator.hasFeature(projectPath, featureName) && !force) {
//         stderr.writeln('❌ Feature "$featureName" already exists.');
//         stderr.writeln('   Use --force to overwrite or choose a different name.');
//         exit(1);
//       }

//       // Get project name from pubspec
//       final projectName = await _getProjectName();

//       // Create config
//       final config = FeatureConfig(
//         name: featureName,
//         force: force,
//         dryRun: dryRun,
//         projectName: projectName,
//      projectPath: projectPath,
//       );

//       if (dryRun) {
//         _printDryRun(config);
//         return;
//       }

//       // Generate feature
//       final generator = FeatureGenerator(config, verbose: verbose);
//       await generator.generate();

//       _printSuccess(featureName);
//     } catch (e) {
//       stderr.writeln('❌ Error: $e');
//       exit(1);
//     }
//   }

//   Future<String> _getProjectName() async {
//     final pubspec = File('pubspec.yaml');
//     if (!pubspec.existsSync()) {
//       return 'my_app';
//     }

//     final content = await pubspec.readAsString();
//     final match = RegExp(r'name:\s*(\w+)').firstMatch(content);
//     return match?.group(1) ?? 'my_app';
//   }

//   void _printDryRun(FeatureConfig config) {
//     print('📋 DRY RUN - Would create feature: ${config.name}');
//     print('   Project: ${config.projectName}');
//     print('\n   Files that would be created:');
//     print('   lib/features/${config.name}/');
//     print('   ├── domain/');
//     print('   │   ├── entities/${config.snakeCase}_entity.dart');
//     print('   │   ├── repositories/${config.snakeCase}_repository.dart');
//     print('   │   └── usecases/');
//     print('   │       ├── get_${config.snakeCase}_usecase.dart');
//     print('   │       ├── get_all_${config.snakeCase}s_usecase.dart');
//     print('   │       ├── create_${config.snakeCase}_usecase.dart');
//     print('   │       ├── update_${config.snakeCase}_usecase.dart');
//     print('   │       └── delete_${config.snakeCase}_usecase.dart');
//     print('   ├── data/');
//     print('   │   ├── models/${config.snakeCase}_model.dart');
//     print('   │   ├── datasources/');
//     print('   │   │   ├── ${config.snakeCase}_remote_datasource.dart');
//     print('   │   │   └── ${config.snakeCase}_local_datasource.dart');
//     print('   │   └── repositories/${config.snakeCase}_repository_impl.dart');
//     print('   └── presentation/');
//     print('       ├── bloc/');
//     print('       │   ├── ${config.snakeCase}_bloc.dart');
//     print('       │   ├── ${config.snakeCase}_event.dart');
//     print('       │   └── ${config.snakeCase}_state.dart');
//     print('       ├── pages/');
//     print('       │   ├── ${config.snakeCase}_page.dart');
//     print('       │   └── ${config.snakeCase}_detail_page.dart');
//     print('       └── widgets/');
//     print('           ├── ${config.snakeCase}_list_widget.dart');
//     print('           └── ${config.snakeCase}_item_widget.dart');
//     print('\n   Files that would be modified:');
//     print('   • lib/core/di/injection_container.dart');
//     print('   • lib/navigation/route_names.dart');
//     print('   • lib/navigation/app_router.dart');
//     print('   • lib/core/constants/api_endpoints.dart');
//     print('\n   Use without --dry-run to actually create the feature.');
//   }

//   void _printSuccess(String featureName) {
//     print('\n' + '═' * 50);
//     print('🎉 Feature "$featureName" created successfully!');
//     print('═' * 50);
//     print('\n📋 What was created:');
//     print('   • Entity, Model');
//     print('   • Repository interface & implementation');
//     print('   • 5 Use cases (Get, GetAll, Create, Update, Delete)');
//     print('   • BLoC with Events and States');
//     print('   • Pages (List & Detail) and Widgets');
//     print('   • DI registration');
//     print('   • Route registration');
//     print('\n📋 Next steps:');
//     print('   1. Review the generated code');
//     print('   2. Customize entity fields as needed');
//     print('   3. Update API endpoints in the remote datasource');
//     print('   4. Run: flutter pub get');
//     print('   5. Navigate to: /$featureName');
//   }
// // }



/// Feature Command
/// 
/// Creates a new feature with complete clean architecture structure.
library;

import 'dart:io';

import 'package:args/args.dart';

import 'base_command.dart';
import '../models/feature_config.dart';
import '../validators/project_validator.dart';
import '../validators/feature_validator.dart';
import '../generators/feature_generator.dart';
import '../utils/cli_prompts.dart';

/// Command to create a new feature
class FeatureCommand extends BaseCommand {
  @override
  String get name => 'feature';

  @override
  String get description => 'Create a new feature with clean architecture structure';

  @override
  ArgParser get argParser => ArgParser()
    ..addOption(
      'name',
      abbr: 'n',
      help: 'Feature name in snake_case (e.g., user_profile)',
      mandatory: true,
    )
    ..addFlag(
      'force',
      abbr: 'f',
      help: 'Force overwrite if feature exists',
      negatable: false,
    )
    ..addFlag(
      'dry-run',
      help: 'Show what would be created without creating files',
      negatable: false,
    )
    ..addFlag(
      'with-example',
      help: 'Include example implementation',
      negatable: false,
    )
    ..addFlag(
      'nav-bar',
      help: 'Add this feature to bottom navigation bar',
      negatable: false,
    )
    ..addOption(
      'icon',
      help: 'Navigation icon (e.g., Icons.shopping_cart_outlined)',
    )
    ..addOption(
      'label',
      help: 'Navigation label (e.g., "Shopping Cart")',
    )
    ..addFlag(
      'interactive',
      abbr: 'i',
      help: 'Interactive mode - prompts for options',
      negatable: false,
    );

  @override
  Future<void> execute(ArgResults results, {bool verbose = false}) async {
    final featureName = results['name'] as String;
    final force = results['force'] == true;
    final dryRun = results['dry-run'] == true;
    final withExample = results['with-example'] == true;
    final interactive = results['interactive'] == true;
    var isNavBarRoute = results['nav-bar'] == true;
    var navIcon = results['icon'] as String?;
    var navLabel = results['label'] as String?;
    
    final projectPath = Directory.current.path;

    print('''
╔════════════════════════════════════════╗
║      Embit CLI - Create Feature        ║
╚════════════════════════════════════════╝
''');

    // ========== Validate Feature Name ==========
    try {
      FeatureValidator.validateOrThrow(featureName);
    } on ArgumentError catch (e) {
      stderr.writeln('❌ $e');
      
      final suggestion = FeatureValidator.suggestValidName(featureName);
      if (suggestion != null) {
        stderr.writeln('\n💡 Did you mean: $suggestion');
      }
      exit(1);
    }

    // ========== Validate Project ==========
    print('🔍 Validating project...');
    
    if (!ProjectValidator.isFlutterProject(projectPath)) {
      stderr.writeln('');
      stderr.writeln('❌ Error: Not a Flutter project');
      exit(1);
    }

    if (!ProjectValidator.isStarterKitInitialized(projectPath)) {
      stderr.writeln('');
      stderr.writeln('❌ Error: Starter kit not initialized');
      stderr.writeln('   Run "embit init" first to set up the project structure.');
      exit(1);
    }

    // ========== Check if Feature Exists ==========
    if (ProjectValidator.hasFeature(projectPath, featureName) && !force) {
      stderr.writeln('');
      stderr.writeln('❌ Error: Feature "$featureName" already exists');
      stderr.writeln('   Use --force to overwrite existing feature');
      exit(1);
    }

    // ========== Interactive Mode ==========
    if (interactive) {
      print('');
      print('📋 Feature Configuration');
      print('   Name: $featureName');
      print('');

      // Ask about navigation bar
      isNavBarRoute = CLIPrompts.confirm(
        'Add this feature to bottom navigation bar?',
        defaultValue: false,
      );

      if (isNavBarRoute) {
        // Get icon
        navIcon = CLIPrompts.prompt(
          'Navigation icon (e.g., Icons.shopping_cart_outlined)',
          defaultValue: 'Icons.${featureName}_outlined',
        );

        // Get label
        final defaultLabel = featureName.split('_').map((w) => 
          w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}'
        ).join(' ');
        
        navLabel = CLIPrompts.prompt(
          'Navigation label',
          defaultValue: defaultLabel,
        );
      }
    } else if (!isNavBarRoute) {
      // Non-interactive mode: ask once if --nav-bar not specified
      print('');
      isNavBarRoute = CLIPrompts.confirm(
        'Add this feature to bottom navigation bar?',
        defaultValue: false,
      );

      if (isNavBarRoute && navIcon == null) {
        navIcon = 'Icons.${featureName}_outlined';
      }
    }

    // ========== Get Project Name ==========
    final projectName = ProjectValidator.getProjectName(projectPath);

    // ========== Create Config ==========
    final config = FeatureConfig(
      name: featureName,
      projectName: projectName,
      withExample: withExample,
      force: force,
      dryRun: dryRun,
      isNavBarRoute: isNavBarRoute,
      navIcon: navIcon,
      navLabel: navLabel,
      projectPath: projectPath,
    );

    // ========== Dry Run ==========
    if (dryRun) {
      print('');
      print('📋 DRY RUN - Would create feature: $featureName');
      print('');
      _printStructurePreview(config);
      print('');
      print('   Run without --dry-run to create files.');
      return;
    }

    // ========== Generate Feature ==========
    print('');
    print('🚀 Creating feature: $featureName');
    print('   Project: $projectName');
    if (isNavBarRoute) {
      print('   Navigation: Bottom Nav Bar ✓');
      print('   Icon: ${config.displayIcon}');
      print('   Label: ${config.displayLabel}');
    }
    print('');

    try {
      final generator = FeatureGenerator(config, verbose: verbose);
      await generator.generate();
    } catch (e) {
      stderr.writeln('');
      stderr.writeln('❌ Error generating feature: $e');
      exit(1);
    }

    // ========== Success Message ==========
    print('');
    print('═══════════════════════════════════════════════════════════════');
    print('');
    print('🎉 Feature "$featureName" created successfully!');
    print('');
    print('📁 Structure:');
    print('   lib/features/$featureName/');
    print('   ├── data/');
    print('   │   ├── datasources/');
    print('   │   ├── models/');
    print('   │   └── repositories/');
    print('   ├── domain/');
    print('   │   ├── entities/');
    print('   │   ├── repositories/');
    print('   │   └── usecases/');
    print('   └── presentation/');
    print('       ├── bloc/');
    print('       ├── pages/');
    print('       └── widgets/');
    print('');
    if (isNavBarRoute) {
      print('🧭 Navigation:');
      print('   ✓ Added to bottom navigation bar');
      print('   ✓ Added to ShellRoute (MainShell)');
      print('   ✓ Added to public routes');
      print('');
    }
    print('📋 Next steps:');
    print('');
    print('   1. Run: flutter pub get');
    print('');
    print('   2. Implement your entity in:');
    print('      lib/features/$featureName/domain/entities/${featureName}_entity.dart');
    print('');
    print('   3. Add API endpoints in:');
    print('      lib/core/constants/api_endpoints.dart');
    print('');
    print('   4. Navigate to the feature:');
    print('      context.go(RoutePaths.$featureName);');
    print('');
    print('═══════════════════════════════════════════════════════════════');
  }

  void _printStructurePreview(FeatureConfig config) {
    final files = [
      // Domain
      'lib/features/${config.name}/domain/entities/${config.snakeCase}_entity.dart',
      'lib/features/${config.name}/domain/repositories/${config.snakeCase}_repository.dart',
      'lib/features/${config.name}/domain/usecases/get_${config.snakeCase}_usecase.dart',
      'lib/features/${config.name}/domain/usecases/get_all_${config.snakeCase}s_usecase.dart',
      'lib/features/${config.name}/domain/usecases/create_${config.snakeCase}_usecase.dart',
      'lib/features/${config.name}/domain/usecases/update_${config.snakeCase}_usecase.dart',
      'lib/features/${config.name}/domain/usecases/delete_${config.snakeCase}_usecase.dart',
      // Data
      'lib/features/${config.name}/data/models/${config.snakeCase}_model.dart',
      'lib/features/${config.name}/data/datasources/${config.snakeCase}_remote_datasource.dart',
      'lib/features/${config.name}/data/datasources/${config.snakeCase}_local_datasource.dart',
      'lib/features/${config.name}/data/repositories/${config.snakeCase}_repository_impl.dart',
      // Presentation
      'lib/features/${config.name}/presentation/bloc/${config.snakeCase}_bloc.dart',
      'lib/features/${config.name}/presentation/bloc/${config.snakeCase}_event.dart',
      'lib/features/${config.name}/presentation/bloc/${config.snakeCase}_state.dart',
      'lib/features/${config.name}/presentation/pages/${config.snakeCase}_page.dart',
      'lib/features/${config.name}/presentation/pages/${config.snakeCase}_detail_page.dart',
      'lib/features/${config.name}/presentation/widgets/${config.snakeCase}_list_widget.dart',
      'lib/features/${config.name}/presentation/widgets/${config.snakeCase}_item_widget.dart',
    ];

    print('   Files to be created:');
    for (final file in files) {
      print('   📄 $file');
    }

    print('');
    print('   Files to be updated:');
    print('   📝 lib/core/di/injection_container.dart');
    print('   📝 lib/navigation/route_names.dart');
    print('   📝 lib/navigation/app_router.dart');
    print('   📝 lib/core/constants/api_endpoints.dart');
    
    if (config.isNavBarRoute) {
      print('   📝 lib/navigation/role_based_navigator.dart');
    }
  }
}