# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter diary app that requires authentication and database integration. The app allows users to create, read, and delete diary entries after logging in with Google or GitHub.

## Development Commands

### Build and Run
```bash
# Run the app in debug mode
flutter run

# Run on specific device/platform
flutter run -d chrome     # Web
flutter run -d ios        # iOS simulator
flutter run -d android    # Android emulator

# Build for release
flutter build apk         # Android APK
flutter build ios         # iOS (requires Mac with Xcode)
flutter build web         # Web
```

### Testing and Quality
```bash
# Run tests
flutter test

# Run linting
flutter analyze

# Format code
flutter format lib/
```

### Dependencies
```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade
```

## Architecture Requirements

Based on `docs/subject.md`, the app needs:

### 1. Authentication System
- Login page with Google/GitHub OAuth
- User session management
- Protected routes (profile page only accessible when logged in)
- Choose Firebase Auth, AWS Amplify, or similar service

### 2. Database Structure
Required fields for diary entries:
- User email address
- Entry date
- Entry title
- User's mood for the day
- Entry content

### 3. Core Pages
- **Login Page**: OAuth buttons for Google/GitHub
- **Profile Page**: List all diary entries, create/read/delete functionality

### 4. CRUD Operations
Implement logic for:
- Creating new diary entries
- Reading/viewing entries
- Deleting entries
- Real-time list updates after create/delete

## Current State

The project is in its initial template state. No authentication or diary functionality has been implemented yet. The following packages will likely be needed:

- Authentication: `firebase_auth` or AWS Amplify Flutter
- Database: `cloud_firestore`, `aws_amplify`, or SQLite
- State Management: `provider`, `riverpod`, or `bloc`
- OAuth: Platform-specific OAuth packages

## Testing Requirements

For evaluation, create a Google test account with pre-populated diary entries for evaluators to test the app functionality.