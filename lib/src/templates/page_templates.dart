import '../models/feature_config.dart';

class PageTemplates {
  /// Main page template
  static String page(FeatureConfig config) => '''
/// ${config.pascalCase} Page
///
/// Main page for ${config.name} feature.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../bloc/${config.snakeCase}_bloc.dart';
import '../bloc/${config.snakeCase}_event.dart';
import '../bloc/${config.snakeCase}_state.dart';
import '../widgets/${config.snakeCase}_list_widget.dart';

/// ${config.pascalCase} page widget
class ${config.pascalCase}Page extends StatelessWidget {
  const ${config.pascalCase}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<${config.pascalCase}Bloc>()
        ..add(const ${config.pascalCase}ListLoadRequested()),
      child: const ${config.pascalCase}View(),
    );
  }
}

class ${config.pascalCase}View extends StatelessWidget {
  const ${config.pascalCase}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${config.pascalCase}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<${config.pascalCase}Bloc>().add(
                const ${config.pascalCase}RefreshRequested(),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<${config.pascalCase}Bloc, ${config.pascalCase}State>(
        listener: (context, state) {
          if (state is ${config.pascalCase}Error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<${config.pascalCase}Bloc>().add(
                      const ${config.pascalCase}ErrorCleared(),
                    );
                  },
                ),
              ),
            );
          }
          if (state is ${config.pascalCase}OperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            ${config.pascalCase}Initial() => const _InitialView(),
            ${config.pascalCase}Loading() => const _LoadingView(),
            ${config.pascalCase}ListLoaded(:final ${config.camelCase}s) =>
              ${config.pascalCase}ListWidget(${config.camelCase}s: ${config.camelCase}s),
            ${config.pascalCase}Operating(:final ${config.camelCase}s) =>
              ${config.pascalCase}ListWidget(${config.camelCase}s: ${config.camelCase}s, isOperating: true),
            ${config.pascalCase}OperationSuccess(:final ${config.camelCase}s) =>
              ${config.pascalCase}ListWidget(${config.camelCase}s: ${config.camelCase}s),
            ${config.pascalCase}Error(:final ${config.camelCase}s) =>
              ${config.camelCase}s != null && ${config.camelCase}s.isNotEmpty
                  ? ${config.pascalCase}ListWidget(${config.camelCase}s: ${config.camelCase}s)
                  : const _ErrorView(),
            _ => const SizedBox(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create ${config.pascalCase}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description (optional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                context.read<${config.pascalCase}Bloc>().add(
                  ${config.pascalCase}CreateRequested(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  ),
                );
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _InitialView extends StatelessWidget {
  const _InitialView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Press refresh to load data'),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load data'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<${config.pascalCase}Bloc>().add(
                const ${config.pascalCase}ListLoadRequested(),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
''';

  /// Detail page template
  static String detailPage(FeatureConfig config) => '''
/// ${config.pascalCase} Detail Page
///
/// Detail page for viewing a single ${config.name}.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../bloc/${config.snakeCase}_bloc.dart';
import '../bloc/${config.snakeCase}_event.dart';
import '../bloc/${config.snakeCase}_state.dart';

/// ${config.pascalCase} detail page widget
class ${config.pascalCase}DetailPage extends StatelessWidget {
  final String id;

  const ${config.pascalCase}DetailPage({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<${config.pascalCase}Bloc>()
        ..add(${config.pascalCase}LoadRequested(id: id)),
      child: const ${config.pascalCase}DetailView(),
    );
  }
}

class ${config.pascalCase}DetailView extends StatelessWidget {
  const ${config.pascalCase}DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${config.pascalCase} Details'),
      ),
      body: BlocBuilder<${config.pascalCase}Bloc, ${config.pascalCase}State>(
        builder: (context, state) {
          return switch (state) {
            ${config.pascalCase}Loading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ${config.pascalCase}Loaded(:final ${config.camelCase}) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ${config.camelCase}.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('ID: \${${config.camelCase}.id}'),
                  if (${config.camelCase}.description != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(${config.camelCase}.description!),
                  ],
                  const SizedBox(height: 16),
                  Text('Status: \${${config.camelCase}.isActive ? "Active" : "Inactive"}'),
                  const SizedBox(height: 8),
                  Text('Created: \${${config.camelCase}.createdAt}'),
                  if (${config.camelCase}.updatedAt != null)
                    Text('Updated: \${${config.camelCase}.updatedAt}'),
                ],
              ),
            ),
            ${config.pascalCase}Error(:final message) => Center(
              child: Text('Error: \$message'),
            ),
            _ => const SizedBox(),
          };
        },
      ),
    );
  }
}
''';
}