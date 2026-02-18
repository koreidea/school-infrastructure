import 'package:drift/drift.dart';
import 'database_service.dart';
import '../database/app_database.dart';
import '../providers/admin_global_config_provider.dart';

/// Referral decision logic based on the ECD Challenge dataset rules.
///
/// Rules (all configurable via GlobalConfig):
/// - High Risk (any trend) → Priority referral to RBSK/DEIC
/// - Medium Risk + Worsening → Close monitoring + caregiver counselling
/// - Low/Medium Stable or Improving → Routine monitoring at Anganwadi level
class ReferralService {
  /// Auto-create referrals after a screening result is saved.
  /// Called from screening_results_storage.dart after persisting to Drift.
  /// [config] provides admin-configurable referral rules.
  static Future<void> evaluateAndCreateReferrals({
    required int childRemoteId,
    required int screeningResultLocalId,
    required String baselineCategory,
    required int numDelays,
    required String autismRisk,
    required String adhdRisk,
    required String behaviorRisk,
    required String assessmentCycle,
    String? conductedByUserId,
    GlobalConfig? config,
  }) async {
    final db = DatabaseService.db;
    final highAuto = config?.referralHighAuto ?? true;
    final medFollowupCheck = config?.referralMediumFollowupCheck ?? true;

    // Determine if referral is needed
    if (highAuto && baselineCategory == 'High') {
      // High risk → auto-create priority referral
      final reason = _determineReferralReason(
        numDelays: numDelays,
        autismRisk: autismRisk,
        adhdRisk: adhdRisk,
        behaviorRisk: behaviorRisk,
        config: config,
      );
      final type = _determineReferralType(reason, config: config);

      final referralLocalId = await db.referralDao.insertReferral(
        LocalReferralsCompanion.insert(
          childRemoteId: Value(childRemoteId),
          screeningResultLocalId: Value(screeningResultLocalId),
          referralTriggered: const Value(true),
          referralType: Value(type),
          referralReason: Value(reason),
          referralStatus: const Value('Pending'),
          referredBy: Value(conductedByUserId),
          referredDate: Value(DateTime.now().toIso8601String().split('T')[0]),
        ),
      );
      await db.syncQueueDao.enqueue(
        entityType: 'referral',
        entityLocalId: referralLocalId,
        operation: 'insert',
        priority: 3,
      );
    } else if (medFollowupCheck && baselineCategory == 'Medium' && assessmentCycle == 'Follow-up') {
      // Medium risk on follow-up → check if worsening
      final previousResult =
          await db.screeningDao.getLatestResultForChildByRemoteId(childRemoteId);
      if (previousResult != null &&
          _isWorsening(previousResult.baselineCategory, baselineCategory)) {
        final reason = _determineReferralReason(
          numDelays: numDelays,
          autismRisk: autismRisk,
          adhdRisk: adhdRisk,
          behaviorRisk: behaviorRisk,
          config: config,
        );

        final referralLocalId = await db.referralDao.insertReferral(
          LocalReferralsCompanion.insert(
            childRemoteId: Value(childRemoteId),
            screeningResultLocalId: Value(screeningResultLocalId),
            referralTriggered: const Value(true),
            referralType: Value(config?.referralTypeEnvironment ?? 'AWW_INTERVENTION'),
            referralReason: Value(reason),
            referralStatus: const Value('Pending'),
            referredBy: Value(conductedByUserId),
            referredDate: Value(DateTime.now().toIso8601String().split('T')[0]),
          ),
        );
        await db.syncQueueDao.enqueue(
          entityType: 'referral',
          entityLocalId: referralLocalId,
          operation: 'insert',
          priority: 3,
        );
      }
    }
    // Low/Medium stable → routine monitoring, no referral created
  }

  /// Determine the primary reason for referral based on risk factors.
  /// Uses configurable priority order from GlobalConfig.
  static String _determineReferralReason({
    required int numDelays,
    required String autismRisk,
    required String adhdRisk,
    required String behaviorRisk,
    GlobalConfig? config,
  }) {
    final priority = config?.referralReasonPriority ??
        ['AUTISM', 'ADHD', 'GDD', 'BEHAVIOUR', 'DOMAIN_DELAY'];
    final gddDelayCount = config?.referralGddDelayCount ?? 2;

    for (final reason in priority) {
      switch (reason) {
        case 'AUTISM':
          if (autismRisk == 'High') return 'AUTISM';
        case 'ADHD':
          if (adhdRisk == 'High') return 'ADHD';
        case 'GDD':
          if (numDelays >= gddDelayCount) return 'GDD';
        case 'BEHAVIOUR':
          if (behaviorRisk == 'High') return 'BEHAVIOUR';
        case 'DOMAIN_DELAY':
          if (numDelays >= 1) return 'DOMAIN_DELAY';
      }
    }
    return 'GDD'; // fallback
  }

  /// Determine the referral type based on reason.
  /// Uses configurable type mapping from GlobalConfig.
  static String _determineReferralType(String reason, {GlobalConfig? config}) {
    switch (reason) {
      case 'AUTISM':
        return config?.referralTypeAutism ?? 'DEIC';
      case 'GDD':
        return config?.referralTypeGdd ?? 'DEIC';
      case 'ADHD':
        return config?.referralTypeAdhd ?? 'RBSK';
      case 'BEHAVIOUR':
        return config?.referralTypeBehaviour ?? 'RBSK';
      case 'ENVIRONMENT':
        return config?.referralTypeEnvironment ?? 'AWW_INTERVENTION';
      case 'DOMAIN_DELAY':
        return config?.referralTypeDomainDelay ?? 'PHC';
      default:
        return 'PHC';
    }
  }

  /// Check if the child's risk has worsened compared to previous assessment
  static bool _isWorsening(String previousCategory, String currentCategory) {
    const rankMap = {'Low': 0, 'Medium': 1, 'High': 2};
    final prev = rankMap[previousCategory] ?? 0;
    final curr = rankMap[currentCategory] ?? 0;
    return curr > prev;
  }
}
