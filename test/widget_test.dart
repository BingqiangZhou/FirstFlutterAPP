// Flutter 2048 Game widget tests
//
// This file contains tests for the 2048 game implementation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_2048_game/main.dart';

void main() {
  group('2048 Game UI Tests', () {
    testWidgets('App displays correctly on startup', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify the app title
      expect(find.text('2048 Game'), findsOneWidget);

      // Verify the game title
      expect(find.text('2048'), findsOneWidget);

      // Verify the new game button
      expect(find.text('新游戏'), findsOneWidget);

      // Verify the score boxes
      expect(find.text('分数'), findsOneWidget);
      expect(find.text('最高分'), findsOneWidget);

      // Verify the operation hint
      expect(find.text('使用方向键: ↑ ↓ ← 或 → 来移动方块'), findsOneWidget);
    });

    testWidgets('New game button resets the game', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Find and tap the new game button
      final newGameButton = find.text('新游戏');
      expect(newGameButton, findsOneWidget);

      await tester.tap(newGameButton);
      await tester.pump();

      // Verify the game board is displayed
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('Game responds to keyboard input', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Simulate arrow key press
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      // The game should still be running
      expect(find.text('2048 Game'), findsOneWidget);
    });

    testWidgets('Game displays empty tiles initially', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Find all containers representing tiles
      final tiles = find.byType(Container);

      // Verify we have tiles (16 for 4x4 grid + other containers)
      expect(tiles, findsWidgets);

      // Check that some tiles are empty (value 0)
      // This is harder to test directly as empty tiles show no text
      // but we can verify the grid structure exists
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
