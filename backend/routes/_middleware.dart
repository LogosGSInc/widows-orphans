// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:dart_frog/dart_frog.dart';
import 'package:backend/config/sentry_init.dart';
import 'package:backend/middleware/cors_middleware.dart';
import 'package:backend/middleware/request_logger.dart';
import 'package:backend/middleware/sentry_middleware.dart';

/// Middleware that initializes Sentry on the first request.
Middleware _sentryInitMiddleware() {
  return (handler) {
    return (context) async {
      await initSentry();
      return handler(context);
    };
  };
}

Handler middleware(Handler handler) {
  return handler
      .use(sentryMiddleware())
      .use(corsMiddleware())
      .use(requestLogger())
      .use(_sentryInitMiddleware());
}
