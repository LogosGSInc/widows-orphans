// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_service.dart';
import '../../providers/need_providers.dart';
import '../widgets/status_badge.dart';

/// List of needs available to the helper (assigned or open in zone).
/// Route: /available
///
/// NO requester identity is shown anywhere on this screen.
class AvailableNeedsScreen extends ConsumerWidget {
  const AvailableNeedsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableAsync = ref.watch(availableNeedsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Needs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: availableAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Unable to load: $e')),
        data: (needs) {
          if (needs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No needs available right now. Check back later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(availableNeedsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: needs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final need = needs[index];

                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(categoryIcon(need.category)),
                  ),
                  title: Row(
                    children: [
                      Text(categoryLabel(need.category)),
                      const SizedBox(width: 8),
                      StatusBadge(status: need.status),
                    ],
                  ),
                  subtitle: Text(
                    '${urgencyLabel(need.urgency)} · ${need.locationZone}',
                  ),
                  onTap: () => context.go('/available/${need.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
