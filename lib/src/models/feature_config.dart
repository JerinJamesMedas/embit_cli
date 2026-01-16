/// Feature Configuration Model
/// 
/// Contains all configuration for feature generation.
library;

/// Feature configuration
class FeatureConfig {
  // ==================== CORE FIELDS ====================
  
  /// Feature name in snake_case (e.g., user_profile)
  final String name;
  
  /// Feature name in PascalCase (e.g., UserProfile)
  final String pascalCase;
  
  /// Feature name in camelCase (e.g., userProfile)
  final String camelCase;
  
  /// Feature name in snake_case (alias for name)
  final String snakeCase;
  
  /// Project name from pubspec.yaml
  final String projectName;
  
  /// Project path (absolute path to project root)
  final String projectPath;

  // ==================== OPTIONS ====================
  
  /// Whether to include example data/implementation
  final bool withExample;
  
  /// Whether to force overwrite existing files
  final bool force;
  
  /// Whether this is a dry run (no files created)
  final bool dryRun;

  // ==================== NAVIGATION BAR ====================
  
  /// Whether this feature should appear in bottom navigation bar
  final bool isNavBarRoute;
  
  /// Icon for navigation bar (e.g., Icons.shopping_cart_outlined)
  final String? navIcon;
  
  /// Active/selected icon for navigation bar (e.g., Icons.shopping_cart)
  final String? navActiveIcon;
  
  /// Label for navigation bar (e.g., "Shopping Cart")
  final String? navLabel;
  
  /// Required permission to access this route (e.g., viewOrders)
  final String? requiredPermission;

  // ==================== CONSTRUCTOR ====================

  FeatureConfig({
    required this.name,
    required this.projectName,
    required this.projectPath,
    this.withExample = false,
    this.force = false,
    this.dryRun = false,
    this.isNavBarRoute = false,
    this.navIcon,
    this.navActiveIcon,
    this.navLabel,
    this.requiredPermission,
  })  : pascalCase = _toPascalCase(name),
        camelCase = _toCamelCase(name),
        snakeCase = name;

  // ==================== CASE CONVERTERS ====================

  /// Converts snake_case to PascalCase
  static String _toPascalCase(String input) {
    return input.split('_').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join();
  }

  /// Converts snake_case to camelCase
  static String _toCamelCase(String input) {
    final pascal = _toPascalCase(input);
    if (pascal.isEmpty) return '';
    return '${pascal[0].toLowerCase()}${pascal.substring(1)}';
  }

  // ==================== COMPUTED PROPERTIES ====================

  /// Gets the display label for navigation (defaults to Title Case)
  /// e.g., "user_profile" -> "User Profile"
  String get displayLabel {
    return navLabel ?? name.split('_').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  /// Gets the navigation icon (defaults to folder icon)
  String get displayIcon {
    if (navIcon != null) return navIcon!;
    
    // Try to use feature-specific icon if available
    // Otherwise fall back to generic icons
    return 'Icons.${snakeCase}_outlined';
  }

  /// Gets the active navigation icon (defaults to filled version of icon)
  String get displayActiveIcon {
    if (navActiveIcon != null) return navActiveIcon!;
    if (navIcon != null) {
      // Remove _outlined suffix if present
      return navIcon!.replaceAll('_outlined', '');
    }
    return 'Icons.$snakeCase';
  }

  /// Feature path relative to lib/features/
  String get featurePath => 'lib/features/$snakeCase';

  /// Full path to domain layer
  String get domainPath => '$featurePath/domain';

  /// Full path to data layer
  String get dataPath => '$featurePath/data';

  /// Full path to presentation layer
  String get presentationPath => '$featurePath/presentation';

  /// Package import prefix
  String get packagePrefix => 'package:$projectName';

  /// Feature import path
  String get featureImportPath => '$packagePrefix/features/$snakeCase';

  /// Route path (e.g., "/user_profile")
  String get routePath => '/$snakeCase';

  /// Detail route path (e.g., "/user_profile/:userProfileId")
  String get detailRoutePath => '/$snakeCase/:${camelCase}Id';

  /// API endpoint path (e.g., "/user_profiles")
  String get apiEndpointPath => '/${snakeCase}s';

  // ==================== COPY WITH ====================

  /// Creates a copy with updated values
  FeatureConfig copyWith({
    String? name,
    String? projectName,
    String? projectPath,
    bool? withExample,
    bool? force,
    bool? dryRun,
    bool? isNavBarRoute,
    String? navIcon,
    String? navActiveIcon,
    String? navLabel,
    String? requiredPermission,
  }) {
    return FeatureConfig(
      name: name ?? this.name,
      projectName: projectName ?? this.projectName,
      projectPath: projectPath ?? this.projectPath,
      withExample: withExample ?? this.withExample,
      force: force ?? this.force,
      dryRun: dryRun ?? this.dryRun,
      isNavBarRoute: isNavBarRoute ?? this.isNavBarRoute,
      navIcon: navIcon ?? this.navIcon,
      navActiveIcon: navActiveIcon ?? this.navActiveIcon,
      navLabel: navLabel ?? this.navLabel,
      requiredPermission: requiredPermission ?? this.requiredPermission,
    );
  }

  // ==================== VALIDATION ====================

  /// Validates the configuration
  List<String> validate() {
    final errors = <String>[];

    if (name.isEmpty) {
      errors.add('Feature name cannot be empty');
    }

    if (projectName.isEmpty) {
      errors.add('Project name cannot be empty');
    }

    if (projectPath.isEmpty) {
      errors.add('Project path cannot be empty');
    }

    if (isNavBarRoute && navIcon != null) {
      if (!navIcon!.startsWith('Icons.')) {
        errors.add('Nav icon should start with "Icons." (e.g., Icons.home_outlined)');
      }
    }

    return errors;
  }

  /// Whether the configuration is valid
  bool get isValid => validate().isEmpty;

  // ==================== TO STRING ====================

  @override
  String toString() {
    return '''FeatureConfig(
  name: $name,
  pascalCase: $pascalCase,
  camelCase: $camelCase,
  projectName: $projectName,
  projectPath: $projectPath,
  isNavBarRoute: $isNavBarRoute,
  navIcon: $navIcon,
  navLabel: $navLabel,
)''';
  }

  // ==================== EQUALITY ====================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureConfig &&
        other.name == name &&
        other.projectName == projectName &&
        other.projectPath == projectPath;
  }

  @override
  int get hashCode => name.hashCode ^ projectName.hashCode ^ projectPath.hashCode;
}

/// Extension for common icon mappings
extension FeatureIconSuggestions on FeatureConfig {
  /// Suggests icons based on feature name
  static Map<String, String> get commonIcons => {
    'home': 'Icons.home_outlined',
    'profile': 'Icons.person_outlined',
    'settings': 'Icons.settings_outlined',
    'notifications': 'Icons.notifications_outlined',
    'messages': 'Icons.message_outlined',
    'chat': 'Icons.chat_outlined',
    'feed': 'Icons.feed_outlined',
    'search': 'Icons.search_outlined',
    'favorites': 'Icons.favorite_outlined',
    'bookmark': 'Icons.bookmark_outlined',
    'cart': 'Icons.shopping_cart_outlined',
    'shopping': 'Icons.shopping_bag_outlined',
    'orders': 'Icons.receipt_outlined',
    'payment': 'Icons.payment_outlined',
    'wallet': 'Icons.wallet_outlined',
    'analytics': 'Icons.analytics_outlined',
    'dashboard': 'Icons.dashboard_outlined',
    'reports': 'Icons.assessment_outlined',
    'users': 'Icons.people_outlined',
    'products': 'Icons.inventory_outlined',
    'categories': 'Icons.category_outlined',
    'tags': 'Icons.label_outlined',
    'files': 'Icons.folder_outlined',
    'documents': 'Icons.description_outlined',
    'images': 'Icons.image_outlined',
    'videos': 'Icons.video_library_outlined',
    'calendar': 'Icons.calendar_today_outlined',
    'events': 'Icons.event_outlined',
    'tasks': 'Icons.task_outlined',
    'notes': 'Icons.note_outlined',
    'help': 'Icons.help_outlined',
    'support': 'Icons.support_agent_outlined',
    'about': 'Icons.info_outlined',
  };

  /// Gets suggested icon based on feature name
  String get suggestedIcon {
    // Check if any key is contained in the feature name
    for (final entry in FeatureIconSuggestions.commonIcons.entries) {
      if (snakeCase.contains(entry.key)) {
        return entry.value;
      }
    }
    return 'Icons.folder_outlined';
  }

  /// Gets suggested active icon
  String get suggestedActiveIcon {
    return suggestedIcon.replaceAll('_outlined', '');
  }
}