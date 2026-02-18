import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/screening_tools_registry.dart';
import '../models/screening_tool.dart';

/// Admin service for managing screening tool configurations in Supabase.
/// This service is used by the admin UI for CRUD operations on tool configs,
/// questions, response options, and scoring rules. It connects directly to
/// Supabase (no Drift) since admin config management is an online-only feature.
class AdminSupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // Tool listing & detail
  // ---------------------------------------------------------------------------

  /// Fetch all screening tool configs ordered by sort_order, with question count.
  static Future<List<Map<String, dynamic>>> getAllTools() async {
    final tools = await _client
        .from('screening_tool_configs')
        .select('*, screening_questions(count)')
        .order('sort_order');

    return List<Map<String, dynamic>>.from(tools);
  }

  /// Fetch a single tool with its questions and each question's response options,
  /// plus any tool-level default response options.
  static Future<Map<String, dynamic>> getToolDetail(int toolId) async {
    final tool = await _client
        .from('screening_tool_configs')
        .select(
            '*, screening_questions(*, response_options(*)), response_options(*)')
        .eq('id', toolId)
        .single();

    return Map<String, dynamic>.from(tool);
  }

  // ---------------------------------------------------------------------------
  // Tool CRUD
  // ---------------------------------------------------------------------------

  /// Update tool-level metadata (name, description, age range, etc.).
  static Future<Map<String, dynamic>> updateTool(
      int id, Map<String, dynamic> data) async {
    final result = await _client
        .from('screening_tool_configs')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  // ---------------------------------------------------------------------------
  // Question CRUD
  // ---------------------------------------------------------------------------

  /// Add a new question to a tool.
  static Future<Map<String, dynamic>> addQuestion(
      Map<String, dynamic> data) async {
    final result = await _client
        .from('screening_questions')
        .insert(data)
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  /// Update an existing question.
  static Future<Map<String, dynamic>> updateQuestion(
      int id, Map<String, dynamic> data) async {
    final result = await _client
        .from('screening_questions')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  /// Soft-delete a question by setting is_active = false.
  static Future<void> deleteQuestion(int id) async {
    await _client
        .from('screening_questions')
        .update({'is_active': false})
        .eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Response Option CRUD
  // ---------------------------------------------------------------------------

  /// Add a response option to a question.
  static Future<Map<String, dynamic>> addResponseOption(
      Map<String, dynamic> data) async {
    final result = await _client
        .from('response_options')
        .insert(data)
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  /// Update an existing response option.
  static Future<Map<String, dynamic>> updateResponseOption(
      int id, Map<String, dynamic> data) async {
    final result = await _client
        .from('response_options')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  /// Hard-delete a response option.
  static Future<void> deleteResponseOption(int id) async {
    await _client.from('response_options').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Scoring Rules CRUD
  // ---------------------------------------------------------------------------

  /// Fetch all scoring rules for a tool.
  static Future<List<Map<String, dynamic>>> getScoringRules(int toolId) async {
    final rules = await _client
        .from('scoring_rules')
        .select()
        .eq('tool_config_id', toolId)
        .order('domain')
        .order('parameter_name');
    return List<Map<String, dynamic>>.from(rules);
  }

  /// Add a new scoring rule.
  static Future<Map<String, dynamic>> addScoringRule(
      Map<String, dynamic> data) async {
    final result = await _client
        .from('scoring_rules')
        .insert(data)
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  /// Update an existing scoring rule.
  static Future<Map<String, dynamic>> updateScoringRule(
      int id, Map<String, dynamic> data) async {
    final result = await _client
        .from('scoring_rules')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  /// Hard-delete a scoring rule.
  static Future<void> deleteScoringRule(int id) async {
    await _client.from('scoring_rules').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Tool Create / Archive
  // ---------------------------------------------------------------------------

  /// Create a brand new screening tool.
  static Future<Map<String, dynamic>> createTool(
      Map<String, dynamic> data) async {
    final result = await _client
        .from('screening_tool_configs')
        .insert(data)
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  /// Soft-archive a tool (set is_active = false).
  static Future<void> archiveTool(int id) async {
    await _client
        .from('screening_tool_configs')
        .update({'is_active': false})
        .eq('id', id);
  }

  /// Restore an archived tool (set is_active = true).
  static Future<void> restoreTool(int id) async {
    await _client
        .from('screening_tool_configs')
        .update({'is_active': true})
        .eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Question Reorder
  // ---------------------------------------------------------------------------

  /// Batch-update sort_order for a list of questions.
  /// [orders] is a list of {id: int, sort_order: int}.
  static Future<void> reorderQuestions(
      List<Map<String, dynamic>> orders) async {
    for (final o in orders) {
      await _client
          .from('screening_questions')
          .update({'sort_order': o['sort_order']})
          .eq('id', o['id']);
    }
  }

  // ---------------------------------------------------------------------------
  // Import / Export
  // ---------------------------------------------------------------------------

  /// Export a complete tool config as a JSON-serializable map.
  static Future<Map<String, dynamic>> exportToolAsJson(int toolId) async {
    final tool = await _client
        .from('screening_tool_configs')
        .select(
            '*, screening_questions(*, response_options(*)), response_options(*)')
        .eq('id', toolId)
        .single();

    final rules = await getScoringRules(toolId);

    return {
      'tool': {
        'tool_type': tool['tool_type'],
        'tool_id': tool['tool_id'],
        'name': tool['name'],
        'name_te': tool['name_te'],
        'description': tool['description'],
        'description_te': tool['description_te'],
        'min_age_months': tool['min_age_months'],
        'max_age_months': tool['max_age_months'],
        'response_format': tool['response_format'],
        'domains': tool['domains'],
        'icon_name': tool['icon_name'],
        'color_hex': tool['color_hex'],
        'sort_order': tool['sort_order'],
        'is_age_bracket_filtered': tool['is_age_bracket_filtered'],
      },
      'questions': (tool['screening_questions'] as List<dynamic>? ?? [])
          .map((q) {
        final qm = q as Map<String, dynamic>;
        return {
          'code': qm['code'],
          'text_en': qm['text_en'],
          'text_te': qm['text_te'],
          'domain': qm['domain'],
          'domain_name_en': qm['domain_name_en'],
          'domain_name_te': qm['domain_name_te'],
          'age_months': qm['age_months'],
          'is_critical': qm['is_critical'],
          'is_red_flag': qm['is_red_flag'],
          'is_reverse_scored': qm['is_reverse_scored'],
          'unit': qm['unit'],
          'sort_order': qm['sort_order'],
          'response_options': (qm['response_options'] as List<dynamic>? ?? [])
              .map((o) {
            final om = o as Map<String, dynamic>;
            return {
              'label_en': om['label_en'],
              'label_te': om['label_te'],
              'value': om['value'],
              'color_hex': om['color_hex'],
              'sort_order': om['sort_order'],
            };
          }).toList(),
        };
      }).toList(),
      'tool_response_options':
          (tool['response_options'] as List<dynamic>? ?? []).map((o) {
        final om = o as Map<String, dynamic>;
        return {
          'label_en': om['label_en'],
          'label_te': om['label_te'],
          'value': om['value'],
          'color_hex': om['color_hex'],
          'sort_order': om['sort_order'],
        };
      }).toList(),
      'scoring_rules': rules.map((r) {
        return {
          'rule_type': r['rule_type'],
          'domain': r['domain'],
          'parameter_name': r['parameter_name'],
          'parameter_value': r['parameter_value'],
          'description': r['description'],
        };
      }).toList(),
    };
  }

  /// Import a tool from JSON. Creates or updates tool, questions, options, rules.
  /// Returns the created/updated tool config id.
  static Future<int> importToolFromJson(Map<String, dynamic> json) async {
    final toolData = json['tool'] as Map<String, dynamic>;
    final questions = json['questions'] as List<dynamic>? ?? [];
    final toolOptions = json['tool_response_options'] as List<dynamic>? ?? [];
    final scoringRules = json['scoring_rules'] as List<dynamic>? ?? [];

    // Check if tool with same tool_id exists
    final existing = await _client
        .from('screening_tool_configs')
        .select('id')
        .eq('tool_id', toolData['tool_id'])
        .maybeSingle();

    int toolConfigId;
    if (existing != null) {
      // Update existing
      toolConfigId = existing['id'] as int;
      await _client
          .from('screening_tool_configs')
          .update(toolData)
          .eq('id', toolConfigId);
    } else {
      // Insert new
      final row = await _client
          .from('screening_tool_configs')
          .insert(toolData)
          .select()
          .single();
      toolConfigId = row['id'] as int;
    }

    // Delete existing questions, options, rules — then re-insert
    await _client
        .from('screening_questions')
        .delete()
        .eq('tool_config_id', toolConfigId);
    await _client
        .from('response_options')
        .delete()
        .eq('tool_config_id', toolConfigId);
    await _client
        .from('scoring_rules')
        .delete()
        .eq('tool_config_id', toolConfigId);

    // Insert questions + per-question options
    for (final q in questions) {
      final qm = q as Map<String, dynamic>;
      final qOpts = qm.remove('response_options') as List<dynamic>? ?? [];
      final qRow = await _client
          .from('screening_questions')
          .insert({...qm, 'tool_config_id': toolConfigId})
          .select()
          .single();
      final qId = qRow['id'] as int;

      if (qOpts.isNotEmpty) {
        final optRows = qOpts
            .map((o) => {
                  ...(o as Map<String, dynamic>),
                  'question_id': qId,
                  'tool_config_id': toolConfigId,
                })
            .toList();
        await _client.from('response_options').insert(optRows);
      }
    }

    // Insert tool-level response options
    if (toolOptions.isNotEmpty) {
      final optRows = toolOptions
          .map((o) => {
                ...(o as Map<String, dynamic>),
                'tool_config_id': toolConfigId,
                'question_id': null,
              })
          .toList();
      await _client.from('response_options').insert(optRows);
    }

    // Insert scoring rules
    if (scoringRules.isNotEmpty) {
      final ruleRows = scoringRules
          .map((r) => {
                ...(r as Map<String, dynamic>),
                'tool_config_id': toolConfigId,
              })
          .toList();
      await _client.from('scoring_rules').insert(ruleRows);
    }

    return toolConfigId;
  }

  // ---------------------------------------------------------------------------
  // Seed helpers
  // ---------------------------------------------------------------------------

  /// Return the count of tool configs currently in Supabase (useful to decide
  /// whether seeding is needed).
  static Future<int> getToolCount() async {
    final list = await _client.from('screening_tool_configs').select('id');
    return (list as List).length;
  }

  /// Populate Supabase tables from the hardcoded [allScreeningTools] registry.
  /// This is an idempotent-ish operation: it inserts only; callers should check
  /// [getToolCount] first to avoid duplicates.
  static Future<void> seedAllTools() async {
    // Fetch existing tool_ids so we skip already-seeded tools
    final existingRows = await _client
        .from('screening_tool_configs')
        .select('tool_id');
    final existingIds = (existingRows as List)
        .map((r) => r['tool_id'] as String)
        .toSet();

    for (int i = 0; i < allScreeningTools.length; i++) {
      final tool = allScreeningTools[i];

      // Skip if this tool already exists in the DB
      if (existingIds.contains(tool.id)) continue;

      // ----- Insert tool config -----
      final toolRow = await _client
          .from('screening_tool_configs')
          .insert({
            'tool_type': tool.type.name,
            'tool_id': tool.id,
            'name': tool.name,
            'name_te': tool.nameTe,
            'description': tool.description,
            'description_te': tool.descriptionTe,
            'min_age_months': tool.minAgeMonths,
            'max_age_months': tool.maxAgeMonths,
            'response_format': tool.responseFormat.name,
            'domains': tool.domains,
            'icon_name': _iconToName(tool.icon),
            'color_hex': _colorToHex(tool.color),
            'sort_order': tool.order,
            'is_age_bracket_filtered': tool.isAgeBracketFiltered,
          })
          .select()
          .single();

      final int toolConfigId = toolRow['id'] as int;

      // ----- Insert questions -----
      for (int qi = 0; qi < tool.questions.length; qi++) {
        final q = tool.questions[qi];

        final questionRow = await _client
            .from('screening_questions')
            .insert({
              'tool_config_id': toolConfigId,
              'code': q.id,
              'text_en': q.question,
              'text_te': q.questionTe,
              'domain': q.domain,
              'domain_name_en': q.domainName,
              'domain_name_te': q.domainNameTe,
              'age_months': q.ageMonths,
              'is_critical': q.isCritical,
              'is_red_flag': q.isRedFlag,
              'is_reverse_scored': q.isReverseScored,
              'unit': q.unit,
              'sort_order': qi,
            })
            .select()
            .single();

        final int questionId = questionRow['id'] as int;

        // Insert per-question response options if the question defines them.
        if (q.responseOptions != null && q.responseOptions!.isNotEmpty) {
          final optionRows = q.responseOptions!
              .asMap()
              .entries
              .map((entry) {
                final opt = entry.value;
                return {
                  'question_id': questionId,
                  'value': opt.value,
                  'label_en': opt.label,
                  'label_te': opt.labelTe,
                  'color_hex':
                      opt.color != null ? _colorToHex(opt.color!) : null,
                  'sort_order': entry.key,
                };
              })
              .toList();

          await _client.from('response_options').insert(optionRows);
        }
      }

      // ----- Insert default tool-level response options -----
      // For tools that use a uniform scale (yesNo, threePoint, fourPoint,
      // fivePoint) and whose questions do NOT carry per-question options,
      // we insert a set of default options linked to the tool config.
      final bool questionsHaveOptions = tool.questions
          .any((q) => q.responseOptions != null && q.responseOptions!.isNotEmpty);

      if (!questionsHaveOptions) {
        final defaultOptions =
            _buildDefaultOptionsForFormat(tool.responseFormat);
        if (defaultOptions.isNotEmpty) {
          final rows = defaultOptions
              .asMap()
              .entries
              .map((entry) {
                final opt = entry.value;
                return {
                  'tool_config_id': toolConfigId,
                  'question_id': null, // tool-level default
                  'value': opt['value'],
                  'label_en': opt['label'],
                  'label_te': opt['labelTe'],
                  'color_hex': opt['color_hex'],
                  'sort_order': entry.key,
                };
              })
              .toList();

          await _client.from('response_options').insert(rows);
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Global Config CRUD (admin_global_config table)
  // ---------------------------------------------------------------------------

  /// Fetch all global config entries.
  static Future<List<Map<String, dynamic>>> getGlobalConfigs() async {
    final rows = await _client
        .from('admin_global_config')
        .select()
        .order('category')
        .order('config_key');
    return List<Map<String, dynamic>>.from(rows);
  }

  /// Upsert a global config entry by config_key.
  static Future<void> upsertGlobalConfig(
      String key, dynamic value, String? description, String? category) async {
    await _client.from('admin_global_config').upsert(
      {
        'config_key': key,
        'config_value': value,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
      },
      onConflict: 'config_key',
    );
  }

  /// Delete a global config entry by config_key.
  static Future<void> deleteGlobalConfig(String key) async {
    await _client.from('admin_global_config').delete().eq('config_key', key);
  }

  // ---------------------------------------------------------------------------
  // Intervention Activities CRUD
  // ---------------------------------------------------------------------------

  /// Fetch all intervention activities.
  static Future<List<Map<String, dynamic>>> getActivities() async {
    final rows = await _client
        .from('intervention_activities')
        .select()
        .order('domain')
        .order('sort_order');
    return List<Map<String, dynamic>>.from(rows);
  }

  /// Add a new intervention activity.
  static Future<Map<String, dynamic>> addActivity(
      Map<String, dynamic> data) async {
    final result = await _client
        .from('intervention_activities')
        .insert(data)
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  /// Update an intervention activity.
  static Future<Map<String, dynamic>> updateActivity(
      int id, Map<String, dynamic> data) async {
    final result = await _client
        .from('intervention_activities')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  /// Hard-delete an intervention activity.
  static Future<void> deleteActivity(int id) async {
    await _client.from('activity_guidance_steps').delete().eq('activity_id', id);
    await _client.from('intervention_activities').delete().eq('id', id);
  }

  /// Fetch guidance steps for an activity.
  static Future<List<Map<String, dynamic>>> getGuidanceSteps(
      int activityId) async {
    final rows = await _client
        .from('activity_guidance_steps')
        .select()
        .eq('activity_id', activityId)
        .order('step_number');
    return List<Map<String, dynamic>>.from(rows);
  }

  /// Replace all guidance steps for an activity.
  static Future<void> saveGuidanceSteps(
      int activityId, List<Map<String, dynamic>> steps) async {
    await _client
        .from('activity_guidance_steps')
        .delete()
        .eq('activity_id', activityId);
    if (steps.isNotEmpty) {
      final rows = steps.map((s) => {...s, 'activity_id': activityId}).toList();
      await _client.from('activity_guidance_steps').insert(rows);
    }
  }

  /// Seed intervention activities from the hardcoded data in intervention_provider.
  /// Returns the number of activities seeded.
  static Future<int> seedActivities() async {
    // This imports the hardcoded data. On first call, it seeds all activities.
    final existing = await _client
        .from('intervention_activities')
        .select('id');
    if ((existing as List).isNotEmpty) return 0; // Already seeded

    // We'll seed using a simplified approach - insert activities via the provider data
    // The actual hardcoded data is in intervention_provider.dart's allActivities list
    // For now, return 0 — the caller can seed manually or the screen offers a seed button
    return 0;
  }

  // ---------------------------------------------------------------------------
  // Sync: Pull all configs for mobile app
  // ---------------------------------------------------------------------------

  /// Fetch all active tool configs with their questions, response options, and scoring rules.
  /// Used by SyncService to pull admin-edited configs into the mobile app's local Drift DB.
  static Future<List<Map<String, dynamic>>> fetchAllToolsWithDetails() async {
    // Fetch all active tools
    final tools = await _client
        .from('screening_tool_configs')
        .select()
        .eq('is_active', true)
        .order('sort_order');

    final result = <Map<String, dynamic>>[];
    for (final tool in tools) {
      final toolId = tool['id'] as int;

      // Fetch questions for this tool
      final questions = await _client
          .from('screening_questions')
          .select()
          .eq('tool_id', toolId)
          .eq('is_active', true)
          .order('sort_order');

      // Fetch response options for this tool
      final options = await _client
          .from('response_options')
          .select()
          .eq('tool_id', toolId)
          .order('sort_order');

      // Fetch scoring rules for this tool
      final rules = await _client
          .from('scoring_rules')
          .select()
          .eq('tool_id', toolId);

      result.add({
        ...tool,
        'questions': List<Map<String, dynamic>>.from(questions),
        'options': List<Map<String, dynamic>>.from(options),
        'scoring_rules': List<Map<String, dynamic>>.from(rules),
      });
    }

    return result;
  }

  /// Fetch all scoring rules across all tools.
  /// Useful for bulk sync of scoring logic into the local Drift DB.
  static Future<List<Map<String, dynamic>>> fetchAllScoringRulesForAllTools() async {
    final rules = await _client
        .from('scoring_rules')
        .select()
        .order('tool_id');
    return List<Map<String, dynamic>>.from(rules);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Convert a Flutter [IconData] to a Material icon name string.
  /// We compare by [IconData.codePoint] against known Icons constants.
  static String _iconToName(IconData icon) {
    // Map of IconData → name for all icons used in the screening tool registry.
    final iconMap = <IconData, String>{
      Icons.child_care: 'child_care',
      Icons.medical_services: 'medical_services',
      Icons.psychology: 'psychology',
      Icons.psychology_alt: 'psychology_alt',
      Icons.flash_on: 'flash_on',
      Icons.warning_amber: 'warning_amber',
      Icons.balance: 'balance',
      Icons.family_restroom: 'family_restroom',
      Icons.favorite_border: 'favorite_border',
      Icons.home: 'home',
      Icons.restaurant: 'restaurant',
    };

    return iconMap[icon] ?? 'help_outline';
  }

  /// Convert a Flutter [Color] to a hex string (without leading #).
  static String _colorToHex(Color color) {
    // ignore: deprecated_member_use
    return color.value.toRadixString(16).padLeft(8, '0').substring(2);
  }

  /// Build default response-option maps for a given [ResponseFormat].
  static List<Map<String, dynamic>> _buildDefaultOptionsForFormat(
      ResponseFormat format) {
    switch (format) {
      case ResponseFormat.yesNo:
        return [
          {
            'value': 1,
            'label': 'Yes',
            'labelTe': 'అవును',
            'color_hex': '4CAF50'
          },
          {
            'value': 0,
            'label': 'No',
            'labelTe': 'కాదు',
            'color_hex': 'F44336'
          },
        ];
      case ResponseFormat.threePoint:
        return [
          {
            'value': 2,
            'label': 'High Extent',
            'labelTe': 'అధిక స్థాయి',
            'color_hex': '4CAF50'
          },
          {
            'value': 1,
            'label': 'Some Extent',
            'labelTe': 'కొంత స్థాయి',
            'color_hex': 'FFC107'
          },
          {
            'value': 0,
            'label': 'Low Extent',
            'labelTe': 'తక్కువ స్థాయి',
            'color_hex': 'F44336'
          },
        ];
      case ResponseFormat.fourPoint:
        return [
          {
            'value': 0,
            'label': 'Not at all',
            'labelTe': 'అస్సలు కాదు',
            'color_hex': '4CAF50'
          },
          {
            'value': 1,
            'label': 'Several days',
            'labelTe': 'కొన్ని రోజులు',
            'color_hex': '8BC34A'
          },
          {
            'value': 2,
            'label': 'More than half the days',
            'labelTe': 'సగానికి పైగా రోజులు',
            'color_hex': 'FF9800'
          },
          {
            'value': 3,
            'label': 'Nearly every day',
            'labelTe': 'దాదాపు ప్రతిరోజూ',
            'color_hex': 'F44336'
          },
        ];
      case ResponseFormat.fivePoint:
        return [
          {
            'value': 1,
            'label': 'Rarely',
            'labelTe': 'అరుదుగా',
            'color_hex': '4CAF50'
          },
          {
            'value': 2,
            'label': 'Sometimes',
            'labelTe': 'కొన్నిసార్లు',
            'color_hex': '8BC34A'
          },
          {
            'value': 3,
            'label': 'Frequently',
            'labelTe': 'తరచుగా',
            'color_hex': 'FFC107'
          },
          {
            'value': 4,
            'label': 'Mostly',
            'labelTe': 'చాలా వరకు',
            'color_hex': 'FF9800'
          },
          {
            'value': 5,
            'label': 'Always',
            'labelTe': 'ఎల్లప్పుడూ',
            'color_hex': 'F44336'
          },
        ];
      case ResponseFormat.numericInput:
      case ResponseFormat.mixed:
        // No predefined option set for these formats.
        return [];
    }
  }
}
