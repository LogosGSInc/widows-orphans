// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:domain/domain.dart';
import '../auth/auth_provider.dart';
import '../auth/sign_in_screen.dart';
import '../screens/requester_home_screen.dart';
import '../screens/helper_home_screen.dart';
import '../screens/dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/signin',
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
          UserRole.orgAdmin => '/dashboard',
          UserRole.moderator => '/dashboard',
          UserRole.sponsorAdmin => '/dashboard',
        };
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/requests',
        builder: (context, state) => const RequesterHomeScreen(),
      ),
      GoRoute(
        path: '/available',
        builder: (context, state) => const HelperHomeScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});
