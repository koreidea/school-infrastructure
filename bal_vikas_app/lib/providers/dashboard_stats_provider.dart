import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';

/// Dashboard stats for CDPO/CW/EO (project scope)
final projectStatsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, projectId) async {
  try {
    return await SupabaseService.getDashboardStats('project', projectId);
  } catch (e) {
    return _emptyStats('project');
  }
});

/// Dashboard stats for DW (district scope)
final districtStatsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, districtId) async {
  try {
    return await SupabaseService.getDashboardStats('district', districtId);
  } catch (e) {
    return _emptyStats('district');
  }
});

/// Dashboard stats for SUPERVISOR (sector scope)
final sectorStatsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, sectorId) async {
  try {
    return await SupabaseService.getDashboardStats('sector', sectorId);
  } catch (e) {
    return _emptyStats('sector');
  }
});

/// Dashboard stats for SENIOR_OFFICIAL (state scope)
final stateStatsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, stateId) async {
  try {
    return await SupabaseService.getDashboardStats('state', stateId);
  } catch (e) {
    return _emptyStats('state');
  }
});

Map<String, dynamic> _emptyStats(String scope) => {
      'scope': scope,
      'total_districts': 0,
      'total_projects': 0,
      'total_sectors': 0,
      'total_awcs': 0,
      'total_children': 0,
      'screened_this_month': 0,
      'high_risk_count': 0,
      'referrals_needed': 0,
      'sub_units': <Map<String, dynamic>>[],
    };
