import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_supabase_service.dart';

/// Provides the full list of screening tool configs from Supabase, each
/// enriched with a question count. Used by the admin tool management UI.
final adminToolsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return AdminSupabaseService.getAllTools();
});

/// Provides detailed data for a single screening tool (metadata + questions +
/// response options). Keyed by the Supabase `screening_tool_configs.id`.
final adminToolDetailProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, toolId) async {
  return AdminSupabaseService.getToolDetail(toolId);
});
