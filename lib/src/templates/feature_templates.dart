import 'package:embit_cli/src/models/feature_config.dart';

class FeatureTemplates {
  // Entity template
  static String entity(FeatureConfig config) => '''
import 'package:${config.projectPath}/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

sealed class ${config.pascalCase}Entity {
  const ${config.pascalCase}Entity();
}

class ${config.pascalCase} extends ${config.pascalCase}Entity {
  final String id;
  final DateTime createdAt;
  
  const ${config.pascalCase}({
    required this.id,
    required this.createdAt,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ${config.pascalCase} &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ${config.pascalCase}Failure extends ${config.pascalCase}Entity 
    implements FeatureFailure {
  final String message;
  
  const ${config.pascalCase}Failure(this.message);
  
  @override
  String toString() => '${config.pascalCase}Failure: \$message';
}
''';

  // Repository interface
  static String repository(FeatureConfig config) => '''
import 'package:${config.projectPath}/core/errors/failures.dart';
import 'package:${config.projectPath}/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/${config.snakeCase}_entity.dart';

abstract class ${config.pascalCase}Repository {
  Future<Either<Failure, ${config.pascalCase}>> get${config.pascalCase}(String id);
  Future<Either<Failure, Unit>> save${config.pascalCase}(${config.pascalCase} ${config.camelCase});
  Future<Either<Failure, List<${config.pascalCase}>>> getAll${config.pascalCase}s();
}
''';

  // Repository implementation
  static String repositoryImpl(FeatureConfig config) => '''
import 'package:${config.projectPath}/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../../domain/repositories/${config.snakeCase}_repository.dart';
import '../datasources/${config.snakeCase}_remote_datasource.dart';
import '../datasources/${config.snakeCase}_local_datasource.dart';
import '../models/${config.snakeCase}_model.dart';

class ${config.pascalCase}RepositoryImpl implements ${config.pascalCase}Repository {
  final ${config.pascalCase}RemoteDataSource remoteDataSource;
  final ${config.pascalCase}LocalDataSource localDataSource;
  
  ${config.pascalCase}RepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<Either<Failure, ${config.pascalCase}>> get${config.pascalCase}(String id) async {
    try {
      // Try local first
      final localResult = await localDataSource.get${config.pascalCase}(id);
      if (localResult != null) {
        return Right(localResult.toEntity());
      }
      
      // Fallback to remote
      final remoteResult = await remoteDataSource.get${config.pascalCase}(id);
      return Right(remoteResult.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> save${config.pascalCase}(${config.pascalCase} ${config.camelCase}) async {
    try {
      final model = ${config.pascalCase}Model.fromEntity(${config.camelCase});
      await localDataSource.save${config.pascalCase}(model);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<${config.pascalCase}>>> getAll${config.pascalCase}s() async {
    try {
      final models = await remoteDataSource.getAll${config.pascalCase}s();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
''';

  // Use case
  static String useCase(FeatureConfig config) => '''
import 'package:${config.projectPath}/core/errors/failures.dart';
import 'package:${config.projectPath}/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../repositories/${config.snakeCase}_repository.dart';

class Get${config.pascalCase}UseCase implements UseCase<${config.pascalCase}, String> {
  final ${config.pascalCase}Repository repository;
  
  Get${config.pascalCase}UseCase(this.repository);
  
  @override
  Future<Either<Failure, ${config.pascalCase}>> call(String params) async {
    return await repository.get${config.pascalCase}(params);
  }
}

class Save${config.pascalCase}UseCase implements UseCase<Unit, ${config.pascalCase}> {
  final ${config.pascalCase}Repository repository;
  
  Save${config.pascalCase}UseCase(this.repository);
  
  @override
  Future<Either<Failure, Unit>> call(${config.pascalCase} params) async {
    return await repository.save${config.pascalCase}(params);
  }
}
''';

  // Bloc Event
  static String blocEvent(FeatureConfig config) => '''
part of '${config.snakeCase}_bloc.dart';

sealed class ${config.pascalCase}Event extends Equatable {
  const ${config.pascalCase}Event();

  @override
  List<Object> get props => [];
}

class Load${config.pascalCase}Event extends ${config.pascalCase}Event {
  final String id;
  
  const Load${config.pascalCase}Event(this.id);
  
  @override
  List<Object> get props => [id];
}

class Save${config.pascalCase}Event extends ${config.pascalCase}Event {
  final ${config.pascalCase} ${config.camelCase};
  
  const Save${config.pascalCase}Event(this.${config.camelCase});
  
  @override
  List<Object> get props => [${config.camelCase}];
}

class Refresh${config.pascalCase}sEvent extends ${config.pascalCase}Event {
  const Refresh${config.pascalCase}sEvent();
}
''';

  // Bloc State
  static String blocState(FeatureConfig config) => '''
part of '${config.snakeCase}_bloc.dart';

sealed class ${config.pascalCase}State extends Equatable {
  const ${config.pascalCase}State();
  
  @override
  List<Object> get props => [];
}

final class ${config.pascalCase}Initial extends ${config.pascalCase}State {}

final class ${config.pascalCase}Loading extends ${config.pascalCase}State {}

final class ${config.pascalCase}Loaded extends ${config.pascalCase}State {
  final ${config.pascalCase} ${config.camelCase};
  
  const ${config.pascalCase}Loaded(this.${config.camelCase});
  
  @override
  List<Object> get props => [${config.camelCase}];
}

final class ${config.pascalCase}sLoaded extends ${config.pascalCase}State {
  final List<${config.pascalCase}> ${config.camelCase}s;
  
  const ${config.pascalCase}sLoaded(this.${config.camelCase}s);
  
  @override
  List<Object> get props => [${config.camelCase}s];
}

final class ${config.pascalCase}Error extends ${config.pascalCase}State {
  final String message;
  
  const ${config.pascalCase}Error(this.message);
  
  @override
  List<Object> get props => [message];
}

final class ${config.pascalCase}Saved extends ${config.pascalCase}State {
  const ${config.pascalCase}Saved();
}
''';

  // Bloc
  static String bloc(FeatureConfig config) => '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:${config.projectPath}/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../../domain/usecases/get_${config.snakeCase}_usecase.dart';
import '../../domain/usecases/save_${config.snakeCase}_usecase.dart';

part '${config.snakeCase}_event.dart';
part '${config.snakeCase}_state.dart';

class ${config.pascalCase}Bloc extends Bloc<${config.pascalCase}Event, ${config.pascalCase}State> {
  final Get${config.pascalCase}UseCase get${config.pascalCase}UseCase;
  final Save${config.pascalCase}UseCase save${config.pascalCase}UseCase;
  
  ${config.pascalCase}Bloc({
    required this.get${config.pascalCase}UseCase,
    required this.save${config.pascalCase}UseCase,
  }) : super(${config.pascalCase}Initial()) {
    on<Load${config.pascalCase}Event>(_onLoad${config.pascalCase});
    on<Save${config.pascalCase}Event>(_onSave${config.pascalCase});
    on<Refresh${config.pascalCase}sEvent>(_onRefresh${config.pascalCase}s);
  }
  
  Future<void> _onLoad${config.pascalCase}(
    Load${config.pascalCase}Event event,
    Emitter<${config.pascalCase}State> emit,
  ) async {
    emit(${config.pascalCase}Loading());
    
    final result = await get${config.pascalCase}UseCase(event.id);
    
    result.fold(
      (failure) => emit(${config.pascalCase}Error(failure.message)),
      (${config.camelCase}) => emit(${config.pascalCase}Loaded(${config.camelCase})),
    );
  }
  
  Future<void> _onSave${config.pascalCase}(
    Save${config.pascalCase}Event event,
    Emitter<${config.pascalCase}State> emit,
  ) async {
    emit(${config.pascalCase}Loading());
    
    final result = await save${config.pascalCase}UseCase(event.${config.camelCase});
    
    result.fold(
      (failure) => emit(${config.pascalCase}Error(failure.message)),
      (_) => emit(${config.pascalCase}Saved()),
    );
  }
  
  Future<void> _onRefresh${config.pascalCase}s(
    Refresh${config.pascalCase}sEvent event,
    Emitter<${config.pascalCase}State> emit,
  ) async {
    // Implementation depends on your API
    emit(${config.pascalCase}Initial());
  }
}
''';

  // Page with DI
  static String page(FeatureConfig config) => '''
import 'package:flutter/material.dart';
import 'package:${config.projectPath}/core/di/dependency_injection.dart';
import 'bloc/${config.snakeCase}_bloc.dart';
import 'widgets/${config.snakeCase}_widget.dart';

class ${config.pascalCase}Page extends StatelessWidget {
  static const String routeName = '/${config.snakeCase}';
  
  final String? id;
  
  const ${config.pascalCase}Page({super.key, this.id});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<${config.pascalCase}Bloc>(),
      child: _${config.pascalCase}View(id: id),
    );
  }
}

class _${config.pascalCase}View extends StatelessWidget {
  final String? id;
  
  const _${config.pascalCase}View({this.id});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${config.pascalCase}'),
      ),
      body: ${config.pascalCase}Widget(id: id),
    );
  }
}
''';

  // DI Registration
  static String diRegistration(FeatureConfig config) => '''
import 'package:${config.projectPath}/core/di/dependency_injection.dart';
import 'package:${config.projectPath}/features/${config.snakeCase}/data/datasources/${config.snakeCase}_remote_datasource.dart';
import 'package:${config.projectPath}/features/${config.snakeCase}/data/datasources/${config.snakeCase}_local_datasource.dart';
import 'package:${config.projectPath}/features/${config.snakeCase}/data/repositories/${config.snakeCase}_repository_impl.dart';
import 'package:${config.projectPath}/features/${config.snakeCase}/domain/repositories/${config.snakeCase}_repository.dart';
import 'package:${config.projectPath}/features/${config.snakeCase}/domain/usecases/get_${config.snakeCase}_usecase.dart';
import 'package:${config.projectPath}/features/${config.snakeCase}/domain/usecases/save_${config.snakeCase}_usecase.dart';
import 'package:${config.projectPath}/features/${config.snakeCase}/presentation/bloc/${config.snakeCase}_bloc.dart';

void register${config.pascalCase}Feature() {
  // Data Sources
  getIt.registerLazySingleton<${config.pascalCase}RemoteDataSource>(
    () => ${config.pascalCase}RemoteDataSourceImpl(),
  );
  
  getIt.registerLazySingleton<${config.pascalCase}LocalDataSource>(
    () => ${config.pascalCase}LocalDataSourceImpl(),
  );
  
  // Repository
  getIt.registerLazySingleton<${config.pascalCase}Repository>(
    () => ${config.pascalCase}RepositoryImpl(
      remoteDataSource: getIt<${config.pascalCase}RemoteDataSource>(),
      localDataSource: getIt<${config.pascalCase}LocalDataSource>(),
    ),
  );
  
  // Use Cases
  getIt.registerLazySingleton(
    () => Get${config.pascalCase}UseCase(
      getIt<${config.pascalCase}Repository>(),
    ),
  );
  
  getIt.registerLazySingleton(
    () => Save${config.pascalCase}UseCase(
      getIt<${config.pascalCase}Repository>(),
    ),
  );
  
  // Bloc (factory because each page needs its own instance)
  getIt.registerFactory(
    () => ${config.pascalCase}Bloc(
      get${config.pascalCase}UseCase: getIt<Get${config.pascalCase}UseCase>(),
      save${config.pascalCase}UseCase: getIt<Save${config.pascalCase}UseCase>(),
    ),
  );
}
''';

  // Route Registration
  static String routeRegistration(FeatureConfig config) => '''
import 'package:${config.projectPath}/features/${config.snakeCase}/presentation/pages/${config.snakeCase}_page.dart';

Map<String, WidgetBuilder> get${config.pascalCase}Routes() {
  return {
    ${config.pascalCase}Page.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      return ${config.pascalCase}Page(
        id: args?['id'] as String?,
      );
    },
  };
}
''';

  // Feature Index
  static String featureIndex(FeatureConfig config) => '''
library ${config.snakeCase}_feature;

// Domain
export 'domain/entities/${config.snakeCase}_entity.dart';
export 'domain/repositories/${config.snakeCase}_repository.dart';
export 'domain/usecases/get_${config.snakeCase}_usecase.dart';
export 'domain/usecases/save_${config.snakeCase}_usecase.dart';

// Data
export 'data/datasources/${config.snakeCase}_remote_datasource.dart';
export 'data/datasources/${config.snakeCase}_local_datasource.dart';
export 'data/models/${config.snakeCase}_model.dart';
export 'data/repositories/${config.snakeCase}_repository_impl.dart';

// Presentation
export 'presentation/bloc/${config.snakeCase}_bloc.dart';
export 'presentation/pages/${config.snakeCase}_page.dart';
export 'presentation/widgets/${config.snakeCase}_widget.dart';

// DI Registration
export 'di/${config.snakeCase}_di.dart';

// Route Registration
export 'routes/${config.snakeCase}_routes.dart';
''';
}