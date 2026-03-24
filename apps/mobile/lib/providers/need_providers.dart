// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domain/domain.dart';
import '../services/need_service.dart';

/// Manages the list of the current requester's own needs.
final needsProvider =
    AsyncNotifierProvider<NeedsNotifier, List<NeedRequest>>(
  NeedsNotifier.new,
);

class NeedsNotifier extends AsyncNotifier<List<NeedRequest>> {
  @override
  Future<List<NeedRequest>> build() async {
    return needService.getMyNeeds();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => needService.getMyNeeds());
  }

  Future<NeedRequest> createNeed({
    required NeedCategory category,
    required NeedUrgency urgency,
    required String locationZone,
    String? description,
    bool isAnonymous = false,
  }) async {
    final need = await needService.createNeed(
      category: category,
      urgency: urgency,
      locationZone: locationZone,
      description: description,
      isAnonymous: isAnonymous,
    );
    await refresh();
    return need;
  }
}

/// Provides a single need detail by ID.
final needDetailProvider =
    AsyncNotifierProvider.family<NeedDetailNotifier, NeedRequest, String>(
  NeedDetailNotifier.new,
);

class NeedDetailNotifier extends FamilyAsyncNotifier<NeedRequest, String> {
  @override
  Future<NeedRequest> build(String arg) async {
    return needService.getNeedById(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => needService.getNeedById(arg));
  }

  Future<void> updateStatus(NeedStatus status) async {
    await needService.updateNeedStatus(arg, status);
    await refresh();
  }
}

/// Manages the org admin's need queue.
final queueProvider =
    AsyncNotifierProvider<QueueNotifier, List<NeedRequest>>(
  QueueNotifier.new,
);

class QueueNotifier extends AsyncNotifier<List<NeedRequest>> {
  @override
  Future<List<NeedRequest>> build() async {
    return needService.getQueue();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => needService.getQueue());
  }

  Future<void> assignHelper(String needId, String helperId) async {
    await needService.assignHelper(needId, helperId);
    await refresh();
  }

  Future<void> escalateNeed(String needId) async {
    await needService.escalateNeed(needId);
    await refresh();
  }

  Future<void> updateStatus(String needId, NeedStatus status) async {
    await needService.updateNeedStatus(needId, status);
    await refresh();
  }
}

/// Manages the helper's available/assigned needs.
final availableNeedsProvider =
    AsyncNotifierProvider<AvailableNeedsNotifier, List<NeedRequest>>(
  AvailableNeedsNotifier.new,
);

class AvailableNeedsNotifier extends AsyncNotifier<List<NeedRequest>> {
  @override
  Future<List<NeedRequest>> build() async {
    return needService.getAvailableNeeds();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => needService.getAvailableNeeds());
  }

  Future<void> updateStatus(String needId, NeedStatus status) async {
    await needService.updateNeedStatus(needId, status);
    await refresh();
  }
}

/// Stream provider for realtime status updates on a specific need.
final needRealtimeProvider =
    StreamProvider.family<NeedRequest, String>((ref, needId) {
  final controller = StreamController<NeedRequest>();

  // Fetch initial value
  needService.getNeedById(needId).then(
    controller.add,
    onError: controller.addError,
  );

  // Subscribe to realtime updates
  final channel = needService.subscribeToNeed(needId, controller.add);

  ref.onDispose(() {
    channel.unsubscribe();
    controller.close();
  });

  return controller.stream;
});

/// Provides the list of helpers in the admin's org for assignment.
final orgHelpersProvider = FutureProvider<List<AppUser>>((ref) async {
  return needService.getOrgHelpers();
});
