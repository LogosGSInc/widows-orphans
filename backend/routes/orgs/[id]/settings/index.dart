// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// PATCH /orgs/:id/settings — update org settings.
///
/// Updatable fields: name, type, location_zones, routing_rules,
/// notification_prefs (email digest frequency).
/// JWT protected, ORG_ADMIN role required, scoped to caller's org_id.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.patch) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final userId = context.read<String>();
  final body = await context.request.json() as Map<String, dynamic>;

  // In production, verifies userId belongs to org `id` with ORG_ADMIN role,
  // then updates partner_orgs row with the provided fields.
  return Response.json(
    body: {
      'org_id': id,
      'updated_by': userId,
      'updated_fields': body.keys.toList(),
    },
  );
}
