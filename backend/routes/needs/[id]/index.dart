// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// GET /needs/:id — get a single NeedRequest (scoped by RLS).
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final userId = context.read<String>();

  // In production, Supabase RLS ensures the user can only see
  // needs they are authorized to view.
  return Response.json(
    body: {
      'id': id,
      'message': 'Need detail fetched for user $userId',
    },
  );
}
