// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:domain/domain.dart';
import '../../providers/need_providers.dart';
import '../widgets/status_badge.dart';

/// Helper's view of a single need with Claim / In Progress / Fulfilled actions.
/// Route: /available/:id
///
/// NEVER shows: requester name, requester profile, requester history.
class NeedDetailScreen extends ConsumerStatefulWidget {
  const NeedDetailScreen({super.key, required this.needId});

  final String needId;

  @override
  ConsumerState<NeedDetailScreen> createState() => _NeedDetailScreenState();
}

class _NeedDetailScreenState extends ConsumerState<NeedDetailScreen> {
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final needAsync = ref.watch(needDetailProvider(widget.needId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Need Detail')),
      body: needAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Unable to load: $e')),
        data: (need) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category header
                Row(
                  children: [
                    Icon(
                      categoryIcon(need.category),
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      categoryLabel(need.category),
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                StatusBadge(status: need.status),
                const SizedBox(height: 16),

                _DetailRow(
                  label: 'Urgency',
                  value: urgencyLabel(need.urgency),
                ),
                _DetailRow(label: 'Zone', value: need.locationZone),

                if (need.description != null &&
                    need.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Description', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(need.description!),
                    ),
                  ),
                ],

                const Spacer(),

                // Action buttons (context-dependent based on current status)
                ..._buildActions(need),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildActions(NeedRequest need) {
    final actions = <Widget>[];

    if (need.status == NeedStatus.open ||
        need.status == NeedStatus.matched) {
      actions.add(
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isBusy ? null : () => _claim(need),
            child: const Text('Claim This Need'),
          ),
        ),
      );
    }

    if (need.status == NeedStatus.matched ||
        need.status == NeedStatus.open) {
      actions.add(const SizedBox(height: 8));
      actions.add(
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isBusy ? null : () => _markInProgress(need),
            child: const Text('Mark In Progress'),
          ),
        ),
      );
    }

    if (need.status == NeedStatus.inProgress) {
      actions.add(
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isBusy ? null : () => _markFulfilled(need),
            child: const Text('Mark Fulfilled'),
          ),
        ),
      );
    }

    actions.add(const SizedBox(height: 16));

    return actions;
  }

  Future<void> _claim(NeedRequest need) async {
    setState(() => _isBusy = true);
    try {
      await ref
          .read(needDetailProvider(widget.needId).notifier)
          .updateStatus(NeedStatus.inProgress);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _markInProgress(NeedRequest need) async {
    setState(() => _isBusy = true);
    try {
      await ref
          .read(needDetailProvider(widget.needId).notifier)
          .updateStatus(NeedStatus.inProgress);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _markFulfilled(NeedRequest need) async {
    // Prompt for optional fulfillment note (internal only)
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Fulfillment Note'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Optional note (internal only)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    setState(() => _isBusy = true);
    try {
      await ref
          .read(needDetailProvider(widget.needId).notifier)
          .updateStatus(NeedStatus.fulfilled);
      if (mounted) context.go('/available');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
