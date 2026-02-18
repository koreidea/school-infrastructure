// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_dao.dart';

// ignore_for_file: type=lint
mixin _$ReferralDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalReferralsTable get localReferrals => attachedDatabase.localReferrals;
  ReferralDaoManager get managers => ReferralDaoManager(this);
}

class ReferralDaoManager {
  final _$ReferralDaoMixin _db;
  ReferralDaoManager(this._db);
  $$LocalReferralsTableTableManager get localReferrals =>
      $$LocalReferralsTableTableManager(
          _db.attachedDatabase, _db.localReferrals);
}
