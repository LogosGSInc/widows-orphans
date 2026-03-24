// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:domain/domain.dart';
import '../../providers/need_providers.dart';
import '../widgets/status_badge.dart';

/// Screen for submitting a new need request.
/// Route: /requests/new
class NewRequestScreen extends ConsumerStatefulWidget {
  const NewRequestScreen({super.key});

  @override
  ConsumerState<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends ConsumerState<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  NeedCategory _category = NeedCategory.food;
  NeedUrgency _urgency = NeedUrgency.medium;
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final need = await ref.read(needsProvider.notifier).createNeed(
            category: _category,
            urgency: _urgency,
            locationZone: _locationController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            isAnonymous: _isAnonymous,
          );

      if (mounted) {
        context.go('/requests/status/${need.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to submit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit a Need'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category dropdown
              DropdownButtonFormField<NeedCategory>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: NeedCategory.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Icon(categoryIcon(c), size: 20),
                        const SizedBox(width: 8),
                        Text(categoryLabel(c)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              const SizedBox(height: 16),

              // Urgency segmented control
              Text('Urgency', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              SegmentedButton<NeedUrgency>(
                segments: NeedUrgency.values.map((u) {
                  return ButtonSegment(
                    value: u,
                    label: Text(urgencyLabel(u)),
                  );
                }).toList(),
                selected: {_urgency},
                onSelectionChanged: (v) {
                  setState(() => _urgency = v.first);
                },
              ),
              const SizedBox(height: 16),

              // Location zone
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location / Zone',
                  hintText: 'e.g. Downtown, North Side',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a general location or zone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description (optional)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText:
                      'You may describe your need here. This is optional.',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Anonymous toggle
              SwitchListTile(
                title: const Text('Keep my identity private from helpers'),
                value: _isAnonymous,
                onChanged: (v) => setState(() => _isAnonymous = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              // Submit button
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit My Need'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
