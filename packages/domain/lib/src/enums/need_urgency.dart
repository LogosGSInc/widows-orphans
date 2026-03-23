// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum NeedUrgency {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH'),
  critical('CRITICAL');

  const NeedUrgency(this.value);
  final String value;
}
