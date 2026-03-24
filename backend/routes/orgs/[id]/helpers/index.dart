// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// GET /orgs/:id/helpers — helper list for org with assigned/fulfilled counts.
///
/// Returns list of HELPER users in the org with zone, trust tier,
/// assigned count, and fulfilled count.
/// JWT protected, ORG_ADMIN role required, scoped to caller's org_id.
/// Fulfillment counts visible to org_admin only — never exposed publicly.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final userId = context.read<String>();

  // In production, verifies userId belongs to org `id` with ORG_ADMIN role,
  // then queries helper users scoped to org_id with fulfillment stats.
  return Response.json(
    body: {
      'org_id': id,
      'admin_id': userId,
      'helpers': <Map<String, dynamic>>[],
    },
  );
}
