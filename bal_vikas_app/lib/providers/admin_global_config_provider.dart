import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_supabase_service.dart';

/// Cached global config values from admin_global_config table.
/// Provides a Map<String, dynamic> keyed by config_key → config_value.
/// Falls back to hardcoded defaults if DB value is not set.
class GlobalConfig {
  final Map<String, dynamic> _values;

  GlobalConfig(this._values);

  /// Get a config value, falling back to [defaultValue] if not set.
  T get<T>(String key, T defaultValue) {
    final v = _values[key];
    if (v == null) return defaultValue;
    if (v is T) return v;
    // Handle num → int/double coercion
    if (defaultValue is int && v is num) return v.toInt() as T;
    if (defaultValue is double && v is num) return v.toDouble() as T;
    if (defaultValue is bool && v is bool) return v as T;
    // Handle JSON-encoded lists
    if (defaultValue is List && v is String) {
      try {
        return jsonDecode(v) as T;
      } catch (_) {}
    }
    if (defaultValue is List && v is List) return v as T;
    return defaultValue;
  }

  // ── Baseline Score Formula ──
  int get baselineWeightDelays => get('baseline_weight_delays', 5);
  int get baselineWeightAutismHigh => get('baseline_weight_autism_high', 15);
  int get baselineWeightAutismModerate => get('baseline_weight_autism_moderate', 8);
  int get baselineWeightAdhdHigh => get('baseline_weight_adhd_high', 8);
  int get baselineWeightAdhdModerate => get('baseline_weight_adhd_moderate', 4);
  int get baselineWeightBehaviorHigh => get('baseline_weight_behavior_high', 7);
  int get baselineCutoffLow => get('baseline_cutoff_low', 10);
  int get baselineCutoffMedium => get('baseline_cutoff_medium', 25);

  // ── Composite Risk ──
  int get compositeHighCount => get('composite_high_count', 2);
  int get compositeMediumHighCount => get('composite_medium_high_count', 1);
  int get compositeMediumCount => get('composite_medium_count', 2);
  int get compositeHighWeight => get('composite_high_weight', 3);
  int get compositeMediumWeight => get('composite_medium_weight', 1);

  // ── Delay Detection ──
  double get delayDqThreshold => get('delay_dq_threshold', 85.0);

  // ── Predictive Model Weights ──
  double get predDevWeight => get('pred_dev_weight', 0.40);
  double get predDelayMax => get('pred_delay_max', 15.0);
  double get predAutismWeight => get('pred_autism_weight', 0.08);
  double get predAdhdWeight => get('pred_adhd_weight', 0.06);
  double get predBehaviorWeight => get('pred_behavior_weight', 0.06);
  double get predPhq9Weight => get('pred_phq9_weight', 0.05);
  double get predHomestimWeight => get('pred_homestim_weight', 0.05);
  double get predNutritionWeight => get('pred_nutrition_weight', 0.05);
  double get predTrajSevere => get('pred_traj_severe', 10.0);
  double get predTrajModerate => get('pred_traj_moderate', 7.0);
  double get predTrajMild => get('pred_traj_mild', 4.0);
  double get predTrajStable => get('pred_traj_stable', 2.0);
  double get predPatternLangSocial => get('pred_pattern_lang_social', 3.0);
  double get predPatternToxicEnv => get('pred_pattern_toxic_env', 3.0);
  double get predPatternYoungDelays => get('pred_pattern_young_delays', 2.0);
  double get predCatLow => get('pred_cat_low', 25.0);
  double get predCatMedium => get('pred_cat_medium', 50.0);
  double get predCatHigh => get('pred_cat_high', 75.0);
  double get predTrendImproving => get('pred_trend_improving', 5.0);
  double get predTrendWorsening => get('pred_trend_worsening', -5.0);

  // ── Feature Extraction ──
  double get featLangSocialDq => get('feat_lang_social_dq', 80.0);
  double get featToxicPhq9 => get('feat_toxic_phq9', 10.0);
  double get featToxicHomestim => get('feat_toxic_homestim', 80.0);
  double get featYoungDelaysCount => get('feat_young_delays_count', 3.0);
  double get featYoungAgeMax => get('feat_young_age_max', 24.0);
  double get featHomestimHigh => get('feat_homestim_high', 7.0);
  double get featHomestimMedium => get('feat_homestim_medium', 15.0);
  double get featNutritionHigh => get('feat_nutrition_high', 3.0);
  double get featNutritionMedium => get('feat_nutrition_medium', 1.0);

  // ── Referral Rules ──
  bool get referralHighAuto => get('referral_high_auto', true);
  bool get referralMediumFollowupCheck => get('referral_medium_followup_check', true);
  List<String> get referralReasonPriority =>
      get('referral_reason_priority', ['AUTISM', 'ADHD', 'GDD', 'BEHAVIOUR', 'DOMAIN_DELAY']);
  String get referralTypeAutism => get('referral_type_autism', 'DEIC');
  String get referralTypeGdd => get('referral_type_gdd', 'DEIC');
  String get referralTypeAdhd => get('referral_type_adhd', 'RBSK');
  String get referralTypeBehaviour => get('referral_type_behaviour', 'RBSK');
  String get referralTypeEnvironment => get('referral_type_environment', 'AWW_INTERVENTION');
  String get referralTypeDomainDelay => get('referral_type_domain_delay', 'PHC');
  int get referralGddDelayCount => get('referral_gdd_delay_count', 2);
}

/// Provider that loads global configs from Supabase.
/// Returns a GlobalConfig with all values cached in memory.
final globalConfigProvider = FutureProvider<GlobalConfig>((ref) async {
  try {
    final rows = await AdminSupabaseService.getGlobalConfigs();
    final map = <String, dynamic>{};
    for (final row in rows) {
      map[row['config_key'] as String] = row['config_value'];
    }
    return GlobalConfig(map);
  } catch (_) {
    // Return defaults if Supabase is unavailable
    return GlobalConfig({});
  }
});

/// Synchronous access to global config with fallback to defaults.
/// Use this in code paths that can't await (like scoring functions).
GlobalConfig getGlobalConfigSync(ProviderContainer? container) {
  if (container == null) return GlobalConfig({});
  try {
    final asyncValue = container.read(globalConfigProvider);
    return asyncValue.value ?? GlobalConfig({});
  } catch (_) {
    return GlobalConfig({});
  }
}
