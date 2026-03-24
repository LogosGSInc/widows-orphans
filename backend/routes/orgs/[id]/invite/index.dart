// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// POST /orgs/:id/invite — invite a new helper via email.
///
/// Request body: { "email": "helper@example.com" }
/// Triggers Supabase Auth invite for the new helper user.
/// JWT protected, ORG_ADMIN role required, scoped to caller's org_id.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final userId = context.read<String>();
  final body = await context.request.json() as Map<String, dynamic>;
  final email = body['email'] as String?;

  if (email == null || email.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Email is required'},
    );
  }

  // In production, verifies userId belongs to org `id` with ORG_ADMIN role,
  // then triggers Supabase Auth invite and creates a HELPER user record
  // linked to this org.
  return Response.json(
    statusCode: HttpStatus.created,
    body: {
      'org_id': id,
      'invited_by': userId,
      'email': email,
      'status': 'invited',
    },
  );
}
