// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum TrustTier {
  unverified('UNVERIFIED'),
  basic('BASIC'),
  trusted('TRUSTED'),
  verifiedPartner('VERIFIED_PARTNER');

  const TrustTier(this.value);
  final String value;
}
