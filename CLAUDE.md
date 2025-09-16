# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter package project called `iautomat_auth_manager`. It's currently a basic package template with minimal implementation.

## Development Commands

### Dependencies
- **Install dependencies**: `flutter pub get`
- **Update dependencies**: `flutter pub upgrade`

### Testing
- **Run all tests**: `flutter test`
- **Run specific test**: `flutter test test/iautomat_auth_manager_test.dart`

### Code Quality
- **Analyze code**: `flutter analyze`
- **Format code**: `dart format .`

### Package Management
- **Check package health**: `dart pub publish --dry-run`

## Project Structure

```
lib/
├── iautomat_auth_manager.dart    # Main package entry point
test/
├── iautomat_auth_manager_test.dart    # Package tests
```

## Current Implementation

The package currently contains only a basic `Calculator` class as a template. The actual authentication management functionality needs to be implemented.

## Configuration Files

- **pubspec.yaml**: Package configuration, dependencies
- **analysis_options.yaml**: Uses `flutter_lints` for code analysis
- **README.md**: Template documentation (needs updating)

## Development Notes

- Minimum Dart SDK: 3.9.2
- Minimum Flutter: 1.17.0
- Uses `flutter_lints` for code quality
- Package is in initial state with template code