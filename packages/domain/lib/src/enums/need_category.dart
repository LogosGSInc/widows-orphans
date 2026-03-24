// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum NeedCategory {
  food('FOOD'),
  transport('TRANSPORT'),
  household('HOUSEHOLD'),
  medical('MEDICAL'),
  family('FAMILY'),
  prayer('PRAYER'),
  emergency('EMERGENCY'),
  custom('CUSTOM');

  const NeedCategory(this.value);
  final String value;
}
