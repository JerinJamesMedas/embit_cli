import 'dart:io';

class CoreGenerator {
  final String projectPath;

  CoreGenerator(this.projectPath);

  Future<void> generateCoreStructure() async {
    await _createCoreDirectories();
    await _generateBaseClasses();
    await _generateDI();
    await _generateNavigation();
    await _generateNetworkLayer();
  }

  Future<void> _createCoreDirectories() async {
    final directories = [
      'core/errors',
      'core/usecases',
      'core/utils',
      'core/constants',
      'core/styles',
      'core/di',
      'core/network',
      'core/database',
      'core/navigation',
      'core/features',
    ];

    for (final dir in directories) {
      await Directory('lib/$dir').create(recursive: true);
    }
  }

  Future<void> _generateBaseClasses() async {
    // Base failure
    final failureContent = '''
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
    
    await File('lib/core/errors/failures.dart').writeAsString(failureContent);
    
    // Base use case
    final useCaseContent = '''
import 'package:dartz/dartz.dart';
import 'failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
''';
    
    await File('lib/core/usecases/usecase.dart').writeAsString(useCaseContent);
  }

  Future<void> _generateDI() async {
    final diContent = '''
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> initDependencyInjection() async {
  // Core dependencies will be registered here
  // Feature dependencies are added automatically by Embit CLI
}
''';
    
    await File('lib/core/di/dependency_injection.dart').writeAsString(diContent);
  }

  Future<void> _generateNavigation() async {
    final routerContent = '''
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Routes are added automatically by Embit CLI
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('Route \${settings.name} not configured'),
        ),
      ),
    );
  }
}
''';
    
    await File('lib/core/navigation/app_router.dart').writeAsString(routerContent);
  }

  Future<void> _generateNetworkLayer() async {
    final networkContent = '''
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Implement connectivity check
    return true;
  }
}
''';
    
    await File('lib/core/network/network_info.dart').writeAsString(networkContent);
  }
}