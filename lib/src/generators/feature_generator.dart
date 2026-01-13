import 'dart:io';
import 'package:embit_cli/src/models/feature_config.dart';
import 'package:embit_cli/src/templates/feature_templates.dart';
import 'package:embit_cli/src/templates/di_templates.dart';

class FeatureGenerator {
  final FeatureConfig config;

  FeatureGenerator(this.config);

  Future<void> generate() async {
    await _createDirectoryStructure();
    await _generateDomainLayer();
    await _generateDataLayer();
    await _generatePresentationLayer();
    await _generateDI();
    await _generateRoutes();
    await _updateAppRegistries();
    
    print('✅ Generated feature: ${config.name}');
  }

  Future<void> _createDirectoryStructure() async {
    final directories = [
      // Domain
      '${config.name}/domain/entities',
      '${config.name}/domain/repositories',
      '${config.name}/domain/usecases',
      // Data
      '${config.name}/data/datasources',
      '${config.name}/data/models',
      '${config.name}/data/repositories',
      // Presentation
      '${config.name}/presentation/bloc',
      '${config.name}/presentation/pages',
      '${config.name}/presentation/widgets',
      // DI & Routes
      '${config.name}/di',
      '${config.name}/routes',
    ];

    for (final dir in directories) {
      await Directory('lib/features/$dir').create(recursive: true);
    }
  }

  Future<void> _generateDomainLayer() async {
    // Entity
    await File('lib/features/${config.name}/domain/entities/${config.snakeCase}_entity.dart')
        .writeAsString(FeatureTemplates.entity(config));
    
    // Repository interface
    await File('lib/features/${config.name}/domain/repositories/${config.snakeCase}_repository.dart')
        .writeAsString(FeatureTemplates.repository(config));
    
    // Use cases
    await File('lib/features/${config.name}/domain/usecases/get_${config.snakeCase}_usecase.dart')
        .writeAsString(FeatureTemplates.useCase(config));
  }

  Future<void> _generateDataLayer() async {
    // Model
    final modelContent = '''
import '../../domain/entities/${config.snakeCase}_entity.dart';

class ${config.pascalCase}Model {
  final String id;
  final DateTime createdAt;
  
  const ${config.pascalCase}Model({
    required this.id,
    required this.createdAt,
  });
  
  factory ${config.pascalCase}Model.fromJson(Map<String, dynamic> json) {
    return ${config.pascalCase}Model(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  ${config.pascalCase} toEntity() {
    return ${config.pascalCase}(
      id: id,
      createdAt: createdAt,
    );
  }
  
  static ${config.pascalCase}Model fromEntity(${config.pascalCase} entity) {
    return ${config.pascalCase}Model(
      id: entity.id,
      createdAt: entity.createdAt,
    );
  }
}
''';
    
    await File('lib/features/${config.name}/data/models/${config.snakeCase}_model.dart')
        .writeAsString(modelContent);
    
    // Data sources
    final remoteDataSource = '''
import '../models/${config.snakeCase}_model.dart';

abstract class ${config.pascalCase}RemoteDataSource {
  Future<${config.pascalCase}Model> get${config.pascalCase}(String id);
  Future<List<${config.pascalCase}Model>> getAll${config.pascalCase}s();
}

class ${config.pascalCase}RemoteDataSourceImpl implements ${config.pascalCase}RemoteDataSource {
  @override
  Future<${config.pascalCase}Model> get${config.pascalCase}(String id) async {
    // Implement API call
    throw UnimplementedError();
  }
  
  @override
  Future<List<${config.pascalCase}Model>> getAll${config.pascalCase}s() async {
    // Implement API call
    throw UnimplementedError();
  }
}
''';
    
    await File('lib/features/${config.name}/data/datasources/${config.snakeCase}_remote_datasource.dart')
        .writeAsString(remoteDataSource);
    
    final localDataSource = '''
import '../models/${config.snakeCase}_model.dart';

abstract class ${config.pascalCase}LocalDataSource {
  Future<${config.pascalCase}Model?> get${config.pascalCase}(String id);
  Future<void> save${config.pascalCase}(${config.pascalCase}Model model);
}

class ${config.pascalCase}LocalDataSourceImpl implements ${config.pascalCase}LocalDataSource {
  @override
  Future<${config.pascalCase}Model?> get${config.pascalCase}(String id) async {
    // Implement local storage
    return null;
  }
  
  @override
  Future<void> save${config.pascalCase}(${config.pascalCase}Model model) async {
    // Implement local storage
  }
}
''';
    
    await File('lib/features/${config.name}/data/datasources/${config.snakeCase}_local_datasource.dart')
        .writeAsString(localDataSource);
    
    // Repository implementation
    await File('lib/features/${config.name}/data/repositories/${config.snakeCase}_repository_impl.dart')
        .writeAsString(FeatureTemplates.repositoryImpl(config));
  }

  Future<void> _generatePresentationLayer() async {
    // Bloc files
    await File('lib/features/${config.name}/presentation/bloc/${config.snakeCase}_bloc.dart')
        .writeAsString(FeatureTemplates.bloc(config));
    
    await File('lib/features/${config.name}/presentation/bloc/${config.snakeCase}_event.dart')
        .writeAsString(FeatureTemplates.blocEvent(config));
    
    await File('lib/features/${config.name}/presentation/bloc/${config.snakeCase}_state.dart')
        .writeAsString(FeatureTemplates.blocState(config));
    
    // Page
    await File('lib/features/${config.name}/presentation/pages/${config.snakeCase}_page.dart')
        .writeAsString(FeatureTemplates.page(config));
    
    // Widget
    final widgetContent = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/${config.snakeCase}_bloc.dart';
import '../../../domain/entities/${config.snakeCase}_entity.dart';

class ${config.pascalCase}Widget extends StatelessWidget {
  final String? id;
  
  const ${config.pascalCase}Widget({super.key, this.id});
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<${config.pascalCase}Bloc, ${config.pascalCase}State>(
      builder: (context, state) {
        return switch (state) {
          ${config.pascalCase}Initial() => _buildInitial(context),
          ${config.pascalCase}Loading() => _buildLoading(),
          ${config.pascalCase}Loaded(:final ${config.camelCase}) => _buildLoaded(context, ${config.camelCase}),
          ${config.pascalCase}Error(:final message) => _buildError(message),
          ${config.pascalCase}Saved() => _buildSaved(context),
          _ => const SizedBox(),
        };
      },
    );
  }
  
  Widget _buildInitial(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (id != null) {
        context.read<${config.pascalCase}Bloc>().add(Load${config.pascalCase}Event(id!));
      }
    });
    
    return const Center(
      child: Text('Initializing...'),
    );
  }
  
  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  Widget _buildLoaded(BuildContext context, ${config.pascalCase} ${config.camelCase}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('ID: \${${config.camelCase}.id}'),
          Text('Created: \${${config.camelCase}.createdAt}'),
          ElevatedButton(
            onPressed: () {
              // Add save functionality
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text('Error: \$message', textAlign: TextAlign.center),
        ],
      ),
    );
  }
  
  Widget _buildSaved(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 16),
          const Text('Saved successfully!'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<${config.pascalCase}Bloc>().add(const Refresh${config.pascalCase}sEvent());
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
''';
    
    await File('lib/features/${config.name}/presentation/widgets/${config.snakeCase}_widget.dart')
        .writeAsString(widgetContent);
  }

  Future<void> _generateDI() async {
    await File('lib/features/${config.name}/di/${config.snakeCase}_di.dart')
        .writeAsString(FeatureTemplates.diRegistration(config));
  }

  Future<void> _generateRoutes() async {
    await File('lib/features/${config.name}/routes/${config.snakeCase}_routes.dart')
        .writeAsString(FeatureTemplates.routeRegistration(config));
  }

  Future<void> _updateAppRegistries() async {
    // Update main DI container
    await _updateFile(
      'lib/core/di/dependency_injection.dart',
      DITemplates.appDIContainer(config.projectPath, _getAllFeatures()),
    );
    
    // Update route aggregator
    await _updateFile(
      'lib/core/navigation/app_router.dart',
      DITemplates.routeAggregator(config.projectPath, _getAllFeatures()),
    );
    
    // Update feature registry
    await _updateFile(
      'lib/core/features/feature_registry.dart',
      DITemplates.featureRegistry(_getAllFeatures()),
    );
  }

  List<String> _getAllFeatures() {
    final featuresDir = Directory('lib/features');
    if (!featuresDir.existsSync()) return [config.name];
    
    return featuresDir
        .listSync()
        .whereType<Directory>()
        .map((dir) => dir.path.split('/').last)
        .where((name) => name != config.name)
        .toList()
      ..add(config.name)
      ..sort();
  }

  Future<void> _updateFile(String path, String newContent) async {
    final file = File(path);
    if (file.existsSync()) {
      // For existing files, we might want to merge instead of replace
      // This is a simple implementation - you might want to make it smarter
      await file.writeAsString(newContent);
    } else {
      await file.create(recursive: true);
      await file.writeAsString(newContent);
    }
  }
}