import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/admin_supabase_service.dart';

// =============================================================================
//  Default config definitions — each section with its config items.
// =============================================================================

class _ConfigItem {
  final String key;
  final dynamic defaultValue;
  final String description;
  final String inputType; // 'int', 'double', 'bool', 'stringList'

  const _ConfigItem({
    required this.key,
    required this.defaultValue,
    required this.description,
    this.inputType = 'int',
  });
}

class _ConfigSection {
  final String title;
  final String category;
  final IconData icon;
  final Color color;
  final List<_ConfigItem> items;

  const _ConfigSection({
    required this.title,
    required this.category,
    required this.icon,
    required this.color,
    required this.items,
  });
}

const List<_ConfigSection> _sections = [
  // ── Section 1: Baseline Score Formula ───────────────────────────────────
  _ConfigSection(
    title: 'Baseline Score Formula',
    category: 'baseline',
    icon: Icons.calculate_outlined,
    color: Color(0xFF2196F3),
    items: [
      _ConfigItem(key: 'baseline_weight_delays', defaultValue: 5, description: 'Multiplier for numDelays'),
      _ConfigItem(key: 'baseline_weight_autism_high', defaultValue: 15, description: 'Points added for HIGH autism risk'),
      _ConfigItem(key: 'baseline_weight_autism_moderate', defaultValue: 8, description: 'Points added for MODERATE autism risk'),
      _ConfigItem(key: 'baseline_weight_adhd_high', defaultValue: 8, description: 'Points added for HIGH ADHD risk'),
      _ConfigItem(key: 'baseline_weight_adhd_moderate', defaultValue: 4, description: 'Points added for MODERATE ADHD risk'),
      _ConfigItem(key: 'baseline_weight_behavior_high', defaultValue: 7, description: 'Points added for HIGH behavior risk'),
      _ConfigItem(key: 'baseline_cutoff_low', defaultValue: 10, description: 'Score <= this = Low risk'),
      _ConfigItem(key: 'baseline_cutoff_medium', defaultValue: 25, description: 'Score <= this = Medium risk, above = High'),
    ],
  ),

  // ── Section 2: Composite Risk Thresholds ────────────────────────────────
  _ConfigSection(
    title: 'Composite Risk Thresholds',
    category: 'composite',
    icon: Icons.layers_outlined,
    color: Color(0xFF7C4DFF),
    items: [
      _ConfigItem(key: 'composite_high_count', defaultValue: 2, description: 'High-risk tools >= this count -> overall HIGH'),
      _ConfigItem(key: 'composite_medium_high_count', defaultValue: 1, description: 'High-risk tools >= this for MEDIUM threshold'),
      _ConfigItem(key: 'composite_medium_count', defaultValue: 2, description: 'Medium-risk tools >= this count -> overall MEDIUM'),
      _ConfigItem(key: 'composite_high_weight', defaultValue: 3, description: 'Weight multiplier per high-risk tool'),
      _ConfigItem(key: 'composite_medium_weight', defaultValue: 1, description: 'Weight multiplier per medium-risk tool'),
    ],
  ),

  // ── Section 3: Delay Detection ──────────────────────────────────────────
  _ConfigSection(
    title: 'Delay Detection',
    category: 'delay',
    icon: Icons.warning_amber_outlined,
    color: Color(0xFFFF7043),
    items: [
      _ConfigItem(key: 'delay_dq_threshold', defaultValue: 85, description: 'DQ below this value = developmental delay'),
    ],
  ),

  // ── Section 4: Predictive Model Weights ─────────────────────────────────
  _ConfigSection(
    title: 'Predictive Model Weights',
    category: 'predictive',
    icon: Icons.trending_up_outlined,
    color: Color(0xFF26A69A),
    items: [
      _ConfigItem(key: 'pred_dev_weight', defaultValue: 0.40, description: 'Weight for developmental score component', inputType: 'double'),
      _ConfigItem(key: 'pred_delay_max', defaultValue: 15, description: 'Max points from delay component'),
      _ConfigItem(key: 'pred_autism_weight', defaultValue: 0.08, description: 'Weight for autism screening component', inputType: 'double'),
      _ConfigItem(key: 'pred_adhd_weight', defaultValue: 0.06, description: 'Weight for ADHD screening component', inputType: 'double'),
      _ConfigItem(key: 'pred_behavior_weight', defaultValue: 0.06, description: 'Weight for behavior screening component', inputType: 'double'),
      _ConfigItem(key: 'pred_phq9_weight', defaultValue: 0.05, description: 'Weight for PHQ-9 (caregiver mental health)', inputType: 'double'),
      _ConfigItem(key: 'pred_homestim_weight', defaultValue: 0.05, description: 'Weight for home stimulation component', inputType: 'double'),
      _ConfigItem(key: 'pred_nutrition_weight', defaultValue: 0.05, description: 'Weight for nutrition assessment component', inputType: 'double'),
      _ConfigItem(key: 'pred_traj_severe', defaultValue: 10, description: 'Points if dqDelta < -10 (severe regression)'),
      _ConfigItem(key: 'pred_traj_moderate', defaultValue: 7, description: 'Points if dqDelta < -5 (moderate regression)'),
      _ConfigItem(key: 'pred_traj_mild', defaultValue: 4, description: 'Points if dqDelta < 0 (mild regression)'),
      _ConfigItem(key: 'pred_traj_stable', defaultValue: 2, description: 'Points if dqDelta = 0 (stagnation)'),
      _ConfigItem(key: 'pred_pattern_lang_social', defaultValue: 3, description: 'Points for language+social pattern match'),
      _ConfigItem(key: 'pred_pattern_toxic_env', defaultValue: 3, description: 'Points for toxic environment pattern match'),
      _ConfigItem(key: 'pred_pattern_young_delays', defaultValue: 2, description: 'Points for young child with multiple delays'),
      _ConfigItem(key: 'pred_cat_low', defaultValue: 25, description: 'Predictive score <= this = Low risk'),
      _ConfigItem(key: 'pred_cat_medium', defaultValue: 50, description: 'Predictive score <= this = Medium risk'),
      _ConfigItem(key: 'pred_cat_high', defaultValue: 75, description: 'Predictive score <= this = High risk, above = Critical'),
      _ConfigItem(key: 'pred_trend_improving', defaultValue: 5, description: 'dqDelta > this = improving trend'),
      _ConfigItem(key: 'pred_trend_worsening', defaultValue: -5, description: 'dqDelta < this = worsening trend'),
    ],
  ),

  // ── Section 5: Feature Extraction Thresholds ────────────────────────────
  _ConfigSection(
    title: 'Feature Extraction Thresholds',
    category: 'feature_extraction',
    icon: Icons.science_outlined,
    color: Color(0xFFAB47BC),
    items: [
      _ConfigItem(key: 'feat_lang_social_dq', defaultValue: 80, description: 'LC DQ & SE DQ both < this = language+social pattern'),
      _ConfigItem(key: 'feat_toxic_phq9', defaultValue: 10, description: 'PHQ-9 score >= this = toxic environment flag'),
      _ConfigItem(key: 'feat_toxic_homestim', defaultValue: 80, description: 'Home stim risk >= this = toxic environment flag'),
      _ConfigItem(key: 'feat_young_delays_count', defaultValue: 3, description: 'Number of delays >= this = young delays pattern'),
      _ConfigItem(key: 'feat_young_age_max', defaultValue: 24, description: 'Child age < this months qualifies for young delays pattern'),
      _ConfigItem(key: 'feat_homestim_high', defaultValue: 7, description: 'Yes count <= this = 100% home stim risk'),
      _ConfigItem(key: 'feat_homestim_medium', defaultValue: 15, description: 'Yes count <= this = 50% home stim risk'),
      _ConfigItem(key: 'feat_nutrition_high', defaultValue: 3, description: 'Risk factors >= this = 100% nutrition risk'),
      _ConfigItem(key: 'feat_nutrition_medium', defaultValue: 1, description: 'Risk factors >= this = 50% nutrition risk'),
    ],
  ),

  // ── Section 6: Referral Rules ───────────────────────────────────────────
  _ConfigSection(
    title: 'Referral Rules',
    category: 'referral',
    icon: Icons.local_hospital_outlined,
    color: Color(0xFFEF5350),
    items: [
      _ConfigItem(key: 'referral_high_auto', defaultValue: true, description: 'Auto-create referral for High baseline risk', inputType: 'bool'),
      _ConfigItem(key: 'referral_medium_followup_check', defaultValue: true, description: 'Check worsening for Medium + Follow-up visits', inputType: 'bool'),
      _ConfigItem(
        key: 'referral_reason_priority',
        defaultValue: '["AUTISM","ADHD","GDD","BEHAVIOUR","DOMAIN_DELAY"]',
        description: 'Priority order for referral reason assignment',
        inputType: 'stringList',
      ),
      _ConfigItem(key: 'referral_type_autism', defaultValue: 'DEIC', description: 'Referral destination for autism concerns'),
      _ConfigItem(key: 'referral_type_gdd', defaultValue: 'DEIC', description: 'Referral destination for Global Developmental Delay'),
      _ConfigItem(key: 'referral_type_adhd', defaultValue: 'RBSK', description: 'Referral destination for ADHD concerns'),
      _ConfigItem(key: 'referral_type_behaviour', defaultValue: 'RBSK', description: 'Referral destination for behavioural concerns'),
      _ConfigItem(key: 'referral_type_environment', defaultValue: 'AWW_INTERVENTION', description: 'Referral destination for environmental risk'),
      _ConfigItem(key: 'referral_type_domain_delay', defaultValue: 'PHC', description: 'Referral destination for domain-specific delays'),
      _ConfigItem(key: 'referral_gdd_delay_count', defaultValue: 2, description: 'Number of delayed domains >= this = GDD classification'),
    ],
  ),
];

// =============================================================================
//  Formulas Config Screen
// =============================================================================

/// Admin screen for viewing and editing scoring formulas and global config
/// parameters stored in the `admin_global_config` Supabase table.
class FormulasConfigScreen extends ConsumerStatefulWidget {
  const FormulasConfigScreen({super.key});

  @override
  ConsumerState<FormulasConfigScreen> createState() =>
      _FormulasConfigScreenState();
}

class _FormulasConfigScreenState extends ConsumerState<FormulasConfigScreen> {
  static const _primary = Color(0xFF2196F3);
  static const _surface = Color(0xFFF8FAFF);

  bool _loading = true;
  String? _error;

  /// Loaded config values keyed by config_key.
  Map<String, dynamic> _configValues = {};

  /// TextEditingControllers keyed by config_key.
  final Map<String, TextEditingController> _controllers = {};

  /// Tracks which sections are expanded.
  final Map<String, bool> _expanded = {};

  /// Tracks which sections are currently saving.
  final Map<String, bool> _saving = {};

  /// Tracks which individual keys have unsaved changes.
  final Set<String> _dirty = {};

  @override
  void initState() {
    super.initState();
    // Initialize expansion state — all expanded by default.
    for (final section in _sections) {
      _expanded[section.category] = true;
      _saving[section.category] = false;
    }
    _loadConfigs();
  }

  @override
  void dispose() {
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadConfigs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await AdminSupabaseService.getGlobalConfigs();
      final map = <String, dynamic>{};
      for (final row in rows) {
        final key = row['config_key'] as String;
        map[key] = row['config_value'];
      }
      if (mounted) {
        setState(() {
          _configValues = map;
          _loading = false;
        });
        _initControllers();
      }
    } catch (e) {
      // If Supabase table doesn't exist or other error, show defaults
      if (mounted) {
        setState(() {
          _configValues = {};
          _loading = false;
        });
        _initControllers();
        _showSnack(
          'Could not load from DB — showing defaults. Create the admin_global_config table to persist changes.',
          Colors.orange,
        );
      }
    }
  }

  void _initControllers() {
    // Dispose existing controllers
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    _controllers.clear();
    _dirty.clear();

    for (final section in _sections) {
      for (final item in section.items) {
        final value = _resolveValue(item);
        final textValue = _valueToString(value, item.inputType);
        final ctrl = TextEditingController(text: textValue);
        ctrl.addListener(() => _onFieldChanged(item.key));
        _controllers[item.key] = ctrl;
      }
    }
  }

  /// Resolve the effective value for a config item: DB value or default.
  dynamic _resolveValue(_ConfigItem item) {
    if (_configValues.containsKey(item.key)) {
      return _configValues[item.key];
    }
    return item.defaultValue;
  }

  String _valueToString(dynamic value, String inputType) {
    if (value == null) return '';
    if (inputType == 'bool') {
      return (value == true || value == 'true') ? 'true' : 'false';
    }
    if (inputType == 'stringList') {
      if (value is List) return jsonEncode(value);
      return value.toString();
    }
    if (inputType == 'double') {
      if (value is num) return value.toDouble().toString();
    }
    return value.toString();
  }

  void _onFieldChanged(String key) {
    if (!_dirty.contains(key)) {
      setState(() => _dirty.add(key));
    }
  }

  // ── Parsing helpers ───────────────────────────────────────────────────────

  /// Parse a text field value into the appropriate type.
  dynamic _parseValue(String text, _ConfigItem item) {
    switch (item.inputType) {
      case 'bool':
        return text.trim().toLowerCase() == 'true';
      case 'double':
        return double.tryParse(text.trim()) ?? item.defaultValue;
      case 'stringList':
        try {
          final decoded = jsonDecode(text.trim());
          if (decoded is List) return decoded;
        } catch (_) {}
        return item.defaultValue;
      case 'int':
      default:
        // Handle negative integers
        final parsed = int.tryParse(text.trim());
        if (parsed != null) return parsed;
        // Try double then truncate
        final dbl = double.tryParse(text.trim());
        if (dbl != null) return dbl.toInt();
        // Strings like "DEIC", "RBSK" etc.
        if (item.defaultValue is String) return text.trim();
        return item.defaultValue;
    }
  }

  // ── Save & Reset ─────────────────────────────────────────────────────────

  Future<void> _saveSection(_ConfigSection section) async {
    setState(() => _saving[section.category] = true);

    try {
      for (final item in section.items) {
        final ctrl = _controllers[item.key];
        if (ctrl == null) continue;
        final value = _parseValue(ctrl.text, item);
        await AdminSupabaseService.upsertGlobalConfig(
          item.key,
          value,
          item.description,
          section.category,
        );
        _configValues[item.key] = value;
      }

      // Clear dirty flags for this section
      for (final item in section.items) {
        _dirty.remove(item.key);
      }

      if (mounted) {
        _showSnack('${section.title} saved successfully', const Color(0xFF4CAF50));
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Save failed: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _saving[section.category] = false);
      }
    }
  }

  Future<void> _resetSection(_ConfigSection section) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset to Defaults'),
        content: Text(
          'This will reset all "${section.title}" parameters to their default '
          'values. Saved DB entries will be deleted. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _saving[section.category] = true);

    try {
      for (final item in section.items) {
        await AdminSupabaseService.deleteGlobalConfig(item.key);
        _configValues.remove(item.key);
      }
      // Re-init controllers for this section with defaults
      for (final item in section.items) {
        final textValue = _valueToString(item.defaultValue, item.inputType);
        _controllers[item.key]?.text = textValue;
        _dirty.remove(item.key);
      }
      if (mounted) {
        _showSnack('${section.title} reset to defaults', const Color(0xFF4CAF50));
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Reset failed: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _saving[section.category] = false);
      }
    }
  }

  void _showSnack(String msg, Color bg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: const Text(
          'Scoring Formulas & Global Config',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload from database',
            onPressed: _loadConfigs,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Failed to load global configs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadConfigs,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
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
                  'These parameters control all scoring formulas, risk '
                  'thresholds, and referral rules across the platform. '
                  'Changes apply to new screenings immediately. '
                  'Values shown are loaded from the database; defaults are '
                  'used when no DB entry exists.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade800,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Config sections
        for (final section in _sections) ...[
          _buildSectionCard(section),
          const SizedBox(height: 12),
        ],

        const SizedBox(height: 32),
      ],
    );
  }

  // ── Section card ──────────────────────────────────────────────────────────

  Widget _buildSectionCard(_ConfigSection section) {
    final isExpanded = _expanded[section.category] ?? false;
    final isSaving = _saving[section.category] ?? false;
    final hasDirtyItems = section.items.any((item) => _dirty.contains(item.key));
    final itemsFromDb = section.items.where((item) => _configValues.containsKey(item.key)).length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: hasDirtyItems
              ? section.color.withValues(alpha: 0.5)
              : Colors.grey.shade200,
          width: hasDirtyItems ? 1.5 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Section header ────────────────────────────────────────────────
          InkWell(
            onTap: () {
              setState(() {
                _expanded[section.category] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: section.color.withValues(alpha: 0.06),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: section.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(section.icon, color: section.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${section.items.length} parameters'
                          '${itemsFromDb > 0 ? ' ($itemsFromDb saved in DB)' : ' (all defaults)'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasDirtyItems)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Unsaved',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Section body ──────────────────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildSectionBody(section, isSaving),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionBody(_ConfigSection section, bool isSaving) {
    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              for (int i = 0; i < section.items.length; i++) ...[
                _buildConfigRow(section.items[i], section.color),
                if (i < section.items.length - 1)
                  Divider(height: 16, color: Colors.grey.shade100),
              ],
            ],
          ),
        ),

        // ── Action buttons ──────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: isSaving ? null : () => _resetSection(section),
                icon: const Icon(Icons.restart_alt, size: 16),
                label: const Text('Reset to Defaults',
                    style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade700,
                  side: BorderSide(color: Colors.orange.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : () => _saveSection(section),
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 16),
                  label: Text(
                    isSaving ? 'Saving...' : 'Save Section',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: section.color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Config row ────────────────────────────────────────────────────────────

  Widget _buildConfigRow(_ConfigItem item, Color sectionColor) {
    final ctrl = _controllers[item.key];
    if (ctrl == null) return const SizedBox.shrink();

    final isFromDb = _configValues.containsKey(item.key);
    final isDirty = _dirty.contains(item.key);

    // For booleans, use a switch instead of a text field.
    if (item.inputType == 'bool') {
      return _buildBoolRow(item, sectionColor, isFromDb);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: key name + description
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.key,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: isDirty
                              ? sectionColor
                              : Colors.grey.shade800,
                        ),
                      ),
                    ),
                    if (isFromDb) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DB',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    height: 1.3,
                  ),
                ),
                if (!isFromDb)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Default: ${item.defaultValue}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right: value input
          SizedBox(
            width: 120,
            child: TextField(
              controller: ctrl,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: sectionColor,
              ),
              keyboardType: _keyboardType(item.inputType),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDirty
                        ? sectionColor.withValues(alpha: 0.5)
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: sectionColor, width: 1.5),
                ),
                filled: true,
                fillColor: isDirty
                    ? sectionColor.withValues(alpha: 0.04)
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoolRow(_ConfigItem item, Color sectionColor, bool isFromDb) {
    final ctrl = _controllers[item.key];
    final currentVal =
        ctrl?.text.trim().toLowerCase() == 'true';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.key,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    if (isFromDb) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DB',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: currentVal,
            activeColor: sectionColor,
            onChanged: (val) {
              setState(() {
                ctrl?.text = val.toString();
              });
            },
          ),
        ],
      ),
    );
  }

  TextInputType _keyboardType(String inputType) {
    switch (inputType) {
      case 'int':
        return const TextInputType.numberWithOptions(signed: true);
      case 'double':
        return const TextInputType.numberWithOptions(decimal: true);
      default:
        return TextInputType.text;
    }
  }
}
