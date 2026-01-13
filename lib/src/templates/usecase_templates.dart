import '../models/feature_config.dart';

class UseCaseTemplates {
  /// Base usecase (if not already exists in the project)
  static String baseUseCase() => '''
/// Base Use Case
///
/// Abstract class for all use cases in the application.
library;

import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Base use case interface
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case with no parameters
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

/// No params class for use cases that don't need parameters
class NoParams {
  const NoParams();
}
''';

  /// Get use case template
  static String getUseCase(FeatureConfig config) => '''
/// Get ${config.pascalCase} Use Case
///
/// Retrieves a ${config.name} by ID.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/${config.snakeCase}_entity.dart';
import '../repositories/${config.snakeCase}_repository.dart';

/// Parameters for Get${config.pascalCase}UseCase
class Get${config.pascalCase}Params extends Equatable {
  final String id;

  const Get${config.pascalCase}Params({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Get ${config.name} use case
class Get${config.pascalCase}UseCase implements UseCase<${config.pascalCase}Entity, Get${config.pascalCase}Params> {
  final ${config.pascalCase}Repository _repository;

  Get${config.pascalCase}UseCase(this._repository);

  @override
  Future<Either<Failure, ${config.pascalCase}Entity>> call(Get${config.pascalCase}Params params) async {
    if (params.id.isEmpty) {
      return const Left(ValidationFailure(
        message: 'ID cannot be empty',
        fieldErrors: {'id': ['ID is required']},
      ));
    }

    return await _repository.get${config.pascalCase}(params.id);
  }
}
''';

  /// Get all use case template
  static String getAllUseCase(FeatureConfig config) => '''
/// Get All ${config.pascalCase}s Use Case
///
/// Retrieves all ${config.name}s.
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/${config.snakeCase}_entity.dart';
import '../repositories/${config.snakeCase}_repository.dart';

/// Get all ${config.name}s use case
class GetAll${config.pascalCase}sUseCase implements UseCaseNoParams<List<${config.pascalCase}Entity>> {
  final ${config.pascalCase}Repository _repository;

  GetAll${config.pascalCase}sUseCase(this._repository);

  @override
  Future<Either<Failure, List<${config.pascalCase}Entity>>> call() async {
    return await _repository.getAll${config.pascalCase}s();
  }
}
''';

  /// Create use case template
  static String createUseCase(FeatureConfig config) => '''
/// Create ${config.pascalCase} Use Case
///
/// Creates a new ${config.name}.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/${config.snakeCase}_entity.dart';
import '../repositories/${config.snakeCase}_repository.dart';

/// Parameters for Create${config.pascalCase}UseCase
class Create${config.pascalCase}Params extends Equatable {
  final String name;
  final String? description;

  const Create${config.pascalCase}Params({
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [name, description];
}

/// Create ${config.name} use case
class Create${config.pascalCase}UseCase implements UseCase<${config.pascalCase}Entity, Create${config.pascalCase}Params> {
  final ${config.pascalCase}Repository _repository;

  Create${config.pascalCase}UseCase(this._repository);

  @override
  Future<Either<Failure, ${config.pascalCase}Entity>> call(Create${config.pascalCase}Params params) async {
    // Validation
    if (params.name.trim().isEmpty) {
      return const Left(ValidationFailure(
        message: 'Name cannot be empty',
        fieldErrors: {'name': ['Name is required']},
      ));
    }

    return await _repository.create${config.pascalCase}(
      name: params.name.trim(),
      description: params.description?.trim(),
    );
  }
}
''';

  /// Update use case template
  static String updateUseCase(FeatureConfig config) => '''
/// Update ${config.pascalCase} Use Case
///
/// Updates an existing ${config.name}.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/${config.snakeCase}_entity.dart';
import '../repositories/${config.snakeCase}_repository.dart';

/// Parameters for Update${config.pascalCase}UseCase
class Update${config.pascalCase}Params extends Equatable {
  final String id;
  final String? name;
  final String? description;
  final bool? isActive;

  const Update${config.pascalCase}Params({
    required this.id,
    this.name,
    this.description,
    this.isActive,
  });

  @override
  List<Object?> get props => [id, name, description, isActive];
}

/// Update ${config.name} use case
class Update${config.pascalCase}UseCase implements UseCase<${config.pascalCase}Entity, Update${config.pascalCase}Params> {
  final ${config.pascalCase}Repository _repository;

  Update${config.pascalCase}UseCase(this._repository);

  @override
  Future<Either<Failure, ${config.pascalCase}Entity>> call(Update${config.pascalCase}Params params) async {
    // Validation
    if (params.id.isEmpty) {
      return const Left(ValidationFailure(
        message: 'ID cannot be empty',
        fieldErrors: {'id': ['ID is required']},
      ));
    }

    if (params.name != null && params.name!.trim().isEmpty) {
      return const Left(ValidationFailure(
        message: 'Name cannot be empty',
        fieldErrors: {'name': ['Name cannot be empty if provided']},
      ));
    }

    return await _repository.update${config.pascalCase}(
      id: params.id,
      name: params.name?.trim(),
      description: params.description?.trim(),
      isActive: params.isActive,
    );
  }
}
''';

  /// Delete use case template
  static String deleteUseCase(FeatureConfig config) => '''
/// Delete ${config.pascalCase} Use Case
///
/// Deletes a ${config.name} by ID.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/${config.snakeCase}_repository.dart';

/// Parameters for Delete${config.pascalCase}UseCase
class Delete${config.pascalCase}Params extends Equatable {
  final String id;

  const Delete${config.pascalCase}Params({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Delete ${config.name} use case
class Delete${config.pascalCase}UseCase implements UseCase<Unit, Delete${config.pascalCase}Params> {
  final ${config.pascalCase}Repository _repository;

  Delete${config.pascalCase}UseCase(this._repository);

  @override
  Future<Either<Failure, Unit>> call(Delete${config.pascalCase}Params params) async {
    if (params.id.isEmpty) {
      return const Left(ValidationFailure(
        message: 'ID cannot be empty',
        fieldErrors: {'id': ['ID is required']},
      ));
    }

    return await _repository.delete${config.pascalCase}(params.id);
  }
}
''';
}