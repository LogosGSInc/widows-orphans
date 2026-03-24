// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:domain/domain.dart';
import '../../providers/need_providers.dart';
import '../widgets/status_badge.dart';

/// Screen showing the status of a single need request.
/// Route: /requests/status/:id
///
/// Subscribes to Supabase Realtime for live badge updates.
/// When status = FULFILLED, navigates to the confirmation screen.
class NeedStatusScreen extends ConsumerWidget {
  const NeedStatusScreen({super.key, required this.needId});

  final String needId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realtimeAsync = ref.watch(needRealtimeProvider(needId));

    return realtimeAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Need Status')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Need Status')),
        body: Center(child: Text('Unable to load: $e')),
      ),
      data: (need) {
        // Navigate to fulfillment confirmation when fulfilled
        if (need.status == NeedStatus.fulfilled) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/requests/fulfilled/${need.id}');
          });
        }

        final dateStr = need.createdAt != null
            ? DateFormat.yMMMd().add_jm().format(need.createdAt!)
            : '';

        return Scaffold(
          appBar: AppBar(title: const Text('Need Status')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                Row(
                  children: [
                    Icon(
                      categoryIcon(need.category),
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      categoryLabel(need.category),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Status badge
                Row(
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(width: 12),
                    StatusBadge(status: need.status),
                  ],
                ),
                const SizedBox(height: 16),

                // Urgency
                _DetailRow(
                  label: 'Urgency',
                  value: urgencyLabel(need.urgency),
                ),
                const SizedBox(height: 12),

                // Zone
                _DetailRow(
                  label: 'Zone',
                  value: need.locationZone,
                ),
                const SizedBox(height: 12),

                // Date
                if (dateStr.isNotEmpty)
                  _DetailRow(label: 'Submitted', value: dateStr),

                if (need.description != null &&
                    need.description!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(need.description!),
                ],

                const Spacer(),

                // Back to my needs
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/requests'),
                    child: const Text('Back to My Needs'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
