// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/need_category.dart';
import '../enums/need_status.dart';
import '../enums/need_urgency.dart';

part 'need_request.freezed.dart';
part 'need_request.g.dart';

@freezed
class NeedRequest with _$NeedRequest {
  const factory NeedRequest({
    required String id,
    @JsonKey(name: 'requester_id') String? requesterId,
    @JsonKey(name: 'advocate_id') String? advocateId,
    @JsonKey(name: 'org_id') String? orgId,
    required NeedCategory category,
    @Default(NeedStatus.open) NeedStatus status,
    @Default(NeedUrgency.medium) NeedUrgency urgency,
    @JsonKey(name: 'location_zone') required String locationZone,
    String? description,
    @JsonKey(name: 'is_anonymous') @Default(false) bool isAnonymous,
    @JsonKey(name: 'sponsor_backed') @Default(false) bool sponsorBacked,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'fulfilled_at') DateTime? fulfilledAt,
  }) = _NeedRequest;

  factory NeedRequest.fromJson(Map<String, dynamic> json) =>
      _$NeedRequestFromJson(json);
}
