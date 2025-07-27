# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Flutter diary app that uses Supabase for backend services. The project is in early development with a basic Flutter counter app template and Supabase integration setup.

## Common Development Commands

### Build & Run
- `flutter run` - Run the app on connected device/emulator
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app (requires macOS with Xcode)
- `flutter build web` - Build for web deployment

### Code Quality
- `flutter analyze` - Run static analysis to check for errors and warnings
- `flutter test` - Run all tests in the test/ directory
- `flutter test test/widget_test.dart` - Run a specific test file

### Dependencies
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies to latest versions
- `flutter pub outdated` - Check for outdated dependencies

### Development Setup
- `flutter doctor` - Check Flutter installation and dependencies
- `flutter clean` - Clean build artifacts

## Architecture & Structure

### Current Implementation
The app currently has a minimal structure:
- **lib/main.dart**: Entry point with basic counter app template and Supabase initialization
- **Dependencies**: Uses `supabase_flutter: ^2.9.1` for backend integration
- **Testing**: Basic widget test in `test/widget_test.dart`

### Supabase Configuration
The app expects Supabase credentials to be provided in the main.dart file:
- `url` and `anonKey` variables need to be defined before the Supabase.initialize() call
- An `.env.example` file exists showing the expected environment variables structure

### Key Development Considerations
1. The Supabase initialization in main.dart:6 is missing the required URL and anon key variables
2. Consider implementing proper environment variable handling for Supabase credentials
3. The app uses Material Design with a purple color scheme
4. Flutter SDK requirement: ^3.7.2

### Platform-Specific Files
- **iOS**: Podfile exists but needs `pod install` after adding native dependencies
- **Android**: Standard gradle-based build configuration
- **Web**: Basic web support with PWA manifest
- **macOS**: Podfile exists for macOS desktop support