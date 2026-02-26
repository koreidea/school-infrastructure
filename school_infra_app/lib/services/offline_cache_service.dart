import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/school.dart';
import '../models/demand_plan.dart';
import '../models/infra_assessment.dart';

/// Offline cache using Hive for school infrastructure data.
/// Stores JSON maps in Hive boxes so we can work without network.
class OfflineCacheService {
  static const String _schoolsBox = 'schools_cache';
  static const String _demandsBox = 'demands_cache';
  static const String _assessmentsBox = 'assessments_queue';
  static const String _metaBox = 'cache_meta';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_schoolsBox);
    await Hive.openBox<String>(_demandsBox);
    await Hive.openBox<String>(_assessmentsBox);
    await Hive.openBox<String>(_metaBox);
  }

  // ─── Schools Cache ───

  static Future<void> cacheSchools(List<School> schools) async {
    final box = Hive.box<String>(_schoolsBox);
    await box.clear();
    for (final s in schools) {
      await box.put('school_${s.id}', jsonEncode(s.toJson()));
    }
    await _setLastSync('schools');
  }

  static List<School> getCachedSchools() {
    final box = Hive.box<String>(_schoolsBox);
    return box.values.map((json) {
      return School.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }).toList();
  }

  static bool hasSchoolsCache() {
    return Hive.box<String>(_schoolsBox).isNotEmpty;
  }

  // ─── Demand Plans Cache ───

  static Future<void> cacheDemandPlans(List<DemandPlan> demands) async {
    final box = Hive.box<String>(_demandsBox);
    await box.clear();
    for (final d in demands) {
      await box.put('demand_${d.id}', jsonEncode(d.toJson()));
    }
    await _setLastSync('demands');
  }

  static List<DemandPlan> getCachedDemandPlans() {
    final box = Hive.box<String>(_demandsBox);
    return box.values.map((json) {
      return DemandPlan.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }).toList();
  }

  static bool hasDemandPlansCache() {
    return Hive.box<String>(_demandsBox).isNotEmpty;
  }

  // ─── Offline Assessment Queue ───

  static Future<void> queueAssessment(InfraAssessment assessment) async {
    final box = Hive.box<String>(_assessmentsBox);
    final key = 'assessment_${DateTime.now().millisecondsSinceEpoch}';
    await box.put(key, jsonEncode(assessment.toJson()));
  }

  static List<MapEntry<String, InfraAssessment>> getPendingAssessments() {
    final box = Hive.box<String>(_assessmentsBox);
    return box.toMap().entries.map((e) {
      final assessment = InfraAssessment.fromJson(
          jsonDecode(e.value) as Map<String, dynamic>);
      return MapEntry(e.key.toString(), assessment);
    }).toList();
  }

  static Future<void> removeAssessment(String key) async {
    final box = Hive.box<String>(_assessmentsBox);
    await box.delete(key);
  }

  static int get pendingAssessmentCount =>
      Hive.box<String>(_assessmentsBox).length;

  // ─── Meta ───

  static Future<void> _setLastSync(String type) async {
    final box = Hive.box<String>(_metaBox);
    await box.put('last_sync_$type', DateTime.now().toIso8601String());
  }

  static DateTime? getLastSync(String type) {
    final box = Hive.box<String>(_metaBox);
    final value = box.get('last_sync_$type');
    return value != null ? DateTime.tryParse(value) : null;
  }

  static Future<void> clearAll() async {
    await Hive.box<String>(_schoolsBox).clear();
    await Hive.box<String>(_demandsBox).clear();
    await Hive.box<String>(_metaBox).clear();
  }
}
