// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// GET /needs/mine — list the requester's own needs.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final userId = context.read<String>();

  // In production, Supabase RLS ensures only the requester's
  // own needs are returned (requester_id = auth.uid()).
  return Response.json(
    body: {
      'needs': <Map<String, dynamic>>[],
      'requester_id': userId,
    },
  );
}
