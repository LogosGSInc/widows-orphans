// Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/domain.dart';
import '../../auth/auth_provider.dart';
import '../../providers/org_providers.dart';
import '../../services/org_dashboard_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _zonesController = TextEditingController();
  final _inviteEmailController = TextEditingController();
  String _orgType = 'CHURCH';
  String _notificationPref = 'WEEKLY';
  final _routingCategories = <String>{};
  bool _saving = false;
  bool _inviting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _zonesController.dispose();
    _inviteEmailController.dispose();
    super.dispose();
  }

  void _loadFromOrg(PartnerOrg org) {
    _nameController.text = org.name;
    _orgType = org.type;
    _zonesController.text = org.locationZone ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(orgSettingsProvider);
    final theme = Theme.of(context);

    return settingsAsync.when(
      data: (org) {
        if (org != null && _nameController.text.isEmpty) {
          _loadFromOrg(org);
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Organization Settings',
                style: theme.textTheme.headlineMedium),
            const SizedBox(height: 24),

            // Org info section
            _SectionCard(
              title: 'Organization Info',
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Organization Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _orgType,
                  decoration: const InputDecoration(
                    labelText: 'Organization Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CHURCH', child: Text('Church')),
                    DropdownMenuItem(
                        value: 'MINISTRY', child: Text('Ministry')),
                    DropdownMenuItem(
                        value: 'NONPROFIT', child: Text('Nonprofit')),
                    DropdownMenuItem(
                        value: 'COMMUNITY', child: Text('Community')),
                  ],
                  onChanged: (v) => setState(() => _orgType = v ?? _orgType),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _zonesController,
                  decoration: const InputDecoration(
                    labelText: 'Location Zones Covered',
                    helperText: 'One zone per line',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Helper invite section
            _SectionCard(
              title: 'Invite Helper',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inviteEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Helper email address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: _inviting ? null : _inviteHelper,
                      icon: _inviting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: const Text('Send Invite'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'An invitation email will be sent. The helper will be linked to your organization on sign-up.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Routing rules section
            _SectionCard(
              title: 'Routing Rules',
              subtitle:
                  'Select which need categories auto-route to your organization.',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final cat in NeedCategory.values)
                      FilterChip(
                        label: Text(cat.value),
                        selected: _routingCategories.contains(cat.value),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _routingCategories.add(cat.value);
                            } else {
                              _routingCategories.remove(cat.value);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Notification preferences
            _SectionCard(
              title: 'Notification Preferences',
              children: [
                DropdownButtonFormField<String>(
                  value: _notificationPref,
                  decoration: const InputDecoration(
                    labelText: 'Email Digest Frequency',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'DAILY', child: Text('Daily')),
                    DropdownMenuItem(
                        value: 'WEEKLY', child: Text('Weekly')),
                    DropdownMenuItem(value: 'OFF', child: Text('Off')),
                  ],
                  onChanged: (v) =>
                      setState(() => _notificationPref = v ?? _notificationPref),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Save button
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _saving ? null : _saveSettings,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save Settings'),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading settings: $e')),
    );
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);

    try {
      await ref.read(orgSettingsProvider.notifier).updateSettings({
        'name': _nameController.text.trim(),
        'type': _orgType,
        'location_zone': _zonesController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved')),
        );
        ref.read(currentOrgProvider.notifier).refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _inviteHelper() async {
    final email = _inviteEmailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _inviting = true);

    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user?.orgId != null) {
        await orgDashboardService.inviteHelper(user!.orgId!, email);
      }

      if (mounted) {
        _inviteEmailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invitation sent to $email')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to invite: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _inviting = false);
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
