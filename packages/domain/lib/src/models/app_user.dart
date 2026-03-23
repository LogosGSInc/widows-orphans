// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/user_role.dart';
import '../enums/trust_tier.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required UserRole role,
    @JsonKey(name: 'trust_tier') @Default(TrustTier.unverified) TrustTier trustTier,
    @JsonKey(name: 'org_id') String? orgId,
    @JsonKey(name: 'location_zone') String? locationZone,
    @JsonKey(name: 'fulfillment_count') @Default(0) int fulfillmentCount,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
