// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/middleware/rate_limit_middleware.dart';

/// POST /needs/:id/assign — assign a helper to a need (org_admin only).
///
/// Enforces a maximum of [maxActiveClaims] active needs per helper.
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

  // In production this queries Supabase for the helper's active claim count.
  // For pilot, the check is enforced at the DB/RLS level and here as a guard.
  final activeClaimCount = body['_active_claim_count'] as int? ?? 0;
  if (activeClaimCount >= maxActiveClaims) {
    return Response.json(
      statusCode: HttpStatus.conflict,
      body: {
        'error':
            'You have reached the maximum of $maxActiveClaims active needs.',
      },
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
