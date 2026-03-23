// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:dart_frog/dart_frog.dart';

Middleware requestLogger() {
  return (handler) {
    return (context) async {
      final stopwatch = Stopwatch()..start();
      final method = context.request.method.value;
      final path = context.request.uri.path;

      final response = await handler(context);

      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;
      final statusCode = response.statusCode;

      // ignore: avoid_print
      print('[$method] $path -> $statusCode (${duration}ms)');

      return response;
    };
  };
}
