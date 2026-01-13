import 'dart:io';
import 'package:args/args.dart';
import 'package:embit_cli/src/commands/base_command.dart';
import 'package:embit_cli/src/generators/core_generator.dart';

class InitCommand extends BaseCommand {
  @override
  String get name => 'init';
  
  @override
  String get description => 'Initialize project with full Embit architecture';

  @override
  ArgParser get argParser => ArgParser()
    ..addFlag('force', abbr: 'f', help: 'Force initialization', negatable: false)
    ..addFlag('skip-core', help: 'Skip generating core files', negatable: false);

  @override
  Future<void> execute(ArgResults results, {bool verbose = false}) async {
    print('🚀 Initializing Embit Architecture...\n');
    
    // Validate we're in a Flutter project
    final pubspec = File('pubspec.yaml');
    if (!pubspec.existsSync()) {
      stderr.writeln('❌ Error: Not a Flutter project. pubspec.yaml not found.');
      exit(1);
    }
    
    final pubspecContent = await pubspec.readAsString();
    if (!pubspecContent.contains('flutter:')) {
      stderr.writeln('❌ Error: Not a Flutter project.');
      exit(1);
    }
    
    // Get project name from pubspec
    final projectName = _extractProjectName(pubspecContent);
    
    final force = results['force'] == true;
    final skipCore = results['skip-core'] == true;
    
    // Create core structure
    if (!skipCore) {
      print('📁 Generating core architecture...');
      final coreGenerator = CoreGenerator(projectName);
      await coreGenerator.generateCoreStructure();
    }
    
    // Create features directory
    final featuresDir = Directory('lib/features');
    if (!featuresDir.existsSync() || force) {
      await featuresDir.create(recursive: true);
      print('✅ Created: lib/features');
    }
    
    // Add dependencies to pubspec
    await _updatePubspec(pubspec, pubspecContent, projectName);
    
    print('\n🎉 Embit Architecture initialized!');
    print('\n📋 Next steps:');
    print('   1. Run `flutter pub get`');
    print('   2. Create your first feature: `embit feature --name auth`');
    print('   3. Update main.dart to initialize DI and routing');
    print('\n📖 Documentation: https://github.com/yourname/embit-cli');
  }
  
  String _extractProjectName(String pubspecContent) {
    final match = RegExp(r'name:\s*(\w+)').firstMatch(pubspecContent);
    return match?.group(1) ?? 'my_app';
  }
  
  Future<void> _updatePubspec(File pubspec, String content, String projectName) async {
    final dependencies = {
      'get_it': '^7.6.0',
      'dartz': '^0.10.1',
      'flutter_bloc': '^8.1.3',
      'equatable': '^2.0.5',
      'connectivity_plus': '^5.0.2',
      'shared_preferences': '^2.2.2',
      'google_fonts':'^7.0.1',
    };
    
    final devDependencies = {
      'mockito': '^5.4.0',
      'bloc_test': '^9.1.5',
    };
    
    var updated = content;
    
    // Add dependencies
    for (final dep in dependencies.entries) {
      if (!updated.contains('${dep.key}:')) {
        final insertPoint = updated.indexOf('dependencies:') + 'dependencies:'.length;
        updated = updated.replaceRange(
          insertPoint,
          insertPoint,
          '\n  ${dep.key}: ${dep.value}',
        );
      }
    }
    
    // Add dev dependencies
    for (final dep in devDependencies.entries) {
      if (!updated.contains('${dep.key}:')) {
        final insertPoint = updated.indexOf('dev_dependencies:') + 'dev_dependencies:'.length;
        updated = updated.replaceRange(
          insertPoint,
          insertPoint,
          '\n  ${dep.key}: ${dep.value}',
        );
      }
    }
    
    await pubspec.writeAsString(updated);
    print('✅ Updated pubspec.yaml with required dependencies');
  }
}