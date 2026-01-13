// import 'package:flutter/material.dart';
// import 'package:my_app/core/di/dependency_injection.dart';
// import 'package:my_app/core/navigation/app_router.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // Initialize DI (automatically registers all features)
//   await initDependencyInjection();
  
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Embit Architecture Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       onGenerateRoute: AppRouter.generateRoute,
//       initialRoute: '/',
//       home: const HomePage(),
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Embit Features'),
//       ),
//       body: ListView(
//         children: [
//           ListTile(
//             title: const Text('Auth Feature'),
//             onTap: () => Navigator.pushNamed(context, '/auth'),
//           ),
//           ListTile(
//             title: const Text('Profile Feature'),
//             onTap: () => Navigator.pushNamed(context, '/profile'),
//           ),
//           // More features auto-registered by Embit CLI
//         ],
//       ),
//     );
//   }
// }