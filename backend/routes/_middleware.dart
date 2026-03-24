// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:dart_frog/dart_frog.dart';
import 'package:backend/middleware/cors_middleware.dart';
import 'package:backend/middleware/request_logger.dart';

Handler middleware(Handler handler) {
  return handler.use(corsMiddleware()).use(requestLogger());
}
