// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:domain/domain.dart';

/// Returns the color associated with a [NeedStatus].
Color statusColor(NeedStatus status) {
  return switch (status) {
    NeedStatus.open => Colors.grey,
    NeedStatus.underReview => Colors.amber,
    NeedStatus.matched => Colors.blue,
    NeedStatus.inProgress => Colors.blue,
    NeedStatus.fulfilled => Colors.green,
    NeedStatus.closed => Colors.green,
    NeedStatus.escalated => Colors.red,
  };
}

/// Returns a human-readable label for a [NeedStatus].
String statusLabel(NeedStatus status) {
  return switch (status) {
    NeedStatus.open => 'Open',
    NeedStatus.underReview => 'Under Review',
    NeedStatus.matched => 'Matched',
    NeedStatus.inProgress => 'In Progress',
    NeedStatus.fulfilled => 'Fulfilled',
    NeedStatus.closed => 'Closed',
    NeedStatus.escalated => 'Escalated',
  };
}

/// Returns the icon associated with a [NeedCategory].
IconData categoryIcon(NeedCategory category) {
  return switch (category) {
    NeedCategory.food => Icons.restaurant,
    NeedCategory.transport => Icons.directions_car,
    NeedCategory.household => Icons.home,
    NeedCategory.medical => Icons.medical_services,
    NeedCategory.family => Icons.family_restroom,
    NeedCategory.prayer => Icons.volunteer_activism,
    NeedCategory.emergency => Icons.warning_amber,
    NeedCategory.custom => Icons.more_horiz,
  };
}

/// Returns a human-readable label for a [NeedCategory].
String categoryLabel(NeedCategory category) {
  return switch (category) {
    NeedCategory.food => 'Food',
    NeedCategory.transport => 'Transport',
    NeedCategory.household => 'Household',
    NeedCategory.medical => 'Medical',
    NeedCategory.family => 'Family',
    NeedCategory.prayer => 'Prayer',
    NeedCategory.emergency => 'Emergency',
    NeedCategory.custom => 'Other',
  };
}

/// Returns a human-readable label for a [NeedUrgency].
String urgencyLabel(NeedUrgency urgency) {
  return switch (urgency) {
    NeedUrgency.low => 'Low',
    NeedUrgency.medium => 'Medium',
    NeedUrgency.high => 'High',
    NeedUrgency.critical => 'Critical',
  };
}

/// A chip that displays the current status with appropriate color.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final NeedStatus status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(
          color: color.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

extension on Color {
  Color get shade700 {
    if (this == Colors.grey) return Colors.grey.shade700;
    if (this == Colors.amber) return Colors.amber.shade700;
    if (this == Colors.blue) return Colors.blue.shade700;
    if (this == Colors.green) return Colors.green.shade700;
    if (this == Colors.red) return Colors.red.shade700;
    return this;
  }
}
