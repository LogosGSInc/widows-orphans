// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:sentry/sentry.dart';
import 'package:backend/config/env.dart';
import 'package:backend/middleware/sentry_middleware.dart' show beforeSend;

bool _initialized = false;

/// Initializes Sentry for the backend. Safe to call multiple times —
/// only the first invocation has effect.
Future<void> initSentry() async {
  if (_initialized) return;
  _initialized = true;

  final dsn = Env.sentryDsn;
  if (dsn.isEmpty) return;

  await Sentry.init((options) {
    options.dsn = dsn;
    options.tracesSampleRate = 1.0;
    options.beforeSend = beforeSend;
    options.sendDefaultPii = false;
  });
}
