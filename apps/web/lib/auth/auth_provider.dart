// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domain/domain.dart';

/// Provides the current Supabase auth state as a stream.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Provides the current authenticated [AppUser] from the users table.
final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, AppUser?>(
  CurrentUserNotifier.new,
);

class CurrentUserNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;
    return _fetchUser(session.user.id);
  }

  Future<AppUser?> _fetchUser(String userId) async {
    final response = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return AppUser.fromJson(response);
  }

  Future<void> refresh() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      state = const AsyncData(null);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchUser(session.user.id));
  }
}

/// Provides the current user's org details.
final currentOrgProvider =
    AsyncNotifierProvider<CurrentOrgNotifier, PartnerOrg?>(
  CurrentOrgNotifier.new,
);

class CurrentOrgNotifier extends AsyncNotifier<PartnerOrg?> {
  @override
  Future<PartnerOrg?> build() async {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null || user.orgId == null) return null;
    return _fetchOrg(user.orgId!);
  }

  Future<PartnerOrg?> _fetchOrg(String orgId) async {
    final response = await Supabase.instance.client
        .from('partner_orgs')
        .select()
        .eq('id', orgId)
        .maybeSingle();

    if (response == null) return null;
    return PartnerOrg.fromJson(response);
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null || user.orgId == null) {
      state = const AsyncData(null);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchOrg(user.orgId!));
  }
}
