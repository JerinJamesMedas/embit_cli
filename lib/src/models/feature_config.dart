class FeatureConfig {
  final String name;
  final String pascalCase;
  final String camelCase;
  final String snakeCase;
  final bool withExample;
  final bool force;
  final bool dryRun;
  final String projectPath;

  FeatureConfig({
    required this.name,
    this.withExample = false,
    this.force = false,
    this.dryRun = false,
    required this.projectPath,
  })  : pascalCase = _toPascalCase(name),
        camelCase = _toCamelCase(name),
        snakeCase = name;

  static String _toPascalCase(String input) {
    return input.split('_').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join();
  }

  static String _toCamelCase(String input) {
    final pascal = _toPascalCase(input);
    return '${pascal[0].toLowerCase()}${pascal.substring(1)}';
  }
}