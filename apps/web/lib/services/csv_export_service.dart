// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:domain/domain.dart';
import 'org_dashboard_service.dart';

/// Generates CSV files and triggers browser downloads.
///
/// CRITICAL: Never include requester PII when is_anonymous = true.
class CsvExportService {
  /// Export queue data as CSV.
  ///
  /// Columns: #, Category, Urgency, Zone, Status, Submitted Date, Assigned To
  /// Respects anonymity: requester info is never included.
  void exportQueue(List<NeedRequest> needs, {String filename = 'queue_export.csv'}) {
    final buffer = StringBuffer();
    buffer.writeln('#,Category,Urgency,Zone,Status,Submitted,Assigned To');

    for (var i = 0; i < needs.length; i++) {
      final need = needs[i];
      buffer.writeln([
        i + 1,
        _escapeCsv(need.category.value),
        _escapeCsv(need.urgency.value),
        _escapeCsv(need.locationZone),
        _escapeCsv(need.status.value),
        need.createdAt?.toIso8601String().split('T').first ?? '',
        // Never include requester PII. Assigned helper ID is internal only.
        need.advocateId ?? 'Unassigned',
      ].join(','));
    }

    _download(buffer.toString(), filename);
  }

  /// Export report data as CSV.
  ///
  /// Columns: Category, Total Submitted, Total Fulfilled, Avg Hours to Fulfillment
  /// Aggregate only — no individual requester data.
  void exportReport(OrgReport report, {String filename = 'report_export.csv'}) {
    final buffer = StringBuffer();
    buffer.writeln('Category,Total Submitted,Total Fulfilled,Avg Hours to Fulfillment');

    for (final stat in report.categoryBreakdown) {
      buffer.writeln([
        _escapeCsv(stat.category),
        stat.submitted,
        stat.fulfilled,
        stat.avgHours.toStringAsFixed(1),
      ].join(','));
    }

    // Summary row
    buffer.writeln([
      'TOTAL',
      report.totalSubmitted,
      report.totalFulfilled,
      report.avgHoursToFulfillment.toStringAsFixed(1),
    ].join(','));

    _download(buffer.toString(), filename);
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  void _download(String content, String filename) {
    final blob = html.Blob([content], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}

/// Singleton instance.
final csvExportService = CsvExportService();
