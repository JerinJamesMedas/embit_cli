/// CLI Prompts
/// 
/// Utility functions for interactive CLI prompts.
library;

import 'dart:io';

/// CLI prompt utilities
class CLIPrompts {
  CLIPrompts._();

  /// Prompts for a yes/no confirmation
  static bool confirm(String message, {bool defaultValue = false}) {
    final defaultHint = defaultValue ? 'Y/n' : 'y/N';
    stdout.write('$message [$defaultHint]: ');
    
    final input = stdin.readLineSync()?.toLowerCase().trim() ?? '';
    
    if (input.isEmpty) {
      return defaultValue;
    }
    
    return input == 'y' || input == 'yes';
  }

  /// Prompts for text input
  static String prompt(String message, {String? defaultValue}) {
    if (defaultValue != null) {
      stdout.write('$message [$defaultValue]: ');
    } else {
      stdout.write('$message: ');
    }
    
    final input = stdin.readLineSync()?.trim() ?? '';
    
    if (input.isEmpty && defaultValue != null) {
      return defaultValue;
    }
    
    return input;
  }

  /// Prompts for selection from a list
  static int select(String message, List<String> options, {int defaultIndex = 0}) {
    print(message);
    
    for (var i = 0; i < options.length; i++) {
      final marker = i == defaultIndex ? '>' : ' ';
      print('  $marker ${i + 1}. ${options[i]}');
    }
    
    stdout.write('Enter number [${defaultIndex + 1}]: ');
    final input = stdin.readLineSync()?.trim() ?? '';
    
    if (input.isEmpty) {
      return defaultIndex;
    }
    
    final index = int.tryParse(input);
    if (index != null && index >= 1 && index <= options.length) {
      return index - 1;
    }
    
    return defaultIndex;
  }

  /// Prompts for an icon selection
  static String selectIcon(String featureName) {
    print('Select an icon for the navigation bar:');
    
    final commonIcons = [
      'Icons.${featureName}_outlined',
      'Icons.folder_outlined',
      'Icons.list_outlined',
      'Icons.dashboard_outlined',
      'Icons.grid_view_outlined',
      'Icons.category_outlined',
      'Icons.article_outlined',
      'Icons.bookmark_outlined',
      'Icons.favorite_outlined',
      'Icons.star_outlined',
      'Custom (enter manually)',
    ];
    
    for (var i = 0; i < commonIcons.length; i++) {
      print('  ${i + 1}. ${commonIcons[i]}');
    }
    
    stdout.write('Enter number [1]: ');
    final input = stdin.readLineSync()?.trim() ?? '';
    
    if (input.isEmpty) {
      return commonIcons[0];
    }
    
    final index = int.tryParse(input);
    if (index != null && index >= 1 && index <= commonIcons.length) {
      if (index == commonIcons.length) {
        // Custom icon
        return prompt('Enter icon name (e.g., Icons.shopping_cart_outlined)');
      }
      return commonIcons[index - 1];
    }
    
    return commonIcons[0];
  }
}