// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// POST /needs/:id/escalate — escalate a need (moderator/org_admin only).
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final userId = context.read<String>();

  // In production, role check (MODERATOR/ORG_ADMIN) + Supabase update.
  return Response.json(
    body: {
      'id': id,
      'status': 'ESCALATED',
      'escalated_by': userId,
    },
  );
}
