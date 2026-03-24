// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Fulfillment confirmation screen — "Need Honored".
/// Route: /requests/fulfilled/:id
///
/// This is the emotional peak of the product.
/// Simple checkmark. No trophy, no confetti, no social share.
class NeedFulfilledScreen extends StatelessWidget {
  const NeedFulfilledScreen({super.key, required this.needId});

  final String needId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Simple checkmark icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 56,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Need Honored',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Body
              Text(
                'This need has been fulfilled. Thank you for trusting this community.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // Single action: Return to My Needs
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/requests'),
                  child: const Text('Return to My Needs'),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
