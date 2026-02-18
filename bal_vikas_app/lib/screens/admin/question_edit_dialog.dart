import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_config_provider.dart';
import '../../services/admin_supabase_service.dart';

/// Shows a Material 3 dialog for adding or editing a screening question.
///
/// When [existingQuestion] is provided, the dialog opens in edit mode with
/// pre-filled fields; otherwise it opens in add mode.
///
/// On save, the question is persisted via [AdminSupabaseService] and the
/// provider for [toolId] is invalidated so the parent screen refreshes.
Future<void> showQuestionEditDialog(
  BuildContext context,
  WidgetRef ref,
  int toolId, {
  Map<String, dynamic>? existingQuestion,
  List<String> domains = const [],
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _QuestionEditDialog(
      toolId: toolId,
      existingQuestion: existingQuestion,
      domains: domains,
      ref: ref,
    ),
  );
}

class _QuestionEditDialog extends StatefulWidget {
  final int toolId;
  final Map<String, dynamic>? existingQuestion;
  final List<String> domains;
  final WidgetRef ref;

  const _QuestionEditDialog({
    required this.toolId,
    this.existingQuestion,
    required this.domains,
    required this.ref,
  });

  @override
  State<_QuestionEditDialog> createState() => _QuestionEditDialogState();
}

class _QuestionEditDialogState extends State<_QuestionEditDialog> {
  late final bool _isEdit;
  bool _saving = false;

  // Controllers
  late final TextEditingController _codeCtrl;
  late final TextEditingController _textEnCtrl;
  late final TextEditingController _textTeCtrl;
  late final TextEditingController _domainNameEnCtrl;
  late final TextEditingController _domainNameTeCtrl;
  late final TextEditingController _ageMonthsCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _sortOrderCtrl;

  String? _selectedDomain;
  bool _isCritical = false;
  bool _isRedFlag = false;
  bool _isReverseScored = false;
  bool _useCustomOptions = false;

  // Mutable list of response options for this question
  // Each entry: {id: int?, label_en: String, label_te: String, value: int, color_hex: String?, sort_order: int}
  List<Map<String, dynamic>> _responseOptions = [];

  static const _primary = Color(0xFF2196F3);

  @override
  void initState() {
    super.initState();
    _isEdit = widget.existingQuestion != null;
    final q = widget.existingQuestion ?? {};

    _codeCtrl = TextEditingController(text: q['code'] as String? ?? '');
    _textEnCtrl = TextEditingController(text: q['text_en'] as String? ?? '');
    _textTeCtrl = TextEditingController(text: q['text_te'] as String? ?? '');
    _domainNameEnCtrl =
        TextEditingController(text: q['domain_name_en'] as String? ?? '');
    _domainNameTeCtrl =
        TextEditingController(text: q['domain_name_te'] as String? ?? '');
    _ageMonthsCtrl = TextEditingController(
      text: q['age_months'] != null ? '${q['age_months']}' : '',
    );
    _unitCtrl = TextEditingController(text: q['unit'] as String? ?? '');
    _sortOrderCtrl = TextEditingController(
      text: '${q['sort_order'] ?? 0}',
    );

    _selectedDomain = q['domain'] as String?;
    _isCritical = q['is_critical'] as bool? ?? false;
    _isRedFlag = q['is_red_flag'] as bool? ?? false;
    _isReverseScored = q['is_reverse_scored'] as bool? ?? false;

    // Load existing response options
    final existingOpts = q['response_options'] as List<dynamic>? ?? [];
    if (existingOpts.isNotEmpty) {
      _useCustomOptions = true;
      _responseOptions = existingOpts.map((o) {
        final opt = o as Map<String, dynamic>;
        return {
          'id': opt['id'],
          'label_en': opt['label_en'] ?? '',
          'label_te': opt['label_te'] ?? '',
          'value': opt['value'] ?? 0,
          'color_hex': opt['color_hex'] ?? '',
          'sort_order': opt['sort_order'] ?? 0,
        };
      }).toList();
      _responseOptions.sort((a, b) =>
          (a['sort_order'] as int).compareTo(b['sort_order'] as int));
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _textEnCtrl.dispose();
    _textTeCtrl.dispose();
    _domainNameEnCtrl.dispose();
    _domainNameTeCtrl.dispose();
    _ageMonthsCtrl.dispose();
    _unitCtrl.dispose();
    _sortOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Basic validation
    if (_codeCtrl.text.trim().isEmpty) {
      _showValidationError('Code is required');
      return;
    }
    if (_textEnCtrl.text.trim().isEmpty) {
      _showValidationError('Question text (English) is required');
      return;
    }

    setState(() => _saving = true);

    final data = <String, dynamic>{
      'code': _codeCtrl.text.trim(),
      'text_en': _textEnCtrl.text.trim(),
      'text_te': _textTeCtrl.text.trim(),
      'domain': _selectedDomain,
      'domain_name_en': _domainNameEnCtrl.text.trim(),
      'domain_name_te': _domainNameTeCtrl.text.trim(),
      'age_months': _ageMonthsCtrl.text.isNotEmpty
          ? int.tryParse(_ageMonthsCtrl.text)
          : null,
      'is_critical': _isCritical,
      'is_red_flag': _isRedFlag,
      'is_reverse_scored': _isReverseScored,
      'unit': _unitCtrl.text.trim().isNotEmpty ? _unitCtrl.text.trim() : null,
      'sort_order': int.tryParse(_sortOrderCtrl.text) ?? 0,
    };

    try {
      int questionId;
      if (_isEdit) {
        questionId = widget.existingQuestion!['id'] as int;
        await AdminSupabaseService.updateQuestion(questionId, data);
      } else {
        final result = await AdminSupabaseService.addQuestion(
            {...data, 'tool_config_id': widget.toolId});
        questionId = result['id'] as int;
      }

      // Sync response options
      await _syncResponseOptions(questionId);

      widget.ref.invalidate(adminToolDetailProvider(widget.toolId));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(_isEdit ? 'Question updated' : 'Question added'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showValidationError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.orange),
    );
  }

  /// Sync response options to Supabase for a given question.
  /// - If custom options are disabled, delete all existing options.
  /// - Otherwise, delete removed ones, update existing, insert new.
  Future<void> _syncResponseOptions(int questionId) async {
    final existingOpts = widget.existingQuestion?['response_options']
            as List<dynamic>? ??
        [];
    final existingIds =
        existingOpts.map((o) => (o as Map)['id'] as int).toSet();

    if (!_useCustomOptions) {
      // Remove all options for this question
      for (final id in existingIds) {
        await AdminSupabaseService.deleteResponseOption(id);
      }
      return;
    }

    // Determine which to delete, update, or insert
    final currentIds = _responseOptions
        .where((o) => o['id'] != null)
        .map((o) => o['id'] as int)
        .toSet();
    final toDelete = existingIds.difference(currentIds);

    for (final id in toDelete) {
      await AdminSupabaseService.deleteResponseOption(id);
    }

    for (final opt in _responseOptions) {
      final optData = {
        'question_id': questionId,
        'label_en': opt['label_en'],
        'label_te': opt['label_te'],
        'value': opt['value'],
        'color_hex':
            (opt['color_hex'] as String?)?.isNotEmpty == true ? opt['color_hex'] : null,
        'sort_order': opt['sort_order'],
      };

      if (opt['id'] != null) {
        await AdminSupabaseService.updateResponseOption(
            opt['id'] as int, optData);
      } else {
        await AdminSupabaseService.addResponseOption(optData);
      }
    }
  }

  void _addOption() {
    setState(() {
      _responseOptions.add({
        'id': null,
        'label_en': '',
        'label_te': '',
        'value': _responseOptions.length,
        'color_hex': '',
        'sort_order': _responseOptions.length,
      });
    });
  }

  void _removeOption(int index) {
    setState(() => _responseOptions.removeAt(index));
  }

  void _addPresetOptions(String preset) {
    setState(() {
      _responseOptions.clear();
      switch (preset) {
        case 'yesNo':
          _responseOptions.addAll([
            {'id': null, 'label_en': 'Yes', 'label_te': 'అవును', 'value': 1, 'color_hex': '4CAF50', 'sort_order': 0},
            {'id': null, 'label_en': 'No', 'label_te': 'కాదు', 'value': 0, 'color_hex': 'F44336', 'sort_order': 1},
          ]);
          break;
        case 'threePoint':
          _responseOptions.addAll([
            {'id': null, 'label_en': 'High Extent', 'label_te': 'అధిక స్థాయి', 'value': 2, 'color_hex': '4CAF50', 'sort_order': 0},
            {'id': null, 'label_en': 'Some Extent', 'label_te': 'కొంత స్థాయి', 'value': 1, 'color_hex': 'FFC107', 'sort_order': 1},
            {'id': null, 'label_en': 'Low Extent', 'label_te': 'తక్కువ స్థాయి', 'value': 0, 'color_hex': 'F44336', 'sort_order': 2},
          ]);
          break;
        case 'fourPoint':
          _responseOptions.addAll([
            {'id': null, 'label_en': 'Not at all', 'label_te': 'అస్సలు కాదు', 'value': 0, 'color_hex': '4CAF50', 'sort_order': 0},
            {'id': null, 'label_en': 'Several days', 'label_te': 'కొన్ని రోజులు', 'value': 1, 'color_hex': '8BC34A', 'sort_order': 1},
            {'id': null, 'label_en': 'More than half', 'label_te': 'సగానికి పైగా', 'value': 2, 'color_hex': 'FF9800', 'sort_order': 2},
            {'id': null, 'label_en': 'Nearly every day', 'label_te': 'దాదాపు ప్రతిరోజూ', 'value': 3, 'color_hex': 'F44336', 'sort_order': 3},
          ]);
          break;
        case 'fivePoint':
          _responseOptions.addAll([
            {'id': null, 'label_en': 'Rarely', 'label_te': 'అరుదుగా', 'value': 1, 'color_hex': '4CAF50', 'sort_order': 0},
            {'id': null, 'label_en': 'Sometimes', 'label_te': 'కొన్నిసార్లు', 'value': 2, 'color_hex': '8BC34A', 'sort_order': 1},
            {'id': null, 'label_en': 'Frequently', 'label_te': 'తరచుగా', 'value': 3, 'color_hex': 'FFC107', 'sort_order': 2},
            {'id': null, 'label_en': 'Mostly', 'label_te': 'చాలా వరకు', 'value': 4, 'color_hex': 'FF9800', 'sort_order': 3},
            {'id': null, 'label_en': 'Always', 'label_te': 'ఎల్లప్పుడూ', 'value': 5, 'color_hex': 'F44336', 'sort_order': 4},
          ]);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 700 ? 600.0 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 850),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_note, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    _isEdit ? 'Edit Question' : 'Add New Question',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ── Body ───────────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Code + Sort order
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _codeCtrl,
                            readOnly: _isEdit,
                            decoration: _inputDecor(
                              'Code',
                              hint: 'e.g. CDC_GM_01',
                              icon: Icons.tag,
                            ),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _sortOrderCtrl,
                            decoration: _inputDecor('Sort #',
                                icon: Icons.sort),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Question English
                    TextField(
                      controller: _textEnCtrl,
                      decoration: _inputDecor(
                        'Question Text (English)',
                        icon: Icons.text_fields,
                      ),
                      maxLines: 3,
                      minLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Question Telugu
                    TextField(
                      controller: _textTeCtrl,
                      decoration: _inputDecor(
                        'Question Text (Telugu)',
                        icon: Icons.translate,
                      ),
                      maxLines: 3,
                      minLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Domain dropdown + domain names
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedDomain,
                            decoration:
                                _inputDecor('Domain', icon: Icons.category),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('None',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14)),
                              ),
                              // Build unique domain list, including selected if not already present
                              ...{
                                ...widget.domains,
                                if (_selectedDomain != null) _selectedDomain!,
                              }.map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d,
                                      style: const TextStyle(fontSize: 14)),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              setState(() => _selectedDomain = v);
                              // Auto-fill domain names if available
                              if (v != null) {
                                if (_domainNameEnCtrl.text.isEmpty) {
                                  _domainNameEnCtrl.text = v;
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _domainNameEnCtrl,
                            decoration:
                                _inputDecor('Domain Name (En)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _domainNameTeCtrl,
                            decoration:
                                _inputDecor('Domain Name (Te)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Age months + unit
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ageMonthsCtrl,
                            decoration: _inputDecor(
                              'Age (months)',
                              hint: 'optional',
                              icon: Icons.cake_outlined,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _unitCtrl,
                            decoration: _inputDecor(
                              'Unit',
                              hint: 'cm, kg...',
                              icon: Icons.straighten,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Toggles row
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _SwitchRow(
                            label: 'Is Critical',
                            icon: Icons.warning_amber,
                            iconColor: Colors.orange,
                            value: _isCritical,
                            onChanged: (v) =>
                                setState(() => _isCritical = v),
                          ),
                          const Divider(height: 1),
                          _SwitchRow(
                            label: 'Is Red Flag',
                            icon: Icons.flag,
                            iconColor: Colors.red,
                            value: _isRedFlag,
                            onChanged: (v) =>
                                setState(() => _isRedFlag = v),
                          ),
                          const Divider(height: 1),
                          _SwitchRow(
                            label: 'Is Reverse Scored',
                            icon: Icons.swap_vert,
                            iconColor: _primary,
                            value: _isReverseScored,
                            onChanged: (v) =>
                                setState(() => _isReverseScored = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Response Options Section ──────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Toggle header
                          Row(
                            children: [
                              Icon(Icons.list_alt, size: 20, color: _primary),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Custom Response Options',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _useCustomOptions,
                                onChanged: (v) =>
                                    setState(() => _useCustomOptions = v),
                                activeColor: _primary,
                              ),
                            ],
                          ),

                          if (_useCustomOptions) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Use presets or build custom options:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Preset buttons
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _PresetChip(
                                  label: 'Yes / No',
                                  onTap: () => _addPresetOptions('yesNo'),
                                ),
                                _PresetChip(
                                  label: '3-Point',
                                  onTap: () => _addPresetOptions('threePoint'),
                                ),
                                _PresetChip(
                                  label: '4-Point',
                                  onTap: () => _addPresetOptions('fourPoint'),
                                ),
                                _PresetChip(
                                  label: '5-Point',
                                  onTap: () => _addPresetOptions('fivePoint'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Options list
                            if (_responseOptions.isNotEmpty)
                              ...List.generate(_responseOptions.length, (i) {
                                final opt = _responseOptions[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      children: [
                                        // Row 1: Label EN + Value + Delete
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: TextField(
                                                controller:
                                                    TextEditingController(
                                                        text: opt['label_en']
                                                            as String),
                                                decoration: _inputDecor(
                                                    'Label (En)'),
                                                style: const TextStyle(
                                                    fontSize: 13),
                                                onChanged: (v) =>
                                                    _responseOptions[i]
                                                        ['label_en'] = v,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 60,
                                              child: TextField(
                                                controller:
                                                    TextEditingController(
                                                        text:
                                                            '${opt['value']}'),
                                                decoration:
                                                    _inputDecor('Value'),
                                                style: const TextStyle(
                                                    fontSize: 13),
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (v) =>
                                                    _responseOptions[i]
                                                            ['value'] =
                                                        int.tryParse(v) ?? 0,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  size: 18, color: Colors.red),
                                              onPressed: () =>
                                                  _removeOption(i),
                                              constraints:
                                                  const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        // Row 2: Label TE + Color
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: TextField(
                                                controller:
                                                    TextEditingController(
                                                        text: opt['label_te']
                                                            as String),
                                                decoration: _inputDecor(
                                                    'Label (Te)'),
                                                style: const TextStyle(
                                                    fontSize: 13),
                                                onChanged: (v) =>
                                                    _responseOptions[i]
                                                        ['label_te'] = v,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 60,
                                              child: TextField(
                                                controller:
                                                    TextEditingController(
                                                        text: opt['color_hex']
                                                                as String? ??
                                                            ''),
                                                decoration:
                                                    _inputDecor('Color'),
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontFamily: 'monospace'),
                                                onChanged: (v) =>
                                                    _responseOptions[i]
                                                        ['color_hex'] = v,
                                              ),
                                            ),
                                            // Color preview
                                            const SizedBox(width: 4),
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: _parseColor(
                                                    opt['color_hex']
                                                        as String?),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                            // Add option button
                            Center(
                              child: TextButton.icon(
                                onPressed: _addOption,
                                icon: const Icon(Icons.add_circle_outline,
                                    size: 18),
                                label: const Text('Add Option',
                                    style: TextStyle(fontSize: 13)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _saving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(_isEdit ? Icons.save : Icons.add),
                      label: Text(_saving
                          ? 'Saving...'
                          : _isEdit
                              ? 'Update Question'
                              : 'Add Question'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey.shade300;
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return Colors.grey.shade300;
    }
  }

  InputDecoration _inputDecor(String label,
      {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null
          ? Icon(icon, size: 20, color: Colors.grey.shade500)
          : null,
      labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Switch Row helper
// ═══════════════════════════════════════════════════════════════════════════

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      backgroundColor: const Color(0xFF2196F3).withValues(alpha: 0.1),
      side: BorderSide(color: const Color(0xFF2196F3).withValues(alpha: 0.3)),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }
}
