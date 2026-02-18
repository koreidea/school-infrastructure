import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_config_provider.dart';
import '../../services/admin_supabase_service.dart';
import 'question_edit_dialog.dart';
import 'response_option_editor.dart';
import 'questionnaire_preview_screen.dart';
import 'scoring_rules_screen.dart';
import 'tool_import_export.dart';

/// Screen to view and edit a single screening tool's metadata and questions.
/// Questions are grouped by domain and (optionally) by age bracket.
class ToolDetailScreen extends ConsumerStatefulWidget {
  final int toolId;

  const ToolDetailScreen({super.key, required this.toolId});

  @override
  ConsumerState<ToolDetailScreen> createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends ConsumerState<ToolDetailScreen> {
  bool _metaExpanded = false;
  bool _saving = false;

  // Editable metadata controllers
  final _nameEnController = TextEditingController();
  final _nameTeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  String _responseFormat = 'yesNo';
  List<String> _domains = [];
  bool _metaInitialized = false;

  static const _primary = Color(0xFF2196F3);

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameTeController.dispose();
    _descriptionController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  void _initMeta(Map<String, dynamic> tool) {
    if (_metaInitialized) return;
    _metaInitialized = true;
    _nameEnController.text = tool['name'] as String? ?? '';
    _nameTeController.text = tool['name_te'] as String? ?? '';
    _descriptionController.text = tool['description'] as String? ?? '';
    _minAgeController.text = '${tool['min_age_months'] ?? 0}';
    _maxAgeController.text = '${tool['max_age_months'] ?? 72}';
    _responseFormat = tool['response_format'] as String? ?? 'yesNo';
    final rawDomains = tool['domains'] ?? tool['domains_json'];
    if (rawDomains is List) {
      _domains = rawDomains.map((e) => e.toString()).toList();
    }
    // Also collect domains from actual questions so existing values are always present
    final questions = tool['screening_questions'] as List<dynamic>? ?? [];
    for (final q in questions) {
      final d = (q as Map<String, dynamic>)['domain'] as String?;
      if (d != null && d.isNotEmpty && !_domains.contains(d)) {
        _domains.add(d);
      }
    }
  }

  Future<void> _saveMeta() async {
    setState(() => _saving = true);
    try {
      await AdminSupabaseService.updateTool(widget.toolId, {
        'name': _nameEnController.text,
        'name_te': _nameTeController.text,
        'description': _descriptionController.text,
        'min_age_months': int.tryParse(_minAgeController.text) ?? 0,
        'max_age_months': int.tryParse(_maxAgeController.text) ?? 72,
        'response_format': _responseFormat,
      });
      ref.invalidate(adminToolDetailProvider(widget.toolId));
      ref.invalidate(adminToolsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tool metadata saved'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteQuestion(int questionId, String questionText) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Question'),
        content: Text(
          'Are you sure you want to delete this question?\n\n"$questionText"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
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
        await AdminSupabaseService.deleteQuestion(questionId);
        ref.invalidate(adminToolDetailProvider(widget.toolId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question deleted'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _archiveTool(Map<String, dynamic> tool) async {
    final isActive = tool['is_active'] as bool? ?? true;
    final action = isActive ? 'Archive' : 'Restore';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$action Tool'),
        content: Text('${isActive ? 'Archive' : 'Restore'} this screening tool?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: isActive ? Colors.orange : _primary),
            child: Text(action, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        if (isActive) {
          await AdminSupabaseService.archiveTool(widget.toolId);
        } else {
          await AdminSupabaseService.restoreTool(widget.toolId);
        }
        ref.invalidate(adminToolDetailProvider(widget.toolId));
        ref.invalidate(adminToolsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tool ${isActive ? 'archived' : 'restored'}'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
          if (isActive) Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _reorderQuestions(
      List<Map<String, dynamic>> questions, int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final q = questions.removeAt(oldIndex);
    questions.insert(newIndex, q);
    // Update sort_order
    final orders = <Map<String, dynamic>>[];
    for (int i = 0; i < questions.length; i++) {
      orders.add({'id': questions[i]['id'], 'sort_order': i});
    }
    try {
      await AdminSupabaseService.reorderQuestions(orders);
      ref.invalidate(adminToolDetailProvider(widget.toolId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reorder failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(adminToolDetailProvider(widget.toolId));

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: _primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: _primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text('Failed to load tool: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(adminToolDetailProvider(widget.toolId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (tool) {
        _initMeta(tool);
        return _buildBody(tool);
      },
    );
  }

  Widget _buildBody(Map<String, dynamic> tool) {
    final toolName = tool['name'] as String? ?? 'Tool';
    final questions = (tool['screening_questions'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final responseOptions = (tool['response_options'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final toolColor = _resolveColor(tool);

    // Group questions by domain
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final q in questions) {
      final domain = q['domain'] as String? ?? 'General';
      grouped.putIfAbsent(domain, () => []).add(q);
    }

    // Sort within each domain by age (if present) then sort_order
    for (final list in grouped.values) {
      list.sort((a, b) {
        final ageA = a['age_months'] as int? ?? 0;
        final ageB = b['age_months'] as int? ?? 0;
        if (ageA != ageB) return ageA.compareTo(ageB);
        final orderA = a['sort_order'] as int? ?? 0;
        final orderB = b['sort_order'] as int? ?? 0;
        return orderA.compareTo(orderB);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(
          toolName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: toolColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: 'Preview',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuestionnairePreviewScreen(toolId: widget.toolId),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _saveMeta,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'scoring':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScoringRulesScreen(
                        toolId: widget.toolId,
                        toolName: tool['name'] as String? ?? 'Tool',
                        toolType: tool['tool_type'] as String? ?? '',
                        toolColor: toolColor,
                      ),
                    ),
                  );
                case 'export':
                  showExportDialog(context, widget.toolId, toolName, toolColor);
                case 'archive':
                  _archiveTool(tool);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'scoring', child: ListTile(leading: Icon(Icons.tune), title: Text('Scoring Rules'), dense: true, contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(value: 'export', child: ListTile(leading: Icon(Icons.file_download_outlined), title: Text('Export JSON'), dense: true, contentPadding: EdgeInsets.zero)),
              PopupMenuItem(
                value: 'archive',
                child: ListTile(
                  leading: Icon((tool['is_active'] as bool? ?? true) ? Icons.archive_outlined : Icons.unarchive_outlined),
                  title: Text((tool['is_active'] as bool? ?? true) ? 'Archive Tool' : 'Restore Tool'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showQuestionEditDialog(
          context,
          ref,
          widget.toolId,
          domains: _domains,
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Question'),
        backgroundColor: toolColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Collapsible metadata section ─────────────────────────────
          _buildMetadataSection(tool, toolColor, responseOptions),

          const SizedBox(height: 20),

          // ── Questions header ─────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.quiz_outlined, color: toolColor, size: 22),
              const SizedBox(width: 8),
              Text(
                'Questions (${questions.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Grouped question lists ───────────────────────────────────
          if (questions.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No questions yet. Tap "Add Question" to get started.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          else
            ...grouped.entries.map((entry) {
              final domainKey = entry.key;
              final domainQuestions = entry.value;
              // Determine domain display name
              final firstQ = domainQuestions.first;
              final domainLabel =
                  firstQ['domain_name_en'] as String? ?? domainKey;

              return _buildDomainGroup(
                domainKey,
                domainLabel,
                domainQuestions,
                toolColor,
              );
            }),

          // Extra space for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── Metadata section ─────────────────────────────────────────────────

  Widget _buildMetadataSection(
    Map<String, dynamic> tool,
    Color toolColor,
    List<Map<String, dynamic>> responseOptions,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _metaExpanded = !_metaExpanded),
            borderRadius:
                BorderRadius.vertical(top: const Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, color: toolColor, size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    'Tool Metadata & Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _metaExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  // Name fields
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameEnController,
                          decoration: _inputDecor('Name (English)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _nameTeController,
                          decoration: _inputDecor('Name (Telugu)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    decoration: _inputDecor('Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  // Age range + response format
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _minAgeController,
                          decoration: _inputDecor('Min Age (m)'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _maxAgeController,
                          decoration: _inputDecor('Max Age (m)'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _responseFormat,
                          decoration: _inputDecor('Response Format'),
                          items: const [
                            DropdownMenuItem(
                                value: 'yesNo', child: Text('Yes / No')),
                            DropdownMenuItem(
                                value: 'threePoint', child: Text('3-Point')),
                            DropdownMenuItem(
                                value: 'fourPoint', child: Text('4-Point')),
                            DropdownMenuItem(
                                value: 'fivePoint', child: Text('5-Point')),
                            DropdownMenuItem(
                                value: 'numericInput',
                                child: Text('Numeric Input')),
                            DropdownMenuItem(
                                value: 'mixed', child: Text('Mixed')),
                          ],
                          onChanged: (v) =>
                              setState(() => _responseFormat = v ?? 'yesNo'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Domains chips
                  Text(
                    'Domains',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _domains
                        .map(
                          (d) => Chip(
                            label: Text(d,
                                style: const TextStyle(fontSize: 13)),
                            backgroundColor: toolColor.withValues(alpha: 0.1),
                            side: BorderSide(
                                color: toolColor.withValues(alpha: 0.3)),
                            deleteIcon:
                                const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() => _domains.remove(d));
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  // Response options editor
                  if (responseOptions.isNotEmpty) ...[
                    Text(
                      'Response Options',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ResponseOptionEditor(
                      toolId: widget.toolId,
                      options: responseOptions,
                      ref: ref,
                    ),
                  ],
                ],
              ),
            ),
            crossFadeState: _metaExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  // ── Domain group ─────────────────────────────────────────────────────

  Widget _buildDomainGroup(
    String domainKey,
    String domainLabel,
    List<Map<String, dynamic>> questions,
    Color toolColor,
  ) {
    // Sub-group by age if applicable
    final hasAge = questions.any((q) => q['age_months'] != null);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            leading: Container(
              width: 6,
              height: 28,
              decoration: BoxDecoration(
                color: toolColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            title: Text(
              domainLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              '${questions.length} question${questions.length == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            children: [
              const Divider(height: 1),
              if (hasAge)
                ..._buildAgeGroupedQuestions(questions, toolColor)
              else
                ...questions.map((q) => _buildQuestionTile(q, toolColor)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAgeGroupedQuestions(
    List<Map<String, dynamic>> questions,
    Color toolColor,
  ) {
    final ageGroups = <int?, List<Map<String, dynamic>>>{};
    for (final q in questions) {
      final age = q['age_months'] as int?;
      ageGroups.putIfAbsent(age, () => []).add(q);
    }

    final widgets = <Widget>[];
    for (final entry in ageGroups.entries) {
      final ageLabel = entry.key != null ? '${entry.key} months' : 'No age';
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          color: Colors.grey.shade50,
          child: Row(
            children: [
              Icon(Icons.cake_outlined, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                ageLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
      for (final q in entry.value) {
        widgets.add(_buildQuestionTile(q, toolColor));
      }
    }
    return widgets;
  }

  // ── Question tile ────────────────────────────────────────────────────

  Widget _buildQuestionTile(Map<String, dynamic> q, Color toolColor) {
    final code = q['code'] as String? ?? '';
    final textEn = q['text_en'] as String? ?? '';
    final domain = q['domain'] as String? ?? '';
    final ageMonths = q['age_months'] as int?;
    final isCritical = q['is_critical'] as bool? ?? false;
    final isRedFlag = q['is_red_flag'] as bool? ?? false;
    final questionId = q['id'] as int? ?? 0;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: ListTile(
        dense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
        leading: SizedBox(
          width: 54,
          child: Text(
            code,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              fontFamily: 'monospace',
            ),
          ),
        ),
        title: Text(
          textEn,
          style: const TextStyle(fontSize: 13, height: 1.3),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 6,
            children: [
              if (domain.isNotEmpty)
                _badge(domain, toolColor.withValues(alpha: 0.1), toolColor),
              if (ageMonths != null)
                _badge('${ageMonths}m', Colors.blue.shade50,
                    Colors.blue.shade700),
              if (isCritical)
                _badge('Critical', Colors.orange.shade50,
                    Colors.orange.shade800),
              if (isRedFlag)
                _badge('Red Flag', Colors.red.shade50, Colors.red.shade700),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 18, color: Colors.grey.shade600),
              tooltip: 'Edit question',
              onPressed: () => showQuestionEditDialog(
                context,
                ref,
                widget.toolId,
                existingQuestion: q,
                domains: _domains,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 18, color: Colors.red.shade400),
              tooltip: 'Delete question',
              onPressed: () => _deleteQuestion(questionId, textEn),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Widget _badge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  InputDecoration _inputDecor(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    );
  }

  Color _resolveColor(Map<String, dynamic> tool) {
    final hex = tool['color_hex'] as String?;
    if (hex != null && hex.isNotEmpty) {
      try {
        final cleaned = hex.replaceFirst('#', '');
        return Color(int.parse('FF$cleaned', radix: 16));
      } catch (_) {}
    }
    return _primary;
  }
}
