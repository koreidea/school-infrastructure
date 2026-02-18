import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/admin_supabase_service.dart';

/// Admin screen for managing intervention activities in Supabase.
/// Supports CRUD operations on `intervention_activities` and
/// `activity_guidance_steps` tables, with domain filtering, search,
/// and a seed-from-app action.
class ActivitiesConfigScreen extends ConsumerStatefulWidget {
  const ActivitiesConfigScreen({super.key});

  @override
  ConsumerState<ActivitiesConfigScreen> createState() =>
      _ActivitiesConfigScreenState();
}

class _ActivitiesConfigScreenState
    extends ConsumerState<ActivitiesConfigScreen> {
  // ── Theme constants ──────────────────────────────────────────────────
  static const _primary = Color(0xFF4CAF50);
  static const _primaryDark = Color(0xFF388E3C);
  static const _surface = Color(0xFFF6FBF6);

  // ── Domain colour map ────────────────────────────────────────────────
  static const _domainColors = <String, Color>{
    'gm': Color(0xFF2196F3), // blue
    'fm': Color(0xFF9C27B0), // purple
    'lc': Color(0xFFFF9800), // orange
    'cog': Color(0xFF009688), // teal
    'se': Color(0xFFE91E63), // pink
  };

  static const _domainLabels = <String, String>{
    'gm': 'Gross Motor',
    'fm': 'Fine Motor',
    'lc': 'Language',
    'cog': 'Cognitive',
    'se': 'Social-Emotional',
  };

  static const _domainIcons = <String, IconData>{
    'gm': Icons.directions_run,
    'fm': Icons.back_hand_outlined,
    'lc': Icons.record_voice_over,
    'cog': Icons.psychology,
    'se': Icons.people,
  };

  // ── State ────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _activities = [];
  bool _loading = true;
  String? _error;
  String _domainFilter = 'all';
  String _searchQuery = '';
  bool _showSearch = false;
  bool _seeding = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Data loading ─────────────────────────────────────────────────────

  Future<void> _loadActivities() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await AdminSupabaseService.getActivities();
      if (mounted) {
        setState(() {
          _activities = data;
          _loading = false;
        });
      }
    } catch (e) {
      // If Supabase table doesn't exist or other error, show empty state
      if (mounted) {
        setState(() {
          _activities = [];
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not load activities: $e\nCreate the intervention_activities table to use this feature.',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // ── Seed from hardcoded data ─────────────────────────────────────────

  Future<void> _seedFromApp() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Seed Activities'),
        content: const Text(
          'This will populate the database with all hardcoded intervention '
          'activities. Existing activities will not be duplicated.\n\n'
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Seed'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _seeding = true);
    try {
      await AdminSupabaseService.seedActivities();
      await _loadActivities();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activities seeded successfully!'),
            backgroundColor: _primary,
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

  // ── Delete activity ──────────────────────────────────────────────────

  Future<void> _deleteActivity(Map<String, dynamic> activity) async {
    final title = activity['activity_title'] as String? ?? 'this activity';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Activity'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AdminSupabaseService.deleteActivity(activity['id'] as int);
      await _loadActivities();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity deleted'),
            backgroundColor: _primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Filtering helpers ────────────────────────────────────────────────

  List<Map<String, dynamic>> get _filteredActivities {
    var list = _activities;

    if (_domainFilter != 'all') {
      list = list.where((a) => a['domain'] == _domainFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((a) {
        final title =
            (a['activity_title'] as String? ?? '').toLowerCase();
        final code =
            (a['activity_code'] as String? ?? '').toLowerCase();
        return title.contains(q) || code.contains(q);
      }).toList();
    }

    return list;
  }

  /// Group activities by domain for display.
  Map<String, List<Map<String, dynamic>>> get _groupedActivities {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final a in _filteredActivities) {
      final domain = a['domain'] as String? ?? 'other';
      grouped.putIfAbsent(domain, () => []).add(a);
    }
    // Sort within each group by sort_order
    for (final list in grouped.values) {
      list.sort((a, b) {
        final oa = a['sort_order'] as int? ?? 0;
        final ob = b['sort_order'] as int? ?? 0;
        return oa.compareTo(ob);
      });
    }
    return grouped;
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: _buildAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openActivityEditor(null),
        icon: const Icon(Icons.add),
        label: const Text('Add Activity'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: _loadActivities,
        child: _buildBody(),
      ),
    );
  }

  // ── App bar ──────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: _showSearch
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search activities...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            )
          : const Text(
              'Intervention Activities',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // Domain filter dropdown
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filter by domain',
          onSelected: (v) => setState(() => _domainFilter = v),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'all', child: Text('All Domains')),
            ..._domainLabels.entries.map(
              (e) => PopupMenuItem(
                value: e.key,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _domainColors[e.key],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(e.value),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Search toggle
        IconButton(
          icon: Icon(_showSearch ? Icons.close : Icons.search),
          tooltip: _showSearch ? 'Close search' : 'Search',
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchQuery = '';
                _searchController.clear();
              }
            });
          },
        ),

        // Refresh
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: _loadActivities,
        ),
      ],
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_loading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_activities.isEmpty) {
      return _buildEmptyState();
    }

    final grouped = _groupedActivities;

    if (grouped.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No activities match your filters',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // Domain display order
    const domainOrder = ['gm', 'fm', 'lc', 'cog', 'se'];
    final sortedDomains = grouped.keys.toList()
      ..sort((a, b) {
        final ia = domainOrder.indexOf(a);
        final ib = domainOrder.indexOf(b);
        return (ia == -1 ? 99 : ia).compareTo(ib == -1 ? 99 : ib);
      });

    return CustomScrollView(
      slivers: [
        // ── Stats bar ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                _StatChip(
                  icon: Icons.fitness_center,
                  label: '${_activities.length} total',
                  color: _primary,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.filter_list,
                  label: '${_filteredActivities.length} shown',
                  color: _primaryDark,
                ),
                const Spacer(),
                // Seed button
                TextButton.icon(
                  onPressed: _seeding ? null : _seedFromApp,
                  icon: _seeding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _primary,
                          ),
                        )
                      : const Icon(Icons.cloud_download_outlined, size: 18),
                  label: Text(_seeding ? 'Seeding...' : 'Seed from App'),
                  style: TextButton.styleFrom(foregroundColor: _primary),
                ),
              ],
            ),
          ),
        ),

        // ── Active domain filter chip ──────────────────────────────────
        if (_domainFilter != 'all')
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Chip(
                    avatar: Icon(
                      _domainIcons[_domainFilter] ?? Icons.category,
                      size: 16,
                      color: _domainColors[_domainFilter],
                    ),
                    label: Text(
                      _domainLabels[_domainFilter] ?? _domainFilter,
                      style: TextStyle(
                        color: _domainColors[_domainFilter],
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    backgroundColor:
                        (_domainColors[_domainFilter] ?? _primary)
                            .withValues(alpha: 0.1),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () =>
                        setState(() => _domainFilter = 'all'),
                    side: BorderSide(
                      color: (_domainColors[_domainFilter] ?? _primary)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Domain groups ──────────────────────────────────────────────
        for (final domain in sortedDomains) ...[
          SliverToBoxAdapter(
            child: _buildDomainHeader(
                domain, grouped[domain]!.length),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final activity = grouped[domain]![index];
                  return _ActivityCard(
                    activity: activity,
                    domainColor:
                        _domainColors[domain] ?? Colors.grey,
                    onEdit: () => _openActivityEditor(activity),
                    onDelete: () => _deleteActivity(activity),
                  );
                },
                childCount: grouped[domain]!.length,
              ),
            ),
          ),
        ],

        // Extra space for FAB
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  // ── Domain header ────────────────────────────────────────────────────

  Widget _buildDomainHeader(String domain, int count) {
    final color = _domainColors[domain] ?? Colors.grey;
    final label = _domainLabels[domain] ?? domain.toUpperCase();
    final icon = _domainIcons[domain] ?? Icons.category;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Loading state ────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _primary),
          SizedBox(height: 16),
          Text(
            'Loading activities...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ── Error state ──────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Failed to load activities',
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
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadActivities,
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

  // ── Empty state ──────────────────────────────────────────────────────

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
            child: const Icon(Icons.fitness_center,
                size: 72, color: _primary),
          ),
          const SizedBox(height: 24),
          Text(
            'No intervention activities yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seed from the app or add activities manually.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.5),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 240,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _seeding ? null : _seedFromApp,
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
              label: Text(_seeding ? 'Seeding...' : 'Seed from App'),
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

  // ── Open add/edit full-screen dialog ─────────────────────────────────

  Future<void> _openActivityEditor(Map<String, dynamic>? existing) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ActivityEditorScreen(
          activity: existing,
          primaryColor: _primary,
        ),
      ),
    );

    if (result == true) {
      await _loadActivities();
    }
  }
}

// =============================================================================
//  Stat Chip
// =============================================================================

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Activity Card
// =============================================================================

class _ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  final Color domainColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActivityCard({
    required this.activity,
    required this.domainColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final code = activity['activity_code'] as String? ?? '';
    final title = activity['activity_title'] as String? ?? 'Untitled';
    final domain = activity['domain'] as String? ?? '';
    final minAge = activity['min_age_months'] as int? ?? 0;
    final maxAge = activity['max_age_months'] as int? ?? 72;
    final duration = activity['duration_minutes'] as int? ?? 0;
    final riskLevel = activity['risk_level'] as String? ?? 'LOW';
    final hasVideo = activity['has_video'] as bool? ?? false;
    final isActive = activity['is_active'] as bool? ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.55,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: code badge + title ───────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity code badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: domainColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      code,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: domainColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Title
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasVideo)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(Icons.videocam,
                          size: 18, color: Colors.grey.shade500),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Chips row ────────────────────────────────────────────
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildChip(
                    _ActivitiesConfigScreenState._domainLabels[domain] ??
                        domain.toUpperCase(),
                    domainColor.withValues(alpha: 0.1),
                    domainColor,
                  ),
                  _buildChip(
                    '$minAge\u2013${maxAge}m',
                    Colors.blue.shade50,
                    Colors.blue.shade700,
                  ),
                  _buildChip(
                    '$duration min',
                    Colors.grey.shade100,
                    Colors.grey.shade700,
                  ),
                  _buildRiskChip(riskLevel),
                  if (!isActive)
                    _buildChip(
                      'Inactive',
                      Colors.orange.shade50,
                      Colors.orange.shade800,
                    ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Action buttons ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_outlined,
                        size: 16, color: domainColor),
                    label: Text('Edit',
                        style: TextStyle(
                            fontSize: 13, color: domainColor)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline,
                        size: 16, color: Colors.red.shade400),
                    label: Text('Delete',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.red.shade400)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _buildRiskChip(String riskLevel) {
    Color bg;
    Color fg;
    switch (riskLevel) {
      case 'HIGH':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
      case 'MEDIUM':
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade800;
      default:
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
    }
    return _buildChip(riskLevel, bg, fg);
  }
}

// =============================================================================
//  Activity Editor (Full-Screen Dialog)
// =============================================================================

class _ActivityEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? activity;
  final Color primaryColor;

  const _ActivityEditorScreen({
    required this.activity,
    required this.primaryColor,
  });

  @override
  State<_ActivityEditorScreen> createState() => _ActivityEditorScreenState();
}

class _ActivityEditorScreenState extends State<_ActivityEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _loadingSteps = false;

  // ── Activity field controllers ───────────────────────────────────────
  late final TextEditingController _codeCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _titleTeCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _descTeCtrl;
  late final TextEditingController _materialsCtrl;
  late final TextEditingController _materialsTeCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _minAgeCtrl;
  late final TextEditingController _maxAgeCtrl;
  late final TextEditingController _sortOrderCtrl;

  String _domain = 'gm';
  String _riskLevel = 'LOW';
  bool _hasVideo = false;

  // ── Guidance steps ───────────────────────────────────────────────────
  List<_GuidanceStep> _guidanceSteps = [];

  bool get _isEditing => widget.activity != null;

  @override
  void initState() {
    super.initState();
    final a = widget.activity;

    _codeCtrl = TextEditingController(text: a?['activity_code'] as String? ?? '');
    _titleCtrl = TextEditingController(text: a?['activity_title'] as String? ?? '');
    _titleTeCtrl = TextEditingController(text: a?['activity_title_te'] as String? ?? '');
    _descCtrl = TextEditingController(text: a?['activity_description'] as String? ?? '');
    _descTeCtrl = TextEditingController(text: a?['activity_description_te'] as String? ?? '');
    _materialsCtrl = TextEditingController(text: a?['materials_needed'] as String? ?? '');
    _materialsTeCtrl = TextEditingController(text: a?['materials_needed_te'] as String? ?? '');
    _durationCtrl = TextEditingController(text: '${a?['duration_minutes'] ?? 15}');
    _minAgeCtrl = TextEditingController(text: '${a?['min_age_months'] ?? 0}');
    _maxAgeCtrl = TextEditingController(text: '${a?['max_age_months'] ?? 72}');
    _sortOrderCtrl = TextEditingController(text: '${a?['sort_order'] ?? 0}');

    _domain = a?['domain'] as String? ?? 'gm';
    _riskLevel = a?['risk_level'] as String? ?? 'LOW';
    _hasVideo = a?['has_video'] as bool? ?? false;

    if (_isEditing) {
      _loadGuidanceSteps();
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _titleCtrl.dispose();
    _titleTeCtrl.dispose();
    _descCtrl.dispose();
    _descTeCtrl.dispose();
    _materialsCtrl.dispose();
    _materialsTeCtrl.dispose();
    _durationCtrl.dispose();
    _minAgeCtrl.dispose();
    _maxAgeCtrl.dispose();
    _sortOrderCtrl.dispose();
    for (final step in _guidanceSteps) {
      step.dispose();
    }
    super.dispose();
  }

  // ── Load guidance steps for existing activity ────────────────────────

  Future<void> _loadGuidanceSteps() async {
    if (widget.activity == null) return;
    final activityId = widget.activity!['id'] as int;
    setState(() => _loadingSteps = true);
    try {
      final steps = await AdminSupabaseService.getGuidanceSteps(activityId);
      if (mounted) {
        setState(() {
          _guidanceSteps = steps.map((s) => _GuidanceStep.fromMap(s)).toList();
          _guidanceSteps.sort(
              (a, b) => a.stepNumber.compareTo(b.stepNumber));
          _loadingSteps = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSteps = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load guidance steps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Save ─────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final data = <String, dynamic>{
      'activity_code': _codeCtrl.text.trim(),
      'domain': _domain,
      'activity_title': _titleCtrl.text.trim(),
      'activity_title_te': _titleTeCtrl.text.trim(),
      'activity_description': _descCtrl.text.trim(),
      'activity_description_te': _descTeCtrl.text.trim(),
      'materials_needed': _materialsCtrl.text.trim(),
      'materials_needed_te': _materialsTeCtrl.text.trim(),
      'duration_minutes': int.tryParse(_durationCtrl.text) ?? 15,
      'min_age_months': int.tryParse(_minAgeCtrl.text) ?? 0,
      'max_age_months': int.tryParse(_maxAgeCtrl.text) ?? 72,
      'risk_level': _riskLevel,
      'has_video': _hasVideo,
      'sort_order': int.tryParse(_sortOrderCtrl.text) ?? 0,
      'is_active': true,
    };

    try {
      int activityId;

      if (_isEditing) {
        activityId = widget.activity!['id'] as int;
        await AdminSupabaseService.updateActivity(activityId, data);
      } else {
        final result = await AdminSupabaseService.addActivity(data);
        activityId = result['id'] as int;
      }

      // Save guidance steps
      final stepsData = _guidanceSteps
          .asMap()
          .entries
          .map((entry) => {
                'step_number': entry.key + 1,
                'instruction_en': entry.value.instructionEnCtrl.text.trim(),
                'instruction_te': entry.value.instructionTeCtrl.text.trim(),
                'tip_en': entry.value.tipEnCtrl.text.trim(),
                'tip_te': entry.value.tipTeCtrl.text.trim(),
              })
          .toList();

      await AdminSupabaseService.saveGuidanceSteps(activityId, stepsData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEditing ? 'Activity updated' : 'Activity created'),
            backgroundColor: widget.primaryColor,
          ),
        );
        Navigator.of(context).pop(true);
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

  // ── Guidance step helpers ────────────────────────────────────────────

  void _addStep() {
    setState(() {
      _guidanceSteps.add(_GuidanceStep(
        stepNumber: _guidanceSteps.length + 1,
      ));
    });
  }

  void _removeStep(int index) {
    setState(() {
      _guidanceSteps[index].dispose();
      _guidanceSteps.removeAt(index);
      // Re-number
      for (int i = 0; i < _guidanceSteps.length; i++) {
        _guidanceSteps[i].stepNumber = i + 1;
      }
    });
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final domainColor = _ActivitiesConfigScreenState._domainColors[_domain] ??
        widget.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF6),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Activity' : 'Add Activity',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: widget.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
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
              label: Text(_saving ? 'Saving...' : 'Save'),
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
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Basic info section ─────────────────────────────────────
            _SectionHeader(
                title: 'Basic Information', icon: Icons.info_outline),
            const SizedBox(height: 12),
            _buildCard([
              // Activity code + domain row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _codeCtrl,
                      decoration: _inputDecor('Activity Code', 'e.g. GM_001'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _domain,
                      decoration: _inputDecor('Domain', null),
                      items: _ActivitiesConfigScreenState._domainLabels.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color:
                                            _ActivitiesConfigScreenState
                                                ._domainColors[e.key],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(child: Text(e.value, overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _domain = v ?? 'gm'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title English
              TextFormField(
                controller: _titleCtrl,
                decoration: _inputDecor('Activity Title (English)', null),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // Title Telugu
              TextFormField(
                controller: _titleTeCtrl,
                decoration: _inputDecor('Activity Title (Telugu)', null),
              ),
              const SizedBox(height: 14),

              // Description English
              TextFormField(
                controller: _descCtrl,
                decoration:
                    _inputDecor('Description (English)', null),
                maxLines: 3,
              ),
              const SizedBox(height: 14),

              // Description Telugu
              TextFormField(
                controller: _descTeCtrl,
                decoration:
                    _inputDecor('Description (Telugu)', null),
                maxLines: 3,
              ),
            ]),

            const SizedBox(height: 20),

            // ── Materials section ──────────────────────────────────────
            _SectionHeader(
                title: 'Materials & Settings',
                icon: Icons.shopping_bag_outlined),
            const SizedBox(height: 12),
            _buildCard([
              // Materials English
              TextFormField(
                controller: _materialsCtrl,
                decoration:
                    _inputDecor('Materials Needed (English)', null),
              ),
              const SizedBox(height: 14),

              // Materials Telugu
              TextFormField(
                controller: _materialsTeCtrl,
                decoration:
                    _inputDecor('Materials Needed (Telugu)', null),
              ),
              const SizedBox(height: 14),

              // Duration + Age range + Sort order
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationCtrl,
                      decoration:
                          _inputDecor('Duration (min)', null),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _minAgeCtrl,
                      decoration:
                          _inputDecor('Min Age (months)', null),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxAgeCtrl,
                      decoration:
                          _inputDecor('Max Age (months)', null),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Risk level + has_video + sort order
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _riskLevel,
                      decoration: _inputDecor('Risk Level', null),
                      items: const [
                        DropdownMenuItem(
                            value: 'LOW', child: Text('LOW')),
                        DropdownMenuItem(
                            value: 'MEDIUM', child: Text('MEDIUM')),
                        DropdownMenuItem(
                            value: 'HIGH', child: Text('HIGH')),
                      ],
                      onChanged: (v) =>
                          setState(() => _riskLevel = v ?? 'LOW'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _sortOrderCtrl,
                      decoration: _inputDecor('Sort Order', null),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Has video toggle
                  Column(
                    children: [
                      const Text(
                        'Has Video',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Switch(
                        value: _hasVideo,
                        onChanged: (v) =>
                            setState(() => _hasVideo = v),
                        activeColor: widget.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ]),

            const SizedBox(height: 20),

            // ── Guidance steps section ─────────────────────────────────
            _SectionHeader(
              title: 'Guidance Steps',
              icon: Icons.format_list_numbered,
              trailing: TextButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Step'),
                style: TextButton.styleFrom(
                  foregroundColor: widget.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (_loadingSteps)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                    child: CircularProgressIndicator(
                        color: _ActivitiesConfigScreenState._primary)),
              )
            else if (_guidanceSteps.isEmpty)
              _buildCard([
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.format_list_numbered,
                            size: 36, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No guidance steps yet',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _addStep,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add First Step'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: widget.primaryColor,
                            side: BorderSide(
                                color: widget.primaryColor
                                    .withValues(alpha: 0.4)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ])
            else
              ...List.generate(_guidanceSteps.length, (i) {
                final step = _guidanceSteps[i];
                return _buildGuidanceStepCard(step, i, domainColor);
              }),

            // Extra space for scrolling
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ── Guidance step card ───────────────────────────────────────────────

  Widget _buildGuidanceStepCard(
      _GuidanceStep step, int index, Color domainColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: domainColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: domainColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Step ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _removeStep(index),
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: Colors.red.shade400),
                  tooltip: 'Remove step',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Instruction English
            TextFormField(
              controller: step.instructionEnCtrl,
              decoration:
                  _inputDecor('Instruction (English)', null),
              maxLines: 2,
            ),
            const SizedBox(height: 10),

            // Instruction Telugu
            TextFormField(
              controller: step.instructionTeCtrl,
              decoration:
                  _inputDecor('Instruction (Telugu)', null),
              maxLines: 2,
            ),
            const SizedBox(height: 10),

            // Tip English
            TextFormField(
              controller: step.tipEnCtrl,
              decoration: _inputDecor('Tip (English)', null),
            ),
            const SizedBox(height: 10),

            // Tip Telugu
            TextFormField(
              controller: step.tipTeCtrl,
              decoration: _inputDecor('Tip (Telugu)', null),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label, String? hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: widget.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}

// =============================================================================
//  Section Header
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 20,
            color: _ActivitiesConfigScreenState._primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

// =============================================================================
//  Guidance Step Model (local-only, for editor state)
// =============================================================================

class _GuidanceStep {
  int stepNumber;
  final TextEditingController instructionEnCtrl;
  final TextEditingController instructionTeCtrl;
  final TextEditingController tipEnCtrl;
  final TextEditingController tipTeCtrl;

  _GuidanceStep({
    this.stepNumber = 1,
    String instructionEn = '',
    String instructionTe = '',
    String tipEn = '',
    String tipTe = '',
  })  : instructionEnCtrl = TextEditingController(text: instructionEn),
        instructionTeCtrl = TextEditingController(text: instructionTe),
        tipEnCtrl = TextEditingController(text: tipEn),
        tipTeCtrl = TextEditingController(text: tipTe);

  factory _GuidanceStep.fromMap(Map<String, dynamic> map) {
    return _GuidanceStep(
      stepNumber: map['step_number'] as int? ?? 1,
      instructionEn: map['instruction_en'] as String? ?? '',
      instructionTe: map['instruction_te'] as String? ?? '',
      tipEn: map['tip_en'] as String? ?? '',
      tipTe: map['tip_te'] as String? ?? '',
    );
  }

  void dispose() {
    instructionEnCtrl.dispose();
    instructionTeCtrl.dispose();
    tipEnCtrl.dispose();
    tipTeCtrl.dispose();
  }
}
