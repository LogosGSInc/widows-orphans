// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/org_providers.dart';
import '../../services/csv_export_service.dart';
import '../../services/org_dashboard_service.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(orgReportsProvider);
    final dateRange = ref.watch(reportDateRangeProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Reports', style: theme.textTheme.headlineMedium),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () =>
                  ref.read(orgReportsProvider.notifier).refresh(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Aggregate metrics only — no individual requester data.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Date range selector
        Row(
          children: [
            ActionChip(
              avatar: const Icon(Icons.date_range, size: 18),
              label: Text(
                '${DateFormat.yMMMd().format(dateRange.from)} – '
                '${DateFormat.yMMMd().format(dateRange.to)}',
              ),
              onPressed: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: DateTimeRange(
                    start: dateRange.from,
                    end: dateRange.to,
                  ),
                );
                if (range != null) {
                  ref.read(reportDateRangeProvider.notifier).state =
                      ReportDateRange(from: range.start, to: range.end);
                }
              },
            ),
            const SizedBox(width: 8),
            ActionChip(
              label: const Text('Last 7 days'),
              onPressed: () {
                ref.read(reportDateRangeProvider.notifier).state =
                    ReportDateRange(
                  from: DateTime.now().subtract(const Duration(days: 7)),
                );
              },
            ),
            const SizedBox(width: 8),
            ActionChip(
              label: const Text('Last 30 days'),
              onPressed: () {
                ref.read(reportDateRangeProvider.notifier).state =
                    ReportDateRange(
                  from: DateTime.now().subtract(const Duration(days: 30)),
                );
              },
            ),
            const SizedBox(width: 8),
            ActionChip(
              label: const Text('Last 90 days'),
              onPressed: () {
                ref.read(reportDateRangeProvider.notifier).state =
                    ReportDateRange(
                  from: DateTime.now().subtract(const Duration(days: 90)),
                );
              },
            ),
            const Spacer(),
            reportAsync.whenOrNull(
                  data: (report) => OutlinedButton.icon(
                    onPressed: () =>
                        csvExportService.exportReport(report),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Export CSV'),
                  ),
                ) ??
                const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 24),

        // Report data
        reportAsync.when(
          data: (report) => _ReportBody(report: report),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Failed to load report: $e'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report});

  final OrgReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary metrics
        LayoutBuilder(
          builder: (context, constraints) {
            final crossCount = constraints.maxWidth > 800 ? 3 : 1;
            return GridView.count(
              crossAxisCount: crossCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _MetricCard(
                  label: 'Total Submitted',
                  value: '${report.totalSubmitted}',
                  icon: Icons.inbox_outlined,
                ),
                _MetricCard(
                  label: 'Total Fulfilled',
                  value: '${report.totalFulfilled}',
                  icon: Icons.check_circle_outline,
                ),
                _MetricCard(
                  label: 'Avg Time to Fulfillment',
                  value:
                      '${report.avgHoursToFulfillment.toStringAsFixed(1)} hrs',
                  icon: Icons.schedule_outlined,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 32),

        Text(
          'Breakdown by Category',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),

        if (report.categoryBreakdown.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No data for this period.')),
          )
        else ...[
          // Category bar chart (simple)
          for (final stat in report.categoryBreakdown)
            _CategoryRow(stat: stat, maxSubmitted: report.totalSubmitted),

          const SizedBox(height: 24),

          // Category table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Submitted'), numeric: true),
                DataColumn(label: Text('Fulfilled'), numeric: true),
                DataColumn(
                    label: Text('Avg Hours'), numeric: true),
              ],
              rows: [
                for (final stat in report.categoryBreakdown)
                  DataRow(cells: [
                    DataCell(Text(stat.category)),
                    DataCell(Text('${stat.submitted}')),
                    DataCell(Text('${stat.fulfilled}')),
                    DataCell(Text(stat.avgHours.toStringAsFixed(1))),
                  ]),
                // Total row
                DataRow(
                  color: WidgetStateProperty.all(
                    theme.colorScheme.surfaceContainerHighest,
                  ),
                  cells: [
                    const DataCell(Text(
                      'TOTAL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      '${report.totalSubmitted}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      '${report.totalFulfilled}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      report.avgHoursToFulfillment.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 36, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
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

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.stat, required this.maxSubmitted});

  final CategoryStats stat;
  final int maxSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = maxSubmitted > 0 ? stat.submitted / maxSubmitted : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(stat.category, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 20,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text(
              '${stat.submitted}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
