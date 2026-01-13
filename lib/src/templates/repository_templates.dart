import '../models/feature_config.dart';

class RepositoryTemplates {
  /// Repository interface template
  static String repositoryInterface(FeatureConfig config) => '''
/// ${config.pascalCase} Repository Interface
///
/// Abstract repository defining the contract for ${config.name} operations.
/// This interface is implemented by the data layer.
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/${config.snakeCase}_entity.dart';

/// Abstract repository interface for ${config.name} operations
abstract class ${config.pascalCase}Repository {
  /// Gets a ${config.name} by ID
  ///
  /// Returns [${config.pascalCase}Entity] on success or [Failure] on error.
  Future<Either<Failure, ${config.pascalCase}Entity>> get${config.pascalCase}(String id);

  /// Gets all ${config.name}s
  ///
  /// Returns [List<${config.pascalCase}Entity>] on success or [Failure] on error.
  Future<Either<Failure, List<${config.pascalCase}Entity>>> getAll${config.pascalCase}s();

  /// Creates a new ${config.name}
  ///
  /// Returns created [${config.pascalCase}Entity] on success or [Failure] on error.
  Future<Either<Failure, ${config.pascalCase}Entity>> create${config.pascalCase}({
    required String name,
    String? description,
  });

  /// Updates an existing ${config.name}
  ///
  /// Returns updated [${config.pascalCase}Entity] on success or [Failure] on error.
  Future<Either<Failure, ${config.pascalCase}Entity>> update${config.pascalCase}({
    required String id,
    String? name,
    String? description,
    bool? isActive,
  });

  /// Deletes a ${config.name}
  ///
  /// Returns [Unit] on success or [Failure] on error.
  Future<Either<Failure, Unit>> delete${config.pascalCase}(String id);
}
''';

  /// Repository implementation template
  static String repositoryImpl(FeatureConfig config) => '''
/// ${config.pascalCase} Repository Implementation
///
/// Implements the ${config.pascalCase}Repository interface from the domain layer.
/// Coordinates between remote and local data sources.
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/${config.snakeCase}_entity.dart';
import '../../domain/repositories/${config.snakeCase}_repository.dart';
import '../datasources/${config.snakeCase}_local_datasource.dart';
import '../datasources/${config.snakeCase}_remote_datasource.dart';

/// Implementation of ${config.pascalCase}Repository
class ${config.pascalCase}RepositoryImpl implements ${config.pascalCase}Repository {
  final ${config.pascalCase}RemoteDataSource _remoteDataSource;
  final ${config.pascalCase}LocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  ${config.pascalCase}RepositoryImpl({
    required ${config.pascalCase}RemoteDataSource remoteDataSource,
    required ${config.pascalCase}LocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, ${config.pascalCase}Entity>> get${config.pascalCase}(String id) async {
    try {
      // Try local first
      final localData = await _localDataSource.get${config.pascalCase}(id);
      if (localData != null) {
        // If online, refresh in background
        if (await _networkInfo.isConnected) {
          _refreshFromRemote(id);
        }
        return Right(localData.toEntity());
      }

      // No local data, fetch from remote
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      final remoteData = await _remoteDataSource.get${config.pascalCase}(id);
      await _localDataSource.cache${config.pascalCase}(remoteData);
      return Right(remoteData.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on StorageException {
      return const Left(CacheFailure());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<${config.pascalCase}Entity>>> getAll${config.pascalCase}s() async {
    try {
      if (!await _networkInfo.isConnected) {
        // Return cached data if offline
        final cachedData = await _localDataSource.getAll${config.pascalCase}s();
        if (cachedData.isNotEmpty) {
          return Right(cachedData.map((m) => m.toEntity()).toList());
        }
        return const Left(NetworkFailure());
      }

      final remoteData = await _remoteDataSource.getAll${config.pascalCase}s();
      await _localDataSource.cacheAll${config.pascalCase}s(remoteData);
      return Right(remoteData.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ${config.pascalCase}Entity>> create${config.pascalCase}({
    required String name,
    String? description,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await _remoteDataSource.create${config.pascalCase}(
        name: name,
        description: description,
      );
      await _localDataSource.cache${config.pascalCase}(result);
      return Right(result.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(
        message: e.message,
        fieldErrors: e.errors,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ${config.pascalCase}Entity>> update${config.pascalCase}({
    required String id,
    String? name,
    String? description,
    bool? isActive,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await _remoteDataSource.update${config.pascalCase}(
        id: id,
        name: name,
        description: description,
        isActive: isActive,
      );
      await _localDataSource.cache${config.pascalCase}(result);
      return Right(result.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(
        message: e.message,
        fieldErrors: e.errors,
      ));
    } on NotFoundException {
      return const Left(NotFoundFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete${config.pascalCase}(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.delete${config.pascalCase}(id);
      await _localDataSource.remove${config.pascalCase}(id);
      return const Right(unit);
    } on NotFoundException {
      return const Left(NotFoundFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  /// Refresh data from remote in background
  Future<void> _refreshFromRemote(String id) async {
    try {
      final remoteData = await _remoteDataSource.get${config.pascalCase}(id);
      await _localDataSource.cache${config.pascalCase}(remoteData);
    } catch (_) {
      // Ignore background refresh errors
    }
  }
}
''';
}