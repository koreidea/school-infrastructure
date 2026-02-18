import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/admin_supabase_service.dart';

/// Default scoring thresholds extracted from tool_scorer.dart.
/// Keyed by tool_type name → list of {rule_type, domain, parameter_name, parameter_value, description}.
const Map<String, List<Map<String, dynamic>>> _defaultRulesByToolType = {
  'cdcMilestones': [
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'dq_medium', 'parameter_value': 85, 'description': 'DQ below this = Medium risk'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'dq_high', 'parameter_value': 70, 'description': 'DQ below this = High risk'},
  ],
  'rbskTool': [
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'low_count_referral', 'parameter_value': 3, 'description': 'Low-score count triggering referral'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'medium_ratio', 'parameter_value': 0.6, 'description': 'Ratio of low answers for Medium risk'},
  ],
  'mchatAutism': [
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'high_failures', 'parameter_value': 8, 'description': 'Failed items for High risk'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'critical_count', 'parameter_value': 3, 'description': 'Critical failures for High risk'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'medium_failures', 'parameter_value': 3, 'description': 'Failed items for Medium risk'},
  ],
  'isaaAutism': [
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'moderate_min', 'parameter_value': 107, 'description': 'Score >= this = Moderate autism'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'mild_min', 'parameter_value': 70, 'description': 'Score >= this = Mild autism'},
  ],
  'adhdScreening': [
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'high_yes', 'parameter_value': 6, 'description': 'Yes count for High risk'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'medium_yes', 'parameter_value': 4, 'description': 'Yes count for Medium risk'},
  ],
  'rbskBehavioral': [
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'high_yes', 'parameter_value': 3, 'description': 'Yes count for High risk'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'medium_yes', 'parameter_value': 1, 'description': 'Yes count for Medium risk'},
  ],
  'sdqBehavioral': [
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'high_difficulty', 'parameter_value': 17, 'description': 'Total difficulty for High risk'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'medium_difficulty', 'parameter_value': 14, 'description': 'Total difficulty for Medium risk'},
  ],
  'parentChildInteraction': [
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'high_max', 'parameter_value': 8, 'description': 'Score <= this = High risk (inverted)'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'medium_max', 'parameter_value': 16, 'description': 'Score <= this = Medium risk (inverted)'},
  ],
  'parentMentalHealth': [
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'severe_min', 'parameter_value': 15, 'description': 'Score >= this = Severe'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'moderate_min', 'parameter_value': 10, 'description': 'Score >= this = Moderate'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'mild_min', 'parameter_value': 5, 'description': 'Score >= this = Mild'},
  ],
  'homeStimulation': [
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'high_max', 'parameter_value': 7, 'description': 'Score <= this = High risk (inverted)'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'medium_max', 'parameter_value': 15, 'description': 'Score <= this = Medium risk (inverted)'},
  ],
  'nutritionAssessment': [
    {'rule_type': 'threshold', 'domain': 'dietary', 'parameter_name': 'inadequate_count', 'parameter_value': 3, 'description': 'Dietary inadequacy count'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'high_risk_factors', 'parameter_value': 3, 'description': 'Risk factor count for High'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'medium_risk_factors', 'parameter_value': 1, 'description': 'Risk factor count for Medium'},
  ],
  'rbskBirthDefects': [
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'high_red_flags', 'parameter_value': 1, 'description': 'Red flags for High risk'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'high_total', 'parameter_value': 3, 'description': 'Total findings for High risk'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'medium_total', 'parameter_value': 1, 'description': 'Total findings for Medium risk'},
  ],
  'rbskDiseases': [
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'high_red_flags', 'parameter_value': 1, 'description': 'Red flags for High risk'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'high_total', 'parameter_value': 4, 'description': 'Total findings for High risk'},
    {'rule_type': 'threshold', 'domain': '__overall__', 'parameter_name': 'medium_total', 'parameter_value': 2, 'description': 'Total findings for Medium risk'},
  ],
};

/// Full-screen editor for a tool's scoring rules.
class ScoringRulesScreen extends ConsumerStatefulWidget {
  final int toolId;
  final String toolName;
  final String toolType;
  final Color toolColor;

  const ScoringRulesScreen({
    super.key,
    required this.toolId,
    required this.toolName,
    required this.toolType,
    required this.toolColor,
  });

  @override
  ConsumerState<ScoringRulesScreen> createState() => _ScoringRulesScreenState();
}

class _ScoringRulesScreenState extends ConsumerState<ScoringRulesScreen> {
  List<Map<String, dynamic>>? _rules;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rules = await AdminSupabaseService.getScoringRules(widget.toolId);
      if (mounted) setState(() { _rules = rules; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = '$e'; _loading = false; });
    }
  }

  Future<void> _seedDefaults() async {
    final defaults = _defaultRulesByToolType[widget.toolType];
    if (defaults == null || defaults.isEmpty) {
      _showSnack('No default rules defined for this tool type', Colors.orange);
      return;
    }

    try {
      for (final d in defaults) {
        await AdminSupabaseService.addScoringRule({
          'tool_config_id': widget.toolId,
          ...d,
        });
      }
      _showSnack('Default rules seeded', const Color(0xFF4CAF50));
      _loadRules();
    } catch (e) {
      _showSnack('Seed failed: $e', Colors.red);
    }
  }

  Future<void> _deleteRule(int ruleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Rule'),
        content: const Text('Are you sure you want to delete this scoring rule?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await AdminSupabaseService.deleteScoringRule(ruleId);
        _showSnack('Rule deleted', const Color(0xFF4CAF50));
        _loadRules();
      } catch (e) {
        _showSnack('Delete failed: $e', Colors.red);
      }
    }
  }

  void _showSnack(String msg, Color bg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: bg),
      );
    }
  }

  Future<void> _showEditDialog({Map<String, dynamic>? existing}) async {
    final ruleTypeCtrl = TextEditingController(text: existing?['rule_type'] as String? ?? 'threshold');
    final domainCtrl = TextEditingController(text: existing?['domain'] as String? ?? '__overall__');
    final paramNameCtrl = TextEditingController(text: existing?['parameter_name'] as String? ?? '');
    final paramValueCtrl = TextEditingController(text: existing?['parameter_value']?.toString() ?? '');
    final descCtrl = TextEditingController(text: existing?['description'] as String? ?? '');

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(existing != null ? 'Edit Scoring Rule' : 'Add Scoring Rule'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: TextField(controller: ruleTypeCtrl, decoration: _decor('Rule Type'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: domainCtrl, decoration: _decor('Domain'))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: paramNameCtrl, decoration: _decor('Parameter Name')),
                const SizedBox(height: 12),
                TextField(controller: paramValueCtrl, decoration: _decor('Value'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, decoration: _decor('Description'), maxLines: 2),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: widget.toolColor, foregroundColor: Colors.white),
            child: Text(existing != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );

    if (result == true) {
      // Parse value — try int, then double, fallback to string
      dynamic parsedValue = paramValueCtrl.text;
      final intVal = int.tryParse(paramValueCtrl.text);
      if (intVal != null) {
        parsedValue = intVal;
      } else {
        final doubleVal = double.tryParse(paramValueCtrl.text);
        if (doubleVal != null) parsedValue = doubleVal;
      }

      final data = {
        'tool_config_id': widget.toolId,
        'rule_type': ruleTypeCtrl.text.trim(),
        'domain': domainCtrl.text.trim().isEmpty ? null : domainCtrl.text.trim(),
        'parameter_name': paramNameCtrl.text.trim(),
        'parameter_value': parsedValue,
        'description': descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      };

      try {
        if (existing != null) {
          await AdminSupabaseService.updateScoringRule(existing['id'] as int, data);
          _showSnack('Rule updated', const Color(0xFF4CAF50));
        } else {
          await AdminSupabaseService.addScoringRule(data);
          _showSnack('Rule added', const Color(0xFF4CAF50));
        }
        _loadRules();
      } catch (e) {
        _showSnack('Save failed: $e', Colors.red);
      }
    }

    ruleTypeCtrl.dispose();
    domainCtrl.dispose();
    paramNameCtrl.dispose();
    paramValueCtrl.dispose();
    descCtrl.dispose();
  }

  InputDecoration _decor(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Scoring Rules — ${widget.toolName}'),
        backgroundColor: widget.toolColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_rules != null && _rules!.isEmpty)
            TextButton.icon(
              onPressed: _seedDefaults,
              icon: const Icon(Icons.auto_fix_high, color: Colors.white70, size: 18),
              label: const Text('Seed Defaults', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Rule'),
        backgroundColor: widget.toolColor,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 12),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadRules, child: const Text('Retry')),
                    ],
                  ),
                )
              : _rules!.isEmpty
                  ? _buildEmptyState()
                  : _buildRulesList(),
    );
  }

  Widget _buildEmptyState() {
    final hasDefaults = _defaultRulesByToolType.containsKey(widget.toolType);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.toolColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.tune, size: 56, color: widget.toolColor),
          ),
          const SizedBox(height: 20),
          Text(
            'No scoring rules configured',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 8),
          Text(
            hasDefaults
                ? 'Tap "Seed Defaults" to pre-populate with standard thresholds,\nor add custom rules with the + button.'
                : 'Add custom scoring rules with the + button.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          if (hasDefaults) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _seedDefaults,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Seed Defaults'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.toolColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRulesList() {
    // Group by domain
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final r in _rules!) {
      final domain = r['domain'] as String? ?? '__overall__';
      grouped.putIfAbsent(domain, () => []).add(r);
    }

    return ListView(
      padding: const EdgeInsets.all(20),
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
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'These rules override hardcoded scoring thresholds. '
                  'Changes apply to new screenings immediately.',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                ),
              ),
            ],
          ),
        ),

        ...grouped.entries.map((entry) {
          final domain = entry.key;
          final rules = entry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Domain header
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: widget.toolColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      domain == '__overall__' ? 'Overall' : domain,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${rules.length} rule${rules.length == 1 ? '' : 's'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              ...rules.map((r) => _buildRuleCard(r)),
              const SizedBox(height: 8),
            ],
          );
        }),

        const SizedBox(height: 80), // FAB space
      ],
    );
  }

  Widget _buildRuleCard(Map<String, dynamic> rule) {
    final paramName = rule['parameter_name'] as String? ?? '';
    final paramValue = rule['parameter_value'];
    final description = rule['description'] as String? ?? '';
    final ruleType = rule['rule_type'] as String? ?? '';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.toolColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.tune, size: 20, color: widget.toolColor),
        ),
        title: Row(
          children: [
            Text(
              paramName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'monospace'),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: widget.toolColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$paramValue',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.toolColor),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('Type: $ruleType', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade600),
              onPressed: () => _showEditDialog(existing: rule),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
              onPressed: () => _deleteRule(rule['id'] as int),
            ),
          ],
        ),
      ),
    );
  }
}
