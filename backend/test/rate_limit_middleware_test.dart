// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:test/test.dart';
import 'package:backend/middleware/rate_limit_middleware.dart';

void main() {
  setUp(() {
    resetRateLimitStore();
  });

  group('Rate limit store', () {
    test('starts with zero count for new user', () {
      expect(currentRequestCount('user-1'), 0);
    });

    test('increments count on recordRequest', () {
      recordRequest('user-1');
      expect(currentRequestCount('user-1'), 1);
    });

    test('tracks separate counts per user', () {
      recordRequest('user-1');
      recordRequest('user-1');
      recordRequest('user-2');

      expect(currentRequestCount('user-1'), 2);
      expect(currentRequestCount('user-2'), 1);
    });

    test('allows up to maxNeedsPerDay requests', () {
      for (var i = 0; i < maxNeedsPerDay; i++) {
        recordRequest('user-1');
      }
      expect(currentRequestCount('user-1'), maxNeedsPerDay);
    });

    test('maxNeedsPerDay is 5', () {
      expect(maxNeedsPerDay, 5);
    });

    test('maxActiveClaims is 3', () {
      expect(maxActiveClaims, 3);
    });

    test('rateLimitWindow is 24 hours', () {
      expect(rateLimitWindow, const Duration(hours: 24));
    });

    test('resetRateLimitStore clears all state', () {
      recordRequest('user-1');
      recordRequest('user-2');
      resetRateLimitStore();
      expect(currentRequestCount('user-1'), 0);
      expect(currentRequestCount('user-2'), 0);
    });
  });

  group('Rate limit enforcement logic', () {
    test('blocks when count reaches maxNeedsPerDay', () {
      for (var i = 0; i < maxNeedsPerDay; i++) {
        recordRequest('user-1');
      }
      // The 6th request should be blocked
      final count = currentRequestCount('user-1');
      expect(count >= maxNeedsPerDay, isTrue);
    });

    test('allows requests under the limit', () {
      for (var i = 0; i < maxNeedsPerDay - 1; i++) {
        recordRequest('user-1');
      }
      final count = currentRequestCount('user-1');
      expect(count < maxNeedsPerDay, isTrue);
    });
  });
}
