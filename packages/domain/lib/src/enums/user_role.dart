// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum UserRole {
  requester('REQUESTER'),
  helper('HELPER'),
  orgAdmin('ORG_ADMIN'),
  moderator('MODERATOR'),
  sponsorAdmin('SPONSOR_ADMIN');

  const UserRole(this.value);
  final String value;
}
