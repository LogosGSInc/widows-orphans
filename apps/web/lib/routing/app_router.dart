// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:domain/domain.dart';
import '../auth/auth_provider.dart';
import '../auth/sign_in_screen.dart';
import '../widgets/dashboard_shell.dart';
import '../screens/dashboard/dashboard_home_screen.dart';
import '../screens/queue/queue_screen.dart';
import '../screens/helpers/helpers_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';

final _shellKey = GlobalKey<NavigatorState>();

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
        final user = currentUser.valueOrNull;
        if (user == null) return '/signin';

        // Only ORG_ADMIN and MODERATOR may access the partner portal.
        if (user.role == UserRole.orgAdmin ||
            user.role == UserRole.moderator) {
          return '/dashboard';
        }
        // Other roles are not supported in this web app.
        return '/signin';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => DashboardShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardHomeScreen(),
          ),
          GoRoute(
            path: '/dashboard/queue',
            builder: (context, state) => const QueueScreen(),
          ),
          GoRoute(
            path: '/dashboard/helpers',
            builder: (context, state) => const HelpersScreen(),
          ),
          GoRoute(
            path: '/dashboard/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/dashboard/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
