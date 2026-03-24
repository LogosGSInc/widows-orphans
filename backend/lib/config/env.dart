// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';

class Env {
  static String get supabaseUrl =>
      Platform.environment['SUPABASE_URL'] ?? '';

  static String get supabaseServiceKey =>
      Platform.environment['SUPABASE_SERVICE_KEY'] ?? '';

  static String get jwtSecret =>
      Platform.environment['JWT_SECRET'] ?? 'fallback-dev-secret';

  static int get port =>
      int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;

  static List<String> get allowedOrigins =>
      (Platform.environment['ALLOWED_ORIGINS'] ?? 'http://localhost:3000')
          .split(',')
          .map((e) => e.trim())
          .toList();

  static String get sentryDsn =>
      Platform.environment['SENTRY_DSN'] ?? '';
}
