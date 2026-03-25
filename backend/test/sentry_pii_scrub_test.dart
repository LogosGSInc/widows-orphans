// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:test/test.dart';
import 'package:sentry/sentry.dart';
import 'package:backend/middleware/sentry_middleware.dart';

void main() {
  group('Sentry PII scrubbing — beforeSend', () {
    test('strips description from extras', () {
      final event = SentryEvent(
        extra: const {
          'description': 'I need help with rent',
          'category': 'HOUSEHOLD',
        },
      );

      final result = beforeSend(event, Hint());
      expect(result, isNotNull);
      expect(result!.extra, isNot(contains('description')));
      expect(result.extra?['category'], 'HOUSEHOLD');
    });

    test('strips location_zone from extras', () {
      final event = SentryEvent(
        extra: const {
          'location_zone': 'Downtown East',
          'status': 'OPEN',
        },
      );

      final result = beforeSend(event, Hint());
      expect(result, isNotNull);
      expect(result!.extra, isNot(contains('location_zone')));
      expect(result.extra?['status'], 'OPEN');
    });

    test('strips name and email from extras', () {
      final event = SentryEvent(
        extra: const {
          'name': 'Jane Doe',
          'email': 'jane@example.com',
          'role': 'REQUESTER',
        },
      );

      final result = beforeSend(event, Hint());
      expect(result, isNotNull);
      expect(result!.extra, isNot(contains('name')));
      expect(result.extra, isNot(contains('email')));
      expect(result.extra?['role'], 'REQUESTER');
    });

    test('strips requester_id from extras', () {
      final event = SentryEvent(
        extra: const {
          'requester_id': 'uuid-123',
          'need_id': 'uuid-456',
        },
      );

      final result = beforeSend(event, Hint());
      expect(result, isNotNull);
      expect(result!.extra, isNot(contains('requester_id')));
      expect(result.extra?['need_id'], 'uuid-456');
    });

    test('strips PII from breadcrumb data', () {
      final event = SentryEvent(
        breadcrumbs: [
          Breadcrumb(
            message: 'user action',
            data: const {
              'description': 'sensitive description',
              'location_zone': 'secret zone',
              'action': 'submit',
            },
          ),
        ],
      );

      final result = beforeSend(event, Hint());
      expect(result, isNotNull);
      expect(result!.breadcrumbs, hasLength(1));

      final breadcrumbData = result.breadcrumbs!.first.data;
      expect(breadcrumbData, isNot(contains('description')));
      expect(breadcrumbData, isNot(contains('location_zone')));
      expect(breadcrumbData?['action'], 'submit');
    });

    test('handles event with no extras gracefully', () {
      final event = SentryEvent();

      final result = beforeSend(event, Hint());
      expect(result, isNotNull);
    });

    test('handles breadcrumbs with no data gracefully', () {
      final event = SentryEvent(
        breadcrumbs: [
          Breadcrumb(message: 'simple breadcrumb'),
        ],
      );

      final result = beforeSend(event, Hint());
      expect(result, isNotNull);
      expect(result!.breadcrumbs, hasLength(1));
    });

    test('preserves non-PII fields', () {
      final event = SentryEvent(
        extra: const {
          'category': 'FOOD',
          'urgency': 'HIGH',
          'status': 'OPEN',
          'is_anonymous': true,
        },
      );

      final result = beforeSend(event, Hint());
      expect(result, isNotNull);
      expect(result!.extra?['category'], 'FOOD');
      expect(result.extra?['urgency'], 'HIGH');
      expect(result.extra?['status'], 'OPEN');
      expect(result.extra?['is_anonymous'], true);
    });
  });
}
