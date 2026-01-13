class CoreTemplates {
  // Base Failure
  static String baseFailure(String projectPath) => '''
abstract class Failure {
  final String message;
  
  const Failure(this.message);
  
  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

abstract class FeatureFailure extends Failure {
  const FeatureFailure(String message) : super(message);
}
''';

  // Base UseCase
  static String baseUseCase(String projectPath) => '''
import 'package:dartz/dartz.dart';
import 'package:$projectPath/core/errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
''';

  // App Config
  static String appConfig(String projectPath) => '''
class AppConfig {
  final String baseUrl;
  final bool isDebug;
  final String environment;
  
  AppConfig({
    required this.baseUrl,
    required this.isDebug,
    required this.environment,
  });
  
  factory AppConfig.development() {
    return AppConfig(
      baseUrl: const String.fromEnvironment('BASE_URL', defaultValue: 'https://dev.api.example.com'),
      isDebug: true,
      environment: 'development',
    );
  }
  
  factory AppConfig.staging() {
    return AppConfig(
      baseUrl: const String.fromEnvironment('BASE_URL', defaultValue: 'https://staging.api.example.com'),
      isDebug: false,
      environment: 'staging',
    );
  }
  
  factory AppConfig.production() {
    return AppConfig(
      baseUrl: const String.fromEnvironment('BASE_URL', defaultValue: 'https://api.example.com'),
      isDebug: false,
      environment: 'production',
    );
  }
}
''';
}