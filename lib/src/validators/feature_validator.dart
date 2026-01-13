/// Feature Validator
/// 
/// Validates feature names and structure for the starter kit.
library;

/// Feature name validation
class FeatureValidator {
  /// Reserved feature names that cannot be used
  static const List<String> reservedNames = [
    'core',
    'common',
    'shared',
    'app',
    'main',
    'test',
    'lib',
    'src',
    'navigation',
    'widgets',
    'utils',
    'helpers',
    'services',
    'models',
    'bloc',
    'cubit',
  ];

  /// Validates if a feature name is valid snake_case
  static bool isValidName(String name) {
    if (name.isEmpty) return false;
    
    // Must be snake_case (lowercase with underscores)
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
      return false;
    }
    
    // Cannot start or end with underscore
    if (name.startsWith('_') || name.endsWith('_')) {
      return false;
    }
    
    // Cannot contain double underscores
    if (name.contains('__')) {
      return false;
    }

    // Cannot be a reserved name
    if (reservedNames.contains(name)) {
      return false;
    }

    // Minimum length of 2 characters
    if (name.length < 2) {
      return false;
    }

    // Maximum length of 50 characters
    if (name.length > 50) {
      return false;
    }
    
    return true;
  }

  /// Validates a feature name and throws if invalid
  static void validateOrThrow(String name) {
    if (name.isEmpty) {
      throw ArgumentError(
        'Feature name cannot be empty.\n'
        'Usage: embit feature --name <feature_name>',
      );
    }

    if (reservedNames.contains(name)) {
      throw ArgumentError(
        'Invalid feature name: "$name"\n'
        '"$name" is a reserved name and cannot be used.\n'
        '\nReserved names: ${reservedNames.join(', ')}',
      );
    }

    if (!RegExp(r'^[a-z]').hasMatch(name)) {
      throw ArgumentError(
        'Invalid feature name: "$name"\n'
        'Feature names must start with a lowercase letter.\n'
        '\nExample: auth, user_profile, home',
      );
    }

    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
      throw ArgumentError(
        'Invalid feature name: "$name"\n'
        'Feature names must use snake_case (lowercase letters, numbers, and underscores).\n'
        '\nExamples:\n'
        '  ✓ auth\n'
        '  ✓ user_profile\n'
        '  ✓ order_history\n'
        '  ✗ Auth (no uppercase)\n'
        '  ✗ user-profile (no hyphens)\n'
        '  ✗ 123feature (must start with letter)',
      );
    }

    if (name.startsWith('_') || name.endsWith('_')) {
      throw ArgumentError(
        'Invalid feature name: "$name"\n'
        'Feature names cannot start or end with an underscore.\n'
        '\nExample: user_profile (not _user_profile or user_profile_)',
      );
    }

    if (name.contains('__')) {
      throw ArgumentError(
        'Invalid feature name: "$name"\n'
        'Feature names cannot contain consecutive underscores.\n'
        '\nExample: user_profile (not user__profile)',
      );
    }

    if (name.length < 2) {
      throw ArgumentError(
        'Invalid feature name: "$name"\n'
        'Feature names must be at least 2 characters long.',
      );
    }

    if (name.length > 50) {
      throw ArgumentError(
        'Invalid feature name: "$name"\n'
        'Feature names must be 50 characters or less.',
      );
    }
  }

  /// Gets validation error message (returns null if valid)
  static String? getValidationError(String name) {
    try {
      validateOrThrow(name);
      return null;
    } on ArgumentError catch (e) {
      return e.message.toString();
    }
  }

  /// Suggests a valid feature name based on invalid input
  static String? suggestValidName(String invalidName) {
    if (invalidName.isEmpty) return null;

    // Convert to lowercase
    var suggestion = invalidName.toLowerCase();

    // Replace hyphens and spaces with underscores
    suggestion = suggestion.replaceAll(RegExp(r'[-\s]+'), '_');

    // Remove invalid characters
    suggestion = suggestion.replaceAll(RegExp(r'[^a-z0-9_]'), '');

    // Remove leading numbers or underscores
    suggestion = suggestion.replaceFirst(RegExp(r'^[0-9_]+'), '');

    // Remove trailing underscores
    suggestion = suggestion.replaceFirst(RegExp(r'_+$'), '');

    // Replace multiple underscores with single
    suggestion = suggestion.replaceAll(RegExp(r'_+'), '_');

    // Check if suggestion is valid
    if (isValidName(suggestion) && suggestion != invalidName) {
      return suggestion;
    }

    return null;
  }
}

/// Extension methods for feature name conversion
extension FeatureNameConversion on String {
  /// Converts snake_case to PascalCase
  /// Example: user_profile -> UserProfile
  String toPascalCase() {
    return split('_').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join();
  }

  /// Converts snake_case to camelCase
  /// Example: user_profile -> userProfile
  String toCamelCase() {
    final pascal = toPascalCase();
    if (pascal.isEmpty) return '';
    return '${pascal[0].toLowerCase()}${pascal.substring(1)}';
  }

  /// Converts to Title Case with spaces
  /// Example: user_profile -> User Profile
  String toTitleCase() {
    return split('_').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  /// Converts PascalCase or camelCase to snake_case
  /// Example: UserProfile -> user_profile
  String toSnakeCase() {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }
}