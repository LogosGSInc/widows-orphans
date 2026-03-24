// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

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
SentryEvent? _beforeSend(SentryEvent event, Hint hint) {
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.tracesSampleRate = 1.0;
      options.beforeSend = _beforeSend;
      options.sendDefaultPii = false;
    },
    appRunner: () => runApp(
      const ProviderScope(
        child: PartnerPortalApp(),
      ),
    ),
  );
}
