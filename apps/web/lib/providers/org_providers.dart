// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../auth/auth_provider.dart';
import '../services/org_dashboard_service.dart';

// ---------------------------------------------------------------------------
// Dashboard Stats
// ---------------------------------------------------------------------------

final orgStatsProvider =
    AsyncNotifierProvider<OrgStatsNotifier, OrgStats>(OrgStatsNotifier.new);

class OrgStatsNotifier extends AsyncNotifier<OrgStats> {
  @override
  Future<OrgStats> build() async {
    final user = await ref.watch(currentUserProvider.future);
    if (user?.orgId == null) {
      return const OrgStats(
          open: 0, inProgress: 0, fulfilledThisWeek: 0, escalated: 0);
    }
    return orgDashboardService.getStats(user!.orgId!);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

// ---------------------------------------------------------------------------
// Recent Activity
// ---------------------------------------------------------------------------

final recentActivityProvider =
    AsyncNotifierProvider<RecentActivityNotifier, List<NeedRequest>>(
  RecentActivityNotifier.new,
);

class RecentActivityNotifier extends AsyncNotifier<List<NeedRequest>> {
  @override
  Future<List<NeedRequest>> build() async {
    final user = await ref.watch(currentUserProvider.future);
    if (user?.orgId == null) return [];
    return orgDashboardService.getRecentActivity(user!.orgId!);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

// ---------------------------------------------------------------------------
// Queue (paginated, filterable)
// ---------------------------------------------------------------------------

class QueueFilters {
  const QueueFilters({
    this.statusFilter = const {},
    this.categoryFilter = const {},
    this.urgencyFilter = const {},
    this.dateFrom,
    this.dateTo,
    this.page = 0,
  });

  final Set<NeedStatus> statusFilter;
  final Set<NeedCategory> categoryFilter;
  final Set<NeedUrgency> urgencyFilter;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int page;

  QueueFilters copyWith({
    Set<NeedStatus>? statusFilter,
    Set<NeedCategory>? categoryFilter,
    Set<NeedUrgency>? urgencyFilter,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? page,
  }) {
    return QueueFilters(
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      urgencyFilter: urgencyFilter ?? this.urgencyFilter,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      page: page ?? this.page,
    );
  }
}

final queueFiltersProvider =
    StateProvider<QueueFilters>((ref) => const QueueFilters());

final orgQueueProvider =
    AsyncNotifierProvider<OrgQueueNotifier, QueuePage>(OrgQueueNotifier.new);

class OrgQueueNotifier extends AsyncNotifier<QueuePage> {
  @override
  Future<QueuePage> build() async {
    final user = await ref.watch(currentUserProvider.future);
    final filters = ref.watch(queueFiltersProvider);
    if (user?.orgId == null) {
      return const QueuePage(needs: [], page: 0, pageSize: 25);
    }
    return orgDashboardService.getQueue(
      orgId: user!.orgId!,
      page: filters.page,
      statusFilter:
          filters.statusFilter.isEmpty ? null : filters.statusFilter,
      categoryFilter:
          filters.categoryFilter.isEmpty ? null : filters.categoryFilter,
      urgencyFilter:
          filters.urgencyFilter.isEmpty ? null : filters.urgencyFilter,
      dateFrom: filters.dateFrom,
      dateTo: filters.dateTo,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final orgHelpersProvider =
    AsyncNotifierProvider<OrgHelpersNotifier, List<HelperInfo>>(
  OrgHelpersNotifier.new,
);

class OrgHelpersNotifier extends AsyncNotifier<List<HelperInfo>> {
  @override
  Future<List<HelperInfo>> build() async {
    final user = await ref.watch(currentUserProvider.future);
    if (user?.orgId == null) return [];
    return orgDashboardService.getHelpers(user!.orgId!);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

// ---------------------------------------------------------------------------
// Reports
// ---------------------------------------------------------------------------

class ReportDateRange {
  ReportDateRange({DateTime? from, DateTime? to})
      : from = from ??
            DateTime.now().toUtc().subtract(const Duration(days: 30)),
        to = to ?? DateTime.now().toUtc();

  final DateTime from;
  final DateTime to;
}

final reportDateRangeProvider =
    StateProvider<ReportDateRange>((ref) => ReportDateRange());

final orgReportsProvider =
    AsyncNotifierProvider<OrgReportsNotifier, OrgReport>(
  OrgReportsNotifier.new,
);

class OrgReportsNotifier extends AsyncNotifier<OrgReport> {
  @override
  Future<OrgReport> build() async {
    final user = await ref.watch(currentUserProvider.future);
    final range = ref.watch(reportDateRangeProvider);
    if (user?.orgId == null) {
      return const OrgReport(
        totalSubmitted: 0,
        totalFulfilled: 0,
        avgHoursToFulfillment: 0,
        categoryBreakdown: [],
      );
    }
    return orgDashboardService.getReport(
      orgId: user!.orgId!,
      from: range.from,
      to: range.to,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

final orgSettingsProvider =
    AsyncNotifierProvider<OrgSettingsNotifier, PartnerOrg?>(
  OrgSettingsNotifier.new,
);

class OrgSettingsNotifier extends AsyncNotifier<PartnerOrg?> {
  @override
  Future<PartnerOrg?> build() async {
    final org = await ref.watch(currentOrgProvider.future);
    return org;
  }

  Future<void> updateSettings(Map<String, dynamic> updates) async {
    final org = state.valueOrNull;
    if (org == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => orgDashboardService.updateSettings(org.id, updates),
    );
  }
}
