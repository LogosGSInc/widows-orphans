// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domain/domain.dart';

/// Service layer for need request operations.
///
/// Uses the Supabase client directly with RLS policies for access control.
/// The Dart Frog routes define the API contract for future external clients.
class NeedService {
  NeedService(this._client);

  final SupabaseClient _client;

  /// Create a new need request (REQUESTER role).
  Future<NeedRequest> createNeed({
    required NeedCategory category,
    required NeedUrgency urgency,
    required String locationZone,
    String? description,
    bool isAnonymous = false,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('need_requests')
        .insert({
          'requester_id': userId,
          'category': category.value,
          'urgency': urgency.value,
          'location_zone': locationZone,
          'description': description,
          'is_anonymous': isAnonymous,
          'status': NeedStatus.open.value,
        })
        .select()
        .single();

    return NeedRequest.fromJson(response);
  }

  /// Get the current requester's own needs.
  Future<List<NeedRequest>> getMyNeeds() async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('need_requests')
        .select()
        .eq('requester_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => NeedRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a single need by ID (scoped by RLS).
  Future<NeedRequest> getNeedById(String id) async {
    final response = await _client
        .from('need_requests')
        .select()
        .eq('id', id)
        .single();

    return NeedRequest.fromJson(response);
  }

  /// Update the status of a need (role-gated via RLS).
  Future<NeedRequest> updateNeedStatus(String id, NeedStatus status) async {
    final updates = <String, dynamic>{
      'status': status.value,
    };

    if (status == NeedStatus.fulfilled) {
      updates['fulfilled_at'] = DateTime.now().toUtc().toIso8601String();
    }

    final response = await _client
        .from('need_requests')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return NeedRequest.fromJson(response);
  }

  /// Get the org admin's need queue (org_id scoped).
  Future<List<NeedRequest>> getQueue() async {
    final userId = _client.auth.currentUser!.id;

    // Fetch the admin's org_id first
    final userRow = await _client
        .from('users')
        .select('org_id')
        .eq('id', userId)
        .single();

    final orgId = userRow['org_id'] as String?;
    if (orgId == null) return [];

    final response = await _client
        .from('need_requests')
        .select()
        .eq('org_id', orgId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => NeedRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get available/assigned needs for a helper.
  Future<List<NeedRequest>> getAvailableNeeds() async {
    final userId = _client.auth.currentUser!.id;

    // Fetch needs assigned to this helper via RLS.
    final response = await _client
        .from('need_requests')
        .select()
        .or('advocate_id.eq.$userId,status.eq.OPEN')
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => NeedRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Assign a helper to a need (org_admin only).
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

  /// Escalate a need (moderator/org_admin only).
  Future<NeedRequest> escalateNeed(String needId) async {
    final response = await _client
        .from('need_requests')
        .update({
          'status': NeedStatus.escalated.value,
        })
        .eq('id', needId)
        .select()
        .single();

    return NeedRequest.fromJson(response);
  }

  /// Get helpers in the same org for assignment dropdown.
  Future<List<AppUser>> getOrgHelpers() async {
    final userId = _client.auth.currentUser!.id;

    final userRow = await _client
        .from('users')
        .select('org_id')
        .eq('id', userId)
        .single();

    final orgId = userRow['org_id'] as String?;
    if (orgId == null) return [];

    final response = await _client
        .from('users')
        .select()
        .eq('org_id', orgId)
        .eq('role', UserRole.helper.value)
        .eq('is_active', true);

    return (response as List)
        .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Subscribe to realtime changes on a specific need request row.
  RealtimeChannel subscribeToNeed(
    String needId,
    void Function(NeedRequest) onUpdate,
  ) {
    return _client
        .channel('need_$needId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'need_requests',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: needId,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord.isNotEmpty) {
              onUpdate(NeedRequest.fromJson(newRecord));
            }
          },
        )
        .subscribe();
  }
}

/// Provider-accessible singleton.
final needService = NeedService(Supabase.instance.client);
