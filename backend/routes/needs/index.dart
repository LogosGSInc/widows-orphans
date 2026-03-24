// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// POST /needs — create a new NeedRequest (REQUESTER role).
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final userId = context.read<String>();
  final body = await context.request.json() as Map<String, dynamic>;

  // Validate required fields
  final category = body['category'] as String?;
  final urgency = body['urgency'] as String?;
  final locationZone = body['location_zone'] as String?;

  if (category == null || locationZone == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'category and location_zone are required'},
    );
  }

  // In production, this would call Supabase with the user's JWT.
  // The route contract is defined here for future external clients.
  return Response.json(
    statusCode: HttpStatus.created,
    body: {
      'id': 'generated-uuid',
      'requester_id': userId,
      'category': category,
      'urgency': urgency ?? 'MEDIUM',
      'location_zone': locationZone,
      'description': body['description'],
      'is_anonymous': body['is_anonymous'] ?? false,
      'status': 'OPEN',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    },
  );
}
