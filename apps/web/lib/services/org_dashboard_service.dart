// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domain/domain.dart';

/// Service layer for partner org dashboard operations.
///
/// Uses the Supabase client directly with RLS policies for access control.
/// All queries are scoped to the current user's org_id.
class OrgDashboardService {
  OrgDashboardService(this._client);

  final SupabaseClient _client;

  /// Fetch summary stats for the dashboard home.
  Future<OrgStats> getStats(String orgId) async {
    final now = DateTime.now().toUtc();
    // Start of current calendar week (Monday).
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime.utc(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );

    final needs = await _client
        .from('need_requests')
        .select('status, fulfilled_at')
        .eq('org_id', orgId);

    final rows = needs as List;
    var open = 0;
    var inProgress = 0;
    var fulfilledThisWeek = 0;
    var escalated = 0;

    for (final row in rows) {
      final status = row['status'] as String;
      if (status == 'OPEN' || status == 'UNDER_REVIEW') open++;
      if (status == 'MATCHED' || status == 'IN_PROGRESS') inProgress++;
      if (status == 'ESCALATED') escalated++;
      if (status == 'FULFILLED') {
        final fulfilledAt = row['fulfilled_at'] as String?;
        if (fulfilledAt != null) {
          final dt = DateTime.parse(fulfilledAt);
          if (dt.isAfter(weekStartDate)) fulfilledThisWeek++;
        }
      }
    }

    return OrgStats(
      open: open,
      inProgress: inProgress,
      fulfilledThisWeek: fulfilledThisWeek,
      escalated: escalated,
    );
  }

  /// Fetch recent activity (last 10 status changes) for the org.
  Future<List<NeedRequest>> getRecentActivity(String orgId) async {
    final response = await _client
        .from('need_requests')
        .select()
        .eq('org_id', orgId)
        .order('created_at', ascending: false)
        .limit(10);

    return (response as List)
        .map((e) => NeedRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch the org's need queue with optional filters.
  Future<QueuePage> getQueue({
    required String orgId,
    int page = 0,
    int pageSize = 25,
    Set<NeedStatus>? statusFilter,
    Set<NeedCategory>? categoryFilter,
    Set<NeedUrgency>? urgencyFilter,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    var query = _client
        .from('need_requests')
        .select('*, users!need_requests_advocate_id_fkey(id, location_zone, trust_tier)')
        .eq('org_id', orgId);

    if (statusFilter != null && statusFilter.isNotEmpty) {
      query = query.inFilter(
        'status',
        statusFilter.map((s) => s.value).toList(),
      );
    }
    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      query = query.inFilter(
        'category',
        categoryFilter.map((c) => c.value).toList(),
      );
    }
    if (urgencyFilter != null && urgencyFilter.isNotEmpty) {
      query = query.inFilter(
        'urgency',
        urgencyFilter.map((u) => u.value).toList(),
      );
    }
    if (dateFrom != null) {
      query = query.gte('created_at', dateFrom.toIso8601String());
    }
    if (dateTo != null) {
      query = query.lte('created_at', dateTo.toIso8601String());
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    final needs = (response as List)
        .map((e) => NeedRequest.fromJson(e as Map<String, dynamic>))
        .toList();

    return QueuePage(needs: needs, page: page, pageSize: pageSize);
  }

  /// Fetch helpers in the org with assignment/fulfillment counts.
  Future<List<HelperInfo>> getHelpers(String orgId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('org_id', orgId)
        .eq('role', UserRole.helper.value)
        .order('fulfillment_count', ascending: false);

    final helpers = (response as List)
        .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
        .toList();

    // Get assigned counts per helper.
    final assignedCounts = <String, int>{};
    for (final helper in helpers) {
      final count = await _client
          .from('need_requests')
          .select('id')
          .eq('org_id', orgId)
          .eq('advocate_id', helper.id)
          .inFilter('status', ['MATCHED', 'IN_PROGRESS']);
      assignedCounts[helper.id] = (count as List).length;
    }

    return helpers
        .map((h) => HelperInfo(
              user: h,
              assignedCount: assignedCounts[h.id] ?? 0,
            ))
        .toList();
  }

  /// Assign a helper to a need.
  Future<NeedRequest> assignHelper(String needId, String helperId) async {
    final response = await _client
        .from('need_requests')
        .update({
          'advocate_id': helperId,
          'status': NeedStatus.matched.value,
        })
        .eq('id', needId)
        .select()
        .single();

    return NeedRequest.fromJson(response);
  }

  /// Escalate a need.
  Future<NeedRequest> escalateNeed(String needId) async {
    final response = await _client
        .from('need_requests')
        .update({'status': NeedStatus.escalated.value})
        .eq('id', needId)
        .select()
        .single();

    return NeedRequest.fromJson(response);
  }

  /// Close a need.
  Future<NeedRequest> closeNeed(String needId) async {
    final response = await _client
        .from('need_requests')
        .update({'status': NeedStatus.closed.value})
        .eq('id', needId)
        .select()
        .single();

    return NeedRequest.fromJson(response);
  }

  /// Toggle sponsor_backed flag on a fulfilled need.
  Future<NeedRequest> setSponsorBacked(
    String needId, {
    required bool sponsorBacked,
  }) async {
    final response = await _client
        .from('need_requests')
        .update({'sponsor_backed': sponsorBacked})
        .eq('id', needId)
        .select()
        .single();

    return NeedRequest.fromJson(response);
  }

  /// Fetch aggregate report data for the org within a date range.
  Future<OrgReport> getReport({
    required String orgId,
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _client
        .from('need_requests')
        .select('category, status, created_at, fulfilled_at')
        .eq('org_id', orgId)
        .gte('created_at', from.toIso8601String())
        .lte('created_at', to.toIso8601String());

    final rows = response as List;
    var totalSubmitted = rows.length;
    var totalFulfilled = 0;
    var totalHoursToFulfill = 0.0;
    final categoryBreakdown = <String, CategoryStats>{};

    for (final row in rows) {
      final category = row['category'] as String;
      final status = row['status'] as String;
      final createdAt = DateTime.parse(row['created_at'] as String);
      final fulfilledAt = row['fulfilled_at'] as String?;

      final stats = categoryBreakdown.putIfAbsent(
        category,
        () => CategoryStats(category: category),
      );
      stats.submitted++;

      if (status == 'FULFILLED' && fulfilledAt != null) {
        totalFulfilled++;
        stats.fulfilled++;
        final hours =
            DateTime.parse(fulfilledAt).difference(createdAt).inMinutes / 60.0;
        totalHoursToFulfill += hours;
        stats.totalHours += hours;
      }
    }

    return OrgReport(
      totalSubmitted: totalSubmitted,
      totalFulfilled: totalFulfilled,
      avgHoursToFulfillment:
          totalFulfilled > 0 ? totalHoursToFulfill / totalFulfilled : 0,
      categoryBreakdown: categoryBreakdown.values.toList(),
    );
  }

  /// Update org settings.
  Future<PartnerOrg> updateSettings(
    String orgId,
    Map<String, dynamic> updates,
  ) async {
    final response = await _client
        .from('partner_orgs')
        .update(updates)
        .eq('id', orgId)
        .select()
        .single();

    return PartnerOrg.fromJson(response);
  }

  /// Invite a helper by email.
  Future<void> inviteHelper(String orgId, String email) async {
    await _client.auth.admin.inviteUserByEmail(email);
    // In production, the edge function or trigger would create the user
    // record with role=HELPER and org_id set to this org.
  }

  /// Deactivate a helper.
  Future<void> deactivateHelper(String helperId) async {
    await _client
        .from('users')
        .update({'is_active': false})
        .eq('id', helperId);
  }

  /// Update a helper's zone.
  Future<void> updateHelperZone(String helperId, String zone) async {
    await _client
        .from('users')
        .update({'location_zone': zone})
        .eq('id', helperId);
  }
}

/// Summary stats for the dashboard home.
class OrgStats {
  const OrgStats({
    required this.open,
    required this.inProgress,
    required this.fulfilledThisWeek,
    required this.escalated,
  });

  final int open;
  final int inProgress;
  final int fulfilledThisWeek;
  final int escalated;
}

/// A page of needs from the queue.
class QueuePage {
  const QueuePage({
    required this.needs,
    required this.page,
    required this.pageSize,
  });

  final List<NeedRequest> needs;
  final int page;
  final int pageSize;

  bool get hasMore => needs.length >= pageSize;
}

/// Helper user with assignment stats (org_admin eyes only).
class HelperInfo {
  const HelperInfo({
    required this.user,
    required this.assignedCount,
  });

  final AppUser user;
  final int assignedCount;
}

/// Aggregate report data — no individual PII.
class OrgReport {
  const OrgReport({
    required this.totalSubmitted,
    required this.totalFulfilled,
    required this.avgHoursToFulfillment,
    required this.categoryBreakdown,
  });

  final int totalSubmitted;
  final int totalFulfilled;
  final double avgHoursToFulfillment;
  final List<CategoryStats> categoryBreakdown;
}

/// Per-category stats for reports.
class CategoryStats {
  CategoryStats({required this.category});

  final String category;
  int submitted = 0;
  int fulfilled = 0;
  double totalHours = 0;

  double get avgHours => fulfilled > 0 ? totalHours / fulfilled : 0;
}

/// Provider-accessible singleton.
final orgDashboardService =
    OrgDashboardService(Supabase.instance.client);
