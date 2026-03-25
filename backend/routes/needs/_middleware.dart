// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:dart_frog/dart_frog.dart';
import 'package:backend/middleware/auth_middleware.dart';
import 'package:backend/middleware/rate_limit_middleware.dart';

Handler middleware(Handler handler) {
  return handler.use(rateLimitMiddleware()).use(authMiddleware());
}
