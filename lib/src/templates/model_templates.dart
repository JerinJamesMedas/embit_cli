import '../models/feature_config.dart';

class ModelTemplates {
  /// Model template that extends entity
  static String model(FeatureConfig config) => '''
/// ${config.pascalCase} Model
///
/// Data model that extends ${config.pascalCase}Entity.
/// Handles JSON serialization/deserialization for API communication.
library;

import '../../domain/entities/${config.snakeCase}_entity.dart';

/// ${config.pascalCase} data model with JSON serialization
class ${config.pascalCase}Model extends ${config.pascalCase}Entity {
  const ${config.pascalCase}Model({
    required super.id,
    required super.name,
    super.description,
    super.isActive = true,
    required super.createdAt,
    super.updatedAt,
  });

  /// Creates a ${config.pascalCase}Model from JSON map
  factory ${config.pascalCase}Model.fromJson(Map<String, dynamic> json) {
    return ${config.pascalCase}Model(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? 
                json['isActive'] as bool? ?? true,
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']) ?? 
                 DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }

  /// Converts the model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a ${config.pascalCase}Model from a ${config.pascalCase}Entity
  factory ${config.pascalCase}Model.fromEntity(${config.pascalCase}Entity entity) {
    return ${config.pascalCase}Model(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converts this model to an entity
  ${config.pascalCase}Entity toEntity() {
    return ${config.pascalCase}Entity(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates an empty ${config.pascalCase}Model
  factory ${config.pascalCase}Model.empty() {
    return ${config.pascalCase}Model(
      id: '',
      name: '',
      createdAt: DateTime.now(),
    );
  }

  /// Creates a copy with updated fields
  @override
  ${config.pascalCase}Model copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ${config.pascalCase}Model(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }
}
''';
}