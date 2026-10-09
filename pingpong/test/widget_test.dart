// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pingpong/main.dart';

void main() {
  testWidgets('keeps awarding points to the same side after repeated misses', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PingPongApp());
    await tester.tap(find.byKey(const Key('startButton')));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('2     0'), findsOneWidget);
  });

  testWidgets('starts the match and keeps replay available', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PingPongApp());

    expect(find.text('PING PONG'), findsOneWidget);
    expect(find.text('0     0'), findsOneWidget);
    expect(find.byKey(const Key('replayButton')), findsOneWidget);
    expect(find.byKey(const Key('startButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('difficultyMenu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('صعب'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('difficultyMenu')),
        matching: find.text('صعب'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('startButton')));
    await tester.pump();

    expect(find.byKey(const Key('startButton')), findsNothing);

    await tester.tap(find.byKey(const Key('replayButton')));
    await tester.pump();

    expect(find.text('0     0'), findsOneWidget);
  });
}
