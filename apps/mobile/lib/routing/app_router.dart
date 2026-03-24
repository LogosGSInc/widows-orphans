// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:domain/domain.dart';
import '../auth/auth_provider.dart';
import '../auth/sign_in_screen.dart';
import '../screens/requester/my_needs_screen.dart';
import '../screens/requester/new_request_screen.dart';
import '../screens/requester/need_status_screen.dart';
import '../screens/requester/need_fulfilled_screen.dart';
import '../screens/helper/available_needs_screen.dart';
import '../screens/helper/need_detail_screen.dart';
import '../screens/dashboard/queue_screen.dart';
import '../screens/dashboard/review_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/signin',
    observers: [SentryNavigatorObserver()],
    redirect: (context, state) {
      final isAuthenticated = authState.whenOrNull(
            data: (auth) => auth.session != null,
          ) ??
          false;

      final isOnSignIn = state.matchedLocation == '/signin';

      if (!isAuthenticated && !isOnSignIn) return '/signin';
      if (isAuthenticated && isOnSignIn) {
        // Role-based routing
        final user = currentUser.valueOrNull;
        if (user == null) return '/signin';

        return switch (user.role) {
          UserRole.requester => '/requests',
          UserRole.helper => '/available',
          UserRole.orgAdmin => '/dashboard/queue',
          UserRole.moderator => '/dashboard/queue',
          UserRole.sponsorAdmin => '/dashboard/queue',
        };
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),

      // — Requester routes —
      GoRoute(
        path: '/requests',
        builder: (context, state) => const MyNeedsScreen(),
      ),
      GoRoute(
        path: '/requests/new',
        builder: (context, state) => const NewRequestScreen(),
      ),
      GoRoute(
        path: '/requests/status/:id',
        builder: (context, state) => NeedStatusScreen(
          needId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/requests/fulfilled/:id',
        builder: (context, state) => NeedFulfilledScreen(
          needId: state.pathParameters['id']!,
        ),
      ),

      // — Helper routes —
      GoRoute(
        path: '/available',
        builder: (context, state) => const AvailableNeedsScreen(),
      ),
      GoRoute(
        path: '/available/:id',
        builder: (context, state) => NeedDetailScreen(
          needId: state.pathParameters['id']!,
        ),
      ),

      // — Dashboard / Moderator / Org Admin routes —
      GoRoute(
        path: '/dashboard/queue',
        builder: (context, state) => const QueueScreen(),
      ),
      GoRoute(
        path: '/dashboard/review/:id',
        builder: (context, state) => ReviewScreen(
          needId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});
