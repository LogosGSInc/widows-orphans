// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

Middleware corsMiddleware() {
  return (handler) {
    return (context) async {
      final allowedOrigins = Platform.environment['ALLOWED_ORIGINS']
              ?.split(',')
              .map((e) => e.trim())
              .toList() ??
          ['http://localhost:3000', 'http://localhost:8080'];

      final origin = context.request.headers['origin'] ?? '';

      final corsHeaders = <String, String>{
        'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
        'Access-Control-Allow-Headers':
            'Origin, Content-Type, Accept, Authorization',
        'Access-Control-Max-Age': '86400',
      };

      if (allowedOrigins.contains(origin)) {
        corsHeaders['Access-Control-Allow-Origin'] = origin;
      }

      // Handle preflight requests
      if (context.request.method == HttpMethod.options) {
        return Response(statusCode: 204, headers: corsHeaders);
      }

      final response = await handler(context);
      return response.copyWith(
        headers: {...response.headers, ...corsHeaders},
      );
    };
  };
}
