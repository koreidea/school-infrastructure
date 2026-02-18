import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/admin_supabase_service.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _kPrimary = Color(0xFF2196F3);
const _kSurface = Color(0xFFF8FAFF);

const _kDefaultReasonPriority = [
  'AUTISM',
  'ADHD',
  'GDD',
  'BEHAVIOUR',
  'DOMAIN_DELAY',
];

const _kReferralTypeOptions = [
  'DEIC',
  'RBSK',
  'PHC',
  'AWW_INTERVENTION',
  'HOSPITAL',
  'OTHER',
];

/// Default referral-type mappings used when no config exists yet.
const _kDefaultTypeMappings = <String, String>{
  'AUTISM': 'DEIC',
  'GDD': 'DEIC',
  'ADHD': 'RBSK',
  'BEHAVIOUR': 'RBSK',
  'ENVIRONMENT': 'AWW_INTERVENTION',
  'DOMAIN_DELAY': 'PHC',
};

/// Config key constants.
const _kKeyHighAuto = 'referral_high_auto';
const _kKeyMediumFollowup = 'referral_medium_followup_check';
const _kKeyReasonPriority = 'referral_reason_priority';
const _kKeyGddDelayCount = 'referral_gdd_delay_count';
const _kKeyTypePrefix = 'referral_type_';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Admin screen for configuring referral rules stored in the
/// `admin_global_config` Supabase table.
class ReferralRulesScreen extends ConsumerStatefulWidget {
  const ReferralRulesScreen({super.key});

  @override
  ConsumerState<ReferralRulesScreen> createState() =>
      _ReferralRulesScreenState();
}

class _ReferralRulesScreenState extends ConsumerState<ReferralRulesScreen> {
  bool _loading = true;
  String? _error;
  bool _saving = false;
  bool _dirty = false;

  // Section 1: Referral Triggers
  bool _highAutoReferral = true;
  bool _mediumFollowupCheck = true;

  // Section 2: Referral Reason Priority
  List<String> _reasonPriority = List<String>.from(_kDefaultReasonPriority);
  int _gddDelayCount = 2;

  // Section 3: Referral Type Mapping
  final Map<String, String> _typeMappings =
      Map<String, String>.from(_kDefaultTypeMappings);

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadConfigs() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final configs = await AdminSupabaseService.getGlobalConfigs();

      // Build a lookup map: config_key -> config_value
      final lookup = <String, dynamic>{};
      for (final row in configs) {
        final key = row['config_key'] as String?;
        if (key != null) {
          lookup[key] = row['config_value'];
        }
      }

      // --- Section 1 ---
      _highAutoReferral = _parseBool(lookup[_kKeyHighAuto], defaultVal: true);
      _mediumFollowupCheck =
          _parseBool(lookup[_kKeyMediumFollowup], defaultVal: true);

      // --- Section 2 ---
      final priorityRaw = lookup[_kKeyReasonPriority];
      if (priorityRaw is List) {
        _reasonPriority =
            priorityRaw.map((e) => e.toString()).toList();
      } else if (priorityRaw is String) {
        try {
          final decoded = jsonDecode(priorityRaw);
          if (decoded is List) {
            _reasonPriority =
                decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {
          // keep defaults
        }
      }

      final gddRaw = lookup[_kKeyGddDelayCount];
      if (gddRaw is int) {
        _gddDelayCount = gddRaw;
      } else if (gddRaw is num) {
        _gddDelayCount = gddRaw.toInt();
      } else if (gddRaw is String) {
        _gddDelayCount = int.tryParse(gddRaw) ?? 2;
      }

      // --- Section 3 ---
      for (final reason in _kDefaultTypeMappings.keys) {
        final key = '$_kKeyTypePrefix${reason.toLowerCase()}';
        final val = lookup[key];
        if (val is String && _kReferralTypeOptions.contains(val)) {
          _typeMappings[reason] = val;
        }
      }

      _dirty = false;

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      // If Supabase table doesn't exist or other error, show defaults
      _dirty = false;
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Could not load from DB — showing defaults. Create the admin_global_config table to persist changes.',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _saveAll() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      // Section 1
      await AdminSupabaseService.upsertGlobalConfig(
        _kKeyHighAuto,
        _highAutoReferral,
        'Auto-create referral for high-risk screening results',
        'referral',
      );
      await AdminSupabaseService.upsertGlobalConfig(
        _kKeyMediumFollowup,
        _mediumFollowupCheck,
        'Check for worsening on follow-up for medium-risk results',
        'referral',
      );

      // Section 2
      await AdminSupabaseService.upsertGlobalConfig(
        _kKeyReasonPriority,
        _reasonPriority,
        'Priority order for determining referral reason',
        'referral',
      );
      await AdminSupabaseService.upsertGlobalConfig(
        _kKeyGddDelayCount,
        _gddDelayCount,
        'Number of domain delays required for GDD diagnosis',
        'referral',
      );

      // Section 3
      for (final entry in _typeMappings.entries) {
        final key = '$_kKeyTypePrefix${entry.key.toLowerCase()}';
        await AdminSupabaseService.upsertGlobalConfig(
          key,
          entry.value,
          'Referral type for ${entry.key} reason',
          'referral',
        );
      }

      _dirty = false;
      _showSnack('All referral rules saved successfully', const Color(0xFF4CAF50));
    } catch (e) {
      _showSnack('Save failed: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool _parseBool(dynamic value, {bool defaultVal = false}) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultVal;
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        title: const Text(
          'Referral Rules Configuration',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_dirty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Unsaved changes',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload configuration',
            onPressed: _loadConfigs,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _saveAll,
        icon: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save),
        label: Text(_saving ? 'Saving...' : 'Save Changes'),
        backgroundColor: _dirty ? _kPrimary : Colors.grey,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _kPrimary));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Failed to load referral rules',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadConfigs,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        // Info banner
        _buildInfoBanner(
          'Configure how referrals are automatically created from '
          'screening results. Changes take effect on new screenings '
          'immediately after saving.',
        ),
        const SizedBox(height: 24),

        // Section 1: Referral Triggers
        _buildSectionHeader('Referral Triggers', Icons.notifications_active),
        const SizedBox(height: 12),
        _buildTriggerCard(
          title: 'High Risk Auto-Referral',
          subtitle:
              'Automatically create a referral when a child is screened as '
              'high risk on any tool.',
          configKey: _kKeyHighAuto,
          value: _highAutoReferral,
          onChanged: (val) {
            setState(() => _highAutoReferral = val);
            _markDirty();
          },
        ),
        const SizedBox(height: 8),
        _buildTriggerCard(
          title: 'Medium + Follow-up Worsening Check',
          subtitle:
              'When a medium-risk child is re-screened and the result is '
              'equal or worse, auto-create a referral.',
          configKey: _kKeyMediumFollowup,
          value: _mediumFollowupCheck,
          onChanged: (val) {
            setState(() => _mediumFollowupCheck = val);
            _markDirty();
          },
        ),

        const SizedBox(height: 28),

        // Section 2: Referral Reason Priority
        _buildSectionHeader('Referral Reason Priority', Icons.format_list_numbered),
        const SizedBox(height: 8),
        _buildInfoBanner(
          'Drag to reorder. When a child qualifies for multiple referral '
          'reasons, the highest priority reason is used.',
        ),
        const SizedBox(height: 12),
        _buildReorderableList(),
        const SizedBox(height: 12),
        _buildGddThresholdCard(),

        const SizedBox(height: 28),

        // Section 3: Referral Type Mapping
        _buildSectionHeader('Referral Type Mapping', Icons.account_tree),
        const SizedBox(height: 8),
        _buildInfoBanner(
          'Choose which facility type each referral reason routes to.',
        ),
        const SizedBox(height: 12),
        ..._typeMappings.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildTypeMappingCard(entry.key, entry.value),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section header
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: _kPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 22, color: _kPrimary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Info banner
  // ---------------------------------------------------------------------------

  Widget _buildInfoBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.blue.shade800),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 1: Trigger cards
  // ---------------------------------------------------------------------------

  Widget _buildTriggerCard({
    required String title,
    required String subtitle,
    required String configKey,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: value
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                value ? Icons.check_circle : Icons.cancel_outlined,
                size: 22,
                color: value ? const Color(0xFF4CAF50) : Colors.grey,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Key: $configKey',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              activeColor: const Color(0xFF4CAF50),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 2: Reorderable priority list
  // ---------------------------------------------------------------------------

  Widget _buildReorderableList() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: _kPrimary.withValues(alpha: 0.05),
            child: Row(
              children: [
                Icon(Icons.drag_indicator, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text(
                  'Drag to reorder priority (highest first)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                Text(
                  'Key: $_kKeyReasonPriority',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          // Reorderable list
          SizedBox(
            // Compute a fixed height so the ReorderableListView doesn't
            // need unbounded vertical space.
            height: _reasonPriority.length * 56.0,
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: _reasonPriority.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _reasonPriority.removeAt(oldIndex);
                  _reasonPriority.insert(newIndex, item);
                });
                _markDirty();
              },
              itemBuilder: (context, index) {
                final reason = _reasonPriority[index];
                return _buildPriorityTile(reason, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityTile(String reason, int index) {
    final color = _reasonColor(reason);

    return Container(
      key: ValueKey(reason),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Icon(
                  Icons.drag_handle,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          _reasonDisplayName(reason),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            reason,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 2: GDD threshold card
  // ---------------------------------------------------------------------------

  Widget _buildGddThresholdCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 22,
                color: Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GDD Delay Count Threshold',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Number of developmental domain delays required to '
                    'classify as Global Developmental Delay (GDD).',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Key: $_kKeyGddDelayCount',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Stepper control
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _stepperButton(
                    icon: Icons.remove,
                    onTap: _gddDelayCount > 1
                        ? () {
                            setState(() => _gddDelayCount--);
                            _markDirty();
                          }
                        : null,
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      '$_gddDelayCount',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                  ),
                  _stepperButton(
                    icon: Icons.add,
                    onTap: _gddDelayCount < 6
                        ? () {
                            setState(() => _gddDelayCount++);
                            _markDirty();
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepperButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? _kPrimary : Colors.grey.shade300,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 3: Type mapping card
  // ---------------------------------------------------------------------------

  Widget _buildTypeMappingCard(String reason, String currentType) {
    final color = _reasonColor(reason);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Reason label
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _reasonIcon(reason),
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _reasonDisplayName(reason),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Key: $_kKeyTypePrefix${reason.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade400),
            const SizedBox(width: 12),

            // Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _typeColor(currentType).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _typeColor(currentType).withValues(alpha: 0.3),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentType,
                  isDense: true,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _typeColor(currentType),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: _typeColor(currentType),
                  ),
                  items: _kReferralTypeOptions
                      .map(
                        (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null && val != currentType) {
                      setState(() => _typeMappings[reason] = val);
                      _markDirty();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Visual helpers
  // ---------------------------------------------------------------------------

  String _reasonDisplayName(String reason) {
    switch (reason) {
      case 'AUTISM':
        return 'Autism Spectrum';
      case 'ADHD':
        return 'ADHD';
      case 'GDD':
        return 'Global Developmental Delay';
      case 'BEHAVIOUR':
        return 'Behavioural Concern';
      case 'DOMAIN_DELAY':
        return 'Domain-specific Delay';
      case 'ENVIRONMENT':
        return 'Environmental Risk';
      default:
        return reason;
    }
  }

  Color _reasonColor(String reason) {
    switch (reason) {
      case 'AUTISM':
        return const Color(0xFF9C27B0);
      case 'ADHD':
        return const Color(0xFFFF9800);
      case 'GDD':
        return const Color(0xFFE91E63);
      case 'BEHAVIOUR':
        return const Color(0xFF2196F3);
      case 'DOMAIN_DELAY':
        return const Color(0xFF009688);
      case 'ENVIRONMENT':
        return const Color(0xFF795548);
      default:
        return Colors.grey;
    }
  }

  IconData _reasonIcon(String reason) {
    switch (reason) {
      case 'AUTISM':
        return Icons.psychology;
      case 'ADHD':
        return Icons.flash_on;
      case 'GDD':
        return Icons.child_care;
      case 'BEHAVIOUR':
        return Icons.emoji_emotions_outlined;
      case 'DOMAIN_DELAY':
        return Icons.timeline;
      case 'ENVIRONMENT':
        return Icons.home_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'DEIC':
        return const Color(0xFF1565C0);
      case 'RBSK':
        return const Color(0xFF2E7D32);
      case 'PHC':
        return const Color(0xFF6A1B9A);
      case 'AWW_INTERVENTION':
        return const Color(0xFFE65100);
      case 'HOSPITAL':
        return const Color(0xFFC62828);
      case 'OTHER':
        return const Color(0xFF546E7A);
      default:
        return Colors.grey;
    }
  }
}
