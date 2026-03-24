// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:domain/domain.dart';
import '../../auth/auth_service.dart';
import '../../providers/need_providers.dart';
import '../widgets/status_badge.dart';

/// Org admin / moderator need queue screen.
/// Route: /dashboard/queue
class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  final Set<NeedStatus> _statusFilter = {};

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(queueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Need Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: queueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Unable to load queue: $e')),
        data: (needs) {
          final filtered = _statusFilter.isEmpty
              ? needs
              : needs.where((n) => _statusFilter.contains(n.status)).toList();

          if (filtered.isEmpty) {
            return const Center(
              child: Text(
                'No needs in queue.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(queueProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final need = filtered[index];
                final dateStr = need.createdAt != null
                    ? DateFormat.yMMMd().format(need.createdAt!)
                    : '';

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
                    '${urgencyLabel(need.urgency)} · ${need.locationZone} · $dateStr',
                  ),
                  trailing: _buildActions(need),
                  onTap: () => context.go('/dashboard/review/${need.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildActions(NeedRequest need) {
    return PopupMenuButton<String>(
      onSelected: (action) => _handleAction(action, need),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'review', child: Text('Review')),
        const PopupMenuItem(value: 'assign', child: Text('Assign to Helper')),
        const PopupMenuItem(value: 'escalate', child: Text('Escalate')),
        const PopupMenuItem(value: 'close', child: Text('Close')),
      ],
    );
  }

  Future<void> _handleAction(String action, NeedRequest need) async {
    switch (action) {
      case 'review':
        context.go('/dashboard/review/${need.id}');
      case 'assign':
        context.go('/dashboard/review/${need.id}');
      case 'escalate':
        await ref.read(queueProvider.notifier).escalateNeed(need.id);
      case 'close':
        await ref
            .read(queueProvider.notifier)
            .updateStatus(need.id, NeedStatus.closed);
    }
  }

  void _showFilterDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Filter by Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: NeedStatus.values.map((s) {
                  return CheckboxListTile(
                    title: Text(statusLabel(s)),
                    value: _statusFilter.contains(s),
                    onChanged: (checked) {
                      setDialogState(() {
                        if (checked == true) {
                          _statusFilter.add(s);
                        } else {
                          _statusFilter.remove(s);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() => _statusFilter.clear());
                  },
                  child: const Text('Clear'),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
