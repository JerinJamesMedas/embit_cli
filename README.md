# Embit CLI Documentation

## Version 0.6.0

[![Version](https://img.shields.io/badge/version-0.6.0-blue.svg)](https://github.com/embit-cli)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## Table of Contents

- [Overview](#overview)
- [What's New in 0.6.0](#whats-new-in-060)
- [Installation](#installation)
- [Commands](#commands)
  - [init](#init)
  - [feature](#feature)
  - [generate](#generate)
  - [build](#build)
  - [clean](#clean)
- [Feature Command Deep Dive](#feature-command-deep-dive)
- [Examples](#examples)
- [Configuration](#configuration)
- [Changelog](#changelog)
- [Troubleshooting](#troubleshooting)

---

## Overview

**Embit CLI** is a powerful command-line interface tool designed to accelerate Flutter/Dart development by automating project scaffolding, feature generation, and boilerplate code creation.

---

## What's New in 0.6.0

### 🚀 New Features

| Feature | Description |
|---------|-------------|
| **Navigation Bar Integration** | Generate features with automatic nav bar registration |
| **Custom Icons Support** | Specify Material icons for nav bar items |
| **Custom Labels** | Define human-readable labels for navigation |
| **Interactive Mode** | Step-by-step guided feature creation |
| **Smart Prompting** | Automatic prompts for nav bar configuration |

### 🔄 Changes from 0.5.0

```diff
+ Added --nav-bar flag for explicit navigation bar integration
+ Added --icon option for custom nav bar icons
+ Added --label option for custom nav bar labels
+ Added --interactive flag for guided feature creation
+ Smart detection: features with nav bar trigger automatic prompts
+ Improved feature scaffolding with navigation boilerplate
- Deprecated --simple flag (use --nav-bar=false instead)
```

---

## Installation

### Via Dart Pub

```bash
dart pub global activate embit
```

### Via Homebrew (macOS)

```bash
brew tap embit-cli/tap
brew install embit
```

### Verify Installation

```bash
embit --version
# Output: embit 0.6.0
```

---

## Commands

### init

Initialize a new Embit project or configure an existing Flutter project.

```bash
embit init [options]
```

#### Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--name` | `-n` | Project name | Current directory name |
| `--template` | `-t` | Project template (`clean`, `mvvm`, `bloc`) | `clean` |
| `--org` | `-o` | Organization identifier | `com.example` |
| `--force` | `-f` | Overwrite existing configuration | `false` |

#### Examples

```bash
# Basic initialization
embit init

# Initialize with custom name and template
embit init --name my_app --template bloc --org com.mycompany

# Force reinitialize existing project
embit init --force
```

---

### feature

Generate a new feature module with optional navigation bar integration.

```bash
embit feature --name <feature_name> [options]
```

#### Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--name` | `-n` | Feature name (required) | — |
| `--nav-bar` | — | Include in navigation bar | `false` (prompts if relevant) |
| `--icon` | `-i` | Nav bar icon (Material Icons) | `Icons.circle_outlined` |
| `--label` | `-l` | Nav bar display label | Capitalized feature name |
| `--interactive` | — | Enable interactive mode | `false` |
| `--path` | `-p` | Custom feature path | `lib/features/` |

#### Generated Structure

```
lib/features/<feature_name>/
├── data/
│   ├── datasources/
│   │   └── <feature>_remote_datasource.dart
│   ├── models/
│   │   └── <feature>_model.dart
│   └── repositories/
│       └── <feature>_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── <feature>_entity.dart
│   ├── repositories/
│   │   └── <feature>_repository.dart
│   └── usecases/
│       └── get_<feature>_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── <feature>_bloc.dart
    │   ├── <feature>_event.dart
    │   └── <feature>_state.dart
    ├── pages/
    │   └── <feature>_page.dart
    └── widgets/
        └── <feature>_widget.dart
```

---

### generate

Generate individual components within a feature.

```bash
embit generate <component> --name <name> [options]
```

#### Components

| Component | Description |
|-----------|-------------|
| `bloc` | Generate BLoC pattern files |
| `model` | Generate data model |
| `repository` | Generate repository pattern |
| `usecase` | Generate use case |
| `page` | Generate page/screen |
| `widget` | Generate widget |

#### Examples

```bash
# Generate a new bloc
embit generate bloc --name authentication --feature auth

# Generate a model
embit generate model --name user --feature auth

# Generate a use case
embit generate usecase --name login --feature auth
```

---

### build

Run build commands with Embit enhancements.

```bash
embit build [options]
```

#### Options

| Option | Description |
|--------|-------------|
| `--runner` | Run build_runner |
| `--watch` | Watch for changes |
| `--delete-conflicting` | Delete conflicting outputs |

#### Examples

```bash
# Run build_runner once
embit build --runner

# Watch mode with conflict resolution
embit build --runner --watch --delete-conflicting
```

---

### clean

Clean project build artifacts and generated files.

```bash
embit clean [options]
```

#### Options

| Option | Description |
|--------|-------------|
| `--all` | Clean all generated files |
| `--build` | Clean build folder only |
| `--cache` | Clear Embit cache |

---

## Feature Command Deep Dive

### Basic Feature (No Navigation Bar)

Creates a standalone feature module without nav bar integration.

```bash
embit feature --name orders
```

**Output:**
```
✓ Created feature: orders
✓ Generated 12 files
✓ Feature ready at lib/features/orders/

No navigation bar integration.
```

---

### Feature with Navigation Bar (Interactive Prompt)

When creating features that commonly appear in navigation (detected by naming patterns), Embit will prompt you.

```bash
embit feature --name shopping_cart
```

**Interactive Output:**
```
Creating feature: shopping_cart

? Would you like to add this feature to the navigation bar? (Y/n) Y
? Enter nav bar icon (e.g., Icons.shopping_cart): Icons.shopping_cart_outlined
? Enter nav bar label: Cart

✓ Created feature: shopping_cart
✓ Added to navigation bar
✓ Generated 14 files
✓ Feature ready at lib/features/shopping_cart/
```

---

### Feature with Navigation Bar (Explicit)

Skip prompts by explicitly declaring nav bar integration.

```bash
embit feature --name shopping_cart --nav-bar
```

**Output:**
```
✓ Created feature: shopping_cart
✓ Added to navigation bar with defaults
  - Icon: Icons.shopping_cart_outlined (auto-detected)
  - Label: Shopping Cart
✓ Generated 14 files
```

---

### Feature with Custom Icon and Label

Full control over navigation bar appearance.

```bash
embit feature --name shopping_cart --nav-bar --icon "Icons.shopping_cart_outlined" --label "Cart"
```

**Output:**
```
✓ Created feature: shopping_cart
✓ Added to navigation bar
  - Icon: Icons.shopping_cart_outlined
  - Label: Cart
✓ Generated 14 files
✓ Updated lib/core/navigation/app_navigation.dart
```

**Generated Navigation Code:**
```dart
// lib/core/navigation/app_navigation.dart
NavigationDestination(
  icon: Icon(Icons.shopping_cart_outlined),
  selectedIcon: Icon(Icons.shopping_cart),
  label: 'Cart',
),
```

---

### Interactive Mode

Step-by-step guided feature creation with all options.

```bash
embit feature --name shopping_cart --interactive
```

**Interactive Session:**
```
🚀 Embit Feature Generator (Interactive Mode)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Feature name: shopping_cart ✓

? Select architecture pattern:
  ❯ Clean Architecture (default)
    MVVM
    MVC

? Select state management:
  ❯ BLoC (default)
    Riverpod
    Provider
    GetX

? Add to navigation bar? Yes

? Navigation icon: Icons.shopping_cart_outlined

? Navigation label: Cart

? Generate test files? Yes

? Generate documentation? Yes

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary:
  Feature: shopping_cart
  Pattern: Clean Architecture
  State: BLoC
  Nav Bar: Yes (Cart)
  Tests: Yes
  Docs: Yes

? Proceed with generation? (Y/n) Y

✓ Creating feature structure...
✓ Generating data layer...
✓ Generating domain layer...
✓ Generating presentation layer...
✓ Generating tests...
✓ Updating navigation...
✓ Generating documentation...

🎉 Feature 'shopping_cart' created successfully!

Next steps:
  1. Review generated files in lib/features/shopping_cart/
  2. Implement your business logic in domain/usecases/
  3. Connect your data sources in data/datasources/
```

---

## Examples

### Complete Workflow Example

```bash
# 1. Initialize new project
embit init --name ecommerce_app --template clean --org com.mystore

# 2. Create core features
embit feature --name authentication
embit feature --name home --nav-bar --icon "Icons.home_outlined" --label "Home"
embit feature --name products --nav-bar --icon "Icons.inventory_2_outlined" --label "Products"
embit feature --name shopping_cart --nav-bar --icon "Icons.shopping_cart_outlined" --label "Cart"
embit feature --name profile --nav-bar --icon "Icons.person_outline" --label "Profile"
embit feature --name orders

# 3. Generate additional components
embit generate usecase --name add_to_cart --feature shopping_cart
embit generate model --name cart_item --feature shopping_cart

# 4. Build generated code
embit build --runner --delete-conflicting
```

### Quick Commands Reference

```bash
# Feature without nav bar
embit feature --name orders

# Feature with nav bar (will prompt)
embit feature --name shopping_cart

# Feature with nav bar (explicit, defaults)
embit feature --name shopping_cart --nav-bar

# Feature with custom nav bar settings
embit feature --name shopping_cart --nav-bar --icon "Icons.shopping_cart_outlined" --label "Cart"

# Feature with full interactive mode
embit feature --name shopping_cart --interactive

# Feature at custom path
embit feature --name admin_panel --path lib/admin/features/
```

---

## Configuration

### embit.yaml

Project-level configuration file.

```yaml
# embit.yaml
version: 0.6.0

project:
  name: my_app
  org: com.example

architecture:
  pattern: clean  # clean, mvvm, bloc
  state_management: bloc

features:
  default_path: lib/features/
  generate_tests: true
  
navigation:
  enabled: true
  type: bottom  # bottom, drawer, rail
  max_items: 5
  default_icon: Icons.circle_outlined

templates:
  custom_path: .embit/templates/
```

---

## Changelog

### Version 0.6.0 (Latest)

#### Added
- ✨ Navigation bar integration for features
- ✨ `--nav-bar` flag for explicit nav bar inclusion
- ✨ `--icon` option for custom Material icons
- ✨ `--label` option for custom navigation labels
- ✨ `--interactive` flag for guided feature creation
- ✨ Smart prompting for nav bar features
- ✨ Auto-detection of nav bar icons based on feature names

#### Changed
- 📦 Improved feature scaffolding with navigation boilerplate
- 📦 Better error messages and validation
- 📦 Updated templates for Flutter 3.x compatibility

#### Fixed
- 🐛 Fixed path resolution on Windows
- 🐛 Fixed template variable substitution edge cases

### Version 0.5.0

- Initial public release
- Basic feature generation
- Project initialization
- Component generators
- Build command integration

---

## Troubleshooting

### Common Issues

**Issue: "Feature name already exists"**
```bash
# Use --force to overwrite
- embit feature --name existing_feature --force
```

**Issue: "Navigation bar limit exceeded"**
```bash
# Check your navigation configuration in embit.yaml
# Default max_items is 5
```

**Issue: "Icon not found"**
```bash
# Ensure you're using valid Material Icons
# Format: Icons.icon_name or Icons.icon_name_outlined
- embit feature --name cart --nav-bar --icon "Icons.shopping_cart"
```

### Get Help

```bash
# General help
- embit --help

# Command-specific help
- embit feature --help
- embit generate --help

# Version info
- embit --version
```

---

## Support

- 📖 [Documentation](https://embit.dev/docs)
- 🐛 [Issue Tracker](https://github.com/embit-cli/issues)
- 💬 [Discord Community](https://discord.gg/embit)

---

##  Made with ❤️ by the Embit Team
