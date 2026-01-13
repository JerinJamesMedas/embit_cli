import '../models/feature_config.dart';

class WidgetTemplates {
  /// List widget template
  static String listWidget(FeatureConfig config) => '''
/// ${config.pascalCase} List Widget
///
/// Displays a list of ${config.name}s.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/${config.snakeCase}_entity.dart';
import '../bloc/${config.snakeCase}_bloc.dart';
import '../bloc/${config.snakeCase}_event.dart';
import '${config.snakeCase}_item_widget.dart';

/// List widget for displaying ${config.name}s
class ${config.pascalCase}ListWidget extends StatelessWidget {
  final List<${config.pascalCase}Entity> ${config.camelCase}s;
  final bool isOperating;

  const ${config.pascalCase}ListWidget({
    super.key,
    required this.${config.camelCase}s,
    this.isOperating = false,
  });

  @override
  Widget build(BuildContext context) {
    if (${config.camelCase}s.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No items yet'),
            SizedBox(height: 8),
            Text(
              'Tap the + button to add one',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            context.read<${config.pascalCase}Bloc>().add(
              const ${config.pascalCase}RefreshRequested(),
            );
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ${config.camelCase}s.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = ${config.camelCase}s[index];
              return ${config.pascalCase}ItemWidget(
                ${config.camelCase}: item,
                onTap: () => _onItemTap(context, item),
                onEdit: () => _onItemEdit(context, item),
                onDelete: () => _onItemDelete(context, item),
              );
            },
          ),
        ),
        if (isOperating)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  void _onItemTap(BuildContext context, ${config.pascalCase}Entity item) {
    // Navigate to detail page
    // context.push('/\${RoutePaths.${config.camelCase}s}/\${item.id}');
  }

  void _onItemEdit(BuildContext context, ${config.pascalCase}Entity item) {
    final nameController = TextEditingController(text: item.name);
    final descriptionController = TextEditingController(text: item.description ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit ${config.pascalCase}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
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
              context.read<${config.pascalCase}Bloc>().add(
                ${config.pascalCase}UpdateRequested(
                  id: item.id,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                ),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _onItemDelete(BuildContext context, ${config.pascalCase}Entity item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete ${config.pascalCase}'),
        content: Text('Are you sure you want to delete "\${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<${config.pascalCase}Bloc>().add(
                ${config.pascalCase}DeleteRequested(id: item.id),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
''';

  /// Item widget template
  static String itemWidget(FeatureConfig config) => '''
/// ${config.pascalCase} Item Widget
///
/// Displays a single ${config.name} item in a list.
library;

import 'package:flutter/material.dart';

import '../../domain/entities/${config.snakeCase}_entity.dart';

/// Item widget for displaying a single ${config.name}
class ${config.pascalCase}ItemWidget extends StatelessWidget {
  final ${config.pascalCase}Entity ${config.camelCase};
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ${config.pascalCase}ItemWidget({
    super.key,
    required this.${config.camelCase},
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: ${config.camelCase}.isActive
              ? Colors.green.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
          child: Icon(
            ${config.camelCase}.isActive ? Icons.check : Icons.close,
            color: ${config.camelCase}.isActive ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          ${config.camelCase}.name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration: ${config.camelCase}.isActive
                ? null
                : TextDecoration.lineThrough,
          ),
        ),
        subtitle: ${config.camelCase}.description != null
            ? Text(
                ${config.camelCase}.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
                break;
              case 'delete':
                onDelete?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
''';
}