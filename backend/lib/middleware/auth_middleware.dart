// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Middleware authMiddleware() {
  return (handler) {
    return (context) async {
      final authHeader = context.request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.json(
          statusCode: 401,
          body: {'error': 'Missing or invalid Authorization header'},
        );
      }

      final token = authHeader.substring(7);
      final jwtSecret =
          Platform.environment['JWT_SECRET'] ?? 'fallback-dev-secret';

      try {
        final jwt = JWT.verify(token, SecretKey(jwtSecret));
        final payload = jwt.payload as Map<String, dynamic>;
        final userId = payload['sub'] as String?;

        if (userId == null) {
          return Response.json(
            statusCode: 401,
            body: {'error': 'Invalid token: missing subject'},
          );
        }

        // Provide the authenticated user ID downstream
        final updatedContext = context.provide<String>(() => userId);
        return handler(updatedContext);
      } on JWTExpiredException {
        return Response.json(
          statusCode: 401,
          body: {'error': 'Token expired'},
        );
      } on JWTException catch (e) {
        return Response.json(
          statusCode: 401,
          body: {'error': 'Invalid token: ${e.message}'},
        );
      }
    };
  };
}
