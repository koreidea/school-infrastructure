import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_config_provider.dart';
import '../../services/admin_supabase_service.dart';
import 'tool_detail_screen.dart';
import 'questionnaire_preview_screen.dart';
import 'tool_import_export.dart';
import 'formulas_config_screen.dart';
import 'referral_rules_screen.dart';
import 'activities_config_screen.dart';

/// Main admin dashboard for managing screening tool configurations.
/// Displays all tools in a responsive grid with stats, seed-data action,
/// and quick-access Edit / Preview buttons per tool.
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _seeding = false;
  bool _showArchived = false;
  late AnimationController _shimmerController;

  static const _primary = Color(0xFF2196F3);
  static const _primaryDark = Color(0xFF1565C0);
  static const _surface = Color(0xFFF8FAFF);

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _seedData() async {
    setState(() => _seeding = true);
    try {
      await AdminSupabaseService.seedAllTools();
      ref.invalidate(adminToolsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All screening tools seeded successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seed failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  Future<void> _createNewTool() async {
    final nameCtrl = TextEditingController();
    final toolIdCtrl = TextEditingController();
    String format = 'yesNo';

    final confirmed = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Create New Screening Tool'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Tool Name (English)',
                    hintText: 'e.g. Custom Screening Tool',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: toolIdCtrl,
                  decoration: InputDecoration(
                    labelText: 'Tool ID (unique slug)',
                    hintText: 'e.g. custom_tool_1',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: format,
                  decoration: InputDecoration(
                    labelText: 'Response Format',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'yesNo', child: Text('Yes / No')),
                    DropdownMenuItem(value: 'threePoint', child: Text('3-Point')),
                    DropdownMenuItem(value: 'fourPoint', child: Text('4-Point')),
                    DropdownMenuItem(value: 'fivePoint', child: Text('5-Point')),
                    DropdownMenuItem(value: 'numericInput', child: Text('Numeric Input')),
                    DropdownMenuItem(value: 'mixed', child: Text('Mixed')),
                  ],
                  onChanged: (v) => setDialogState(() => format = v ?? 'yesNo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || toolIdCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx, {
                  'name': nameCtrl.text.trim(),
                  'tool_id': toolIdCtrl.text.trim(),
                  'format': format,
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    nameCtrl.dispose();
    toolIdCtrl.dispose();

    if (confirmed == null) return;

    try {
      final toolRow = await AdminSupabaseService.createTool({
        'tool_type': confirmed['tool_id'],
        'tool_id': confirmed['tool_id'],
        'name': confirmed['name'],
        'name_te': '',
        'response_format': confirmed['format'],
        'sort_order': 99,
      });
      ref.invalidate(adminToolsProvider);
      if (mounted) {
        final newId = toolRow['id'] as int;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ToolDetailScreen(toolId: newId)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Create failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _importTool() async {
    final id = await showImportDialog(context, _primary);
    if (id != null) {
      ref.invalidate(adminToolsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tool imported successfully'), backgroundColor: Color(0xFF4CAF50)),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ToolDetailScreen(toolId: id)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final toolsAsync = ref.watch(adminToolsProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: const Text(
          'Bal Vikas Admin \u2014 Screening Tool Configuration',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showArchived ? Icons.visibility_off : Icons.archive_outlined),
            tooltip: _showArchived ? 'Hide archived' : 'Show archived',
            onPressed: () => setState(() => _showArchived = !_showArchived),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: 'Import tool from JSON',
            onPressed: _importTool,
          ),
          IconButton(
            icon: _seeding
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.cloud_download_outlined),
            tooltip: 'Seed / Sync all tools',
            onPressed: _seeding ? null : _seedData,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh tools',
            onPressed: () => ref.invalidate(adminToolsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewTool,
        icon: const Icon(Icons.add),
        label: const Text('New Tool'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: () async => ref.invalidate(adminToolsProvider),
        child: toolsAsync.when(
          loading: () => _buildLoadingShimmer(),
          error: (err, _) => _buildErrorView(err),
          data: (tools) {
            if (tools.isEmpty) {
              return _buildEmptyState();
            }
            // Filter by archive status
            final filtered = _showArchived
                ? tools
                : tools.where((t) => (t['is_active'] as bool? ?? true)).toList();
            return _buildContent(filtered, screenWidth, allTools: tools);
          },
        ),
      ),
    );
  }

  // ── Loading shimmer ──────────────────────────────────────────────────

  Widget _buildLoadingShimmer() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Shimmer stat cards
          Row(
            children: List.generate(
              3,
              (_) => Expanded(
                child: Container(
                  height: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Shimmer grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error view ───────────────────────────────────────────────────────

  Widget _buildErrorView(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Failed to load screening tools',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              err.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(adminToolsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state with seed button ─────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.quiz_outlined, size: 72, color: _primary),
          ),
          const SizedBox(height: 24),
          Text(
            'No screening tools configured yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seed the database with all 13 ECD screening tools\nincluding CDC, RBSK, M-CHAT, ISAA, ADHD, SDQ, and more.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.5),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 240,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _seeding ? null : _seedData,
              icon: _seeding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_download_outlined),
              label: Text(_seeding ? 'Seeding...' : 'Seed All Tools'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Main content ─────────────────────────────────────────────────────

  Widget _buildContent(List<Map<String, dynamic>> tools, double screenWidth, {List<Map<String, dynamic>>? allTools}) {
    // Compute aggregate stats
    final totalTools = tools.length;
    int totalQuestions = 0;
    final responseFormats = <String>{};
    for (final t in tools) {
      final questionsRaw = t['screening_questions'] as List<dynamic>? ?? [];
      // getAllTools uses screening_questions(count) which returns [{count: N}]
      if (questionsRaw.isNotEmpty && questionsRaw.first is Map && (questionsRaw.first as Map).containsKey('count')) {
        totalQuestions += (questionsRaw.first as Map)['count'] as int? ?? 0;
      } else {
        totalQuestions += questionsRaw.length;
      }
      final fmt = t['response_format'] as String? ?? '';
      if (fmt.isNotEmpty) responseFormats.add(fmt);
    }

    final crossAxisCount = screenWidth > 1200
        ? 4
        : screenWidth > 800
            ? 3
            : screenWidth > 500
                ? 2
                : 1;

    return CustomScrollView(
      slivers: [
        // ── Stats row ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                _StatCard(
                  icon: Icons.build_circle_outlined,
                  label: 'Tools',
                  value: '$totalTools',
                  color: _primary,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.help_outline,
                  label: 'Questions',
                  value: '$totalQuestions',
                  color: const Color(0xFF7C4DFF),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.tune,
                  label: 'Response Formats',
                  value: '${responseFormats.length}',
                  color: const Color(0xFFFF7043),
                ),
              ],
            ),
          ),
        ),

        // ── Config quick-access cards ─────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ConfigQuickCard(
                      icon: Icons.calculate_outlined,
                      label: 'Scoring Formulas',
                      color: const Color(0xFF2196F3),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormulasConfigScreen())),
                    ),
                    const SizedBox(width: 10),
                    _ConfigQuickCard(
                      icon: Icons.local_hospital_outlined,
                      label: 'Referral Rules',
                      color: const Color(0xFFE91E63),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralRulesScreen())),
                    ),
                    const SizedBox(width: 10),
                    _ConfigQuickCard(
                      icon: Icons.sports_handball,
                      label: 'Activities',
                      color: const Color(0xFF4CAF50),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivitiesConfigScreen())),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Section header ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Row(
              children: [
                Text(
                  'Screening Tools',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                if (_showArchived)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Showing archived',
                      style: TextStyle(fontSize: 11, color: Colors.orange.shade800, fontWeight: FontWeight.w500),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  '${tools.length} tools',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Tools grid ─────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final t = tools[index];
                final isArchived = !(t['is_active'] as bool? ?? true);
                return _ToolCard(
                  tool: t,
                  isArchived: isArchived,
                  onEdit: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ToolDetailScreen(
                        toolId: t['id'] as int,
                      ),
                    ),
                  ),
                  onPreview: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuestionnairePreviewScreen(
                        toolId: t['id'] as int,
                      ),
                    ),
                  ),
                );
              },
              childCount: tools.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.25,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Stat Card
// ═══════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Tool Card
// ═══════════════════════════════════════════════════════════════════════════

class _ToolCard extends StatefulWidget {
  final Map<String, dynamic> tool;
  final VoidCallback onEdit;
  final VoidCallback onPreview;
  final bool isArchived;

  const _ToolCard({
    required this.tool,
    required this.onEdit,
    required this.onPreview,
    this.isArchived = false,
  });

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard> {
  bool _hovering = false;

  static const _toolIcons = <String, IconData>{
    'CDC': Icons.child_care,
    'RBSK': Icons.medical_services_outlined,
    'MCHAT': Icons.psychology_outlined,
    'ISAA': Icons.accessibility_new,
    'ADHD': Icons.flash_on,
    'SDQ': Icons.emoji_emotions_outlined,
    'PCI': Icons.family_restroom,
    'PHQ': Icons.self_improvement,
    'HOME': Icons.home_outlined,
    'NUT': Icons.restaurant_outlined,
    'BIRTH': Icons.baby_changing_station,
    'DISEASE': Icons.coronavirus_outlined,
  };

  IconData _resolveIcon(Map<String, dynamic> tool) {
    final iconName = tool['icon_name'] as String? ?? '';
    final name = (tool['name'] as String? ?? '').toUpperCase();

    // Try known abbreviations
    for (final entry in _toolIcons.entries) {
      if (name.contains(entry.key) || iconName.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return Icons.quiz_outlined;
  }

  Color _resolveColor(Map<String, dynamic> tool) {
    final hex = tool['color_hex'] as String?;
    if (hex != null && hex.isNotEmpty) {
      try {
        final cleaned = hex.replaceFirst('#', '');
        return Color(int.parse('FF$cleaned', radix: 16));
      } catch (_) {}
    }
    return const Color(0xFF2196F3);
  }

  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;
    final name = tool['name'] as String? ?? 'Unknown';
    final questionsRaw = tool['screening_questions'] as List<dynamic>? ?? [];
    // getAllTools returns [{count: N}] for the question count
    final int questionCount;
    if (questionsRaw.isNotEmpty && questionsRaw.first is Map && (questionsRaw.first as Map).containsKey('count')) {
      questionCount = (questionsRaw.first as Map)['count'] as int? ?? 0;
    } else {
      questionCount = questionsRaw.length;
    }
    final domains =
        (tool['domains_json'] is List ? tool['domains_json'] as List : []);
    final minAge = tool['min_age_months'] as int? ?? 0;
    final maxAge = tool['max_age_months'] as int? ?? 72;
    final toolColor = _resolveColor(tool);
    final toolIcon = _resolveIcon(tool);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _hovering
            ? (Matrix4.identity()..translate(0.0, -4.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovering
                ? toolColor.withValues(alpha: 0.4)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovering
                  ? toolColor.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: _hovering ? 20 : 8,
              offset: Offset(0, _hovering ? 8 : 2),
            ),
          ],
        ),
        child: Opacity(
          opacity: widget.isArchived ? 0.55 : 1.0,
          child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: icon + color dot + name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: toolColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(toolIcon, color: toolColor, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.isArchived)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Archived',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.orange.shade800),
                      ),
                    )
                  else
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: toolColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Meta chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _MetaChip(
                    icon: Icons.help_outline,
                    label: '$questionCount Q',
                  ),
                  if (domains.isNotEmpty)
                    _MetaChip(
                      icon: Icons.category_outlined,
                      label: '${domains.length} domains',
                    ),
                  _MetaChip(
                    icon: Icons.cake_outlined,
                    label: '$minAge\u2013${maxAge}m',
                  ),
                ],
              ),

              const Spacer(),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: OutlinedButton.icon(
                        onPressed: widget.onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit', style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: toolColor,
                          side: BorderSide(color: toolColor.withValues(alpha: 0.4)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: widget.onPreview,
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label:
                            const Text('Preview', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: toolColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Meta Chip
// ═══════════════════════════════════════════════════════════════════════════

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Config Quick-Access Card
// ═══════════════════════════════════════════════════════════════════════════

class _ConfigQuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ConfigQuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
