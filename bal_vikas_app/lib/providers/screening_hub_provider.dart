import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/screening_tool.dart';
import '../data/screening_tools_registry.dart';
import '../services/database_service.dart';
import '../services/supabase_service.dart';
import '../database/app_database.dart';
import 'screening_config_provider.dart';

/// State for a single tool in the hub
class ToolState {
  final ScreeningToolConfig config;
  final ToolStatus status;
  final Map<String, dynamic> responses;

  const ToolState({
    required this.config,
    this.status = ToolStatus.pending,
    this.responses = const {},
  });

  ToolState copyWith({
    ToolStatus? status,
    Map<String, dynamic>? responses,
  }) {
    return ToolState(
      config: config,
      status: status ?? this.status,
      responses: responses ?? this.responses,
    );
  }
}

/// Hub state containing all tools for the session
class ScreeningHubState {
  final Map<String, dynamic> session;
  final Map<String, dynamic> child;
  final int childAgeMonths;
  final List<ToolState> tools;
  final int? localSessionId; // Drift local session ID
  final String assessmentCycle; // 'Baseline', 'Follow-up', or 'Re-screen'

  const ScreeningHubState({
    required this.session,
    required this.child,
    required this.childAgeMonths,
    this.tools = const [],
    this.localSessionId,
    this.assessmentCycle = 'Baseline',
  });

  ScreeningHubState copyWith({
    List<ToolState>? tools,
    int? localSessionId,
    String? assessmentCycle,
  }) {
    return ScreeningHubState(
      session: session,
      child: child,
      childAgeMonths: childAgeMonths,
      tools: tools ?? this.tools,
      localSessionId: localSessionId ?? this.localSessionId,
      assessmentCycle: assessmentCycle ?? this.assessmentCycle,
    );
  }

  int get completedCount => tools.where((t) => t.status == ToolStatus.completed).length;
  int get skippedCount => tools.where((t) => t.status == ToolStatus.skipped).length;
  int get totalCount => tools.length;
  bool get allDone => tools.every((t) => t.status == ToolStatus.completed || t.status == ToolStatus.skipped);

  /// Get all responses keyed by tool type
  Map<ScreeningToolType, Map<String, dynamic>> get allResponses {
    final result = <ScreeningToolType, Map<String, dynamic>>{};
    for (final tool in tools) {
      if (tool.status == ToolStatus.completed) {
        result[tool.config.type] = tool.responses;
      }
    }
    return result;
  }
}

class ScreeningHubNotifier extends Notifier<ScreeningHubState?> {
  @override
  ScreeningHubState? build() => null;

  Future<void> initialize({
    required Map<String, dynamic> session,
    required Map<String, dynamic> child,
    required int childAgeMonths,
  }) async {
    // Try DB-backed tools first, fall back to hardcoded
    List<ScreeningToolConfig> applicableTools;
    try {
      applicableTools = await ref.read(toolsForAgeProvider(childAgeMonths).future);
    } catch (_) {
      applicableTools = getToolsForAge(childAgeMonths);
    }
    final toolStates = applicableTools
        .map((config) => ToolState(config: config))
        .toList();

    // Create local Drift session and detect assessment cycle
    int? localSessionId;
    String assessmentCycle = 'Baseline';
    if (!kIsWeb) {
      try {
        final db = DatabaseService.db;
        final childId = child['child_id'] as int?;
        final localId = child['local_id'] as int?;

        // Auto-detect assessment cycle: check previous results for this child
        if (childId != null) {
          final previousResult = await db.screeningDao.getLatestResultForChildByRemoteId(childId);
          if (previousResult != null) {
            // Has previous screening — this is a follow-up
            assessmentCycle = 'Follow-up';
          }
        }

        localSessionId = await db.screeningDao.createSession(
          LocalScreeningSessionsCompanion.insert(
            childLocalId: Value(localId),
            childRemoteId: Value(childId),
            conductedBy: session['conducted_by']?.toString() ?? '',
            assessmentDate: DateTime.now().toIso8601String().split('T')[0],
            childAgeMonths: childAgeMonths,
            deviceSessionId: Value(session['device_session_id']?.toString()),
          ),
        );
      } catch (_) {}
    } else {
      // On web: detect assessment cycle from Supabase
      try {
        final childId = child['child_id'] as int?;
        if (childId != null) {
          final history = await SupabaseService.getScreeningHistory(childId);
          if (history.isNotEmpty) {
            assessmentCycle = 'Follow-up';
          }
        }
      } catch (_) {}
    }

    state = ScreeningHubState(
      session: session,
      child: child,
      childAgeMonths: childAgeMonths,
      tools: toolStates,
      localSessionId: localSessionId,
      assessmentCycle: assessmentCycle,
    );
  }

  void updateToolStatus(ScreeningToolType type, ToolStatus status, {Map<String, dynamic>? responses}) {
    if (state == null) return;
    final tools = state!.tools.map((t) {
      if (t.config.type == type) {
        return t.copyWith(
          status: status,
          responses: responses ?? t.responses,
        );
      }
      return t;
    }).toList();
    state = state!.copyWith(tools: tools);
  }

  void skipTool(ScreeningToolType type) {
    updateToolStatus(type, ToolStatus.skipped);
  }

  void completeTool(ScreeningToolType type, Map<String, dynamic> responses) {
    updateToolStatus(type, ToolStatus.completed, responses: responses);

    // Persist responses to Drift (skip on web)
    if (!kIsWeb) {
      final sessionId = state?.localSessionId;
      if (sessionId != null) {
        DatabaseService.db.screeningDao.saveToolResponses(
          sessionLocalId: sessionId,
          toolType: type.name,
          responses: responses,
        ).then((_) {
          // ignore: avoid_print
          print('[Hub] Saved ${type.name} responses for session $sessionId');
        }).catchError((e) {
          // ignore: avoid_print
          print('[Hub] saveToolResponses failed for ${type.name}: $e');
        });
      }
    }
  }

  void reset() {
    state = null;
  }
}

final screeningHubProvider = NotifierProvider<ScreeningHubNotifier, ScreeningHubState?>(() {
  return ScreeningHubNotifier();
});
