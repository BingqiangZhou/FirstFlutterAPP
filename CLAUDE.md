# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter 2048 game implementation. The project is structured as a standard Flutter application with a single main.dart file containing the entire game logic.

## Development Commands

### Basic Development
- `flutter pub get` - Install dependencies
- `flutter run` - Run the app in development mode
- `flutter build apk --release` - Build Android APK for release
- `flutter build windows --release` - Build Windows executable
- `flutter build linux --release` - Build Linux executable
- `flutter build macos --release` - Build macOS executable

### Testing and Analysis
- `flutter test` - Run tests
- `flutter analyze` - Run static analysis on the code
- `flutter format .` - Format all Dart files

### Code Quality
The project uses flutter_lints for code quality enforcement. Run `flutter analyze` to check for linting issues.

## Architecture

### Game Structure
- The entire game is implemented in `lib/main.dart` as a single StatefulWidget
- Game state is managed using a 4x4 grid represented as `List<List<int>>`
- Score tracking includes current score and best score persistence
- Game supports both keyboard (arrow keys) and touch/swipe input

### Key Components
- `Game2048` - Main game widget containing all game logic
- Grid-based game board with responsive sizing
- Tile merging logic for all four directions (up, down, left, right)
- Win/lose condition checking
- Score calculation and display

### UI Features
- Responsive design that adapts to different screen sizes
- Color-coded tiles based on values
- Real-time score display
- Game over and win state overlays
- New game button for restarting

### Platform Support
The project is configured for multi-platform deployment:
- Android (via standard Flutter Android configuration)
- iOS (via standard Flutter iOS configuration)
- Windows (CMake-based build system)
- Linux (GTK-based build system)
- macOS (Cocoa-based build system)
- Web (standard Flutter web configuration)

### CI/CD
GitHub Actions workflow (`.github/workflows/release.yml`) automates builds for all platforms when pushing version tags (v*). The workflow requires Android signing secrets to be configured for release builds.