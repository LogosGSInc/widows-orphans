// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_org.freezed.dart';
part 'partner_org.g.dart';

@freezed
class PartnerOrg with _$PartnerOrg {
  const factory PartnerOrg({
    required String id,
    required String name,
    required String type,
    @JsonKey(name: 'location_zone') String? locationZone,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _PartnerOrg;

  factory PartnerOrg.fromJson(Map<String, dynamic> json) =>
      _$PartnerOrgFromJson(json);
}
