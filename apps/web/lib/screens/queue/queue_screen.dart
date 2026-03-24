// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';
import '../../providers/org_providers.dart';
import '../../services/csv_export_service.dart';
import '../../services/org_dashboard_service.dart';

class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  final _selectedIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(orgQueueProvider);
    final filters = ref.watch(queueFiltersProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Text('Needs Queue', style: theme.textTheme.headlineMedium),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => ref.read(orgQueueProvider.notifier).refresh(),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Filters
        _FilterBar(filters: filters),
        const SizedBox(height: 16),

        // Bulk actions
        if (_selectedIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _BulkActions(
              selectedCount: _selectedIds.length,
              onAssign: () => _bulkAssign(context),
              onEscalate: () => _bulkEscalate(),
              onExport: () => _exportCsv(queueAsync.valueOrNull),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _exportCsv(queueAsync.valueOrNull),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Export CSV'),
              ),
            ),
          ),

        // Data table
        queueAsync.when(
          data: (queuePage) => _QueueTable(
            needs: queuePage.needs,
            selectedIds: _selectedIds,
            onSelectAll: (selected) {
              setState(() {
                if (selected) {
                  _selectedIds.addAll(queuePage.needs.map((n) => n.id));
                } else {
                  _selectedIds.clear();
                }
              });
            },
            onSelectRow: (id, selected) {
              setState(() {
                if (selected) {
                  _selectedIds.add(id);
                } else {
                  _selectedIds.remove(id);
                }
              });
            },
            onAssign: (needId) => _showAssignDialog(context, needId),
            onEscalate: (needId) async {
              await orgDashboardService.escalateNeed(needId);
              ref.read(orgQueueProvider.notifier).refresh();
            },
            onClose: (needId) async {
              await orgDashboardService.closeNeed(needId);
              ref.read(orgQueueProvider.notifier).refresh();
            },
            onToggleSponsor: (need) async {
              await orgDashboardService.setSponsorBacked(
                need.id,
                sponsorBacked: !need.sponsorBacked,
              );
              ref.read(orgQueueProvider.notifier).refresh();
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Failed to load queue: $e'),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Pagination
        queueAsync.whenOrNull(
              data: (queuePage) => _Pagination(
                page: filters.page,
                hasMore: queuePage.hasMore,
                onPrevious: filters.page > 0
                    ? () => ref.read(queueFiltersProvider.notifier).state =
                        filters.copyWith(page: filters.page - 1)
                    : null,
                onNext: queuePage.hasMore
                    ? () => ref.read(queueFiltersProvider.notifier).state =
                        filters.copyWith(page: filters.page + 1)
                    : null,
              ),
            ) ??
            const SizedBox.shrink(),
      ],
    );
  }

  void _exportCsv(QueuePage? queuePage) {
    if (queuePage == null) return;
    csvExportService.exportQueue(queuePage.needs);
  }

  Future<void> _showAssignDialog(BuildContext context, String needId) async {
    final helpersAsync = ref.read(orgHelpersProvider);
    final helpers = helpersAsync.valueOrNull ?? [];

    if (!context.mounted) return;
    final helperId = await showDialog<String>(
      context: context,
      builder: (ctx) => _AssignDialog(helpers: helpers),
    );

    if (helperId != null) {
      await orgDashboardService.assignHelper(needId, helperId);
      ref.read(orgQueueProvider.notifier).refresh();
    }
  }

  Future<void> _bulkAssign(BuildContext context) async {
    final helpersAsync = ref.read(orgHelpersProvider);
    final helpers = helpersAsync.valueOrNull ?? [];

    if (!context.mounted) return;
    final helperId = await showDialog<String>(
      context: context,
      builder: (ctx) => _AssignDialog(helpers: helpers),
    );

    if (helperId != null) {
      for (final needId in _selectedIds) {
        await orgDashboardService.assignHelper(needId, helperId);
      }
      setState(() => _selectedIds.clear());
      ref.read(orgQueueProvider.notifier).refresh();
    }
  }

  Future<void> _bulkEscalate() async {
    for (final needId in _selectedIds) {
      await orgDashboardService.escalateNeed(needId);
    }
    setState(() => _selectedIds.clear());
    ref.read(orgQueueProvider.notifier).refresh();
  }
}

// ---------------------------------------------------------------------------
// Filter Bar
// ---------------------------------------------------------------------------

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filters});

  final QueueFilters filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Status chips
        for (final status in NeedStatus.values)
          FilterChip(
            label: Text(status.value),
            selected: filters.statusFilter.contains(status),
            onSelected: (selected) {
              final updated = Set<NeedStatus>.from(filters.statusFilter);
              if (selected) {
                updated.add(status);
              } else {
                updated.remove(status);
              }
              ref.read(queueFiltersProvider.notifier).state =
                  filters.copyWith(statusFilter: updated, page: 0);
            },
          ),

        const SizedBox(width: 8),

        // Category dropdown
        PopupMenuButton<NeedCategory>(
          tooltip: 'Filter by category',
          child: Chip(
            label: Text(
              filters.categoryFilter.isEmpty
                  ? 'Category'
                  : '${filters.categoryFilter.length} categories',
            ),
            avatar: const Icon(Icons.filter_list, size: 18),
          ),
          itemBuilder: (ctx) => [
            for (final cat in NeedCategory.values)
              CheckedPopupMenuItem(
                value: cat,
                checked: filters.categoryFilter.contains(cat),
                child: Text(cat.value),
              ),
          ],
          onSelected: (cat) {
            final updated = Set<NeedCategory>.from(filters.categoryFilter);
            if (updated.contains(cat)) {
              updated.remove(cat);
            } else {
              updated.add(cat);
            }
            ref.read(queueFiltersProvider.notifier).state =
                filters.copyWith(categoryFilter: updated, page: 0);
          },
        ),

        // Urgency dropdown
        PopupMenuButton<NeedUrgency>(
          tooltip: 'Filter by urgency',
          child: Chip(
            label: Text(
              filters.urgencyFilter.isEmpty
                  ? 'Urgency'
                  : '${filters.urgencyFilter.length} urgency levels',
            ),
            avatar: const Icon(Icons.filter_list, size: 18),
          ),
          itemBuilder: (ctx) => [
            for (final urg in NeedUrgency.values)
              CheckedPopupMenuItem(
                value: urg,
                checked: filters.urgencyFilter.contains(urg),
                child: Text(urg.value),
              ),
          ],
          onSelected: (urg) {
            final updated = Set<NeedUrgency>.from(filters.urgencyFilter);
            if (updated.contains(urg)) {
              updated.remove(urg);
            } else {
              updated.add(urg);
            }
            ref.read(queueFiltersProvider.notifier).state =
                filters.copyWith(urgencyFilter: updated, page: 0);
          },
        ),

        // Date range
        ActionChip(
          avatar: const Icon(Icons.date_range, size: 18),
          label: Text(
            filters.dateFrom != null
                ? '${DateFormat.yMd().format(filters.dateFrom!)} – ${DateFormat.yMd().format(filters.dateTo ?? DateTime.now())}'
                : 'Date Range',
          ),
          onPressed: () async {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDateRange: filters.dateFrom != null
                  ? DateTimeRange(
                      start: filters.dateFrom!,
                      end: filters.dateTo ?? DateTime.now(),
                    )
                  : null,
            );
            if (range != null) {
              ref.read(queueFiltersProvider.notifier).state = filters.copyWith(
                dateFrom: range.start,
                dateTo: range.end,
                page: 0,
              );
            }
          },
        ),

        // Clear filters
        if (filters.statusFilter.isNotEmpty ||
            filters.categoryFilter.isNotEmpty ||
            filters.urgencyFilter.isNotEmpty ||
            filters.dateFrom != null)
          ActionChip(
            avatar: const Icon(Icons.clear, size: 18),
            label: const Text('Clear'),
            onPressed: () {
              ref.read(queueFiltersProvider.notifier).state =
                  const QueueFilters();
            },
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Data Table
// ---------------------------------------------------------------------------

class _QueueTable extends StatelessWidget {
  const _QueueTable({
    required this.needs,
    required this.selectedIds,
    required this.onSelectAll,
    required this.onSelectRow,
    required this.onAssign,
    required this.onEscalate,
    required this.onClose,
    required this.onToggleSponsor,
  });

  final List<NeedRequest> needs;
  final Set<String> selectedIds;
  final void Function(bool) onSelectAll;
  final void Function(String, bool) onSelectRow;
  final void Function(String) onAssign;
  final void Function(String) onEscalate;
  final void Function(String) onClose;
  final void Function(NeedRequest) onToggleSponsor;

  @override
  Widget build(BuildContext context) {
    if (needs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No needs match the current filters.')),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: true,
        columns: const [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Urgency')),
          DataColumn(label: Text('Zone')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Submitted')),
          DataColumn(label: Text('Assigned To')),
          DataColumn(label: Text('Sponsor')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (var i = 0; i < needs.length; i++)
            DataRow(
              selected: selectedIds.contains(needs[i].id),
              onSelectChanged: (selected) =>
                  onSelectRow(needs[i].id, selected ?? false),
              cells: [
                DataCell(Text('${i + 1}')),
                DataCell(Text(needs[i].category.value)),
                DataCell(_urgencyBadge(needs[i].urgency)),
                DataCell(Text(needs[i].locationZone)),
                DataCell(_statusBadge(needs[i].status)),
                DataCell(Text(
                  needs[i].createdAt != null
                      ? DateFormat.yMd().format(needs[i].createdAt!)
                      : '',
                )),
                DataCell(Text(needs[i].advocateId ?? 'Unassigned')),
                DataCell(
                  needs[i].status == NeedStatus.fulfilled
                      ? IconButton(
                          icon: Icon(
                            needs[i].sponsorBacked
                                ? Icons.volunteer_activism
                                : Icons.volunteer_activism_outlined,
                            color: needs[i].sponsorBacked
                                ? Colors.green
                                : null,
                            size: 20,
                          ),
                          tooltip: needs[i].sponsorBacked
                              ? 'Sponsor backed'
                              : 'Mark sponsor backed',
                          onPressed: () => onToggleSponsor(needs[i]),
                        )
                      : const SizedBox.shrink(),
                ),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_add_outlined, size: 20),
                      tooltip: 'Assign',
                      onPressed: () => onAssign(needs[i].id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.warning_amber_outlined, size: 20),
                      tooltip: 'Escalate',
                      onPressed: () => onEscalate(needs[i].id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: 'Close',
                      onPressed: () => onClose(needs[i].id),
                    ),
                  ],
                )),
              ],
            ),
        ],
      ),
    );
  }

  Widget _urgencyBadge(NeedUrgency urgency) {
    final color = switch (urgency) {
      NeedUrgency.low => Colors.grey,
      NeedUrgency.medium => Colors.blue,
      NeedUrgency.high => Colors.orange,
      NeedUrgency.critical => Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        urgency.value,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _statusBadge(NeedStatus status) {
    final color = switch (status) {
      NeedStatus.open => Colors.orange,
      NeedStatus.underReview => Colors.amber.shade700,
      NeedStatus.matched => Colors.blue,
      NeedStatus.inProgress => Colors.indigo,
      NeedStatus.fulfilled => Colors.green,
      NeedStatus.closed => Colors.grey,
      NeedStatus.escalated => Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.value,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bulk Actions
// ---------------------------------------------------------------------------

class _BulkActions extends StatelessWidget {
  const _BulkActions({
    required this.selectedCount,
    required this.onAssign,
    required this.onEscalate,
    required this.onExport,
  });

  final int selectedCount;
  final VoidCallback onAssign;
  final VoidCallback onEscalate;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text('$selectedCount selected'),
            const SizedBox(width: 16),
            FilledButton.tonalIcon(
              onPressed: onAssign,
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: const Text('Assign Selected'),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: onEscalate,
              icon: const Icon(Icons.warning_amber_outlined, size: 18),
              label: const Text('Escalate Selected'),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export CSV'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Assign Dialog
// ---------------------------------------------------------------------------

class _AssignDialog extends StatelessWidget {
  const _AssignDialog({required this.helpers});

  final List<HelperInfo> helpers;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Helper'),
      content: SizedBox(
        width: 400,
        child: helpers.isEmpty
            ? const Text('No active helpers available.')
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final helper in helpers)
                    ListTile(
                      title: Text(helper.user.locationZone ?? 'No zone'),
                      subtitle: Text(
                        '${helper.user.trustTier.value} · '
                        '${helper.assignedCount} assigned · '
                        '${helper.user.fulfillmentCount} fulfilled',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).pop(helper.user.id),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pagination
// ---------------------------------------------------------------------------

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.page,
    required this.hasMore,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final bool hasMore;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrevious,
        ),
        Text('Page ${page + 1}'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
        ),
      ],
    );
  }
}
