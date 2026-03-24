// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:domain/domain.dart';
import '../../providers/need_providers.dart';
import '../widgets/status_badge.dart';

/// Full need detail screen for org admin / moderator review.
/// Route: /dashboard/review/:id
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.needId});

  final String needId;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _notesController = TextEditingController();
  String? _selectedHelperId;
  bool _isBusy = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final needAsync = ref.watch(needDetailProvider(widget.needId));
    final helpersAsync = ref.watch(orgHelpersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Review Need')),
      body: needAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Unable to load: $e')),
        data: (need) {
          final dateStr = need.createdAt != null
              ? DateFormat.yMMMd().add_jm().format(need.createdAt!)
              : '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(categoryIcon(need.category), size: 28),
                    const SizedBox(width: 8),
                    Text(
                      categoryLabel(need.category),
                      style: theme.textTheme.titleLarge,
                    ),
                    const Spacer(),
                    StatusBadge(status: need.status),
                  ],
                ),
                const SizedBox(height: 16),

                // Details
                _DetailRow(label: 'Urgency', value: urgencyLabel(need.urgency)),
                _DetailRow(label: 'Zone', value: need.locationZone),
                _DetailRow(label: 'Submitted', value: dateStr),
                _DetailRow(
                  label: 'Anonymous',
                  value: need.isAnonymous ? 'Yes' : 'No',
                ),

                if (need.description != null &&
                    need.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Description', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(need.description!),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Assign helper dropdown
                Text('Assign Helper', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                helpersAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Unable to load helpers: $e'),
                  data: (helpers) {
                    if (helpers.isEmpty) {
                      return const Text(
                        'No helpers available in your organization.',
                        style: TextStyle(color: Colors.grey),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedHelperId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select a helper',
                      ),
                      items: helpers.map((h) {
                        return DropdownMenuItem(
                          value: h.id,
                          child: Text(
                            '${h.id.substring(0, 8)}... (${h.locationZone ?? "—"})',
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedHelperId = v),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Internal notes
                Text('Internal Notes', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Visible to org admin and moderators only — never shown to requester.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Add internal notes...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _isBusy ? null : () => _approveAndMatch(need),
                        child: const Text('Approve & Match'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isBusy ? null : () => _escalate(need),
                        child: const Text('Escalate'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isBusy ? null : () => _close(need),
                    child: const Text('Close — Unable to Fulfill'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _approveAndMatch(NeedRequest need) async {
    if (_selectedHelperId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a helper first.')),
      );
      return;
    }

    setState(() => _isBusy = true);
    try {
      await ref
          .read(queueProvider.notifier)
          .assignHelper(need.id, _selectedHelperId!);
      if (mounted) context.go('/dashboard/queue');
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

  Future<void> _escalate(NeedRequest need) async {
    setState(() => _isBusy = true);
    try {
      await ref.read(queueProvider.notifier).escalateNeed(need.id);
      if (mounted) context.go('/dashboard/queue');
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

  Future<void> _close(NeedRequest need) async {
    setState(() => _isBusy = true);
    try {
      await ref
          .read(queueProvider.notifier)
          .updateStatus(need.id, NeedStatus.closed);
      if (mounted) context.go('/dashboard/queue');
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
