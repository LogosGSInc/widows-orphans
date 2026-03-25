// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:domain/domain.dart';
import 'package:widows_orphans_mobile/screens/widgets/status_badge.dart';

void main() {
  group('StatusBadge', () {
    Widget buildTestWidget(NeedStatus status) {
      return MaterialApp(
        home: Scaffold(
          body: StatusBadge(status: status),
        ),
      );
    }

    testWidgets('displays "Open" for NeedStatus.open', (tester) async {
      await tester.pumpWidget(buildTestWidget(NeedStatus.open));
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('displays "Under Review" for NeedStatus.underReview',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(NeedStatus.underReview));
      expect(find.text('Under Review'), findsOneWidget);
    });

    testWidgets('displays "Matched" for NeedStatus.matched', (tester) async {
      await tester.pumpWidget(buildTestWidget(NeedStatus.matched));
      expect(find.text('Matched'), findsOneWidget);
    });

    testWidgets('displays "In Progress" for NeedStatus.inProgress',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(NeedStatus.inProgress));
      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('displays "Fulfilled" for NeedStatus.fulfilled',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(NeedStatus.fulfilled));
      expect(find.text('Fulfilled'), findsOneWidget);
    });

    testWidgets('displays "Closed" for NeedStatus.closed', (tester) async {
      await tester.pumpWidget(buildTestWidget(NeedStatus.closed));
      expect(find.text('Closed'), findsOneWidget);
    });

    testWidgets('displays "Escalated" for NeedStatus.escalated',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(NeedStatus.escalated));
      expect(find.text('Escalated'), findsOneWidget);
    });

    testWidgets('has a Container with rounded border', (tester) async {
      await tester.pumpWidget(buildTestWidget(NeedStatus.open));
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.borderRadius, BorderRadius.circular(12));
    });
  });

  group('statusColor', () {
    test('returns grey for OPEN', () {
      expect(statusColor(NeedStatus.open), Colors.grey);
    });

    test('returns amber for UNDER_REVIEW', () {
      expect(statusColor(NeedStatus.underReview), Colors.amber);
    });

    test('returns blue for MATCHED', () {
      expect(statusColor(NeedStatus.matched), Colors.blue);
    });

    test('returns blue for IN_PROGRESS', () {
      expect(statusColor(NeedStatus.inProgress), Colors.blue);
    });

    test('returns green for FULFILLED', () {
      expect(statusColor(NeedStatus.fulfilled), Colors.green);
    });

    test('returns green for CLOSED', () {
      expect(statusColor(NeedStatus.closed), Colors.green);
    });

    test('returns red for ESCALATED', () {
      expect(statusColor(NeedStatus.escalated), Colors.red);
    });
  });

  group('categoryIcon', () {
    test('returns restaurant icon for FOOD', () {
      expect(categoryIcon(NeedCategory.food), Icons.restaurant);
    });

    test('returns car icon for TRANSPORT', () {
      expect(categoryIcon(NeedCategory.transport), Icons.directions_car);
    });
  });

  group('categoryLabel', () {
    test('returns "Food" for NeedCategory.food', () {
      expect(categoryLabel(NeedCategory.food), 'Food');
    });

    test('returns "Other" for NeedCategory.custom', () {
      expect(categoryLabel(NeedCategory.custom), 'Other');
    });
  });

  group('urgencyLabel', () {
    test('returns correct labels for all urgency levels', () {
      expect(urgencyLabel(NeedUrgency.low), 'Low');
      expect(urgencyLabel(NeedUrgency.medium), 'Medium');
      expect(urgencyLabel(NeedUrgency.high), 'High');
      expect(urgencyLabel(NeedUrgency.critical), 'Critical');
    });
  });
}
