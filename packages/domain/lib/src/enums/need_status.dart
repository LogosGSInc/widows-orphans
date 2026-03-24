// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum NeedStatus {
  open('OPEN'),
  underReview('UNDER_REVIEW'),
  matched('MATCHED'),
  inProgress('IN_PROGRESS'),
  fulfilled('FULFILLED'),
  closed('CLOSED'),
  escalated('ESCALATED');

  const NeedStatus(this.value);
  final String value;
}
