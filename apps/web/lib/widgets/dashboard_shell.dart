// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_provider.dart';

class DashboardShell extends ConsumerWidget {
  const DashboardShell({required this.child, super.key});

  final Widget child;

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', path: '/dashboard'),
    _NavItem(icon: Icons.list_alt, label: 'Queue', path: '/dashboard/queue'),
    _NavItem(icon: Icons.people_outlined, label: 'Helpers', path: '/dashboard/helpers'),
    _NavItem(icon: Icons.bar_chart_outlined, label: 'Reports', path: '/dashboard/reports'),
    _NavItem(icon: Icons.settings_outlined, label: 'Settings', path: '/dashboard/settings'),
  ];

  int _selectedIndex(String location) {
    for (var i = _navItems.length - 1; i >= 0; i--) {
      if (location.startsWith(_navItems[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgAsync = ref.watch(currentOrgProvider);
    final orgName = orgAsync.valueOrNull?.name ?? 'Partner Portal';
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _selectedIndex(location);
    final isWide = MediaQuery.sizeOf(context).width >= 840;

    return Scaffold(
      appBar: AppBar(
        title: Text(orgName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (i) =>
                      context.go(_navItems[i].path),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final item in _navItems)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        label: Text(item.label),
                      ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            )
          : child,
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) =>
                  context.go(_navItems[i].path),
              destinations: [
                for (final item in _navItems)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
              ],
            ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final String label;
  final String path;
}
