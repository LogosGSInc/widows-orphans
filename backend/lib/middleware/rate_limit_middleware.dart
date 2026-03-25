// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// Maximum number of POST /needs requests per user per 24-hour window.
const int maxNeedsPerDay = 5;

/// Maximum number of active needs a helper may hold simultaneously.
const int maxActiveClaims = 3;

/// Duration of the rate limit window.
const Duration rateLimitWindow = Duration(hours: 24);

/// In-memory rate limit store: userId -> list of request timestamps.
/// Resets on server restart, which is acceptable for pilot.
final Map<String, List<DateTime>> _needsRateStore = {};

/// Prunes timestamps older than [rateLimitWindow] from the store entry.
void _pruneOldEntries(String userId) {
  final entries = _needsRateStore[userId];
  if (entries == null) return;
  final cutoff = DateTime.now().subtract(rateLimitWindow);
  entries.removeWhere((ts) => ts.isBefore(cutoff));
}

/// Returns the current request count for a user within the window.
int currentRequestCount(String userId) {
  _pruneOldEntries(userId);
  return _needsRateStore[userId]?.length ?? 0;
}

/// Records a new request timestamp for a user.
void recordRequest(String userId) {
  _needsRateStore.putIfAbsent(userId, () => []);
  _needsRateStore[userId]!.add(DateTime.now());
}

/// Clears all rate limit state. Used in tests.
void resetRateLimitStore() {
  _needsRateStore.clear();
}

/// Middleware that enforces rate limiting on POST /needs.
/// 5 requests per user per 24 hours.
Middleware rateLimitMiddleware() {
  return (handler) {
    return (context) async {
      // Only rate-limit POST requests to /needs (the create endpoint)
      final isPostNeeds = context.request.method == HttpMethod.post &&
          context.request.uri.path == '/needs';

      if (!isPostNeeds) {
        return handler(context);
      }

      final userId = context.read<String>();
      _pruneOldEntries(userId);

      final count = _needsRateStore[userId]?.length ?? 0;
      if (count >= maxNeedsPerDay) {
        return Response.json(
          statusCode: HttpStatus.tooManyRequests,
          body: {
            'error':
                'Rate limit exceeded. You may submit up to $maxNeedsPerDay needs per day.',
          },
        );
      }

      // Record the request and proceed
      recordRequest(userId);
      return handler(context);
    };
  };
}
