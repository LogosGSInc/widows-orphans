// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:dart_frog/dart_frog.dart';
import 'package:sentry/sentry.dart';

/// PII fields that must never be sent to Sentry.
const _piiKeys = {
  'description',
  'location_zone',
  'locationZone',
  'name',
  'email',
  'requester_id',
  'requesterId',
};

/// Strips PII from Sentry events before transmission.
SentryEvent? beforeSend(SentryEvent event, Hint hint) {
  var data = event.extra;
  if (data != null) {
    data = Map<String, dynamic>.from(data)
      ..removeWhere((key, _) => _piiKeys.contains(key));
    event = event.copyWith(extra: data);
  }

  // Strip PII from breadcrumbs
  final breadcrumbs = event.breadcrumbs?.map((b) {
    if (b.data == null) return b;
    final cleaned = Map<String, dynamic>.from(b.data!)
      ..removeWhere((key, _) => _piiKeys.contains(key));
    return b.copyWith(data: cleaned);
  }).toList();

  if (breadcrumbs != null) {
    event = event.copyWith(breadcrumbs: breadcrumbs);
  }

  return event;
}

/// Middleware that captures unhandled exceptions and sends them to Sentry.
Middleware sentryMiddleware() {
  return (handler) {
    return (context) async {
      try {
        return await handler(context);
      } catch (exception, stackTrace) {
        await Sentry.captureException(exception, stackTrace: stackTrace);
        rethrow;
      }
    };
  };
}
