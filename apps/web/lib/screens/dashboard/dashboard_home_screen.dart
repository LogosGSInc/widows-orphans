// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';
import '../../providers/org_providers.dart';

class DashboardHomeScreen extends ConsumerWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(orgStatsProvider);
    final activityAsync = ref.watch(recentActivityProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(orgStatsProvider.notifier).refresh();
        ref.read(recentActivityProvider.notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Summary cards
          statsAsync.when(
            data: (stats) => _StatsRow(stats: stats),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorCard(message: 'Failed to load stats: $e'),
          ),

          const SizedBox(height: 32),

          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Recent activity list
          activityAsync.when(
            data: (needs) => needs.isEmpty
                ? const _EmptyState(message: 'No recent activity')
                : Column(
                    children: [
                      for (final need in needs) _ActivityTile(need: need),
                    ],
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                _ErrorCard(message: 'Failed to load activity: $e'),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final OrgStats stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 800 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            _StatCard(
              label: 'Open Needs',
              value: stats.open,
              icon: Icons.inbox_outlined,
              color: Colors.orange,
            ),
            _StatCard(
              label: 'In Progress',
              value: stats.inProgress,
              icon: Icons.pending_actions_outlined,
              color: Colors.blue,
            ),
            _StatCard(
              label: 'Fulfilled This Week',
              value: stats.fulfilledThisWeek,
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            _StatCard(
              label: 'Escalated',
              value: stats.escalated,
              icon: Icons.warning_amber_outlined,
              color: Colors.red,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$value',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.need});

  final NeedRequest need;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = need.createdAt != null
        ? DateFormat.yMMMd().add_jm().format(need.createdAt!)
        : '';

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: ListTile(
        leading: _statusIcon(need.status),
        title: Text(
          '${need.category.value} — ${need.urgency.value}',
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: Text(
          '${need.status.value} · ${need.locationZone} · $dateStr',
        ),
        trailing: _urgencyChip(need.urgency, theme),
      ),
    );
  }

  Widget _statusIcon(NeedStatus status) {
    final (IconData icon, Color color) = switch (status) {
      NeedStatus.open => (Icons.inbox_outlined, Colors.orange),
      NeedStatus.underReview => (Icons.search, Colors.amber),
      NeedStatus.matched => (Icons.handshake_outlined, Colors.blue),
      NeedStatus.inProgress => (Icons.pending_actions, Colors.indigo),
      NeedStatus.fulfilled => (Icons.check_circle, Colors.green),
      NeedStatus.closed => (Icons.cancel_outlined, Colors.grey),
      NeedStatus.escalated => (Icons.warning_amber, Colors.red),
    };
    return Icon(icon, color: color);
  }

  Widget _urgencyChip(NeedUrgency urgency, ThemeData theme) {
    final color = switch (urgency) {
      NeedUrgency.low => Colors.grey,
      NeedUrgency.medium => Colors.blue,
      NeedUrgency.high => Colors.orange,
      NeedUrgency.critical => Colors.red,
    };
    return Chip(
      label: Text(
        urgency.value,
        style: TextStyle(color: color, fontSize: 12),
      ),
      side: BorderSide(color: color),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message),
      ),
    );
  }
}
