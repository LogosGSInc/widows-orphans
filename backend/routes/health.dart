// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  return Response.json(
    body: {
      'status': 'ok',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'version': '0.1.0',
    },
  );
}
