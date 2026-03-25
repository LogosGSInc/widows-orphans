// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:test/test.dart';
import 'package:domain/domain.dart';

void main() {
  group('NeedStatus serialization', () {
    test('all statuses have correct string values', () {
      expect(NeedStatus.open.value, 'OPEN');
      expect(NeedStatus.underReview.value, 'UNDER_REVIEW');
      expect(NeedStatus.matched.value, 'MATCHED');
      expect(NeedStatus.inProgress.value, 'IN_PROGRESS');
      expect(NeedStatus.fulfilled.value, 'FULFILLED');
      expect(NeedStatus.closed.value, 'CLOSED');
      expect(NeedStatus.escalated.value, 'ESCALATED');
    });

    test('all 7 statuses are defined', () {
      expect(NeedStatus.values.length, 7);
    });
  });

  group('NeedCategory serialization', () {
    test('all categories have correct string values', () {
      expect(NeedCategory.food.value, 'FOOD');
      expect(NeedCategory.transport.value, 'TRANSPORT');
      expect(NeedCategory.household.value, 'HOUSEHOLD');
      expect(NeedCategory.medical.value, 'MEDICAL');
      expect(NeedCategory.family.value, 'FAMILY');
      expect(NeedCategory.prayer.value, 'PRAYER');
      expect(NeedCategory.emergency.value, 'EMERGENCY');
      expect(NeedCategory.custom.value, 'CUSTOM');
    });

    test('all 8 categories are defined', () {
      expect(NeedCategory.values.length, 8);
    });
  });

  group('NeedUrgency serialization', () {
    test('all urgency levels have correct string values', () {
      expect(NeedUrgency.low.value, 'LOW');
      expect(NeedUrgency.medium.value, 'MEDIUM');
      expect(NeedUrgency.high.value, 'HIGH');
      expect(NeedUrgency.critical.value, 'CRITICAL');
    });

    test('all 4 urgency levels are defined', () {
      expect(NeedUrgency.values.length, 4);
    });
  });

  group('UserRole serialization', () {
    test('all roles have correct string values', () {
      expect(UserRole.requester.value, 'REQUESTER');
      expect(UserRole.helper.value, 'HELPER');
      expect(UserRole.orgAdmin.value, 'ORG_ADMIN');
      expect(UserRole.moderator.value, 'MODERATOR');
      expect(UserRole.sponsorAdmin.value, 'SPONSOR_ADMIN');
    });

    test('all 5 roles are defined', () {
      expect(UserRole.values.length, 5);
    });
  });

  group('TrustTier serialization', () {
    test('all trust tiers have correct string values', () {
      expect(TrustTier.unverified.value, 'UNVERIFIED');
      expect(TrustTier.basic.value, 'BASIC');
      expect(TrustTier.trusted.value, 'TRUSTED');
      expect(TrustTier.verifiedPartner.value, 'VERIFIED_PARTNER');
    });

    test('all 4 trust tiers are defined', () {
      expect(TrustTier.values.length, 4);
    });
  });
}
