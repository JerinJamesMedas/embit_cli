class FeatureValidator {
  static bool isValidName(String name) {
    if (name.isEmpty) return false;
    
    // Must be snake_case
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
    
    return true;
  }

  static void validateOrThrow(String name) {
    if (!isValidName(name)) {
      throw ArgumentError(
        'Invalid feature name: "$name"\n'
        'Feature names must:\n'
        '  • Use snake_case (lowercase_with_underscores)\n'
        '  • Start with a letter\n'
        '  • Contain only letters, numbers, and single underscores\n'
        '  • Not start or end with underscore\n'
        '\nExamples: auth, user_profile, home_screen',
      );
    }
  }
}