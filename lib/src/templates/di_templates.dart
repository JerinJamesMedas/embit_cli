import '../models/feature_config.dart';

class DITemplates {
  /// Feature DI registration function template
  static String featureRegistration(FeatureConfig config) => '''

/// Initialize ${config.pascalCase} feature
void _init${config.pascalCase}Feature() {
  // ========== BLoC ==========
  sl.registerFactory<${config.pascalCase}Bloc>(
    () => ${config.pascalCase}Bloc(
      get${config.pascalCase}UseCase: sl(),
      getAll${config.pascalCase}sUseCase: sl(),
      create${config.pascalCase}UseCase: sl(),
      update${config.pascalCase}UseCase: sl(),
      delete${config.pascalCase}UseCase: sl(),
    ),
  );

  // ========== Use Cases ==========
  sl.registerLazySingleton<Get${config.pascalCase}UseCase>(
    () => Get${config.pascalCase}UseCase(sl()),
  );

  sl.registerLazySingleton<GetAll${config.pascalCase}sUseCase>(
    () => GetAll${config.pascalCase}sUseCase(sl()),
  );

  sl.registerLazySingleton<Create${config.pascalCase}UseCase>(
    () => Create${config.pascalCase}UseCase(sl()),
  );

  sl.registerLazySingleton<Update${config.pascalCase}UseCase>(
    () => Update${config.pascalCase}UseCase(sl()),
  );

  sl.registerLazySingleton<Delete${config.pascalCase}UseCase>(
    () => Delete${config.pascalCase}UseCase(sl()),
  );

  // ========== Repository ==========
  sl.registerLazySingleton<${config.pascalCase}Repository>(
    () => ${config.pascalCase}RepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ========== Data Sources ==========
  sl.registerLazySingleton<${config.pascalCase}RemoteDataSource>(
    () => ${config.pascalCase}RemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<${config.pascalCase}LocalDataSource>(
    () => ${config.pascalCase}LocalDataSourceImpl(sl()),
  );
}

// ==================== END OF ${config.pascalCase} FEATURE ====================
''';

  /// Imports to add to injection_container.dart
  static String featureImports(FeatureConfig config, String projectName) => '''
// ${config.pascalCase} Feature
import '../../features/${config.snakeCase}/data/datasources/${config.snakeCase}_local_datasource.dart';
import '../../features/${config.snakeCase}/data/datasources/${config.snakeCase}_remote_datasource.dart';
import '../../features/${config.snakeCase}/data/repositories/${config.snakeCase}_repository_impl.dart';
import '../../features/${config.snakeCase}/domain/repositories/${config.snakeCase}_repository.dart';
import '../../features/${config.snakeCase}/domain/usecases/create_${config.snakeCase}_usecase.dart';
import '../../features/${config.snakeCase}/domain/usecases/delete_${config.snakeCase}_usecase.dart';
import '../../features/${config.snakeCase}/domain/usecases/get_${config.snakeCase}_usecase.dart';
import '../../features/${config.snakeCase}/domain/usecases/get_all_${config.snakeCase}s_usecase.dart';
import '../../features/${config.snakeCase}/domain/usecases/update_${config.snakeCase}_usecase.dart';
import '../../features/${config.snakeCase}/presentation/bloc/${config.snakeCase}_bloc.dart';
''';

  /// Call to add in initDependencies()
  static String featureInitCall(FeatureConfig config) =>
      '  _init${config.pascalCase}Feature();';
}