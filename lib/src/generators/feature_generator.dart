import 'dart:io';

import '../models/feature_config.dart';
import '../templates/bloc_templates.dart';
import '../templates/datasource_templates.dart';
import '../templates/di_templates.dart';
import '../templates/entity_templates.dart';
import '../templates/model_templates.dart';
import '../templates/page_templates.dart';
import '../templates/repository_templates.dart';
import '../templates/route_templates.dart';
import '../templates/usecase_templates.dart';
import '../templates/widget_templates.dart';

class FeatureGenerator {
  final FeatureConfig config;
  final bool verbose;

  FeatureGenerator(this.config, {this.verbose = false});

  Future<void> generate() async {
    _log('📁 Creating directory structure...');
    await _createDirectoryStructure();

    _log('📝 Generating domain layer...');
    await _generateDomainLayer();

    _log('📝 Generating data layer...');
    await _generateDataLayer();

    _log('📝 Generating presentation layer...');
    await _generatePresentationLayer();

    _log('🔧 Updating DI container...');
    await _updateDIContainer();

    _log('🛣️ Updating routes...');
    await _updateRoutes();

    _log('🔗 Updating API endpoints...');
    await _updateApiEndpoints();

    print('✅ Feature "${config.name}" generated successfully!');
  }

  void _log(String message) {
    if (verbose) {
      print(message);
    }
  }

  Future<void> _createDirectoryStructure() async {
    final directories = [
      // Domain
      'lib/features/${config.name}/domain/entities',
      'lib/features/${config.name}/domain/repositories',
      'lib/features/${config.name}/domain/usecases',
      // Data
      'lib/features/${config.name}/data/datasources',
      'lib/features/${config.name}/data/models',
      'lib/features/${config.name}/data/repositories',
      // Presentation
      'lib/features/${config.name}/presentation/bloc',
      'lib/features/${config.name}/presentation/pages',
      'lib/features/${config.name}/presentation/widgets',
    ];

    for (final dir in directories) {
      final directory = Directory(dir);
      if (!directory.existsSync()) {
        await directory.create(recursive: true);
        _log('  ✓ Created $dir');
      }
    }
  }

  Future<void> _generateDomainLayer() async {
    // Entity
    await _writeFile(
      'lib/features/${config.name}/domain/entities/${config.snakeCase}_entity.dart',
      EntityTemplates.entity(config),
    );

    // Repository interface
    await _writeFile(
      'lib/features/${config.name}/domain/repositories/${config.snakeCase}_repository.dart',
      RepositoryTemplates.repositoryInterface(config),
    );

    // Use cases
    await _writeFile(
      'lib/features/${config.name}/domain/usecases/get_${config.snakeCase}_usecase.dart',
      UseCaseTemplates.getUseCase(config),
    );

    await _writeFile(
      'lib/features/${config.name}/domain/usecases/get_all_${config.snakeCase}s_usecase.dart',
      UseCaseTemplates.getAllUseCase(config),
    );

    await _writeFile(
      'lib/features/${config.name}/domain/usecases/create_${config.snakeCase}_usecase.dart',
      UseCaseTemplates.createUseCase(config),
    );

    await _writeFile(
      'lib/features/${config.name}/domain/usecases/update_${config.snakeCase}_usecase.dart',
      UseCaseTemplates.updateUseCase(config),
    );

    await _writeFile(
      'lib/features/${config.name}/domain/usecases/delete_${config.snakeCase}_usecase.dart',
      UseCaseTemplates.deleteUseCase(config),
    );
  }

  Future<void> _generateDataLayer() async {
    // Model
    await _writeFile(
      'lib/features/${config.name}/data/models/${config.snakeCase}_model.dart',
      ModelTemplates.model(config),
    );

    // Remote data source
    await _writeFile(
      'lib/features/${config.name}/data/datasources/${config.snakeCase}_remote_datasource.dart',
      DataSourceTemplates.remoteDataSource(config),
    );

    // Local data source
    await _writeFile(
      'lib/features/${config.name}/data/datasources/${config.snakeCase}_local_datasource.dart',
      DataSourceTemplates.localDataSource(config),
    );

    // Repository implementation
    await _writeFile(
      'lib/features/${config.name}/data/repositories/${config.snakeCase}_repository_impl.dart',
      RepositoryTemplates.repositoryImpl(config),
    );
  }

  Future<void> _generatePresentationLayer() async {
    // Bloc
    await _writeFile(
      'lib/features/${config.name}/presentation/bloc/${config.snakeCase}_bloc.dart',
      BlocTemplates.bloc(config),
    );

    await _writeFile(
      'lib/features/${config.name}/presentation/bloc/${config.snakeCase}_event.dart',
      BlocTemplates.events(config),
    );

    await _writeFile(
      'lib/features/${config.name}/presentation/bloc/${config.snakeCase}_state.dart',
      BlocTemplates.states(config),
    );

    // Pages
    await _writeFile(
      'lib/features/${config.name}/presentation/pages/${config.snakeCase}_page.dart',
      PageTemplates.page(config),
    );

    await _writeFile(
      'lib/features/${config.name}/presentation/pages/${config.snakeCase}_detail_page.dart',
      PageTemplates.detailPage(config),
    );

    // Widgets
    await _writeFile(
      'lib/features/${config.name}/presentation/widgets/${config.snakeCase}_list_widget.dart',
      WidgetTemplates.listWidget(config),
    );

    await _writeFile(
      'lib/features/${config.name}/presentation/widgets/${config.snakeCase}_item_widget.dart',
      WidgetTemplates.itemWidget(config),
    );
  }

  Future<void> _updateDIContainer() async {
    final diFile = File('lib/core/di/injection_container.dart');

    if (!diFile.existsSync()) {
      print('  ⚠️ injection_container.dart not found. Skipping DI update.');
      print('     Please add the following manually:');
      print(DITemplates.featureImports(config, config.projectName));
      print(DITemplates.featureRegistration(config));
      return;
    }

    var content = await diFile.readAsString();

    // Check if feature is already registered
    if (content.contains('_init${config.pascalCase}Feature')) {
      _log('  ⚠️ Feature already registered in DI container');
      return;
    }

    // Add imports
    final imports = DITemplates.featureImports(config, config.projectName);

    // Find the last import line
    final importRegex = RegExp(r"import '[^']+';");
    final matches = importRegex.allMatches(content).toList();
    if (matches.isNotEmpty) {
      final lastImportEnd = matches.last.end;
      content =
          '${content.substring(0, lastImportEnd)}\n$imports${content.substring(lastImportEnd)}';
    }

    // Add feature init function
    final registration = DITemplates.featureRegistration(config);

    // Find the last function before the closing of the file
    // Look for the last closing brace of a function
    // final lastFunctionEnd = content.lastIndexOf('\n}');
    // if (lastFunctionEnd != -1) {
    //   content = '${content.substring(0, lastFunctionEnd)}\n$registration${content.substring(lastFunctionEnd)}';
    // }

    const endMarker =
        '// ==================== END OF FEATURE ====================';
    final index = content.lastIndexOf(endMarker);

    if (index == -1) {
      throw Exception('END OF FEATURE marker not found');
    }

    final insertPos = index + endMarker.length;

    content = '${content.substring(0, insertPos)}\n\n$registration${content.substring(insertPos)}';

    // Add call to initDependencies
    final initCall = DITemplates.featureInitCall(config);
    final initDepsRegex =
        RegExp(r'(Future<void> initDependencies\(\) async \{[^}]+)(})');
    content = content.replaceFirstMapped(initDepsRegex, (match) {
      final existingContent = match.group(1)!;
      // Check if already has call
      if (existingContent.contains('_init${config.pascalCase}Feature')) {
        return match.group(0)!;
      }
      return '$existingContent\n$initCall\n${match.group(2)}';
    });

    await diFile.writeAsString(content);
    _log('  ✓ Updated injection_container.dart');
  }

  Future<void> _updateRoutes() async {
    // Update route_names.dart
    final routeNamesFile = File('lib/navigation/route_names.dart');
    if (routeNamesFile.existsSync()) {
      var content = await routeNamesFile.readAsString();

      // Check if routes already exist
      if (!content.contains("${config.camelCase} = '/${config.snakeCase}'")) {
        // Add to RoutePaths class
        final routePathsEnd =
            content.indexOf('}', content.indexOf('class RoutePaths'));
        if (routePathsEnd != -1) {
          content = content.substring(0, routePathsEnd) +
              RouteTemplates.routePaths(config) +
              content.substring(routePathsEnd);
        }

        // Add to RouteNames class
        final routeNamesEnd =
            content.indexOf('}', content.indexOf('class RouteNames'));
        if (routeNamesEnd != -1) {
          content = content.substring(0, routeNamesEnd) +
              RouteTemplates.routeNames(config) +
              content.substring(routeNamesEnd);
        }

        await routeNamesFile.writeAsString(content);
        _log('  ✓ Updated route_names.dart');
      }
    }

    // Update app_router.dart
    final appRouterFile = File('lib/navigation/app_router.dart');
    if (appRouterFile.existsSync()) {
      var content = await appRouterFile.readAsString();

      // Check if routes already exist
      if (!content.contains('${config.pascalCase}Page')) {
        // Add import
        final pageImport =
            RouteTemplates.pageImport(config, config.projectName);
        final importRegex = RegExp(r"import '[^']+';");
        final matches = importRegex.allMatches(content).toList();
        if (matches.isNotEmpty) {
          final lastImportEnd = matches.last.end;
          content =
              '${content.substring(0, lastImportEnd)}\n$pageImport${content.substring(lastImportEnd)}';
        }

        // Add GoRoute - find the routes array in ShellRoute or main routes
        // Look for a pattern like "routes: [" and add before the closing "]"
        final routeEntry = RouteTemplates.goRouteEntries(config);

        // Find the main routes array (before error routes)
        final errorRouteIndex =
            content.indexOf('// ============== ERROR ROUTES');
        if (errorRouteIndex != -1) {
          // Find the last GoRoute before error routes
          final insertPoint = content.lastIndexOf('),', errorRouteIndex);
          if (insertPoint != -1) {
            content = content.substring(0, insertPoint + 2) +
                routeEntry +
                content.substring(insertPoint + 2);
          }
        }

        await appRouterFile.writeAsString(content);
        _log('  ✓ Updated app_router.dart');
      }
    }
  }

  Future<void> _updateApiEndpoints() async {
    final apiFile = File('lib/core/constants/api_endpoints.dart');
    if (apiFile.existsSync()) {
      var content = await apiFile.readAsString();

      // Check if endpoint already exists
      if (!content.contains('${config.camelCase}s')) {
        // Find the last static const in the class
        final classEnd = content.lastIndexOf('}');
        if (classEnd != -1) {
          content = content.substring(0, classEnd) +
              RouteTemplates.apiEndpoint(config) +
              content.substring(classEnd);
        }

        await apiFile.writeAsString(content);
        _log('  ✓ Updated api_endpoints.dart');
      }
    } else {
      _log(
          '  ⚠️ api_endpoints.dart not found. Please add API endpoints manually.');
    }
  }

  Future<void> _writeFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
    _log('  ✓ Created $path');
  }
}
