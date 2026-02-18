import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';
import 'auth_provider.dart';

/// A selectable dataset (e.g., "App Data" or "ECD Sample Data").
/// Each points to a project hierarchy in Supabase.
class DatasetConfig {
  final int id;
  final String name;
  final String? nameTe;
  final int? projectId;
  final int? districtId;
  final int? stateId;
  final bool isDefault;
  final List<int>? districtIds;

  const DatasetConfig({
    required this.id,
    required this.name,
    this.nameTe,
    this.projectId,
    this.districtId,
    this.stateId,
    this.isDefault = false,
    this.districtIds,
  });

  /// Whether this dataset spans multiple districts.
  bool get isMultiDistrict =>
      districtIds != null && districtIds!.length > 1;

  factory DatasetConfig.fromMap(Map<String, dynamic> map) {
    // Parse district_ids — Supabase returns int[] as List<dynamic>
    List<int>? districtIds;
    final rawIds = map['district_ids'];
    if (rawIds is List) {
      districtIds = rawIds.map((e) => e as int).toList();
    }

    return DatasetConfig(
      id: map['id'] as int,
      name: map['name'] as String,
      nameTe: map['name_te'] as String?,
      projectId: map['project_id'] as int?,
      districtId: map['district_id'] as int?,
      stateId: map['state_id'] as int?,
      isDefault: map['is_default'] as bool? ?? false,
      districtIds: districtIds,
    );
  }
}

/// Load available datasets from Supabase `datasets` table.
final availableDatasetsProvider = FutureProvider<List<DatasetConfig>>((ref) async {
  try {
    final rows = await SupabaseService.client
        .from('datasets')
        .select()
        .order('id');
    return (rows as List)
        .map((r) => DatasetConfig.fromMap(r as Map<String, dynamic>))
        .toList();
  } catch (_) {
    // Table might not exist yet — return empty
    return [];
  }
});

/// Active dataset selection.
/// null = use the user's own scope (default behavior).
/// non-null = override all dashboards to show this dataset's data.
class ActiveDatasetNotifier extends Notifier<DatasetConfig?> {
  @override
  DatasetConfig? build() {
    _loadSaved();
    return null;
  }

  Future<void> _loadSaved() async {
    final savedId = await StorageService.getActiveDatasetId();
    // Wait for datasets to actually load from Supabase
    final datasetsAsync = ref.read(availableDatasetsProvider);
    List<DatasetConfig> datasets = datasetsAsync.value ?? [];
    if (datasets.isEmpty) {
      // Datasets haven't loaded yet — fetch directly
      try {
        final rows = await SupabaseService.client
            .from('datasets')
            .select()
            .order('id');
        datasets = (rows as List)
            .map((r) => DatasetConfig.fromMap(r as Map<String, dynamic>))
            .toList();
      } catch (_) {
        datasets = [];
      }
    }
    if (savedId != null) {
      // Load saved preference
      final match = datasets.where((d) => d.id == savedId).toList();
      if (match.isNotEmpty && !match.first.isDefault) {
        state = match.first;
        return;
      }
    }
    // Default to ECD Sample Data if no preference saved
    final ecdSample = datasets.where((d) => !d.isDefault).toList();
    if (ecdSample.isNotEmpty) {
      state = ecdSample.first;
    }
  }

  Future<void> setDataset(DatasetConfig? dataset) async {
    state = (dataset?.isDefault == true) ? null : dataset;
    await StorageService.saveActiveDatasetId(
      (dataset?.isDefault == true) ? null : dataset?.id,
    );
  }
}

final activeDatasetProvider =
    NotifierProvider<ActiveDatasetNotifier, DatasetConfig?>(() {
  return ActiveDatasetNotifier();
});

/// Whether a dataset override is currently active.
final isDatasetOverrideActiveProvider = Provider<bool>((ref) {
  return ref.watch(activeDatasetProvider) != null;
});

/// Effective project ID — reads from active dataset override first,
/// falls back to the current user's projectId.
final effectiveProjectIdProvider = Provider<int?>((ref) {
  final dataset = ref.watch(activeDatasetProvider);
  if (dataset != null) return dataset.projectId;
  return ref.watch(currentUserProvider)?.projectId;
});

/// Effective district ID.
final effectiveDistrictIdProvider = Provider<int?>((ref) {
  final dataset = ref.watch(activeDatasetProvider);
  if (dataset != null) return dataset.districtId;
  return ref.watch(currentUserProvider)?.districtId;
});

/// Effective state ID.
final effectiveStateIdProvider = Provider<int?>((ref) {
  final dataset = ref.watch(activeDatasetProvider);
  if (dataset != null) return dataset.stateId;
  return ref.watch(currentUserProvider)?.stateId;
});

/// District IDs that belong to non-default (sample) datasets.
/// Used to exclude sample data from state-level App Data queries.
/// Prefers districtIds array; falls back to single districtId.
final sampleDatasetDistrictIdsProvider = Provider<Set<int>>((ref) {
  final datasets = ref.watch(availableDatasetsProvider).value ?? [];
  final ids = <int>{};
  for (final d in datasets) {
    if (d.isDefault) continue;
    if (d.districtIds != null && d.districtIds!.isNotEmpty) {
      ids.addAll(d.districtIds!);
    } else if (d.districtId != null) {
      ids.add(d.districtId!);
    }
  }
  return ids;
});

/// Effective district IDs for the active dataset override.
/// Returns districtIds array when available, or single-element list from districtId.
/// null when no override is active.
final effectiveDistrictIdsProvider = Provider<List<int>?>((ref) {
  final dataset = ref.watch(activeDatasetProvider);
  if (dataset == null) return null;
  if (dataset.districtIds != null && dataset.districtIds!.isNotEmpty) {
    return dataset.districtIds!;
  }
  if (dataset.districtId != null) return [dataset.districtId!];
  return null;
});
