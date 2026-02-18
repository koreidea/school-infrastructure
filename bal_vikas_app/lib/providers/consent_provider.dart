import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../services/database_service.dart';
import '../services/audit_service.dart';

/// Manages guardian consent state per child.
///
/// State: Map<childRemoteId, hasActiveConsent>
final consentProvider =
    AsyncNotifierProvider<ConsentNotifier, Map<int, bool>>(() {
  return ConsentNotifier();
});

class ConsentNotifier extends AsyncNotifier<Map<int, bool>> {
  @override
  Future<Map<int, bool>> build() async {
    return _loadConsentMap();
  }

  Future<Map<int, bool>> _loadConsentMap() async {
    final dao = DatabaseService.db.dpdpDao;
    // Get all active consents and build map
    final allChildren = await DatabaseService.db.childrenDao.getAllChildren();
    final consentMap = <int, bool>{};
    for (final child in allChildren) {
      if (child.remoteId != null) {
        final consent =
            await dao.getActiveConsentForChild(child.remoteId!);
        consentMap[child.remoteId!] = consent != null;
      }
    }
    return consentMap;
  }

  /// Check if a child has active consent.
  bool hasConsent(int childRemoteId) {
    return state.value?[childRemoteId] ?? false;
  }

  /// Save a new consent record.
  Future<void> saveConsent({
    required int childRemoteId,
    required String guardianName,
    required String guardianRelation,
    String? guardianPhone,
    required String consentPurpose,
    required String collectedByUserId,
    required String collectedByRole,
    String? digitalSignatureBase64,
    required String languageUsed,
    String? childName,
  }) async {
    final localId =
        await DatabaseService.db.dpdpDao.insertConsent(LocalConsentsCompanion(
      childRemoteId: Value(childRemoteId),
      guardianName: Value(guardianName),
      guardianRelation: Value(guardianRelation),
      guardianPhone: Value(guardianPhone),
      consentPurpose: Value(consentPurpose),
      consentGiven: const Value(true),
      digitalSignatureBase64: Value(digitalSignatureBase64),
      collectedByUserId: Value(collectedByUserId),
      collectedByRole: Value(collectedByRole),
      languageUsed: Value(languageUsed),
    ));

    // Enqueue sync
    await DatabaseService.db.syncQueueDao.enqueue(
      entityType: 'consent',
      entityLocalId: localId,
      operation: 'insert',
      priority: 3,
    );

    // Log the consent collection event
    AuditService.log(
      action: 'record_consent',
      entityType: 'consent',
      entityId: childRemoteId,
      entityName: childName,
      details: {
        'guardian_name': guardianName,
        'guardian_relation': guardianRelation,
        'purpose': consentPurpose,
      },
    );

    // Update state
    final current = Map<int, bool>.from(state.value ?? {});
    current[childRemoteId] = true;
    state = AsyncValue.data(current);
  }

  /// Revoke consent for a child.
  Future<void> revokeConsent(int childRemoteId, String reason) async {
    final consent = await DatabaseService.db.dpdpDao
        .getActiveConsentForChild(childRemoteId);
    if (consent != null) {
      await DatabaseService.db.dpdpDao.revokeConsent(consent.id, reason);
    }

    AuditService.log(
      action: 'revoke_consent',
      entityType: 'consent',
      entityId: childRemoteId,
      details: {'reason': reason},
    );

    final current = Map<int, bool>.from(state.value ?? {});
    current[childRemoteId] = false;
    state = AsyncValue.data(current);
  }

  /// Get consent rate: consented / total children.
  Future<double> getConsentRate() async {
    final consentedCount =
        await DatabaseService.db.dpdpDao.getConsentedChildrenCount();
    final allChildren =
        await DatabaseService.db.childrenDao.getAllChildren();
    if (allChildren.isEmpty) return 0.0;
    return consentedCount / allChildren.length;
  }
}

/// Quick provider to check consent for a specific child.
final childConsentProvider =
    FutureProvider.family<bool, int>((ref, childRemoteId) async {
  final consent = await DatabaseService.db.dpdpDao
      .getActiveConsentForChild(childRemoteId);
  return consent != null;
});
