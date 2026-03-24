// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// POST /needs/:id/assign — assign a helper to a need (org_admin only).
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final userId = context.read<String>();
  final body = await context.request.json() as Map<String, dynamic>;
  final helperId = body['helper_id'] as String?;

  if (helperId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'helper_id is required'},
    );
  }

  // In production, role check (ORG_ADMIN only) + Supabase update.
  return Response.json(
    body: {
      'id': id,
      'advocate_id': helperId,
      'status': 'MATCHED',
      'assigned_by': userId,
    },
  );
}
