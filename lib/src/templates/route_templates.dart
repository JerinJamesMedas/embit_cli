// import '../models/feature_config.dart';

// class RouteTemplates {
//   /// Route paths to add to route_names.dart
//   static String routePaths(FeatureConfig config) => '''
  
//   // ============== ${config.pascalCase.toUpperCase()} ROUTES ==============
//   static const String ${config.camelCase} = '/${config.snakeCase}';
//   static const String ${config.camelCase}Detail = '/${config.snakeCase}/:${config.camelCase}Id';
// ''';

//   /// Route names to add to route_names.dart  
//   static String routeNames(FeatureConfig config) => '''
  
//   // ${config.pascalCase}
//   static const String ${config.camelCase} = '${config.camelCase}';
//   static const String ${config.camelCase}Detail = '${config.camelCase}Detail';
// ''';

//   /// GoRoute entries to add to app_router.dart
//   static String goRouteEntries(FeatureConfig config) => '''
        
//         // ============== ${config.pascalCase.toUpperCase()} ROUTES ==============
//         GoRoute(
//           path: RoutePaths.${config.camelCase},
//           name: RouteNames.${config.camelCase},
//           builder: (context, state) => const ${config.pascalCase}Page(),
//           routes: [
//             GoRoute(
//               path: ':${config.camelCase}Id',
//               name: RouteNames.${config.camelCase}Detail,
//               builder: (context, state) {
//                 final ${config.camelCase}Id = state.pathParameters['${config.camelCase}Id'] ?? '';
//                 return ${config.pascalCase}DetailPage(id: ${config.camelCase}Id);
//               },
//             ),
//           ],
//         ),
// ''';

//   /// Import to add to app_router.dart
//   static String pageImport(FeatureConfig config, String projectName) => '''
// import 'package:${projectName}/features/${config.snakeCase}/presentation/pages/${config.snakeCase}_page.dart';
// import 'package:${projectName}/features/${config.snakeCase}/presentation/pages/${config.snakeCase}_detail_page.dart';
// ''';

//   /// API endpoints to add
//   static String apiEndpoint(FeatureConfig config) => '''
  
//   // ${config.pascalCase}
//   static const String ${config.camelCase} = '/api/${config.snakeCase}s';
// ''';
// }


/// Route Templates
/// 
/// Templates for route-related code generation.
library;

import '../models/feature_config.dart';

/// Route templates
class RouteTemplates {
  /// Route paths for route_names.dart
  static String routePaths(FeatureConfig config) => '''
  // ============== ${config.pascalCase.toUpperCase()} ==============
  static const String ${config.camelCase} = '/${config.snakeCase}';
  static const String ${config.camelCase}Detail = '/${config.snakeCase}/:${config.camelCase}Id';
''';

  /// Route names for route_names.dart
  static String routeNames(FeatureConfig config) => '''
  // ${config.pascalCase}
  static const String ${config.camelCase} = '${config.camelCase}';
  static const String ${config.camelCase}Detail = '${config.camelCase}Detail';
''';

  /// Page import for app_router.dart
  static String pageImport(FeatureConfig config, String projectName) => '''
import 'package:$projectName/features/${config.snakeCase}/presentation/pages/${config.snakeCase}_page.dart';
import 'package:$projectName/features/${config.snakeCase}/presentation/pages/${config.snakeCase}_detail_page.dart';''';

  /// GoRoute entries for standalone routes (not in nav bar)
  static String goRouteEntries(FeatureConfig config) => '''
        GoRoute(
          path: RoutePaths.${config.camelCase},
          name: RouteNames.${config.camelCase},
          builder: (context, state) => const ${config.pascalCase}Page(),
          routes: [
            GoRoute(
              path: ':${config.camelCase}Id',
              name: RouteNames.${config.camelCase}Detail,
              builder: (context, state) {
                final ${config.camelCase}Id = state.pathParameters['${config.camelCase}Id'] ?? '';
                return ${config.pascalCase}DetailPage(id: ${config.camelCase}Id);
              },
            ),
          ],
        ),''';

  /// GoRoute entry for ShellRoute (nav bar routes)
  static String shellRouteEntry(FeatureConfig config) => '''
            // ${config.pascalCase}
            GoRoute(
              path: RoutePaths.${config.camelCase},
              name: RouteNames.${config.camelCase},
              pageBuilder: (context, state) => NoTransitionPage(
                child: const ${config.pascalCase}Page(),
              ),
              routes: [
                GoRoute(
                  path: ':${config.camelCase}Id',
                  name: RouteNames.${config.camelCase}Detail,
                  builder: (context, state) {
                    final ${config.camelCase}Id = state.pathParameters['${config.camelCase}Id'] ?? '';
                    return ${config.pascalCase}DetailPage(id: ${config.camelCase}Id);
                  },
                ),
              ],
            ),''';

  /// NavItem for role_based_navigator.dart
  static String navItem(FeatureConfig config) {
    final permission = config.requiredPermission != null
        ? '\n      requiredPermission: Permissions.${config.requiredPermission},'
        : '';
    
    return '''
    NavItem(
      route: '/${config.snakeCase}',
      icon: ${config.displayIcon},
      activeIcon: ${config.displayActiveIcon},
      label: '${config.displayLabel}',$permission
    ),''';
  }

  /// API endpoint constants
  static String apiEndpoint(FeatureConfig config) => '''
  // ============== ${config.pascalCase.toUpperCase()} ==============
  static const String ${config.camelCase}s = '/${config.snakeCase}s';
  static const String ${config.camelCase}ById = '/${config.snakeCase}s/{id}';
''';

  /// Route guards addition
  static String publicRouteEntry(FeatureConfig config) => '''
      '/${config.snakeCase}',''';
}