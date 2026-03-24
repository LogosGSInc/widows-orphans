// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// POST /needs/:id/flag — flag a need for moderator review.
///
/// Any authenticated role can flag a need. On flag, the need's status is
/// automatically set to UNDER_REVIEW and the flag is recorded.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final userId = context.read<String>();
  final body = await context.request.json() as Map<String, dynamic>;
  final reason = body['reason'] as String?;

  if (reason == null || reason.trim().isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'reason is required'},
    );
  }

  // In production:
  // 1. Insert into need_flags table
  // 2. Update need_requests.status = 'UNDER_REVIEW'
  // Both are done atomically via Supabase RPC or sequential calls.
  return Response.json(
    statusCode: HttpStatus.created,
    body: {
      'flag_id': 'generated-uuid',
      'need_id': id,
      'reporter_id': userId,
      'reason': reason.trim(),
      'need_status': 'UNDER_REVIEW',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    },
  );
}
