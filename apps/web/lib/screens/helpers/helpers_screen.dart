// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/org_providers.dart';
import '../../services/org_dashboard_service.dart';

class HelpersScreen extends ConsumerWidget {
  const HelpersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final helpersAsync = ref.watch(orgHelpersProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Volunteer Helpers',
                style: theme.textTheme.headlineMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () =>
                  ref.read(orgHelpersProvider.notifier).refresh(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Fulfillment counts are visible to org administrators only.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        helpersAsync.when(
          data: (helpers) => helpers.isEmpty
              ? const _EmptyState()
              : _HelpersTable(helpers: helpers),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Failed to load helpers: $e'),
            ),
          ),
        ),
      ],
    );
  }
}

class _HelpersTable extends ConsumerWidget {
  const _HelpersTable({required this.helpers});

  final List<HelperInfo> helpers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Zone')),
          DataColumn(label: Text('Trust Tier')),
          DataColumn(label: Text('Assigned'), numeric: true),
          DataColumn(label: Text('Fulfilled'), numeric: true),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final helper in helpers)
            DataRow(cells: [
              DataCell(Text(helper.user.locationZone ?? 'No zone')),
              DataCell(_trustBadge(helper.user.trustTier.value)),
              DataCell(Text('${helper.assignedCount}')),
              DataCell(Text('${helper.user.fulfillmentCount}')),
              DataCell(
                helper.user.isActive
                    ? const Chip(
                        label: Text('Active', style: TextStyle(fontSize: 12)),
                        backgroundColor: Color(0xFFE8F5E9),
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      )
                    : const Chip(
                        label:
                            Text('Inactive', style: TextStyle(fontSize: 12)),
                        side: BorderSide(color: Colors.grey),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
              ),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_location_outlined, size: 20),
                    tooltip: 'Edit Zone',
                    onPressed: () =>
                        _showEditZoneDialog(context, ref, helper),
                  ),
                  if (helper.user.isActive)
                    IconButton(
                      icon: const Icon(Icons.person_off_outlined, size: 20),
                      tooltip: 'Deactivate',
                      onPressed: () =>
                          _confirmDeactivate(context, ref, helper),
                    ),
                ],
              )),
            ]),
        ],
      ),
    );
  }

  Widget _trustBadge(String tier) {
    final color = switch (tier) {
      'VERIFIED_PARTNER' => Colors.green,
      'TRUSTED' => Colors.blue,
      'BASIC' => Colors.orange,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        tier,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Future<void> _showEditZoneDialog(
    BuildContext context,
    WidgetRef ref,
    HelperInfo helper,
  ) async {
    final controller =
        TextEditingController(text: helper.user.locationZone ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Zone'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Location Zone',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await orgDashboardService.updateHelperZone(helper.user.id, result);
      ref.read(orgHelpersProvider.notifier).refresh();
    }
  }

  Future<void> _confirmDeactivate(
    BuildContext context,
    WidgetRef ref,
    HelperInfo helper,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Helper'),
        content: const Text(
          'This will remove the helper from active duty. '
          'They will no longer receive need assignments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await orgDashboardService.deactivateHelper(helper.user.id);
      ref.read(orgHelpersProvider.notifier).refresh();
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(
            Icons.people_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No helpers yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Invite helpers from the Settings page to get started.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
