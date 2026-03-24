// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/auth_service.dart';
import '../../providers/need_providers.dart';
import '../widgets/status_badge.dart';

/// Screen showing the requester's own needs.
/// Route: /requests
class MyNeedsScreen extends ConsumerWidget {
  const MyNeedsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsAsync = ref.watch(needsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Needs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/requests/new'),
        icon: const Icon(Icons.add),
        label: const Text('Submit a Need'),
      ),
      body: needsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Something went wrong: $e')),
        data: (needs) {
          if (needs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No active needs. You can submit one any time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(needsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: needs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final need = needs[index];
                final dateStr = need.createdAt != null
                    ? DateFormat.yMMMd().format(need.createdAt!)
                    : '';

                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(categoryIcon(need.category)),
                  ),
                  title: Text(categoryLabel(need.category)),
                  subtitle: Text(dateStr),
                  trailing: StatusBadge(status: need.status),
                  onTap: () => context.go('/requests/status/${need.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
