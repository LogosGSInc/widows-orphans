// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// GET /orgs/:id/stats — summary stats for the dashboard home.
///
/// Returns counts: open, in_progress, fulfilled_this_week, escalated.
/// JWT protected, ORG_ADMIN role required, scoped to caller's org_id.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final userId = context.read<String>();

  // In production, verifies userId belongs to org `id` with ORG_ADMIN role,
  // then queries need_requests scoped to org_id for aggregate counts.
  return Response.json(
    body: {
      'org_id': id,
      'admin_id': userId,
      'open': 0,
      'in_progress': 0,
      'fulfilled_this_week': 0,
      'escalated': 0,
      'recent_activity': <Map<String, dynamic>>[],
    },
  );
}
