// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:test/test.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

void main() {
  const jwtSecret = 'test-secret';

  group('JWT validation logic', () {
    test('valid token can be verified', () {
      final jwt = JWT({'sub': 'user-123'});
      final token = jwt.sign(SecretKey(jwtSecret));

      final verified = JWT.verify(token, SecretKey(jwtSecret));
      final payload = verified.payload as Map<String, dynamic>;
      expect(payload['sub'], 'user-123');
    });

    test('expired token throws JWTExpiredException', () {
      final jwt = JWT({'sub': 'user-123'});
      final token = jwt.sign(
        SecretKey(jwtSecret),
        expiresIn: const Duration(seconds: -1),
      );

      expect(
        () => JWT.verify(token, SecretKey(jwtSecret)),
        throwsA(isA<JWTExpiredException>()),
      );
    });

    test('invalid secret throws JWTException', () {
      final jwt = JWT({'sub': 'user-123'});
      final token = jwt.sign(SecretKey(jwtSecret));

      expect(
        () => JWT.verify(token, SecretKey('wrong-secret')),
        throwsA(isA<JWTException>()),
      );
    });

    test('token without sub field returns null subject', () {
      final jwt = JWT({'role': 'REQUESTER'});
      final token = jwt.sign(SecretKey(jwtSecret));

      final verified = JWT.verify(token, SecretKey(jwtSecret));
      final payload = verified.payload as Map<String, dynamic>;
      expect(payload['sub'], isNull);
    });

    test('malformed token string throws JWTException', () {
      expect(
        () => JWT.verify('not-a-real-token', SecretKey(jwtSecret)),
        throwsA(isA<JWTException>()),
      );
    });

    test('Bearer prefix must be stripped before verification', () {
      final jwt = JWT({'sub': 'user-456'});
      final token = jwt.sign(SecretKey(jwtSecret));
      final authHeader = 'Bearer $token';

      // Simulate auth middleware logic
      expect(authHeader.startsWith('Bearer '), isTrue);
      final extracted = authHeader.substring(7);

      final verified = JWT.verify(extracted, SecretKey(jwtSecret));
      final payload = verified.payload as Map<String, dynamic>;
      expect(payload['sub'], 'user-456');
    });
  });
}
