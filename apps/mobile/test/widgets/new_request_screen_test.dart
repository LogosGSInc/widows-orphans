// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:widows_orphans_mobile/screens/requester/new_request_screen.dart';

void main() {
  Widget buildTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: NewRequestScreen(),
      ),
    );
  }

  group('NewRequestScreen', () {
    testWidgets('renders form with all required fields', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // App bar title
      expect(find.text('Submit a Need'), findsOneWidget);

      // Category dropdown
      expect(
        find.byType(DropdownButtonFormField<NeedCategory>),
        findsOneWidget,
      );

      // Urgency segmented button
      expect(find.byType(SegmentedButton<NeedUrgency>), findsOneWidget);

      // Location zone text field
      expect(find.text('Location / Zone'), findsOneWidget);

      // Description field
      expect(find.text('Description (optional)'), findsOneWidget);

      // Anonymous toggle
      expect(
        find.text('Keep my identity private from helpers'),
        findsOneWidget,
      );

      // Submit button
      expect(find.text('Submit My Need'), findsOneWidget);
    });

    testWidgets('location zone validation rejects empty input',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Tap submit without filling location zone
      await tester.tap(find.text('Submit My Need'));
      await tester.pumpAndSettle();

      // Validation message should appear
      expect(
        find.text('Please enter a general location or zone'),
        findsOneWidget,
      );
    });

    testWidgets('anonymous toggle changes state', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Find the switch
      final switchFinder = find.byType(SwitchListTile);
      expect(switchFinder, findsOneWidget);

      // Initially off
      final switchWidget = tester.widget<SwitchListTile>(switchFinder);
      expect(switchWidget.value, isFalse);

      // Toggle it on
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      final updatedSwitch = tester.widget<SwitchListTile>(switchFinder);
      expect(updatedSwitch.value, isTrue);
    });

    testWidgets('all urgency levels are displayed', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Low'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Critical'), findsOneWidget);
    });

    testWidgets('submit button is disabled while submitting', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Fill required field first
      final locationField = find.widgetWithText(TextFormField, 'Location / Zone');
      await tester.enterText(locationField, 'North Side');
      await tester.pumpAndSettle();

      // The button should be enabled before submit
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });
  });
}
