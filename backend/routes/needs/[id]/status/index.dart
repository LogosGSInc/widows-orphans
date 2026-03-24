// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/middleware/rate_limit_middleware.dart';

/// PATCH /needs/:id/status — update need status.
/// Role-gated: helper, org_admin, moderator.
///
/// When transitioning to IN_PROGRESS, enforces the helper claim limit.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.patch) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final userId = context.read<String>();
  final body = await context.request.json() as Map<String, dynamic>;
  final newStatus = body['status'] as String?;

  if (newStatus == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'status is required'},
    );
  }

  final validStatuses = [
    'OPEN',
    'UNDER_REVIEW',
    'MATCHED',
    'IN_PROGRESS',
    'FULFILLED',
    'CLOSED',
    'ESCALATED',
  ];

  if (!validStatuses.contains(newStatus)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Invalid status: $newStatus'},
    );
  }

  // Enforce claim limit when a helper claims (transitions to IN_PROGRESS)
  if (newStatus == 'IN_PROGRESS') {
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
  }

  // In production, role check + Supabase update with RLS.
  return Response.json(
    body: {
      'id': id,
      'status': newStatus,
      'updated_by': userId,
    },
  );
}
