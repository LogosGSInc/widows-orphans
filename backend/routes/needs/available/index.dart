// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// GET /needs/available — helper's available/assigned needs.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final userId = context.read<String>();

  // In production, fetches needs assigned to this helper (advocate_id)
  // or open needs in the helper's zone if trust_tier >= TRUSTED.
  return Response.json(
    body: {
      'needs': <Map<String, dynamic>>[],
      'helper_id': userId,
    },
  );
}
