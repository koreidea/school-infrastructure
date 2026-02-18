// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalChildrenTable extends LocalChildren
    with TableInfo<$LocalChildrenTable, LocalChildrenData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalChildrenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
      'local_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _childUniqueIdMeta =
      const VerificationMeta('childUniqueId');
  @override
  late final GeneratedColumn<String> childUniqueId = GeneratedColumn<String>(
      'child_unique_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dobMeta = const VerificationMeta('dob');
  @override
  late final GeneratedColumn<DateTime> dob = GeneratedColumn<DateTime>(
      'dob', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _awwIdMeta = const VerificationMeta('awwId');
  @override
  late final GeneratedColumn<String> awwId = GeneratedColumn<String>(
      'aww_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _awcIdMeta = const VerificationMeta('awcId');
  @override
  late final GeneratedColumn<int> awcId = GeneratedColumn<int>(
      'awc_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        remoteId,
        childUniqueId,
        name,
        dob,
        gender,
        parentId,
        awwId,
        awcId,
        photoUrl,
        isActive,
        lastSyncedAt,
        localUpdatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_children';
  @override
  VerificationContext validateIntegrity(Insertable<LocalChildrenData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('child_unique_id')) {
      context.handle(
          _childUniqueIdMeta,
          childUniqueId.isAcceptableOrUnknown(
              data['child_unique_id']!, _childUniqueIdMeta));
    } else if (isInserting) {
      context.missing(_childUniqueIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dob')) {
      context.handle(
          _dobMeta, dob.isAcceptableOrUnknown(data['dob']!, _dobMeta));
    } else if (isInserting) {
      context.missing(_dobMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('aww_id')) {
      context.handle(
          _awwIdMeta, awwId.isAcceptableOrUnknown(data['aww_id']!, _awwIdMeta));
    }
    if (data.containsKey('awc_id')) {
      context.handle(
          _awcIdMeta, awcId.isAcceptableOrUnknown(data['awc_id']!, _awcIdMeta));
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  LocalChildrenData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalChildrenData(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}remote_id']),
      childUniqueId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}child_unique_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      dob: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}dob'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parent_id']),
      awwId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aww_id']),
      awcId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}awc_id']),
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
    );
  }

  @override
  $LocalChildrenTable createAlias(String alias) {
    return $LocalChildrenTable(attachedDatabase, alias);
  }
}

class LocalChildrenData extends DataClass
    implements Insertable<LocalChildrenData> {
  final int localId;
  final int? remoteId;
  final String childUniqueId;
  final String name;
  final DateTime dob;
  final String gender;
  final int? parentId;
  final String? awwId;
  final int? awcId;
  final String? photoUrl;
  final bool isActive;
  final DateTime? lastSyncedAt;
  final DateTime localUpdatedAt;
  const LocalChildrenData(
      {required this.localId,
      this.remoteId,
      required this.childUniqueId,
      required this.name,
      required this.dob,
      required this.gender,
      this.parentId,
      this.awwId,
      this.awcId,
      this.photoUrl,
      required this.isActive,
      this.lastSyncedAt,
      required this.localUpdatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    map['child_unique_id'] = Variable<String>(childUniqueId);
    map['name'] = Variable<String>(name);
    map['dob'] = Variable<DateTime>(dob);
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    if (!nullToAbsent || awwId != null) {
      map['aww_id'] = Variable<String>(awwId);
    }
    if (!nullToAbsent || awcId != null) {
      map['awc_id'] = Variable<int>(awcId);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    return map;
  }

  LocalChildrenCompanion toCompanion(bool nullToAbsent) {
    return LocalChildrenCompanion(
      localId: Value(localId),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      childUniqueId: Value(childUniqueId),
      name: Value(name),
      dob: Value(dob),
      gender: Value(gender),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      awwId:
          awwId == null && nullToAbsent ? const Value.absent() : Value(awwId),
      awcId:
          awcId == null && nullToAbsent ? const Value.absent() : Value(awcId),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      isActive: Value(isActive),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      localUpdatedAt: Value(localUpdatedAt),
    );
  }

  factory LocalChildrenData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalChildrenData(
      localId: serializer.fromJson<int>(json['localId']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      childUniqueId: serializer.fromJson<String>(json['childUniqueId']),
      name: serializer.fromJson<String>(json['name']),
      dob: serializer.fromJson<DateTime>(json['dob']),
      gender: serializer.fromJson<String>(json['gender']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      awwId: serializer.fromJson<String?>(json['awwId']),
      awcId: serializer.fromJson<int?>(json['awcId']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'remoteId': serializer.toJson<int?>(remoteId),
      'childUniqueId': serializer.toJson<String>(childUniqueId),
      'name': serializer.toJson<String>(name),
      'dob': serializer.toJson<DateTime>(dob),
      'gender': serializer.toJson<String>(gender),
      'parentId': serializer.toJson<int?>(parentId),
      'awwId': serializer.toJson<String?>(awwId),
      'awcId': serializer.toJson<int?>(awcId),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'isActive': serializer.toJson<bool>(isActive),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
    };
  }

  LocalChildrenData copyWith(
          {int? localId,
          Value<int?> remoteId = const Value.absent(),
          String? childUniqueId,
          String? name,
          DateTime? dob,
          String? gender,
          Value<int?> parentId = const Value.absent(),
          Value<String?> awwId = const Value.absent(),
          Value<int?> awcId = const Value.absent(),
          Value<String?> photoUrl = const Value.absent(),
          bool? isActive,
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          DateTime? localUpdatedAt}) =>
      LocalChildrenData(
        localId: localId ?? this.localId,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        childUniqueId: childUniqueId ?? this.childUniqueId,
        name: name ?? this.name,
        dob: dob ?? this.dob,
        gender: gender ?? this.gender,
        parentId: parentId.present ? parentId.value : this.parentId,
        awwId: awwId.present ? awwId.value : this.awwId,
        awcId: awcId.present ? awcId.value : this.awcId,
        photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
        isActive: isActive ?? this.isActive,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      );
  LocalChildrenData copyWithCompanion(LocalChildrenCompanion data) {
    return LocalChildrenData(
      localId: data.localId.present ? data.localId.value : this.localId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      childUniqueId: data.childUniqueId.present
          ? data.childUniqueId.value
          : this.childUniqueId,
      name: data.name.present ? data.name.value : this.name,
      dob: data.dob.present ? data.dob.value : this.dob,
      gender: data.gender.present ? data.gender.value : this.gender,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      awwId: data.awwId.present ? data.awwId.value : this.awwId,
      awcId: data.awcId.present ? data.awcId.value : this.awcId,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalChildrenData(')
          ..write('localId: $localId, ')
          ..write('remoteId: $remoteId, ')
          ..write('childUniqueId: $childUniqueId, ')
          ..write('name: $name, ')
          ..write('dob: $dob, ')
          ..write('gender: $gender, ')
          ..write('parentId: $parentId, ')
          ..write('awwId: $awwId, ')
          ..write('awcId: $awcId, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('isActive: $isActive, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      localId,
      remoteId,
      childUniqueId,
      name,
      dob,
      gender,
      parentId,
      awwId,
      awcId,
      photoUrl,
      isActive,
      lastSyncedAt,
      localUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalChildrenData &&
          other.localId == this.localId &&
          other.remoteId == this.remoteId &&
          other.childUniqueId == this.childUniqueId &&
          other.name == this.name &&
          other.dob == this.dob &&
          other.gender == this.gender &&
          other.parentId == this.parentId &&
          other.awwId == this.awwId &&
          other.awcId == this.awcId &&
          other.photoUrl == this.photoUrl &&
          other.isActive == this.isActive &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.localUpdatedAt == this.localUpdatedAt);
}

class LocalChildrenCompanion extends UpdateCompanion<LocalChildrenData> {
  final Value<int> localId;
  final Value<int?> remoteId;
  final Value<String> childUniqueId;
  final Value<String> name;
  final Value<DateTime> dob;
  final Value<String> gender;
  final Value<int?> parentId;
  final Value<String?> awwId;
  final Value<int?> awcId;
  final Value<String?> photoUrl;
  final Value<bool> isActive;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime> localUpdatedAt;
  const LocalChildrenCompanion({
    this.localId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.childUniqueId = const Value.absent(),
    this.name = const Value.absent(),
    this.dob = const Value.absent(),
    this.gender = const Value.absent(),
    this.parentId = const Value.absent(),
    this.awwId = const Value.absent(),
    this.awcId = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
  });
  LocalChildrenCompanion.insert({
    this.localId = const Value.absent(),
    this.remoteId = const Value.absent(),
    required String childUniqueId,
    required String name,
    required DateTime dob,
    required String gender,
    this.parentId = const Value.absent(),
    this.awwId = const Value.absent(),
    this.awcId = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
  })  : childUniqueId = Value(childUniqueId),
        name = Value(name),
        dob = Value(dob),
        gender = Value(gender);
  static Insertable<LocalChildrenData> custom({
    Expression<int>? localId,
    Expression<int>? remoteId,
    Expression<String>? childUniqueId,
    Expression<String>? name,
    Expression<DateTime>? dob,
    Expression<String>? gender,
    Expression<int>? parentId,
    Expression<String>? awwId,
    Expression<int>? awcId,
    Expression<String>? photoUrl,
    Expression<bool>? isActive,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? localUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (remoteId != null) 'remote_id': remoteId,
      if (childUniqueId != null) 'child_unique_id': childUniqueId,
      if (name != null) 'name': name,
      if (dob != null) 'dob': dob,
      if (gender != null) 'gender': gender,
      if (parentId != null) 'parent_id': parentId,
      if (awwId != null) 'aww_id': awwId,
      if (awcId != null) 'awc_id': awcId,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (isActive != null) 'is_active': isActive,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
    });
  }

  LocalChildrenCompanion copyWith(
      {Value<int>? localId,
      Value<int?>? remoteId,
      Value<String>? childUniqueId,
      Value<String>? name,
      Value<DateTime>? dob,
      Value<String>? gender,
      Value<int?>? parentId,
      Value<String?>? awwId,
      Value<int?>? awcId,
      Value<String?>? photoUrl,
      Value<bool>? isActive,
      Value<DateTime?>? lastSyncedAt,
      Value<DateTime>? localUpdatedAt}) {
    return LocalChildrenCompanion(
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
      childUniqueId: childUniqueId ?? this.childUniqueId,
      name: name ?? this.name,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      parentId: parentId ?? this.parentId,
      awwId: awwId ?? this.awwId,
      awcId: awcId ?? this.awcId,
      photoUrl: photoUrl ?? this.photoUrl,
      isActive: isActive ?? this.isActive,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (childUniqueId.present) {
      map['child_unique_id'] = Variable<String>(childUniqueId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dob.present) {
      map['dob'] = Variable<DateTime>(dob.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (awwId.present) {
      map['aww_id'] = Variable<String>(awwId.value);
    }
    if (awcId.present) {
      map['awc_id'] = Variable<int>(awcId.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalChildrenCompanion(')
          ..write('localId: $localId, ')
          ..write('remoteId: $remoteId, ')
          ..write('childUniqueId: $childUniqueId, ')
          ..write('name: $name, ')
          ..write('dob: $dob, ')
          ..write('gender: $gender, ')
          ..write('parentId: $parentId, ')
          ..write('awwId: $awwId, ')
          ..write('awcId: $awcId, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('isActive: $isActive, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalScreeningSessionsTable extends LocalScreeningSessions
    with TableInfo<$LocalScreeningSessionsTable, LocalScreeningSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalScreeningSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
      'local_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _childLocalIdMeta =
      const VerificationMeta('childLocalId');
  @override
  late final GeneratedColumn<int> childLocalId = GeneratedColumn<int>(
      'child_local_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _childRemoteIdMeta =
      const VerificationMeta('childRemoteId');
  @override
  late final GeneratedColumn<int> childRemoteId = GeneratedColumn<int>(
      'child_remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _conductedByMeta =
      const VerificationMeta('conductedBy');
  @override
  late final GeneratedColumn<String> conductedBy = GeneratedColumn<String>(
      'conducted_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assessmentDateMeta =
      const VerificationMeta('assessmentDate');
  @override
  late final GeneratedColumn<String> assessmentDate = GeneratedColumn<String>(
      'assessment_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _childAgeMonthsMeta =
      const VerificationMeta('childAgeMonths');
  @override
  late final GeneratedColumn<int> childAgeMonths = GeneratedColumn<int>(
      'child_age_months', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('in_progress'));
  static const VerificationMeta _deviceSessionIdMeta =
      const VerificationMeta('deviceSessionId');
  @override
  late final GeneratedColumn<String> deviceSessionId = GeneratedColumn<String>(
      'device_session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        remoteId,
        childLocalId,
        childRemoteId,
        conductedBy,
        assessmentDate,
        childAgeMonths,
        status,
        deviceSessionId,
        createdAt,
        completedAt,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_screening_sessions';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalScreeningSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('child_local_id')) {
      context.handle(
          _childLocalIdMeta,
          childLocalId.isAcceptableOrUnknown(
              data['child_local_id']!, _childLocalIdMeta));
    }
    if (data.containsKey('child_remote_id')) {
      context.handle(
          _childRemoteIdMeta,
          childRemoteId.isAcceptableOrUnknown(
              data['child_remote_id']!, _childRemoteIdMeta));
    }
    if (data.containsKey('conducted_by')) {
      context.handle(
          _conductedByMeta,
          conductedBy.isAcceptableOrUnknown(
              data['conducted_by']!, _conductedByMeta));
    } else if (isInserting) {
      context.missing(_conductedByMeta);
    }
    if (data.containsKey('assessment_date')) {
      context.handle(
          _assessmentDateMeta,
          assessmentDate.isAcceptableOrUnknown(
              data['assessment_date']!, _assessmentDateMeta));
    } else if (isInserting) {
      context.missing(_assessmentDateMeta);
    }
    if (data.containsKey('child_age_months')) {
      context.handle(
          _childAgeMonthsMeta,
          childAgeMonths.isAcceptableOrUnknown(
              data['child_age_months']!, _childAgeMonthsMeta));
    } else if (isInserting) {
      context.missing(_childAgeMonthsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('device_session_id')) {
      context.handle(
          _deviceSessionIdMeta,
          deviceSessionId.isAcceptableOrUnknown(
              data['device_session_id']!, _deviceSessionIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  LocalScreeningSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalScreeningSession(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}remote_id']),
      childLocalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}child_local_id']),
      childRemoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}child_remote_id']),
      conductedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}conducted_by'])!,
      assessmentDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}assessment_date'])!,
      childAgeMonths: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}child_age_months'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      deviceSessionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}device_session_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $LocalScreeningSessionsTable createAlias(String alias) {
    return $LocalScreeningSessionsTable(attachedDatabase, alias);
  }
}

class LocalScreeningSession extends DataClass
    implements Insertable<LocalScreeningSession> {
  final int localId;
  final int? remoteId;
  final int? childLocalId;
  final int? childRemoteId;
  final String conductedBy;
  final String assessmentDate;
  final int childAgeMonths;
  final String status;
  final String? deviceSessionId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? syncedAt;
  const LocalScreeningSession(
      {required this.localId,
      this.remoteId,
      this.childLocalId,
      this.childRemoteId,
      required this.conductedBy,
      required this.assessmentDate,
      required this.childAgeMonths,
      required this.status,
      this.deviceSessionId,
      required this.createdAt,
      this.completedAt,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    if (!nullToAbsent || childLocalId != null) {
      map['child_local_id'] = Variable<int>(childLocalId);
    }
    if (!nullToAbsent || childRemoteId != null) {
      map['child_remote_id'] = Variable<int>(childRemoteId);
    }
    map['conducted_by'] = Variable<String>(conductedBy);
    map['assessment_date'] = Variable<String>(assessmentDate);
    map['child_age_months'] = Variable<int>(childAgeMonths);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || deviceSessionId != null) {
      map['device_session_id'] = Variable<String>(deviceSessionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  LocalScreeningSessionsCompanion toCompanion(bool nullToAbsent) {
    return LocalScreeningSessionsCompanion(
      localId: Value(localId),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      childLocalId: childLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(childLocalId),
      childRemoteId: childRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(childRemoteId),
      conductedBy: Value(conductedBy),
      assessmentDate: Value(assessmentDate),
      childAgeMonths: Value(childAgeMonths),
      status: Value(status),
      deviceSessionId: deviceSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceSessionId),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalScreeningSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalScreeningSession(
      localId: serializer.fromJson<int>(json['localId']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      childLocalId: serializer.fromJson<int?>(json['childLocalId']),
      childRemoteId: serializer.fromJson<int?>(json['childRemoteId']),
      conductedBy: serializer.fromJson<String>(json['conductedBy']),
      assessmentDate: serializer.fromJson<String>(json['assessmentDate']),
      childAgeMonths: serializer.fromJson<int>(json['childAgeMonths']),
      status: serializer.fromJson<String>(json['status']),
      deviceSessionId: serializer.fromJson<String?>(json['deviceSessionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'remoteId': serializer.toJson<int?>(remoteId),
      'childLocalId': serializer.toJson<int?>(childLocalId),
      'childRemoteId': serializer.toJson<int?>(childRemoteId),
      'conductedBy': serializer.toJson<String>(conductedBy),
      'assessmentDate': serializer.toJson<String>(assessmentDate),
      'childAgeMonths': serializer.toJson<int>(childAgeMonths),
      'status': serializer.toJson<String>(status),
      'deviceSessionId': serializer.toJson<String?>(deviceSessionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalScreeningSession copyWith(
          {int? localId,
          Value<int?> remoteId = const Value.absent(),
          Value<int?> childLocalId = const Value.absent(),
          Value<int?> childRemoteId = const Value.absent(),
          String? conductedBy,
          String? assessmentDate,
          int? childAgeMonths,
          String? status,
          Value<String?> deviceSessionId = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      LocalScreeningSession(
        localId: localId ?? this.localId,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        childLocalId:
            childLocalId.present ? childLocalId.value : this.childLocalId,
        childRemoteId:
            childRemoteId.present ? childRemoteId.value : this.childRemoteId,
        conductedBy: conductedBy ?? this.conductedBy,
        assessmentDate: assessmentDate ?? this.assessmentDate,
        childAgeMonths: childAgeMonths ?? this.childAgeMonths,
        status: status ?? this.status,
        deviceSessionId: deviceSessionId.present
            ? deviceSessionId.value
            : this.deviceSessionId,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  LocalScreeningSession copyWithCompanion(
      LocalScreeningSessionsCompanion data) {
    return LocalScreeningSession(
      localId: data.localId.present ? data.localId.value : this.localId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      childLocalId: data.childLocalId.present
          ? data.childLocalId.value
          : this.childLocalId,
      childRemoteId: data.childRemoteId.present
          ? data.childRemoteId.value
          : this.childRemoteId,
      conductedBy:
          data.conductedBy.present ? data.conductedBy.value : this.conductedBy,
      assessmentDate: data.assessmentDate.present
          ? data.assessmentDate.value
          : this.assessmentDate,
      childAgeMonths: data.childAgeMonths.present
          ? data.childAgeMonths.value
          : this.childAgeMonths,
      status: data.status.present ? data.status.value : this.status,
      deviceSessionId: data.deviceSessionId.present
          ? data.deviceSessionId.value
          : this.deviceSessionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalScreeningSession(')
          ..write('localId: $localId, ')
          ..write('remoteId: $remoteId, ')
          ..write('childLocalId: $childLocalId, ')
          ..write('childRemoteId: $childRemoteId, ')
          ..write('conductedBy: $conductedBy, ')
          ..write('assessmentDate: $assessmentDate, ')
          ..write('childAgeMonths: $childAgeMonths, ')
          ..write('status: $status, ')
          ..write('deviceSessionId: $deviceSessionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      localId,
      remoteId,
      childLocalId,
      childRemoteId,
      conductedBy,
      assessmentDate,
      childAgeMonths,
      status,
      deviceSessionId,
      createdAt,
      completedAt,
      syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalScreeningSession &&
          other.localId == this.localId &&
          other.remoteId == this.remoteId &&
          other.childLocalId == this.childLocalId &&
          other.childRemoteId == this.childRemoteId &&
          other.conductedBy == this.conductedBy &&
          other.assessmentDate == this.assessmentDate &&
          other.childAgeMonths == this.childAgeMonths &&
          other.status == this.status &&
          other.deviceSessionId == this.deviceSessionId &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.syncedAt == this.syncedAt);
}

class LocalScreeningSessionsCompanion
    extends UpdateCompanion<LocalScreeningSession> {
  final Value<int> localId;
  final Value<int?> remoteId;
  final Value<int?> childLocalId;
  final Value<int?> childRemoteId;
  final Value<String> conductedBy;
  final Value<String> assessmentDate;
  final Value<int> childAgeMonths;
  final Value<String> status;
  final Value<String?> deviceSessionId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> syncedAt;
  const LocalScreeningSessionsCompanion({
    this.localId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.childLocalId = const Value.absent(),
    this.childRemoteId = const Value.absent(),
    this.conductedBy = const Value.absent(),
    this.assessmentDate = const Value.absent(),
    this.childAgeMonths = const Value.absent(),
    this.status = const Value.absent(),
    this.deviceSessionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  LocalScreeningSessionsCompanion.insert({
    this.localId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.childLocalId = const Value.absent(),
    this.childRemoteId = const Value.absent(),
    required String conductedBy,
    required String assessmentDate,
    required int childAgeMonths,
    this.status = const Value.absent(),
    this.deviceSessionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  })  : conductedBy = Value(conductedBy),
        assessmentDate = Value(assessmentDate),
        childAgeMonths = Value(childAgeMonths);
  static Insertable<LocalScreeningSession> custom({
    Expression<int>? localId,
    Expression<int>? remoteId,
    Expression<int>? childLocalId,
    Expression<int>? childRemoteId,
    Expression<String>? conductedBy,
    Expression<String>? assessmentDate,
    Expression<int>? childAgeMonths,
    Expression<String>? status,
    Expression<String>? deviceSessionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (remoteId != null) 'remote_id': remoteId,
      if (childLocalId != null) 'child_local_id': childLocalId,
      if (childRemoteId != null) 'child_remote_id': childRemoteId,
      if (conductedBy != null) 'conducted_by': conductedBy,
      if (assessmentDate != null) 'assessment_date': assessmentDate,
      if (childAgeMonths != null) 'child_age_months': childAgeMonths,
      if (status != null) 'status': status,
      if (deviceSessionId != null) 'device_session_id': deviceSessionId,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  LocalScreeningSessionsCompanion copyWith(
      {Value<int>? localId,
      Value<int?>? remoteId,
      Value<int?>? childLocalId,
      Value<int?>? childRemoteId,
      Value<String>? conductedBy,
      Value<String>? assessmentDate,
      Value<int>? childAgeMonths,
      Value<String>? status,
      Value<String?>? deviceSessionId,
      Value<DateTime>? createdAt,
      Value<DateTime?>? completedAt,
      Value<DateTime?>? syncedAt}) {
    return LocalScreeningSessionsCompanion(
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
      childLocalId: childLocalId ?? this.childLocalId,
      childRemoteId: childRemoteId ?? this.childRemoteId,
      conductedBy: conductedBy ?? this.conductedBy,
      assessmentDate: assessmentDate ?? this.assessmentDate,
      childAgeMonths: childAgeMonths ?? this.childAgeMonths,
      status: status ?? this.status,
      deviceSessionId: deviceSessionId ?? this.deviceSessionId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (childLocalId.present) {
      map['child_local_id'] = Variable<int>(childLocalId.value);
    }
    if (childRemoteId.present) {
      map['child_remote_id'] = Variable<int>(childRemoteId.value);
    }
    if (conductedBy.present) {
      map['conducted_by'] = Variable<String>(conductedBy.value);
    }
    if (assessmentDate.present) {
      map['assessment_date'] = Variable<String>(assessmentDate.value);
    }
    if (childAgeMonths.present) {
      map['child_age_months'] = Variable<int>(childAgeMonths.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (deviceSessionId.present) {
      map['device_session_id'] = Variable<String>(deviceSessionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalScreeningSessionsCompanion(')
          ..write('localId: $localId, ')
          ..write('remoteId: $remoteId, ')
          ..write('childLocalId: $childLocalId, ')
          ..write('childRemoteId: $childRemoteId, ')
          ..write('conductedBy: $conductedBy, ')
          ..write('assessmentDate: $assessmentDate, ')
          ..write('childAgeMonths: $childAgeMonths, ')
          ..write('status: $status, ')
          ..write('deviceSessionId: $deviceSessionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalScreeningResponsesTable extends LocalScreeningResponses
    with TableInfo<$LocalScreeningResponsesTable, LocalScreeningResponse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalScreeningResponsesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionLocalIdMeta =
      const VerificationMeta('sessionLocalId');
  @override
  late final GeneratedColumn<int> sessionLocalId = GeneratedColumn<int>(
      'session_local_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _toolTypeMeta =
      const VerificationMeta('toolType');
  @override
  late final GeneratedColumn<String> toolType = GeneratedColumn<String>(
      'tool_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _responsesJsonMeta =
      const VerificationMeta('responsesJson');
  @override
  late final GeneratedColumn<String> responsesJson = GeneratedColumn<String>(
      'responses_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sessionLocalId, toolType, responsesJson, createdAt, syncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_screening_responses';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalScreeningResponse> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_local_id')) {
      context.handle(
          _sessionLocalIdMeta,
          sessionLocalId.isAcceptableOrUnknown(
              data['session_local_id']!, _sessionLocalIdMeta));
    } else if (isInserting) {
      context.missing(_sessionLocalIdMeta);
    }
    if (data.containsKey('tool_type')) {
      context.handle(_toolTypeMeta,
          toolType.isAcceptableOrUnknown(data['tool_type']!, _toolTypeMeta));
    } else if (isInserting) {
      context.missing(_toolTypeMeta);
    }
    if (data.containsKey('responses_json')) {
      context.handle(
          _responsesJsonMeta,
          responsesJson.isAcceptableOrUnknown(
              data['responses_json']!, _responsesJsonMeta));
    } else if (isInserting) {
      context.missing(_responsesJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalScreeningResponse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalScreeningResponse(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionLocalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_local_id'])!,
      toolType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tool_type'])!,
      responsesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}responses_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $LocalScreeningResponsesTable createAlias(String alias) {
    return $LocalScreeningResponsesTable(attachedDatabase, alias);
  }
}

class LocalScreeningResponse extends DataClass
    implements Insertable<LocalScreeningResponse> {
  final int id;
  final int sessionLocalId;
  final String toolType;
  final String responsesJson;
  final DateTime createdAt;
  final DateTime? syncedAt;
  const LocalScreeningResponse(
      {required this.id,
      required this.sessionLocalId,
      required this.toolType,
      required this.responsesJson,
      required this.createdAt,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_local_id'] = Variable<int>(sessionLocalId);
    map['tool_type'] = Variable<String>(toolType);
    map['responses_json'] = Variable<String>(responsesJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  LocalScreeningResponsesCompanion toCompanion(bool nullToAbsent) {
    return LocalScreeningResponsesCompanion(
      id: Value(id),
      sessionLocalId: Value(sessionLocalId),
      toolType: Value(toolType),
      responsesJson: Value(responsesJson),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalScreeningResponse.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalScreeningResponse(
      id: serializer.fromJson<int>(json['id']),
      sessionLocalId: serializer.fromJson<int>(json['sessionLocalId']),
      toolType: serializer.fromJson<String>(json['toolType']),
      responsesJson: serializer.fromJson<String>(json['responsesJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionLocalId': serializer.toJson<int>(sessionLocalId),
      'toolType': serializer.toJson<String>(toolType),
      'responsesJson': serializer.toJson<String>(responsesJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalScreeningResponse copyWith(
          {int? id,
          int? sessionLocalId,
          String? toolType,
          String? responsesJson,
          DateTime? createdAt,
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      LocalScreeningResponse(
        id: id ?? this.id,
        sessionLocalId: sessionLocalId ?? this.sessionLocalId,
        toolType: toolType ?? this.toolType,
        responsesJson: responsesJson ?? this.responsesJson,
        createdAt: createdAt ?? this.createdAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  LocalScreeningResponse copyWithCompanion(
      LocalScreeningResponsesCompanion data) {
    return LocalScreeningResponse(
      id: data.id.present ? data.id.value : this.id,
      sessionLocalId: data.sessionLocalId.present
          ? data.sessionLocalId.value
          : this.sessionLocalId,
      toolType: data.toolType.present ? data.toolType.value : this.toolType,
      responsesJson: data.responsesJson.present
          ? data.responsesJson.value
          : this.responsesJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalScreeningResponse(')
          ..write('id: $id, ')
          ..write('sessionLocalId: $sessionLocalId, ')
          ..write('toolType: $toolType, ')
          ..write('responsesJson: $responsesJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, sessionLocalId, toolType, responsesJson, createdAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalScreeningResponse &&
          other.id == this.id &&
          other.sessionLocalId == this.sessionLocalId &&
          other.toolType == this.toolType &&
          other.responsesJson == this.responsesJson &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class LocalScreeningResponsesCompanion
    extends UpdateCompanion<LocalScreeningResponse> {
  final Value<int> id;
  final Value<int> sessionLocalId;
  final Value<String> toolType;
  final Value<String> responsesJson;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  const LocalScreeningResponsesCompanion({
    this.id = const Value.absent(),
    this.sessionLocalId = const Value.absent(),
    this.toolType = const Value.absent(),
    this.responsesJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  LocalScreeningResponsesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionLocalId,
    required String toolType,
    required String responsesJson,
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  })  : sessionLocalId = Value(sessionLocalId),
        toolType = Value(toolType),
        responsesJson = Value(responsesJson);
  static Insertable<LocalScreeningResponse> custom({
    Expression<int>? id,
    Expression<int>? sessionLocalId,
    Expression<String>? toolType,
    Expression<String>? responsesJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionLocalId != null) 'session_local_id': sessionLocalId,
      if (toolType != null) 'tool_type': toolType,
      if (responsesJson != null) 'responses_json': responsesJson,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  LocalScreeningResponsesCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionLocalId,
      Value<String>? toolType,
      Value<String>? responsesJson,
      Value<DateTime>? createdAt,
      Value<DateTime?>? syncedAt}) {
    return LocalScreeningResponsesCompanion(
      id: id ?? this.id,
      sessionLocalId: sessionLocalId ?? this.sessionLocalId,
      toolType: toolType ?? this.toolType,
      responsesJson: responsesJson ?? this.responsesJson,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionLocalId.present) {
      map['session_local_id'] = Variable<int>(sessionLocalId.value);
    }
    if (toolType.present) {
      map['tool_type'] = Variable<String>(toolType.value);
    }
    if (responsesJson.present) {
      map['responses_json'] = Variable<String>(responsesJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalScreeningResponsesCompanion(')
          ..write('id: $id, ')
          ..write('sessionLocalId: $sessionLocalId, ')
          ..write('toolType: $toolType, ')
          ..write('responsesJson: $responsesJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalScreeningResultsTable extends LocalScreeningResults
    with TableInfo<$LocalScreeningResultsTable, LocalScreeningResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalScreeningResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionLocalIdMeta =
      const VerificationMeta('sessionLocalId');
  @override
  late final GeneratedColumn<int> sessionLocalId = GeneratedColumn<int>(
      'session_local_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sessionRemoteIdMeta =
      const VerificationMeta('sessionRemoteId');
  @override
  late final GeneratedColumn<int> sessionRemoteId = GeneratedColumn<int>(
      'session_remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _childLocalIdMeta =
      const VerificationMeta('childLocalId');
  @override
  late final GeneratedColumn<int> childLocalId = GeneratedColumn<int>(
      'child_local_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _childRemoteIdMeta =
      const VerificationMeta('childRemoteId');
  @override
  late final GeneratedColumn<int> childRemoteId = GeneratedColumn<int>(
      'child_remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _overallRiskMeta =
      const VerificationMeta('overallRisk');
  @override
  late final GeneratedColumn<String> overallRisk = GeneratedColumn<String>(
      'overall_risk', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _overallRiskTeMeta =
      const VerificationMeta('overallRiskTe');
  @override
  late final GeneratedColumn<String> overallRiskTe = GeneratedColumn<String>(
      'overall_risk_te', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _referralNeededMeta =
      const VerificationMeta('referralNeeded');
  @override
  late final GeneratedColumn<bool> referralNeeded = GeneratedColumn<bool>(
      'referral_needed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("referral_needed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _gmDqMeta = const VerificationMeta('gmDq');
  @override
  late final GeneratedColumn<double> gmDq = GeneratedColumn<double>(
      'gm_dq', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _fmDqMeta = const VerificationMeta('fmDq');
  @override
  late final GeneratedColumn<double> fmDq = GeneratedColumn<double>(
      'fm_dq', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _lcDqMeta = const VerificationMeta('lcDq');
  @override
  late final GeneratedColumn<double> lcDq = GeneratedColumn<double>(
      'lc_dq', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _cogDqMeta = const VerificationMeta('cogDq');
  @override
  late final GeneratedColumn<double> cogDq = GeneratedColumn<double>(
      'cog_dq', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _seDqMeta = const VerificationMeta('seDq');
  @override
  late final GeneratedColumn<double> seDq = GeneratedColumn<double>(
      'se_dq', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _compositeDqMeta =
      const VerificationMeta('compositeDq');
  @override
  late final GeneratedColumn<double> compositeDq = GeneratedColumn<double>(
      'composite_dq', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _toolResultsJsonMeta =
      const VerificationMeta('toolResultsJson');
  @override
  late final GeneratedColumn<String> toolResultsJson = GeneratedColumn<String>(
      'tool_results_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _concernsJsonMeta =
      const VerificationMeta('concernsJson');
  @override
  late final GeneratedColumn<String> concernsJson = GeneratedColumn<String>(
      'concerns_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _concernsTeJsonMeta =
      const VerificationMeta('concernsTeJson');
  @override
  late final GeneratedColumn<String> concernsTeJson = GeneratedColumn<String>(
      'concerns_te_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _toolsCompletedMeta =
      const VerificationMeta('toolsCompleted');
  @override
  late final GeneratedColumn<int> toolsCompleted = GeneratedColumn<int>(
      'tools_completed', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _toolsSkippedMeta =
      const VerificationMeta('toolsSkipped');
  @override
  late final GeneratedColumn<int> toolsSkipped = GeneratedColumn<int>(
      'tools_skipped', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _assessmentCycleMeta =
      const VerificationMeta('assessmentCycle');
  @override
  late final GeneratedColumn<String> assessmentCycle = GeneratedColumn<String>(
      'assessment_cycle', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Baseline'));
  static const VerificationMeta _baselineScoreMeta =
      const VerificationMeta('baselineScore');
  @override
  late final GeneratedColumn<int> baselineScore = GeneratedColumn<int>(
      'baseline_score', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _baselineCategoryMeta =
      const VerificationMeta('baselineCategory');
  @override
  late final GeneratedColumn<String> baselineCategory = GeneratedColumn<String>(
      'baseline_category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Low'));
  static const VerificationMeta _numDelaysMeta =
      const VerificationMeta('numDelays');
  @override
  late final GeneratedColumn<int> numDelays = GeneratedColumn<int>(
      'num_delays', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _autismRiskMeta =
      const VerificationMeta('autismRisk');
  @override
  late final GeneratedColumn<String> autismRisk = GeneratedColumn<String>(
      'autism_risk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Low'));
  static const VerificationMeta _adhdRiskMeta =
      const VerificationMeta('adhdRisk');
  @override
  late final GeneratedColumn<String> adhdRisk = GeneratedColumn<String>(
      'adhd_risk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Low'));
  static const VerificationMeta _behaviorRiskMeta =
      const VerificationMeta('behaviorRisk');
  @override
  late final GeneratedColumn<String> behaviorRisk = GeneratedColumn<String>(
      'behavior_risk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Low'));
  static const VerificationMeta _behaviorScoreMeta =
      const VerificationMeta('behaviorScore');
  @override
  late final GeneratedColumn<int> behaviorScore = GeneratedColumn<int>(
      'behavior_score', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _predictedRiskScoreMeta =
      const VerificationMeta('predictedRiskScore');
  @override
  late final GeneratedColumn<double> predictedRiskScore =
      GeneratedColumn<double>('predicted_risk_score', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _predictedRiskCategoryMeta =
      const VerificationMeta('predictedRiskCategory');
  @override
  late final GeneratedColumn<String> predictedRiskCategory =
      GeneratedColumn<String>('predicted_risk_category', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _riskTrendMeta =
      const VerificationMeta('riskTrend');
  @override
  late final GeneratedColumn<String> riskTrend = GeneratedColumn<String>(
      'risk_trend', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _topRiskFactorsJsonMeta =
      const VerificationMeta('topRiskFactorsJson');
  @override
  late final GeneratedColumn<String> topRiskFactorsJson =
      GeneratedColumn<String>('top_risk_factors_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionLocalId,
        sessionRemoteId,
        childLocalId,
        childRemoteId,
        overallRisk,
        overallRiskTe,
        referralNeeded,
        gmDq,
        fmDq,
        lcDq,
        cogDq,
        seDq,
        compositeDq,
        toolResultsJson,
        concernsJson,
        concernsTeJson,
        toolsCompleted,
        toolsSkipped,
        assessmentCycle,
        baselineScore,
        baselineCategory,
        numDelays,
        autismRisk,
        adhdRisk,
        behaviorRisk,
        behaviorScore,
        predictedRiskScore,
        predictedRiskCategory,
        riskTrend,
        topRiskFactorsJson,
        createdAt,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_screening_results';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalScreeningResult> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_local_id')) {
      context.handle(
          _sessionLocalIdMeta,
          sessionLocalId.isAcceptableOrUnknown(
              data['session_local_id']!, _sessionLocalIdMeta));
    } else if (isInserting) {
      context.missing(_sessionLocalIdMeta);
    }
    if (data.containsKey('session_remote_id')) {
      context.handle(
          _sessionRemoteIdMeta,
          sessionRemoteId.isAcceptableOrUnknown(
              data['session_remote_id']!, _sessionRemoteIdMeta));
    }
    if (data.containsKey('child_local_id')) {
      context.handle(
          _childLocalIdMeta,
          childLocalId.isAcceptableOrUnknown(
              data['child_local_id']!, _childLocalIdMeta));
    }
    if (data.containsKey('child_remote_id')) {
      context.handle(
          _childRemoteIdMeta,
          childRemoteId.isAcceptableOrUnknown(
              data['child_remote_id']!, _childRemoteIdMeta));
    }
    if (data.containsKey('overall_risk')) {
      context.handle(
          _overallRiskMeta,
          overallRisk.isAcceptableOrUnknown(
              data['overall_risk']!, _overallRiskMeta));
    } else if (isInserting) {
      context.missing(_overallRiskMeta);
    }
    if (data.containsKey('overall_risk_te')) {
      context.handle(
          _overallRiskTeMeta,
          overallRiskTe.isAcceptableOrUnknown(
              data['overall_risk_te']!, _overallRiskTeMeta));
    }
    if (data.containsKey('referral_needed')) {
      context.handle(
          _referralNeededMeta,
          referralNeeded.isAcceptableOrUnknown(
              data['referral_needed']!, _referralNeededMeta));
    }
    if (data.containsKey('gm_dq')) {
      context.handle(
          _gmDqMeta, gmDq.isAcceptableOrUnknown(data['gm_dq']!, _gmDqMeta));
    }
    if (data.containsKey('fm_dq')) {
      context.handle(
          _fmDqMeta, fmDq.isAcceptableOrUnknown(data['fm_dq']!, _fmDqMeta));
    }
    if (data.containsKey('lc_dq')) {
      context.handle(
          _lcDqMeta, lcDq.isAcceptableOrUnknown(data['lc_dq']!, _lcDqMeta));
    }
    if (data.containsKey('cog_dq')) {
      context.handle(
          _cogDqMeta, cogDq.isAcceptableOrUnknown(data['cog_dq']!, _cogDqMeta));
    }
    if (data.containsKey('se_dq')) {
      context.handle(
          _seDqMeta, seDq.isAcceptableOrUnknown(data['se_dq']!, _seDqMeta));
    }
    if (data.containsKey('composite_dq')) {
      context.handle(
          _compositeDqMeta,
          compositeDq.isAcceptableOrUnknown(
              data['composite_dq']!, _compositeDqMeta));
    }
    if (data.containsKey('tool_results_json')) {
      context.handle(
          _toolResultsJsonMeta,
          toolResultsJson.isAcceptableOrUnknown(
              data['tool_results_json']!, _toolResultsJsonMeta));
    }
    if (data.containsKey('concerns_json')) {
      context.handle(
          _concernsJsonMeta,
          concernsJson.isAcceptableOrUnknown(
              data['concerns_json']!, _concernsJsonMeta));
    }
    if (data.containsKey('concerns_te_json')) {
      context.handle(
          _concernsTeJsonMeta,
          concernsTeJson.isAcceptableOrUnknown(
              data['concerns_te_json']!, _concernsTeJsonMeta));
    }
    if (data.containsKey('tools_completed')) {
      context.handle(
          _toolsCompletedMeta,
          toolsCompleted.isAcceptableOrUnknown(
              data['tools_completed']!, _toolsCompletedMeta));
    }
    if (data.containsKey('tools_skipped')) {
      context.handle(
          _toolsSkippedMeta,
          toolsSkipped.isAcceptableOrUnknown(
              data['tools_skipped']!, _toolsSkippedMeta));
    }
    if (data.containsKey('assessment_cycle')) {
      context.handle(
          _assessmentCycleMeta,
          assessmentCycle.isAcceptableOrUnknown(
              data['assessment_cycle']!, _assessmentCycleMeta));
    }
    if (data.containsKey('baseline_score')) {
      context.handle(
          _baselineScoreMeta,
          baselineScore.isAcceptableOrUnknown(
              data['baseline_score']!, _baselineScoreMeta));
    }
    if (data.containsKey('baseline_category')) {
      context.handle(
          _baselineCategoryMeta,
          baselineCategory.isAcceptableOrUnknown(
              data['baseline_category']!, _baselineCategoryMeta));
    }
    if (data.containsKey('num_delays')) {
      context.handle(_numDelaysMeta,
          numDelays.isAcceptableOrUnknown(data['num_delays']!, _numDelaysMeta));
    }
    if (data.containsKey('autism_risk')) {
      context.handle(
          _autismRiskMeta,
          autismRisk.isAcceptableOrUnknown(
              data['autism_risk']!, _autismRiskMeta));
    }
    if (data.containsKey('adhd_risk')) {
      context.handle(_adhdRiskMeta,
          adhdRisk.isAcceptableOrUnknown(data['adhd_risk']!, _adhdRiskMeta));
    }
    if (data.containsKey('behavior_risk')) {
      context.handle(
          _behaviorRiskMeta,
          behaviorRisk.isAcceptableOrUnknown(
              data['behavior_risk']!, _behaviorRiskMeta));
    }
    if (data.containsKey('behavior_score')) {
      context.handle(
          _behaviorScoreMeta,
          behaviorScore.isAcceptableOrUnknown(
              data['behavior_score']!, _behaviorScoreMeta));
    }
    if (data.containsKey('predicted_risk_score')) {
      context.handle(
          _predictedRiskScoreMeta,
          predictedRiskScore.isAcceptableOrUnknown(
              data['predicted_risk_score']!, _predictedRiskScoreMeta));
    }
    if (data.containsKey('predicted_risk_category')) {
      context.handle(
          _predictedRiskCategoryMeta,
          predictedRiskCategory.isAcceptableOrUnknown(
              data['predicted_risk_category']!, _predictedRiskCategoryMeta));
    }
    if (data.containsKey('risk_trend')) {
      context.handle(_riskTrendMeta,
          riskTrend.isAcceptableOrUnknown(data['risk_trend']!, _riskTrendMeta));
    }
    if (data.containsKey('top_risk_factors_json')) {
      context.handle(
          _topRiskFactorsJsonMeta,
          topRiskFactorsJson.isAcceptableOrUnknown(
              data['top_risk_factors_json']!, _topRiskFactorsJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalScreeningResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalScreeningResult(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionLocalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_local_id'])!,
      sessionRemoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_remote_id']),
      childLocalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}child_local_id']),
      childRemoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}child_remote_id']),
      overallRisk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}overall_risk'])!,
      overallRiskTe: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}overall_risk_te'])!,
      referralNeeded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}referral_needed'])!,
      gmDq: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gm_dq']),
      fmDq: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fm_dq']),
      lcDq: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lc_dq']),
      cogDq: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cog_dq']),
      seDq: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}se_dq']),
      compositeDq: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}composite_dq']),
      toolResultsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}tool_results_json']),
      concernsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}concerns_json']),
      concernsTeJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}concerns_te_json']),
      toolsCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tools_completed'])!,
      toolsSkipped: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tools_skipped'])!,
      assessmentCycle: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}assessment_cycle'])!,
      baselineScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}baseline_score'])!,
      baselineCategory: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}baseline_category'])!,
      numDelays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}num_delays'])!,
      autismRisk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}autism_risk'])!,
      adhdRisk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}adhd_risk'])!,
      behaviorRisk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}behavior_risk'])!,
      behaviorScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}behavior_score'])!,
      predictedRiskScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}predicted_risk_score']),
      predictedRiskCategory: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}predicted_risk_category']),
      riskTrend: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}risk_trend']),
      topRiskFactorsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}top_risk_factors_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $LocalScreeningResultsTable createAlias(String alias) {
    return $LocalScreeningResultsTable(attachedDatabase, alias);
  }
}

class LocalScreeningResult extends DataClass
    implements Insertable<LocalScreeningResult> {
  final int id;
  final int sessionLocalId;
  final int? sessionRemoteId;
  final int? childLocalId;
  final int? childRemoteId;
  final String overallRisk;
  final String overallRiskTe;
  final bool referralNeeded;
  final double? gmDq;
  final double? fmDq;
  final double? lcDq;
  final double? cogDq;
  final double? seDq;
  final double? compositeDq;
  final String? toolResultsJson;
  final String? concernsJson;
  final String? concernsTeJson;
  final int toolsCompleted;
  final int toolsSkipped;
  final String assessmentCycle;
  final int baselineScore;
  final String baselineCategory;
  final int numDelays;
  final String autismRisk;
  final String adhdRisk;
  final String behaviorRisk;
  final int behaviorScore;
  final double? predictedRiskScore;
  final String? predictedRiskCategory;
  final String? riskTrend;
  final String? topRiskFactorsJson;
  final DateTime createdAt;
  final DateTime? syncedAt;
  const LocalScreeningResult(
      {required this.id,
      required this.sessionLocalId,
      this.sessionRemoteId,
      this.childLocalId,
      this.childRemoteId,
      required this.overallRisk,
      required this.overallRiskTe,
      required this.referralNeeded,
      this.gmDq,
      this.fmDq,
      this.lcDq,
      this.cogDq,
      this.seDq,
      this.compositeDq,
      this.toolResultsJson,
      this.concernsJson,
      this.concernsTeJson,
      required this.toolsCompleted,
      required this.toolsSkipped,
      required this.assessmentCycle,
      required this.baselineScore,
      required this.baselineCategory,
      required this.numDelays,
      required this.autismRisk,
      required this.adhdRisk,
      required this.behaviorRisk,
      required this.behaviorScore,
      this.predictedRiskScore,
      this.predictedRiskCategory,
      this.riskTrend,
      this.topRiskFactorsJson,
      required this.createdAt,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_local_id'] = Variable<int>(sessionLocalId);
    if (!nullToAbsent || sessionRemoteId != null) {
      map['session_remote_id'] = Variable<int>(sessionRemoteId);
    }
    if (!nullToAbsent || childLocalId != null) {
      map['child_local_id'] = Variable<int>(childLocalId);
    }
    if (!nullToAbsent || childRemoteId != null) {
      map['child_remote_id'] = Variable<int>(childRemoteId);
    }
    map['overall_risk'] = Variable<String>(overallRisk);
    map['overall_risk_te'] = Variable<String>(overallRiskTe);
    map['referral_needed'] = Variable<bool>(referralNeeded);
    if (!nullToAbsent || gmDq != null) {
      map['gm_dq'] = Variable<double>(gmDq);
    }
    if (!nullToAbsent || fmDq != null) {
      map['fm_dq'] = Variable<double>(fmDq);
    }
    if (!nullToAbsent || lcDq != null) {
      map['lc_dq'] = Variable<double>(lcDq);
    }
    if (!nullToAbsent || cogDq != null) {
      map['cog_dq'] = Variable<double>(cogDq);
    }
    if (!nullToAbsent || seDq != null) {
      map['se_dq'] = Variable<double>(seDq);
    }
    if (!nullToAbsent || compositeDq != null) {
      map['composite_dq'] = Variable<double>(compositeDq);
    }
    if (!nullToAbsent || toolResultsJson != null) {
      map['tool_results_json'] = Variable<String>(toolResultsJson);
    }
    if (!nullToAbsent || concernsJson != null) {
      map['concerns_json'] = Variable<String>(concernsJson);
    }
    if (!nullToAbsent || concernsTeJson != null) {
      map['concerns_te_json'] = Variable<String>(concernsTeJson);
    }
    map['tools_completed'] = Variable<int>(toolsCompleted);
    map['tools_skipped'] = Variable<int>(toolsSkipped);
    map['assessment_cycle'] = Variable<String>(assessmentCycle);
    map['baseline_score'] = Variable<int>(baselineScore);
    map['baseline_category'] = Variable<String>(baselineCategory);
    map['num_delays'] = Variable<int>(numDelays);
    map['autism_risk'] = Variable<String>(autismRisk);
    map['adhd_risk'] = Variable<String>(adhdRisk);
    map['behavior_risk'] = Variable<String>(behaviorRisk);
    map['behavior_score'] = Variable<int>(behaviorScore);
    if (!nullToAbsent || predictedRiskScore != null) {
      map['predicted_risk_score'] = Variable<double>(predictedRiskScore);
    }
    if (!nullToAbsent || predictedRiskCategory != null) {
      map['predicted_risk_category'] = Variable<String>(predictedRiskCategory);
    }
    if (!nullToAbsent || riskTrend != null) {
      map['risk_trend'] = Variable<String>(riskTrend);
    }
    if (!nullToAbsent || topRiskFactorsJson != null) {
      map['top_risk_factors_json'] = Variable<String>(topRiskFactorsJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  LocalScreeningResultsCompanion toCompanion(bool nullToAbsent) {
    return LocalScreeningResultsCompanion(
      id: Value(id),
      sessionLocalId: Value(sessionLocalId),
      sessionRemoteId: sessionRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionRemoteId),
      childLocalId: childLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(childLocalId),
      childRemoteId: childRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(childRemoteId),
      overallRisk: Value(overallRisk),
      overallRiskTe: Value(overallRiskTe),
      referralNeeded: Value(referralNeeded),
      gmDq: gmDq == null && nullToAbsent ? const Value.absent() : Value(gmDq),
      fmDq: fmDq == null && nullToAbsent ? const Value.absent() : Value(fmDq),
      lcDq: lcDq == null && nullToAbsent ? const Value.absent() : Value(lcDq),
      cogDq:
          cogDq == null && nullToAbsent ? const Value.absent() : Value(cogDq),
      seDq: seDq == null && nullToAbsent ? const Value.absent() : Value(seDq),
      compositeDq: compositeDq == null && nullToAbsent
          ? const Value.absent()
          : Value(compositeDq),
      toolResultsJson: toolResultsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(toolResultsJson),
      concernsJson: concernsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(concernsJson),
      concernsTeJson: concernsTeJson == null && nullToAbsent
          ? const Value.absent()
          : Value(concernsTeJson),
      toolsCompleted: Value(toolsCompleted),
      toolsSkipped: Value(toolsSkipped),
      assessmentCycle: Value(assessmentCycle),
      baselineScore: Value(baselineScore),
      baselineCategory: Value(baselineCategory),
      numDelays: Value(numDelays),
      autismRisk: Value(autismRisk),
      adhdRisk: Value(adhdRisk),
      behaviorRisk: Value(behaviorRisk),
      behaviorScore: Value(behaviorScore),
      predictedRiskScore: predictedRiskScore == null && nullToAbsent
          ? const Value.absent()
          : Value(predictedRiskScore),
      predictedRiskCategory: predictedRiskCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(predictedRiskCategory),
      riskTrend: riskTrend == null && nullToAbsent
          ? const Value.absent()
          : Value(riskTrend),
      topRiskFactorsJson: topRiskFactorsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(topRiskFactorsJson),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalScreeningResult.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalScreeningResult(
      id: serializer.fromJson<int>(json['id']),
      sessionLocalId: serializer.fromJson<int>(json['sessionLocalId']),
      sessionRemoteId: serializer.fromJson<int?>(json['sessionRemoteId']),
      childLocalId: serializer.fromJson<int?>(json['childLocalId']),
      childRemoteId: serializer.fromJson<int?>(json['childRemoteId']),
      overallRisk: serializer.fromJson<String>(json['overallRisk']),
      overallRiskTe: serializer.fromJson<String>(json['overallRiskTe']),
      referralNeeded: serializer.fromJson<bool>(json['referralNeeded']),
      gmDq: serializer.fromJson<double?>(json['gmDq']),
      fmDq: serializer.fromJson<double?>(json['fmDq']),
      lcDq: serializer.fromJson<double?>(json['lcDq']),
      cogDq: serializer.fromJson<double?>(json['cogDq']),
      seDq: serializer.fromJson<double?>(json['seDq']),
      compositeDq: serializer.fromJson<double?>(json['compositeDq']),
      toolResultsJson: serializer.fromJson<String?>(json['toolResultsJson']),
      concernsJson: serializer.fromJson<String?>(json['concernsJson']),
      concernsTeJson: serializer.fromJson<String?>(json['concernsTeJson']),
      toolsCompleted: serializer.fromJson<int>(json['toolsCompleted']),
      toolsSkipped: serializer.fromJson<int>(json['toolsSkipped']),
      assessmentCycle: serializer.fromJson<String>(json['assessmentCycle']),
      baselineScore: serializer.fromJson<int>(json['baselineScore']),
      baselineCategory: serializer.fromJson<String>(json['baselineCategory']),
      numDelays: serializer.fromJson<int>(json['numDelays']),
      autismRisk: serializer.fromJson<String>(json['autismRisk']),
      adhdRisk: serializer.fromJson<String>(json['adhdRisk']),
      behaviorRisk: serializer.fromJson<String>(json['behaviorRisk']),
      behaviorScore: serializer.fromJson<int>(json['behaviorScore']),
      predictedRiskScore:
          serializer.fromJson<double?>(json['predictedRiskScore']),
      predictedRiskCategory:
          serializer.fromJson<String?>(json['predictedRiskCategory']),
      riskTrend: serializer.fromJson<String?>(json['riskTrend']),
      topRiskFactorsJson:
          serializer.fromJson<String?>(json['topRiskFactorsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionLocalId': serializer.toJson<int>(sessionLocalId),
      'sessionRemoteId': serializer.toJson<int?>(sessionRemoteId),
      'childLocalId': serializer.toJson<int?>(childLocalId),
      'childRemoteId': serializer.toJson<int?>(childRemoteId),
      'overallRisk': serializer.toJson<String>(overallRisk),
      'overallRiskTe': serializer.toJson<String>(overallRiskTe),
      'referralNeeded': serializer.toJson<bool>(referralNeeded),
      'gmDq': serializer.toJson<double?>(gmDq),
      'fmDq': serializer.toJson<double?>(fmDq),
      'lcDq': serializer.toJson<double?>(lcDq),
      'cogDq': serializer.toJson<double?>(cogDq),
      'seDq': serializer.toJson<double?>(seDq),
      'compositeDq': serializer.toJson<double?>(compositeDq),
      'toolResultsJson': serializer.toJson<String?>(toolResultsJson),
      'concernsJson': serializer.toJson<String?>(concernsJson),
      'concernsTeJson': serializer.toJson<String?>(concernsTeJson),
      'toolsCompleted': serializer.toJson<int>(toolsCompleted),
      'toolsSkipped': serializer.toJson<int>(toolsSkipped),
      'assessmentCycle': serializer.toJson<String>(assessmentCycle),
      'baselineScore': serializer.toJson<int>(baselineScore),
      'baselineCategory': serializer.toJson<String>(baselineCategory),
      'numDelays': serializer.toJson<int>(numDelays),
      'autismRisk': serializer.toJson<String>(autismRisk),
      'adhdRisk': serializer.toJson<String>(adhdRisk),
      'behaviorRisk': serializer.toJson<String>(behaviorRisk),
      'behaviorScore': serializer.toJson<int>(behaviorScore),
      'predictedRiskScore': serializer.toJson<double?>(predictedRiskScore),
      'predictedRiskCategory':
          serializer.toJson<String?>(predictedRiskCategory),
      'riskTrend': serializer.toJson<String?>(riskTrend),
      'topRiskFactorsJson': serializer.toJson<String?>(topRiskFactorsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalScreeningResult copyWith(
          {int? id,
          int? sessionLocalId,
          Value<int?> sessionRemoteId = const Value.absent(),
          Value<int?> childLocalId = const Value.absent(),
          Value<int?> childRemoteId = const Value.absent(),
          String? overallRisk,
          String? overallRiskTe,
          bool? referralNeeded,
          Value<double?> gmDq = const Value.absent(),
          Value<double?> fmDq = const Value.absent(),
          Value<double?> lcDq = const Value.absent(),
          Value<double?> cogDq = const Value.absent(),
          Value<double?> seDq = const Value.absent(),
          Value<double?> compositeDq = const Value.absent(),
          Value<String?> toolResultsJson = const Value.absent(),
          Value<String?> concernsJson = const Value.absent(),
          Value<String?> concernsTeJson = const Value.absent(),
          int? toolsCompleted,
          int? toolsSkipped,
          String? assessmentCycle,
          int? baselineScore,
          String? baselineCategory,
          int? numDelays,
          String? autismRisk,
          String? adhdRisk,
          String? behaviorRisk,
          int? behaviorScore,
          Value<double?> predictedRiskScore = const Value.absent(),
          Value<String?> predictedRiskCategory = const Value.absent(),
          Value<String?> riskTrend = const Value.absent(),
          Value<String?> topRiskFactorsJson = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      LocalScreeningResult(
        id: id ?? this.id,
        sessionLocalId: sessionLocalId ?? this.sessionLocalId,
        sessionRemoteId: sessionRemoteId.present
            ? sessionRemoteId.value
            : this.sessionRemoteId,
        childLocalId:
            childLocalId.present ? childLocalId.value : this.childLocalId,
        childRemoteId:
            childRemoteId.present ? childRemoteId.value : this.childRemoteId,
        overallRisk: overallRisk ?? this.overallRisk,
        overallRiskTe: overallRiskTe ?? this.overallRiskTe,
        referralNeeded: referralNeeded ?? this.referralNeeded,
        gmDq: gmDq.present ? gmDq.value : this.gmDq,
        fmDq: fmDq.present ? fmDq.value : this.fmDq,
        lcDq: lcDq.present ? lcDq.value : this.lcDq,
        cogDq: cogDq.present ? cogDq.value : this.cogDq,
        seDq: seDq.present ? seDq.value : this.seDq,
        compositeDq: compositeDq.present ? compositeDq.value : this.compositeDq,
        toolResultsJson: toolResultsJson.present
            ? toolResultsJson.value
            : this.toolResultsJson,
        concernsJson:
            concernsJson.present ? concernsJson.value : this.concernsJson,
        concernsTeJson:
            concernsTeJson.present ? concernsTeJson.value : this.concernsTeJson,
        toolsCompleted: toolsCompleted ?? this.toolsCompleted,
        toolsSkipped: toolsSkipped ?? this.toolsSkipped,
        assessmentCycle: assessmentCycle ?? this.assessmentCycle,
        baselineScore: baselineScore ?? this.baselineScore,
        baselineCategory: baselineCategory ?? this.baselineCategory,
        numDelays: numDelays ?? this.numDelays,
        autismRisk: autismRisk ?? this.autismRisk,
        adhdRisk: adhdRisk ?? this.adhdRisk,
        behaviorRisk: behaviorRisk ?? this.behaviorRisk,
        behaviorScore: behaviorScore ?? this.behaviorScore,
        predictedRiskScore: predictedRiskScore.present
            ? predictedRiskScore.value
            : this.predictedRiskScore,
        predictedRiskCategory: predictedRiskCategory.present
            ? predictedRiskCategory.value
            : this.predictedRiskCategory,
        riskTrend: riskTrend.present ? riskTrend.value : this.riskTrend,
        topRiskFactorsJson: topRiskFactorsJson.present
            ? topRiskFactorsJson.value
            : this.topRiskFactorsJson,
        createdAt: createdAt ?? this.createdAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  LocalScreeningResult copyWithCompanion(LocalScreeningResultsCompanion data) {
    return LocalScreeningResult(
      id: data.id.present ? data.id.value : this.id,
      sessionLocalId: data.sessionLocalId.present
          ? data.sessionLocalId.value
          : this.sessionLocalId,
      sessionRemoteId: data.sessionRemoteId.present
          ? data.sessionRemoteId.value
          : this.sessionRemoteId,
      childLocalId: data.childLocalId.present
          ? data.childLocalId.value
          : this.childLocalId,
      childRemoteId: data.childRemoteId.present
          ? data.childRemoteId.value
          : this.childRemoteId,
      overallRisk:
          data.overallRisk.present ? data.overallRisk.value : this.overallRisk,
      overallRiskTe: data.overallRiskTe.present
          ? data.overallRiskTe.value
          : this.overallRiskTe,
      referralNeeded: data.referralNeeded.present
          ? data.referralNeeded.value
          : this.referralNeeded,
      gmDq: data.gmDq.present ? data.gmDq.value : this.gmDq,
      fmDq: data.fmDq.present ? data.fmDq.value : this.fmDq,
      lcDq: data.lcDq.present ? data.lcDq.value : this.lcDq,
      cogDq: data.cogDq.present ? data.cogDq.value : this.cogDq,
      seDq: data.seDq.present ? data.seDq.value : this.seDq,
      compositeDq:
          data.compositeDq.present ? data.compositeDq.value : this.compositeDq,
      toolResultsJson: data.toolResultsJson.present
          ? data.toolResultsJson.value
          : this.toolResultsJson,
      concernsJson: data.concernsJson.present
          ? data.concernsJson.value
          : this.concernsJson,
      concernsTeJson: data.concernsTeJson.present
          ? data.concernsTeJson.value
          : this.concernsTeJson,
      toolsCompleted: data.toolsCompleted.present
          ? data.toolsCompleted.value
          : this.toolsCompleted,
      toolsSkipped: data.toolsSkipped.present
          ? data.toolsSkipped.value
          : this.toolsSkipped,
      assessmentCycle: data.assessmentCycle.present
          ? data.assessmentCycle.value
          : this.assessmentCycle,
      baselineScore: data.baselineScore.present
          ? data.baselineScore.value
          : this.baselineScore,
      baselineCategory: data.baselineCategory.present
          ? data.baselineCategory.value
          : this.baselineCategory,
      numDelays: data.numDelays.present ? data.numDelays.value : this.numDelays,
      autismRisk:
          data.autismRisk.present ? data.autismRisk.value : this.autismRisk,
      adhdRisk: data.adhdRisk.present ? data.adhdRisk.value : this.adhdRisk,
      behaviorRisk: data.behaviorRisk.present
          ? data.behaviorRisk.value
          : this.behaviorRisk,
      behaviorScore: data.behaviorScore.present
          ? data.behaviorScore.value
          : this.behaviorScore,
      predictedRiskScore: data.predictedRiskScore.present
          ? data.predictedRiskScore.value
          : this.predictedRiskScore,
      predictedRiskCategory: data.predictedRiskCategory.present
          ? data.predictedRiskCategory.value
          : this.predictedRiskCategory,
      riskTrend: data.riskTrend.present ? data.riskTrend.value : this.riskTrend,
      topRiskFactorsJson: data.topRiskFactorsJson.present
          ? data.topRiskFactorsJson.value
          : this.topRiskFactorsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalScreeningResult(')
          ..write('id: $id, ')
          ..write('sessionLocalId: $sessionLocalId, ')
          ..write('sessionRemoteId: $sessionRemoteId, ')
          ..write('childLocalId: $childLocalId, ')
          ..write('childRemoteId: $childRemoteId, ')
          ..write('overallRisk: $overallRisk, ')
          ..write('overallRiskTe: $overallRiskTe, ')
          ..write('referralNeeded: $referralNeeded, ')
          ..write('gmDq: $gmDq, ')
          ..write('fmDq: $fmDq, ')
          ..write('lcDq: $lcDq, ')
          ..write('cogDq: $cogDq, ')
          ..write('seDq: $seDq, ')
          ..write('compositeDq: $compositeDq, ')
          ..write('toolResultsJson: $toolResultsJson, ')
          ..write('concernsJson: $concernsJson, ')
          ..write('concernsTeJson: $concernsTeJson, ')
          ..write('toolsCompleted: $toolsCompleted, ')
          ..write('toolsSkipped: $toolsSkipped, ')
          ..write('assessmentCycle: $assessmentCycle, ')
          ..write('baselineScore: $baselineScore, ')
          ..write('baselineCategory: $baselineCategory, ')
          ..write('numDelays: $numDelays, ')
          ..write('autismRisk: $autismRisk, ')
          ..write('adhdRisk: $adhdRisk, ')
          ..write('behaviorRisk: $behaviorRisk, ')
          ..write('behaviorScore: $behaviorScore, ')
          ..write('predictedRiskScore: $predictedRiskScore, ')
          ..write('predictedRiskCategory: $predictedRiskCategory, ')
          ..write('riskTrend: $riskTrend, ')
          ..write('topRiskFactorsJson: $topRiskFactorsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        sessionLocalId,
        sessionRemoteId,
        childLocalId,
        childRemoteId,
        overallRisk,
        overallRiskTe,
        referralNeeded,
        gmDq,
        fmDq,
        lcDq,
        cogDq,
        seDq,
        compositeDq,
        toolResultsJson,
        concernsJson,
        concernsTeJson,
        toolsCompleted,
        toolsSkipped,
        assessmentCycle,
        baselineScore,
        baselineCategory,
        numDelays,
        autismRisk,
        adhdRisk,
        behaviorRisk,
        behaviorScore,
        predictedRiskScore,
        predictedRiskCategory,
        riskTrend,
        topRiskFactorsJson,
        createdAt,
        syncedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalScreeningResult &&
          other.id == this.id &&
          other.sessionLocalId == this.sessionLocalId &&
          other.sessionRemoteId == this.sessionRemoteId &&
          other.childLocalId == this.childLocalId &&
          other.childRemoteId == this.childRemoteId &&
          other.overallRisk == this.overallRisk &&
          other.overallRiskTe == this.overallRiskTe &&
          other.referralNeeded == this.referralNeeded &&
          other.gmDq == this.gmDq &&
          other.fmDq == this.fmDq &&
          other.lcDq == this.lcDq &&
          other.cogDq == this.cogDq &&
          other.seDq == this.seDq &&
          other.compositeDq == this.compositeDq &&
          other.toolResultsJson == this.toolResultsJson &&
          other.concernsJson == this.concernsJson &&
          other.concernsTeJson == this.concernsTeJson &&
          other.toolsCompleted == this.toolsCompleted &&
          other.toolsSkipped == this.toolsSkipped &&
          other.assessmentCycle == this.assessmentCycle &&
          other.baselineScore == this.baselineScore &&
          other.baselineCategory == this.baselineCategory &&
          other.numDelays == this.numDelays &&
          other.autismRisk == this.autismRisk &&
          other.adhdRisk == this.adhdRisk &&
          other.behaviorRisk == this.behaviorRisk &&
          other.behaviorScore == this.behaviorScore &&
          other.predictedRiskScore == this.predictedRiskScore &&
          other.predictedRiskCategory == this.predictedRiskCategory &&
          other.riskTrend == this.riskTrend &&
          other.topRiskFactorsJson == this.topRiskFactorsJson &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class LocalScreeningResultsCompanion
    extends UpdateCompanion<LocalScreeningResult> {
  final Value<int> id;
  final Value<int> sessionLocalId;
  final Value<int?> sessionRemoteId;
  final Value<int?> childLocalId;
  final Value<int?> childRemoteId;
  final Value<String> overallRisk;
  final Value<String> overallRiskTe;
  final Value<bool> referralNeeded;
  final Value<double?> gmDq;
  final Value<double?> fmDq;
  final Value<double?> lcDq;
  final Value<double?> cogDq;
  final Value<double?> seDq;
  final Value<double?> compositeDq;
  final Value<String?> toolResultsJson;
  final Value<String?> concernsJson;
  final Value<String?> concernsTeJson;
  final Value<int> toolsCompleted;
  final Value<int> toolsSkipped;
  final Value<String> assessmentCycle;
  final Value<int> baselineScore;
  final Value<String> baselineCategory;
  final Value<int> numDelays;
  final Value<String> autismRisk;
  final Value<String> adhdRisk;
  final Value<String> behaviorRisk;
  final Value<int> behaviorScore;
  final Value<double?> predictedRiskScore;
  final Value<String?> predictedRiskCategory;
  final Value<String?> riskTrend;
  final Value<String?> topRiskFactorsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  const LocalScreeningResultsCompanion({
    this.id = const Value.absent(),
    this.sessionLocalId = const Value.absent(),
    this.sessionRemoteId = const Value.absent(),
    this.childLocalId = const Value.absent(),
    this.childRemoteId = const Value.absent(),
    this.overallRisk = const Value.absent(),
    this.overallRiskTe = const Value.absent(),
    this.referralNeeded = const Value.absent(),
    this.gmDq = const Value.absent(),
    this.fmDq = const Value.absent(),
    this.lcDq = const Value.absent(),
    this.cogDq = const Value.absent(),
    this.seDq = const Value.absent(),
    this.compositeDq = const Value.absent(),
    this.toolResultsJson = const Value.absent(),
    this.concernsJson = const Value.absent(),
    this.concernsTeJson = const Value.absent(),
    this.toolsCompleted = const Value.absent(),
    this.toolsSkipped = const Value.absent(),
    this.assessmentCycle = const Value.absent(),
    this.baselineScore = const Value.absent(),
    this.baselineCategory = const Value.absent(),
    this.numDelays = const Value.absent(),
    this.autismRisk = const Value.absent(),
    this.adhdRisk = const Value.absent(),
    this.behaviorRisk = const Value.absent(),
    this.behaviorScore = const Value.absent(),
    this.predictedRiskScore = const Value.absent(),
    this.predictedRiskCategory = const Value.absent(),
    this.riskTrend = const Value.absent(),
    this.topRiskFactorsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  LocalScreeningResultsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionLocalId,
    this.sessionRemoteId = const Value.absent(),
    this.childLocalId = const Value.absent(),
    this.childRemoteId = const Value.absent(),
    required String overallRisk,
    this.overallRiskTe = const Value.absent(),
    this.referralNeeded = const Value.absent(),
    this.gmDq = const Value.absent(),
    this.fmDq = const Value.absent(),
    this.lcDq = const Value.absent(),
    this.cogDq = const Value.absent(),
    this.seDq = const Value.absent(),
    this.compositeDq = const Value.absent(),
    this.toolResultsJson = const Value.absent(),
    this.concernsJson = const Value.absent(),
    this.concernsTeJson = const Value.absent(),
    this.toolsCompleted = const Value.absent(),
    this.toolsSkipped = const Value.absent(),
    this.assessmentCycle = const Value.absent(),
    this.baselineScore = const Value.absent(),
    this.baselineCategory = const Value.absent(),
    this.numDelays = const Value.absent(),
    this.autismRisk = const Value.absent(),
    this.adhdRisk = const Value.absent(),
    this.behaviorRisk = const Value.absent(),
    this.behaviorScore = const Value.absent(),
    this.predictedRiskScore = const Value.absent(),
    this.predictedRiskCategory = const Value.absent(),
    this.riskTrend = const Value.absent(),
    this.topRiskFactorsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  })  : sessionLocalId = Value(sessionLocalId),
        overallRisk = Value(overallRisk);
  static Insertable<LocalScreeningResult> custom({
    Expression<int>? id,
    Expression<int>? sessionLocalId,
    Expression<int>? sessionRemoteId,
    Expression<int>? childLocalId,
    Expression<int>? childRemoteId,
    Expression<String>? overallRisk,
    Expression<String>? overallRiskTe,
    Expression<bool>? referralNeeded,
    Expression<double>? gmDq,
    Expression<double>? fmDq,
    Expression<double>? lcDq,
    Expression<double>? cogDq,
    Expression<double>? seDq,
    Expression<double>? compositeDq,
    Expression<String>? toolResultsJson,
    Expression<String>? concernsJson,
    Expression<String>? concernsTeJson,
    Expression<int>? toolsCompleted,
    Expression<int>? toolsSkipped,
    Expression<String>? assessmentCycle,
    Expression<int>? baselineScore,
    Expression<String>? baselineCategory,
    Expression<int>? numDelays,
    Expression<String>? autismRisk,
    Expression<String>? adhdRisk,
    Expression<String>? behaviorRisk,
    Expression<int>? behaviorScore,
    Expression<double>? predictedRiskScore,
    Expression<String>? predictedRiskCategory,
    Expression<String>? riskTrend,
    Expression<String>? topRiskFactorsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionLocalId != null) 'session_local_id': sessionLocalId,
      if (sessionRemoteId != null) 'session_remote_id': sessionRemoteId,
      if (childLocalId != null) 'child_local_id': childLocalId,
      if (childRemoteId != null) 'child_remote_id': childRemoteId,
      if (overallRisk != null) 'overall_risk': overallRisk,
      if (overallRiskTe != null) 'overall_risk_te': overallRiskTe,
      if (referralNeeded != null) 'referral_needed': referralNeeded,
      if (gmDq != null) 'gm_dq': gmDq,
      if (fmDq != null) 'fm_dq': fmDq,
      if (lcDq != null) 'lc_dq': lcDq,
      if (cogDq != null) 'cog_dq': cogDq,
      if (seDq != null) 'se_dq': seDq,
      if (compositeDq != null) 'composite_dq': compositeDq,
      if (toolResultsJson != null) 'tool_results_json': toolResultsJson,
      if (concernsJson != null) 'concerns_json': concernsJson,
      if (concernsTeJson != null) 'concerns_te_json': concernsTeJson,
      if (toolsCompleted != null) 'tools_completed': toolsCompleted,
      if (toolsSkipped != null) 'tools_skipped': toolsSkipped,
      if (assessmentCycle != null) 'assessment_cycle': assessmentCycle,
      if (baselineScore != null) 'baseline_score': baselineScore,
      if (baselineCategory != null) 'baseline_category': baselineCategory,
      if (numDelays != null) 'num_delays': numDelays,
      if (autismRisk != null) 'autism_risk': autismRisk,
      if (adhdRisk != null) 'adhd_risk': adhdRisk,
      if (behaviorRisk != null) 'behavior_risk': behaviorRisk,
      if (behaviorScore != null) 'behavior_score': behaviorScore,
      if (predictedRiskScore != null)
        'predicted_risk_score': predictedRiskScore,
      if (predictedRiskCategory != null)
        'predicted_risk_category': predictedRiskCategory,
      if (riskTrend != null) 'risk_trend': riskTrend,
      if (topRiskFactorsJson != null)
        'top_risk_factors_json': topRiskFactorsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  LocalScreeningResultsCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionLocalId,
      Value<int?>? sessionRemoteId,
      Value<int?>? childLocalId,
      Value<int?>? childRemoteId,
      Value<String>? overallRisk,
      Value<String>? overallRiskTe,
      Value<bool>? referralNeeded,
      Value<double?>? gmDq,
      Value<double?>? fmDq,
      Value<double?>? lcDq,
      Value<double?>? cogDq,
      Value<double?>? seDq,
      Value<double?>? compositeDq,
      Value<String?>? toolResultsJson,
      Value<String?>? concernsJson,
      Value<String?>? concernsTeJson,
      Value<int>? toolsCompleted,
      Value<int>? toolsSkipped,
      Value<String>? assessmentCycle,
      Value<int>? baselineScore,
      Value<String>? baselineCategory,
      Value<int>? numDelays,
      Value<String>? autismRisk,
      Value<String>? adhdRisk,
      Value<String>? behaviorRisk,
      Value<int>? behaviorScore,
      Value<double?>? predictedRiskScore,
      Value<String?>? predictedRiskCategory,
      Value<String?>? riskTrend,
      Value<String?>? topRiskFactorsJson,
      Value<DateTime>? createdAt,
      Value<DateTime?>? syncedAt}) {
    return LocalScreeningResultsCompanion(
      id: id ?? this.id,
      sessionLocalId: sessionLocalId ?? this.sessionLocalId,
      sessionRemoteId: sessionRemoteId ?? this.sessionRemoteId,
      childLocalId: childLocalId ?? this.childLocalId,
      childRemoteId: childRemoteId ?? this.childRemoteId,
      overallRisk: overallRisk ?? this.overallRisk,
      overallRiskTe: overallRiskTe ?? this.overallRiskTe,
      referralNeeded: referralNeeded ?? this.referralNeeded,
      gmDq: gmDq ?? this.gmDq,
      fmDq: fmDq ?? this.fmDq,
      lcDq: lcDq ?? this.lcDq,
      cogDq: cogDq ?? this.cogDq,
      seDq: seDq ?? this.seDq,
      compositeDq: compositeDq ?? this.compositeDq,
      toolResultsJson: toolResultsJson ?? this.toolResultsJson,
      concernsJson: concernsJson ?? this.concernsJson,
      concernsTeJson: concernsTeJson ?? this.concernsTeJson,
      toolsCompleted: toolsCompleted ?? this.toolsCompleted,
      toolsSkipped: toolsSkipped ?? this.toolsSkipped,
      assessmentCycle: assessmentCycle ?? this.assessmentCycle,
      baselineScore: baselineScore ?? this.baselineScore,
      baselineCategory: baselineCategory ?? this.baselineCategory,
      numDelays: numDelays ?? this.numDelays,
      autismRisk: autismRisk ?? this.autismRisk,
      adhdRisk: adhdRisk ?? this.adhdRisk,
      behaviorRisk: behaviorRisk ?? this.behaviorRisk,
      behaviorScore: behaviorScore ?? this.behaviorScore,
      predictedRiskScore: predictedRiskScore ?? this.predictedRiskScore,
      predictedRiskCategory:
          predictedRiskCategory ?? this.predictedRiskCategory,
      riskTrend: riskTrend ?? this.riskTrend,
      topRiskFactorsJson: topRiskFactorsJson ?? this.topRiskFactorsJson,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionLocalId.present) {
      map['session_local_id'] = Variable<int>(sessionLocalId.value);
    }
    if (sessionRemoteId.present) {
      map['session_remote_id'] = Variable<int>(sessionRemoteId.value);
    }
    if (childLocalId.present) {
      map['child_local_id'] = Variable<int>(childLocalId.value);
    }
    if (childRemoteId.present) {
      map['child_remote_id'] = Variable<int>(childRemoteId.value);
    }
    if (overallRisk.present) {
      map['overall_risk'] = Variable<String>(overallRisk.value);
    }
    if (overallRiskTe.present) {
      map['overall_risk_te'] = Variable<String>(overallRiskTe.value);
    }
    if (referralNeeded.present) {
      map['referral_needed'] = Variable<bool>(referralNeeded.value);
    }
    if (gmDq.present) {
      map['gm_dq'] = Variable<double>(gmDq.value);
    }
    if (fmDq.present) {
      map['fm_dq'] = Variable<double>(fmDq.value);
    }
    if (lcDq.present) {
      map['lc_dq'] = Variable<double>(lcDq.value);
    }
    if (cogDq.present) {
      map['cog_dq'] = Variable<double>(cogDq.value);
    }
    if (seDq.present) {
      map['se_dq'] = Variable<double>(seDq.value);
    }
    if (compositeDq.present) {
      map['composite_dq'] = Variable<double>(compositeDq.value);
    }
    if (toolResultsJson.present) {
      map['tool_results_json'] = Variable<String>(toolResultsJson.value);
    }
    if (concernsJson.present) {
      map['concerns_json'] = Variable<String>(concernsJson.value);
    }
    if (concernsTeJson.present) {
      map['concerns_te_json'] = Variable<String>(concernsTeJson.value);
    }
    if (toolsCompleted.present) {
      map['tools_completed'] = Variable<int>(toolsCompleted.value);
    }
    if (toolsSkipped.present) {
      map['tools_skipped'] = Variable<int>(toolsSkipped.value);
    }
    if (assessmentCycle.present) {
      map['assessment_cycle'] = Variable<String>(assessmentCycle.value);
    }
    if (baselineScore.present) {
      map['baseline_score'] = Variable<int>(baselineScore.value);
    }
    if (baselineCategory.present) {
      map['baseline_category'] = Variable<String>(baselineCategory.value);
    }
    if (numDelays.present) {
      map['num_delays'] = Variable<int>(numDelays.value);
    }
    if (autismRisk.present) {
      map['autism_risk'] = Variable<String>(autismRisk.value);
    }
    if (adhdRisk.present) {
      map['adhd_risk'] = Variable<String>(adhdRisk.value);
    }
    if (behaviorRisk.present) {
      map['behavior_risk'] = Variable<String>(behaviorRisk.value);
    }
    if (behaviorScore.present) {
      map['behavior_score'] = Variable<int>(behaviorScore.value);
    }
    if (predictedRiskScore.present) {
      map['predicted_risk_score'] = Variable<double>(predictedRiskScore.value);
    }
    if (predictedRiskCategory.present) {
      map['predicted_risk_category'] =
          Variable<String>(predictedRiskCategory.value);
    }
    if (riskTrend.present) {
      map['risk_trend'] = Variable<String>(riskTrend.value);
    }
    if (topRiskFactorsJson.present) {
      map['top_risk_factors_json'] = Variable<String>(topRiskFactorsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalScreeningResultsCompanion(')
          ..write('id: $id, ')
          ..write('sessionLocalId: $sessionLocalId, ')
          ..write('sessionRemoteId: $sessionRemoteId, ')
          ..write('childLocalId: $childLocalId, ')
          ..write('childRemoteId: $childRemoteId, ')
          ..write('overallRisk: $overallRisk, ')
          ..write('overallRiskTe: $overallRiskTe, ')
          ..write('referralNeeded: $referralNeeded, ')
          ..write('gmDq: $gmDq, ')
          ..write('fmDq: $fmDq, ')
          ..write('lcDq: $lcDq, ')
          ..write('cogDq: $cogDq, ')
          ..write('seDq: $seDq, ')
          ..write('compositeDq: $compositeDq, ')
          ..write('toolResultsJson: $toolResultsJson, ')
          ..write('concernsJson: $concernsJson, ')
          ..write('concernsTeJson: $concernsTeJson, ')
          ..write('toolsCompleted: $toolsCompleted, ')
          ..write('toolsSkipped: $toolsSkipped, ')
          ..write('assessmentCycle: $assessmentCycle, ')
          ..write('baselineScore: $baselineScore, ')
          ..write('baselineCategory: $baselineCategory, ')
          ..write('numDelays: $numDelays, ')
          ..write('autismRisk: $autismRisk, ')
          ..write('adhdRisk: $adhdRisk, ')
          ..write('behaviorRisk: $behaviorRisk, ')
          ..write('behaviorScore: $behaviorScore, ')
          ..write('predictedRiskScore: $predictedRiskScore, ')
          ..write('predictedRiskCategory: $predictedRiskCategory, ')
          ..write('riskTrend: $riskTrend, ')
          ..write('topRiskFactorsJson: $topRiskFactorsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityLocalIdMeta =
      const VerificationMeta('entityLocalId');
  @override
  late final GeneratedColumn<int> entityLocalId = GeneratedColumn<int>(
      'entity_local_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _lastAttemptAtMeta =
      const VerificationMeta('lastAttemptAt');
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>('last_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityLocalId,
        operation,
        retryCount,
        lastError,
        priority,
        createdAt,
        lastAttemptAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_local_id')) {
      context.handle(
          _entityLocalIdMeta,
          entityLocalId.isAcceptableOrUnknown(
              data['entity_local_id']!, _entityLocalIdMeta));
    } else if (isInserting) {
      context.missing(_entityLocalIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
          _lastAttemptAtMeta,
          lastAttemptAt.isAcceptableOrUnknown(
              data['last_attempt_at']!, _lastAttemptAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityLocalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}entity_local_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_attempt_at']),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String entityType;
  final int entityLocalId;
  final String operation;
  final int retryCount;
  final String? lastError;
  final int priority;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  const SyncQueueData(
      {required this.id,
      required this.entityType,
      required this.entityLocalId,
      required this.operation,
      required this.retryCount,
      this.lastError,
      required this.priority,
      required this.createdAt,
      this.lastAttemptAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_local_id'] = Variable<int>(entityLocalId);
    map['operation'] = Variable<String>(operation);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['priority'] = Variable<int>(priority);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityLocalId: Value(entityLocalId),
      operation: Value(operation),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      priority: Value(priority),
      createdAt: Value(createdAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityLocalId: serializer.fromJson<int>(json['entityLocalId']),
      operation: serializer.fromJson<String>(json['operation']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      priority: serializer.fromJson<int>(json['priority']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityLocalId': serializer.toJson<int>(entityLocalId),
      'operation': serializer.toJson<String>(operation),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'priority': serializer.toJson<int>(priority),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
    };
  }

  SyncQueueData copyWith(
          {int? id,
          String? entityType,
          int? entityLocalId,
          String? operation,
          int? retryCount,
          Value<String?> lastError = const Value.absent(),
          int? priority,
          DateTime? createdAt,
          Value<DateTime?> lastAttemptAt = const Value.absent()}) =>
      SyncQueueData(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityLocalId: entityLocalId ?? this.entityLocalId,
        operation: operation ?? this.operation,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
        priority: priority ?? this.priority,
        createdAt: createdAt ?? this.createdAt,
        lastAttemptAt:
            lastAttemptAt.present ? lastAttemptAt.value : this.lastAttemptAt,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityLocalId: data.entityLocalId.present
          ? data.entityLocalId.value
          : this.entityLocalId,
      operation: data.operation.present ? data.operation.value : this.operation,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      priority: data.priority.present ? data.priority.value : this.priority,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityLocalId: $entityLocalId, ')
          ..write('operation: $operation, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityLocalId, operation,
      retryCount, lastError, priority, createdAt, lastAttemptAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityLocalId == this.entityLocalId &&
          other.operation == this.operation &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.priority == this.priority &&
          other.createdAt == this.createdAt &&
          other.lastAttemptAt == this.lastAttemptAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<int> entityLocalId;
  final Value<String> operation;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<int> priority;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastAttemptAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityLocalId = const Value.absent(),
    this.operation = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.priority = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required int entityLocalId,
    required String operation,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.priority = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
  })  : entityType = Value(entityType),
        entityLocalId = Value(entityLocalId),
        operation = Value(operation);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<int>? entityLocalId,
    Expression<String>? operation,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<int>? priority,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAttemptAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityLocalId != null) 'entity_local_id': entityLocalId,
      if (operation != null) 'operation': operation,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (priority != null) 'priority': priority,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityType,
      Value<int>? entityLocalId,
      Value<String>? operation,
      Value<int>? retryCount,
      Value<String?>? lastError,
      Value<int>? priority,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastAttemptAt}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityLocalId: entityLocalId ?? this.entityLocalId,
      operation: operation ?? this.operation,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityLocalId.present) {
      map['entity_local_id'] = Variable<int>(entityLocalId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityLocalId: $entityLocalId, ')
          ..write('operation: $operation, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt')
          ..write(')'))
        .toString();
  }
}

class $LocalToolConfigsTable extends LocalToolConfigs
    with TableInfo<$LocalToolConfigsTable, LocalToolConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalToolConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _toolTypeMeta =
      const VerificationMeta('toolType');
  @override
  late final GeneratedColumn<String> toolType = GeneratedColumn<String>(
      'tool_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _toolIdMeta = const VerificationMeta('toolId');
  @override
  late final GeneratedColumn<String> toolId = GeneratedColumn<String>(
      'tool_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameTeMeta = const VerificationMeta('nameTe');
  @override
  late final GeneratedColumn<String> nameTe = GeneratedColumn<String>(
      'name_te', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _descriptionTeMeta =
      const VerificationMeta('descriptionTe');
  @override
  late final GeneratedColumn<String> descriptionTe = GeneratedColumn<String>(
      'description_te', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _minAgeMonthsMeta =
      const VerificationMeta('minAgeMonths');
  @override
  late final GeneratedColumn<int> minAgeMonths = GeneratedColumn<int>(
      'min_age_months', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _maxAgeMonthsMeta =
      const VerificationMeta('maxAgeMonths');
  @override
  late final GeneratedColumn<int> maxAgeMonths = GeneratedColumn<int>(
      'max_age_months', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(72));
  static const VerificationMeta _responseFormatMeta =
      const VerificationMeta('responseFormat');
  @override
  late final GeneratedColumn<String> responseFormat = GeneratedColumn<String>(
      'response_format', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _domainsJsonMeta =
      const VerificationMeta('domainsJson');
  @override
  late final GeneratedColumn<String> domainsJson = GeneratedColumn<String>(
      'domains_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isAgeBracketFilteredMeta =
      const VerificationMeta('isAgeBracketFiltered');
  @override
  late final GeneratedColumn<bool> isAgeBracketFiltered = GeneratedColumn<bool>(
      'is_age_bracket_filtered', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_age_bracket_filtered" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remoteId,
        toolType,
        toolId,
        name,
        nameTe,
        description,
        descriptionTe,
        minAgeMonths,
        maxAgeMonths,
        responseFormat,
        domainsJson,
        iconName,
        colorHex,
        sortOrder,
        isAgeBracketFiltered,
        isActive,
        version,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_tool_configs';
  @override
  VerificationContext validateIntegrity(Insertable<LocalToolConfig> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('tool_type')) {
      context.handle(_toolTypeMeta,
          toolType.isAcceptableOrUnknown(data['tool_type']!, _toolTypeMeta));
    } else if (isInserting) {
      context.missing(_toolTypeMeta);
    }
    if (data.containsKey('tool_id')) {
      context.handle(_toolIdMeta,
          toolId.isAcceptableOrUnknown(data['tool_id']!, _toolIdMeta));
    } else if (isInserting) {
      context.missing(_toolIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_te')) {
      context.handle(_nameTeMeta,
          nameTe.isAcceptableOrUnknown(data['name_te']!, _nameTeMeta));
    } else if (isInserting) {
      context.missing(_nameTeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('description_te')) {
      context.handle(
          _descriptionTeMeta,
          descriptionTe.isAcceptableOrUnknown(
              data['description_te']!, _descriptionTeMeta));
    }
    if (data.containsKey('min_age_months')) {
      context.handle(
          _minAgeMonthsMeta,
          minAgeMonths.isAcceptableOrUnknown(
              data['min_age_months']!, _minAgeMonthsMeta));
    }
    if (data.containsKey('max_age_months')) {
      context.handle(
          _maxAgeMonthsMeta,
          maxAgeMonths.isAcceptableOrUnknown(
              data['max_age_months']!, _maxAgeMonthsMeta));
    }
    if (data.containsKey('response_format')) {
      context.handle(
          _responseFormatMeta,
          responseFormat.isAcceptableOrUnknown(
              data['response_format']!, _responseFormatMeta));
    } else if (isInserting) {
      context.missing(_responseFormatMeta);
    }
    if (data.containsKey('domains_json')) {
      context.handle(
          _domainsJsonMeta,
          domainsJson.isAcceptableOrUnknown(
              data['domains_json']!, _domainsJsonMeta));
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_age_bracket_filtered')) {
      context.handle(
          _isAgeBracketFilteredMeta,
          isAgeBracketFiltered.isAcceptableOrUnknown(
              data['is_age_bracket_filtered']!, _isAgeBracketFilteredMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalToolConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalToolConfig(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}remote_id']),
      toolType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tool_type'])!,
      toolId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tool_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      nameTe: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_te'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      descriptionTe: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description_te'])!,
      minAgeMonths: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}min_age_months'])!,
      maxAgeMonths: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_age_months'])!,
      responseFormat: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}response_format'])!,
      domainsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domains_json'])!,
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name']),
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isAgeBracketFiltered: attachedDatabase.typeMapping.read(DriftSqlType.bool,
          data['${effectivePrefix}is_age_bracket_filtered'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $LocalToolConfigsTable createAlias(String alias) {
    return $LocalToolConfigsTable(attachedDatabase, alias);
  }
}

class LocalToolConfig extends DataClass implements Insertable<LocalToolConfig> {
  final int id;
  final int? remoteId;
  final String toolType;
  final String toolId;
  final String name;
  final String nameTe;
  final String description;
  final String descriptionTe;
  final int minAgeMonths;
  final int maxAgeMonths;
  final String responseFormat;
  final String domainsJson;
  final String? iconName;
  final String? colorHex;
  final int sortOrder;
  final bool isAgeBracketFiltered;
  final bool isActive;
  final int version;
  final DateTime? lastSyncedAt;
  const LocalToolConfig(
      {required this.id,
      this.remoteId,
      required this.toolType,
      required this.toolId,
      required this.name,
      required this.nameTe,
      required this.description,
      required this.descriptionTe,
      required this.minAgeMonths,
      required this.maxAgeMonths,
      required this.responseFormat,
      required this.domainsJson,
      this.iconName,
      this.colorHex,
      required this.sortOrder,
      required this.isAgeBracketFiltered,
      required this.isActive,
      required this.version,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    map['tool_type'] = Variable<String>(toolType);
    map['tool_id'] = Variable<String>(toolId);
    map['name'] = Variable<String>(name);
    map['name_te'] = Variable<String>(nameTe);
    map['description'] = Variable<String>(description);
    map['description_te'] = Variable<String>(descriptionTe);
    map['min_age_months'] = Variable<int>(minAgeMonths);
    map['max_age_months'] = Variable<int>(maxAgeMonths);
    map['response_format'] = Variable<String>(responseFormat);
    map['domains_json'] = Variable<String>(domainsJson);
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<String>(colorHex);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_age_bracket_filtered'] = Variable<bool>(isAgeBracketFiltered);
    map['is_active'] = Variable<bool>(isActive);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalToolConfigsCompanion toCompanion(bool nullToAbsent) {
    return LocalToolConfigsCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      toolType: Value(toolType),
      toolId: Value(toolId),
      name: Value(name),
      nameTe: Value(nameTe),
      description: Value(description),
      descriptionTe: Value(descriptionTe),
      minAgeMonths: Value(minAgeMonths),
      maxAgeMonths: Value(maxAgeMonths),
      responseFormat: Value(responseFormat),
      domainsJson: Value(domainsJson),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
      sortOrder: Value(sortOrder),
      isAgeBracketFiltered: Value(isAgeBracketFiltered),
      isActive: Value(isActive),
      version: Value(version),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalToolConfig.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalToolConfig(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      toolType: serializer.fromJson<String>(json['toolType']),
      toolId: serializer.fromJson<String>(json['toolId']),
      name: serializer.fromJson<String>(json['name']),
      nameTe: serializer.fromJson<String>(json['nameTe']),
      description: serializer.fromJson<String>(json['description']),
      descriptionTe: serializer.fromJson<String>(json['descriptionTe']),
      minAgeMonths: serializer.fromJson<int>(json['minAgeMonths']),
      maxAgeMonths: serializer.fromJson<int>(json['maxAgeMonths']),
      responseFormat: serializer.fromJson<String>(json['responseFormat']),
      domainsJson: serializer.fromJson<String>(json['domainsJson']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      colorHex: serializer.fromJson<String?>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isAgeBracketFiltered:
          serializer.fromJson<bool>(json['isAgeBracketFiltered']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      version: serializer.fromJson<int>(json['version']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int?>(remoteId),
      'toolType': serializer.toJson<String>(toolType),
      'toolId': serializer.toJson<String>(toolId),
      'name': serializer.toJson<String>(name),
      'nameTe': serializer.toJson<String>(nameTe),
      'description': serializer.toJson<String>(description),
      'descriptionTe': serializer.toJson<String>(descriptionTe),
      'minAgeMonths': serializer.toJson<int>(minAgeMonths),
      'maxAgeMonths': serializer.toJson<int>(maxAgeMonths),
      'responseFormat': serializer.toJson<String>(responseFormat),
      'domainsJson': serializer.toJson<String>(domainsJson),
      'iconName': serializer.toJson<String?>(iconName),
      'colorHex': serializer.toJson<String?>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isAgeBracketFiltered': serializer.toJson<bool>(isAgeBracketFiltered),
      'isActive': serializer.toJson<bool>(isActive),
      'version': serializer.toJson<int>(version),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalToolConfig copyWith(
          {int? id,
          Value<int?> remoteId = const Value.absent(),
          String? toolType,
          String? toolId,
          String? name,
          String? nameTe,
          String? description,
          String? descriptionTe,
          int? minAgeMonths,
          int? maxAgeMonths,
          String? responseFormat,
          String? domainsJson,
          Value<String?> iconName = const Value.absent(),
          Value<String?> colorHex = const Value.absent(),
          int? sortOrder,
          bool? isAgeBracketFiltered,
          bool? isActive,
          int? version,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      LocalToolConfig(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        toolType: toolType ?? this.toolType,
        toolId: toolId ?? this.toolId,
        name: name ?? this.name,
        nameTe: nameTe ?? this.nameTe,
        description: description ?? this.description,
        descriptionTe: descriptionTe ?? this.descriptionTe,
        minAgeMonths: minAgeMonths ?? this.minAgeMonths,
        maxAgeMonths: maxAgeMonths ?? this.maxAgeMonths,
        responseFormat: responseFormat ?? this.responseFormat,
        domainsJson: domainsJson ?? this.domainsJson,
        iconName: iconName.present ? iconName.value : this.iconName,
        colorHex: colorHex.present ? colorHex.value : this.colorHex,
        sortOrder: sortOrder ?? this.sortOrder,
        isAgeBracketFiltered: isAgeBracketFiltered ?? this.isAgeBracketFiltered,
        isActive: isActive ?? this.isActive,
        version: version ?? this.version,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  LocalToolConfig copyWithCompanion(LocalToolConfigsCompanion data) {
    return LocalToolConfig(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      toolType: data.toolType.present ? data.toolType.value : this.toolType,
      toolId: data.toolId.present ? data.toolId.value : this.toolId,
      name: data.name.present ? data.name.value : this.name,
      nameTe: data.nameTe.present ? data.nameTe.value : this.nameTe,
      description:
          data.description.present ? data.description.value : this.description,
      descriptionTe: data.descriptionTe.present
          ? data.descriptionTe.value
          : this.descriptionTe,
      minAgeMonths: data.minAgeMonths.present
          ? data.minAgeMonths.value
          : this.minAgeMonths,
      maxAgeMonths: data.maxAgeMonths.present
          ? data.maxAgeMonths.value
          : this.maxAgeMonths,
      responseFormat: data.responseFormat.present
          ? data.responseFormat.value
          : this.responseFormat,
      domainsJson:
          data.domainsJson.present ? data.domainsJson.value : this.domainsJson,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isAgeBracketFiltered: data.isAgeBracketFiltered.present
          ? data.isAgeBracketFiltered.value
          : this.isAgeBracketFiltered,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      version: data.version.present ? data.version.value : this.version,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalToolConfig(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('toolType: $toolType, ')
          ..write('toolId: $toolId, ')
          ..write('name: $name, ')
          ..write('nameTe: $nameTe, ')
          ..write('description: $description, ')
          ..write('descriptionTe: $descriptionTe, ')
          ..write('minAgeMonths: $minAgeMonths, ')
          ..write('maxAgeMonths: $maxAgeMonths, ')
          ..write('responseFormat: $responseFormat, ')
          ..write('domainsJson: $domainsJson, ')
          ..write('iconName: $iconName, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isAgeBracketFiltered: $isAgeBracketFiltered, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      remoteId,
      toolType,
      toolId,
      name,
      nameTe,
      description,
      descriptionTe,
      minAgeMonths,
      maxAgeMonths,
      responseFormat,
      domainsJson,
      iconName,
      colorHex,
      sortOrder,
      isAgeBracketFiltered,
      isActive,
      version,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalToolConfig &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.toolType == this.toolType &&
          other.toolId == this.toolId &&
          other.name == this.name &&
          other.nameTe == this.nameTe &&
          other.description == this.description &&
          other.descriptionTe == this.descriptionTe &&
          other.minAgeMonths == this.minAgeMonths &&
          other.maxAgeMonths == this.maxAgeMonths &&
          other.responseFormat == this.responseFormat &&
          other.domainsJson == this.domainsJson &&
          other.iconName == this.iconName &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder &&
          other.isAgeBracketFiltered == this.isAgeBracketFiltered &&
          other.isActive == this.isActive &&
          other.version == this.version &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalToolConfigsCompanion extends UpdateCompanion<LocalToolConfig> {
  final Value<int> id;
  final Value<int?> remoteId;
  final Value<String> toolType;
  final Value<String> toolId;
  final Value<String> name;
  final Value<String> nameTe;
  final Value<String> description;
  final Value<String> descriptionTe;
  final Value<int> minAgeMonths;
  final Value<int> maxAgeMonths;
  final Value<String> responseFormat;
  final Value<String> domainsJson;
  final Value<String?> iconName;
  final Value<String?> colorHex;
  final Value<int> sortOrder;
  final Value<bool> isAgeBracketFiltered;
  final Value<bool> isActive;
  final Value<int> version;
  final Value<DateTime?> lastSyncedAt;
  const LocalToolConfigsCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.toolType = const Value.absent(),
    this.toolId = const Value.absent(),
    this.name = const Value.absent(),
    this.nameTe = const Value.absent(),
    this.description = const Value.absent(),
    this.descriptionTe = const Value.absent(),
    this.minAgeMonths = const Value.absent(),
    this.maxAgeMonths = const Value.absent(),
    this.responseFormat = const Value.absent(),
    this.domainsJson = const Value.absent(),
    this.iconName = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isAgeBracketFiltered = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  LocalToolConfigsCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    required String toolType,
    required String toolId,
    required String name,
    required String nameTe,
    this.description = const Value.absent(),
    this.descriptionTe = const Value.absent(),
    this.minAgeMonths = const Value.absent(),
    this.maxAgeMonths = const Value.absent(),
    required String responseFormat,
    this.domainsJson = const Value.absent(),
    this.iconName = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isAgeBracketFiltered = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  })  : toolType = Value(toolType),
        toolId = Value(toolId),
        name = Value(name),
        nameTe = Value(nameTe),
        responseFormat = Value(responseFormat);
  static Insertable<LocalToolConfig> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<String>? toolType,
    Expression<String>? toolId,
    Expression<String>? name,
    Expression<String>? nameTe,
    Expression<String>? description,
    Expression<String>? descriptionTe,
    Expression<int>? minAgeMonths,
    Expression<int>? maxAgeMonths,
    Expression<String>? responseFormat,
    Expression<String>? domainsJson,
    Expression<String>? iconName,
    Expression<String>? colorHex,
    Expression<int>? sortOrder,
    Expression<bool>? isAgeBracketFiltered,
    Expression<bool>? isActive,
    Expression<int>? version,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (toolType != null) 'tool_type': toolType,
      if (toolId != null) 'tool_id': toolId,
      if (name != null) 'name': name,
      if (nameTe != null) 'name_te': nameTe,
      if (description != null) 'description': description,
      if (descriptionTe != null) 'description_te': descriptionTe,
      if (minAgeMonths != null) 'min_age_months': minAgeMonths,
      if (maxAgeMonths != null) 'max_age_months': maxAgeMonths,
      if (responseFormat != null) 'response_format': responseFormat,
      if (domainsJson != null) 'domains_json': domainsJson,
      if (iconName != null) 'icon_name': iconName,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isAgeBracketFiltered != null)
        'is_age_bracket_filtered': isAgeBracketFiltered,
      if (isActive != null) 'is_active': isActive,
      if (version != null) 'version': version,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  LocalToolConfigsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? remoteId,
      Value<String>? toolType,
      Value<String>? toolId,
      Value<String>? name,
      Value<String>? nameTe,
      Value<String>? description,
      Value<String>? descriptionTe,
      Value<int>? minAgeMonths,
      Value<int>? maxAgeMonths,
      Value<String>? responseFormat,
      Value<String>? domainsJson,
      Value<String?>? iconName,
      Value<String?>? colorHex,
      Value<int>? sortOrder,
      Value<bool>? isAgeBracketFiltered,
      Value<bool>? isActive,
      Value<int>? version,
      Value<DateTime?>? lastSyncedAt}) {
    return LocalToolConfigsCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      toolType: toolType ?? this.toolType,
      toolId: toolId ?? this.toolId,
      name: name ?? this.name,
      nameTe: nameTe ?? this.nameTe,
      description: description ?? this.description,
      descriptionTe: descriptionTe ?? this.descriptionTe,
      minAgeMonths: minAgeMonths ?? this.minAgeMonths,
      maxAgeMonths: maxAgeMonths ?? this.maxAgeMonths,
      responseFormat: responseFormat ?? this.responseFormat,
      domainsJson: domainsJson ?? this.domainsJson,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      isAgeBracketFiltered: isAgeBracketFiltered ?? this.isAgeBracketFiltered,
      isActive: isActive ?? this.isActive,
      version: version ?? this.version,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (toolType.present) {
      map['tool_type'] = Variable<String>(toolType.value);
    }
    if (toolId.present) {
      map['tool_id'] = Variable<String>(toolId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameTe.present) {
      map['name_te'] = Variable<String>(nameTe.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (descriptionTe.present) {
      map['description_te'] = Variable<String>(descriptionTe.value);
    }
    if (minAgeMonths.present) {
      map['min_age_months'] = Variable<int>(minAgeMonths.value);
    }
    if (maxAgeMonths.present) {
      map['max_age_months'] = Variable<int>(maxAgeMonths.value);
    }
    if (responseFormat.present) {
      map['response_format'] = Variable<String>(responseFormat.value);
    }
    if (domainsJson.present) {
      map['domains_json'] = Variable<String>(domainsJson.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isAgeBracketFiltered.present) {
      map['is_age_bracket_filtered'] =
          Variable<bool>(isAgeBracketFiltered.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalToolConfigsCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('toolType: $toolType, ')
          ..write('toolId: $toolId, ')
          ..write('name: $name, ')
          ..write('nameTe: $nameTe, ')
          ..write('description: $description, ')
          ..write('descriptionTe: $descriptionTe, ')
          ..write('minAgeMonths: $minAgeMonths, ')
          ..write('maxAgeMonths: $maxAgeMonths, ')
          ..write('responseFormat: $responseFormat, ')
          ..write('domainsJson: $domainsJson, ')
          ..write('iconName: $iconName, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isAgeBracketFiltered: $isAgeBracketFiltered, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalQuestionsTable extends LocalQuestions
    with TableInfo<$LocalQuestionsTable, LocalQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _toolConfigIdMeta =
      const VerificationMeta('toolConfigId');
  @override
  late final GeneratedColumn<int> toolConfigId = GeneratedColumn<int>(
      'tool_config_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _textEnMeta = const VerificationMeta('textEn');
  @override
  late final GeneratedColumn<String> textEn = GeneratedColumn<String>(
      'text_en', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _textTeMeta = const VerificationMeta('textTe');
  @override
  late final GeneratedColumn<String> textTe = GeneratedColumn<String>(
      'text_te', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
      'domain', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _domainNameEnMeta =
      const VerificationMeta('domainNameEn');
  @override
  late final GeneratedColumn<String> domainNameEn = GeneratedColumn<String>(
      'domain_name_en', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _domainNameTeMeta =
      const VerificationMeta('domainNameTe');
  @override
  late final GeneratedColumn<String> domainNameTe = GeneratedColumn<String>(
      'domain_name_te', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryTeMeta =
      const VerificationMeta('categoryTe');
  @override
  late final GeneratedColumn<String> categoryTe = GeneratedColumn<String>(
      'category_te', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ageMonthsMeta =
      const VerificationMeta('ageMonths');
  @override
  late final GeneratedColumn<int> ageMonths = GeneratedColumn<int>(
      'age_months', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isCriticalMeta =
      const VerificationMeta('isCritical');
  @override
  late final GeneratedColumn<bool> isCritical = GeneratedColumn<bool>(
      'is_critical', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_critical" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isRedFlagMeta =
      const VerificationMeta('isRedFlag');
  @override
  late final GeneratedColumn<bool> isRedFlag = GeneratedColumn<bool>(
      'is_red_flag', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_red_flag" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isReverseScoredMeta =
      const VerificationMeta('isReverseScored');
  @override
  late final GeneratedColumn<bool> isReverseScored = GeneratedColumn<bool>(
      'is_reverse_scored', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_reverse_scored" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _overrideFormatMeta =
      const VerificationMeta('overrideFormat');
  @override
  late final GeneratedColumn<String> overrideFormat = GeneratedColumn<String>(
      'override_format', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remoteId,
        toolConfigId,
        code,
        textEn,
        textTe,
        domain,
        domainNameEn,
        domainNameTe,
        category,
        categoryTe,
        ageMonths,
        isCritical,
        isRedFlag,
        isReverseScored,
        unit,
        overrideFormat,
        sortOrder,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_questions';
  @override
  VerificationContext validateIntegrity(Insertable<LocalQuestion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('tool_config_id')) {
      context.handle(
          _toolConfigIdMeta,
          toolConfigId.isAcceptableOrUnknown(
              data['tool_config_id']!, _toolConfigIdMeta));
    } else if (isInserting) {
      context.missing(_toolConfigIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('text_en')) {
      context.handle(_textEnMeta,
          textEn.isAcceptableOrUnknown(data['text_en']!, _textEnMeta));
    } else if (isInserting) {
      context.missing(_textEnMeta);
    }
    if (data.containsKey('text_te')) {
      context.handle(_textTeMeta,
          textTe.isAcceptableOrUnknown(data['text_te']!, _textTeMeta));
    } else if (isInserting) {
      context.missing(_textTeMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(_domainMeta,
          domain.isAcceptableOrUnknown(data['domain']!, _domainMeta));
    }
    if (data.containsKey('domain_name_en')) {
      context.handle(
          _domainNameEnMeta,
          domainNameEn.isAcceptableOrUnknown(
              data['domain_name_en']!, _domainNameEnMeta));
    }
    if (data.containsKey('domain_name_te')) {
      context.handle(
          _domainNameTeMeta,
          domainNameTe.isAcceptableOrUnknown(
              data['domain_name_te']!, _domainNameTeMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('category_te')) {
      context.handle(
          _categoryTeMeta,
          categoryTe.isAcceptableOrUnknown(
              data['category_te']!, _categoryTeMeta));
    }
    if (data.containsKey('age_months')) {
      context.handle(_ageMonthsMeta,
          ageMonths.isAcceptableOrUnknown(data['age_months']!, _ageMonthsMeta));
    }
    if (data.containsKey('is_critical')) {
      context.handle(
          _isCriticalMeta,
          isCritical.isAcceptableOrUnknown(
              data['is_critical']!, _isCriticalMeta));
    }
    if (data.containsKey('is_red_flag')) {
      context.handle(
          _isRedFlagMeta,
          isRedFlag.isAcceptableOrUnknown(
              data['is_red_flag']!, _isRedFlagMeta));
    }
    if (data.containsKey('is_reverse_scored')) {
      context.handle(
          _isReverseScoredMeta,
          isReverseScored.isAcceptableOrUnknown(
              data['is_reverse_scored']!, _isReverseScoredMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('override_format')) {
      context.handle(
          _overrideFormatMeta,
          overrideFormat.isAcceptableOrUnknown(
              data['override_format']!, _overrideFormatMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalQuestion(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}remote_id']),
      toolConfigId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tool_config_id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      textEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_en'])!,
      textTe: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_te'])!,
      domain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domain']),
      domainNameEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domain_name_en']),
      domainNameTe: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domain_name_te']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      categoryTe: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_te']),
      ageMonths: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age_months']),
      isCritical: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_critical'])!,
      isRedFlag: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_red_flag'])!,
      isReverseScored: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_reverse_scored'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit']),
      overrideFormat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}override_format']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $LocalQuestionsTable createAlias(String alias) {
    return $LocalQuestionsTable(attachedDatabase, alias);
  }
}

class LocalQuestion extends DataClass implements Insertable<LocalQuestion> {
  final int id;
  final int? remoteId;
  final int toolConfigId;
  final String code;
  final String textEn;
  final String textTe;
  final String? domain;
  final String? domainNameEn;
  final String? domainNameTe;
  final String? category;
  final String? categoryTe;
  final int? ageMonths;
  final bool isCritical;
  final bool isRedFlag;
  final bool isReverseScored;
  final String? unit;
  final String? overrideFormat;
  final int sortOrder;
  final bool isActive;
  const LocalQuestion(
      {required this.id,
      this.remoteId,
      required this.toolConfigId,
      required this.code,
      required this.textEn,
      required this.textTe,
      this.domain,
      this.domainNameEn,
      this.domainNameTe,
      this.category,
      this.categoryTe,
      this.ageMonths,
      required this.isCritical,
      required this.isRedFlag,
      required this.isReverseScored,
      this.unit,
      this.overrideFormat,
      required this.sortOrder,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    map['tool_config_id'] = Variable<int>(toolConfigId);
    map['code'] = Variable<String>(code);
    map['text_en'] = Variable<String>(textEn);
    map['text_te'] = Variable<String>(textTe);
    if (!nullToAbsent || domain != null) {
      map['domain'] = Variable<String>(domain);
    }
    if (!nullToAbsent || domainNameEn != null) {
      map['domain_name_en'] = Variable<String>(domainNameEn);
    }
    if (!nullToAbsent || domainNameTe != null) {
      map['domain_name_te'] = Variable<String>(domainNameTe);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || categoryTe != null) {
      map['category_te'] = Variable<String>(categoryTe);
    }
    if (!nullToAbsent || ageMonths != null) {
      map['age_months'] = Variable<int>(ageMonths);
    }
    map['is_critical'] = Variable<bool>(isCritical);
    map['is_red_flag'] = Variable<bool>(isRedFlag);
    map['is_reverse_scored'] = Variable<bool>(isReverseScored);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || overrideFormat != null) {
      map['override_format'] = Variable<String>(overrideFormat);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  LocalQuestionsCompanion toCompanion(bool nullToAbsent) {
    return LocalQuestionsCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      toolConfigId: Value(toolConfigId),
      code: Value(code),
      textEn: Value(textEn),
      textTe: Value(textTe),
      domain:
          domain == null && nullToAbsent ? const Value.absent() : Value(domain),
      domainNameEn: domainNameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(domainNameEn),
      domainNameTe: domainNameTe == null && nullToAbsent
          ? const Value.absent()
          : Value(domainNameTe),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      categoryTe: categoryTe == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryTe),
      ageMonths: ageMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(ageMonths),
      isCritical: Value(isCritical),
      isRedFlag: Value(isRedFlag),
      isReverseScored: Value(isReverseScored),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      overrideFormat: overrideFormat == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideFormat),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
    );
  }

  factory LocalQuestion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalQuestion(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      toolConfigId: serializer.fromJson<int>(json['toolConfigId']),
      code: serializer.fromJson<String>(json['code']),
      textEn: serializer.fromJson<String>(json['textEn']),
      textTe: serializer.fromJson<String>(json['textTe']),
      domain: serializer.fromJson<String?>(json['domain']),
      domainNameEn: serializer.fromJson<String?>(json['domainNameEn']),
      domainNameTe: serializer.fromJson<String?>(json['domainNameTe']),
      category: serializer.fromJson<String?>(json['category']),
      categoryTe: serializer.fromJson<String?>(json['categoryTe']),
      ageMonths: serializer.fromJson<int?>(json['ageMonths']),
      isCritical: serializer.fromJson<bool>(json['isCritical']),
      isRedFlag: serializer.fromJson<bool>(json['isRedFlag']),
      isReverseScored: serializer.fromJson<bool>(json['isReverseScored']),
      unit: serializer.fromJson<String?>(json['unit']),
      overrideFormat: serializer.fromJson<String?>(json['overrideFormat']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int?>(remoteId),
      'toolConfigId': serializer.toJson<int>(toolConfigId),
      'code': serializer.toJson<String>(code),
      'textEn': serializer.toJson<String>(textEn),
      'textTe': serializer.toJson<String>(textTe),
      'domain': serializer.toJson<String?>(domain),
      'domainNameEn': serializer.toJson<String?>(domainNameEn),
      'domainNameTe': serializer.toJson<String?>(domainNameTe),
      'category': serializer.toJson<String?>(category),
      'categoryTe': serializer.toJson<String?>(categoryTe),
      'ageMonths': serializer.toJson<int?>(ageMonths),
      'isCritical': serializer.toJson<bool>(isCritical),
      'isRedFlag': serializer.toJson<bool>(isRedFlag),
      'isReverseScored': serializer.toJson<bool>(isReverseScored),
      'unit': serializer.toJson<String?>(unit),
      'overrideFormat': serializer.toJson<String?>(overrideFormat),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  LocalQuestion copyWith(
          {int? id,
          Value<int?> remoteId = const Value.absent(),
          int? toolConfigId,
          String? code,
          String? textEn,
          String? textTe,
          Value<String?> domain = const Value.absent(),
          Value<String?> domainNameEn = const Value.absent(),
          Value<String?> domainNameTe = const Value.absent(),
          Value<String?> category = const Value.absent(),
          Value<String?> categoryTe = const Value.absent(),
          Value<int?> ageMonths = const Value.absent(),
          bool? isCritical,
          bool? isRedFlag,
          bool? isReverseScored,
          Value<String?> unit = const Value.absent(),
          Value<String?> overrideFormat = const Value.absent(),
          int? sortOrder,
          bool? isActive}) =>
      LocalQuestion(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        toolConfigId: toolConfigId ?? this.toolConfigId,
        code: code ?? this.code,
        textEn: textEn ?? this.textEn,
        textTe: textTe ?? this.textTe,
        domain: domain.present ? domain.value : this.domain,
        domainNameEn:
            domainNameEn.present ? domainNameEn.value : this.domainNameEn,
        domainNameTe:
            domainNameTe.present ? domainNameTe.value : this.domainNameTe,
        category: category.present ? category.value : this.category,
        categoryTe: categoryTe.present ? categoryTe.value : this.categoryTe,
        ageMonths: ageMonths.present ? ageMonths.value : this.ageMonths,
        isCritical: isCritical ?? this.isCritical,
        isRedFlag: isRedFlag ?? this.isRedFlag,
        isReverseScored: isReverseScored ?? this.isReverseScored,
        unit: unit.present ? unit.value : this.unit,
        overrideFormat:
            overrideFormat.present ? overrideFormat.value : this.overrideFormat,
        sortOrder: sortOrder ?? this.sortOrder,
        isActive: isActive ?? this.isActive,
      );
  LocalQuestion copyWithCompanion(LocalQuestionsCompanion data) {
    return LocalQuestion(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      toolConfigId: data.toolConfigId.present
          ? data.toolConfigId.value
          : this.toolConfigId,
      code: data.code.present ? data.code.value : this.code,
      textEn: data.textEn.present ? data.textEn.value : this.textEn,
      textTe: data.textTe.present ? data.textTe.value : this.textTe,
      domain: data.domain.present ? data.domain.value : this.domain,
      domainNameEn: data.domainNameEn.present
          ? data.domainNameEn.value
          : this.domainNameEn,
      domainNameTe: data.domainNameTe.present
          ? data.domainNameTe.value
          : this.domainNameTe,
      category: data.category.present ? data.category.value : this.category,
      categoryTe:
          data.categoryTe.present ? data.categoryTe.value : this.categoryTe,
      ageMonths: data.ageMonths.present ? data.ageMonths.value : this.ageMonths,
      isCritical:
          data.isCritical.present ? data.isCritical.value : this.isCritical,
      isRedFlag: data.isRedFlag.present ? data.isRedFlag.value : this.isRedFlag,
      isReverseScored: data.isReverseScored.present
          ? data.isReverseScored.value
          : this.isReverseScored,
      unit: data.unit.present ? data.unit.value : this.unit,
      overrideFormat: data.overrideFormat.present
          ? data.overrideFormat.value
          : this.overrideFormat,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuestion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('toolConfigId: $toolConfigId, ')
          ..write('code: $code, ')
          ..write('textEn: $textEn, ')
          ..write('textTe: $textTe, ')
          ..write('domain: $domain, ')
          ..write('domainNameEn: $domainNameEn, ')
          ..write('domainNameTe: $domainNameTe, ')
          ..write('category: $category, ')
          ..write('categoryTe: $categoryTe, ')
          ..write('ageMonths: $ageMonths, ')
          ..write('isCritical: $isCritical, ')
          ..write('isRedFlag: $isRedFlag, ')
          ..write('isReverseScored: $isReverseScored, ')
          ..write('unit: $unit, ')
          ..write('overrideFormat: $overrideFormat, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      remoteId,
      toolConfigId,
      code,
      textEn,
      textTe,
      domain,
      domainNameEn,
      domainNameTe,
      category,
      categoryTe,
      ageMonths,
      isCritical,
      isRedFlag,
      isReverseScored,
      unit,
      overrideFormat,
      sortOrder,
      isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalQuestion &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.toolConfigId == this.toolConfigId &&
          other.code == this.code &&
          other.textEn == this.textEn &&
          other.textTe == this.textTe &&
          other.domain == this.domain &&
          other.domainNameEn == this.domainNameEn &&
          other.domainNameTe == this.domainNameTe &&
          other.category == this.category &&
          other.categoryTe == this.categoryTe &&
          other.ageMonths == this.ageMonths &&
          other.isCritical == this.isCritical &&
          other.isRedFlag == this.isRedFlag &&
          other.isReverseScored == this.isReverseScored &&
          other.unit == this.unit &&
          other.overrideFormat == this.overrideFormat &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive);
}

class LocalQuestionsCompanion extends UpdateCompanion<LocalQuestion> {
  final Value<int> id;
  final Value<int?> remoteId;
  final Value<int> toolConfigId;
  final Value<String> code;
  final Value<String> textEn;
  final Value<String> textTe;
  final Value<String?> domain;
  final Value<String?> domainNameEn;
  final Value<String?> domainNameTe;
  final Value<String?> category;
  final Value<String?> categoryTe;
  final Value<int?> ageMonths;
  final Value<bool> isCritical;
  final Value<bool> isRedFlag;
  final Value<bool> isReverseScored;
  final Value<String?> unit;
  final Value<String?> overrideFormat;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  const LocalQuestionsCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.toolConfigId = const Value.absent(),
    this.code = const Value.absent(),
    this.textEn = const Value.absent(),
    this.textTe = const Value.absent(),
    this.domain = const Value.absent(),
    this.domainNameEn = const Value.absent(),
    this.domainNameTe = const Value.absent(),
    this.category = const Value.absent(),
    this.categoryTe = const Value.absent(),
    this.ageMonths = const Value.absent(),
    this.isCritical = const Value.absent(),
    this.isRedFlag = const Value.absent(),
    this.isReverseScored = const Value.absent(),
    this.unit = const Value.absent(),
    this.overrideFormat = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  LocalQuestionsCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    required int toolConfigId,
    required String code,
    required String textEn,
    required String textTe,
    this.domain = const Value.absent(),
    this.domainNameEn = const Value.absent(),
    this.domainNameTe = const Value.absent(),
    this.category = const Value.absent(),
    this.categoryTe = const Value.absent(),
    this.ageMonths = const Value.absent(),
    this.isCritical = const Value.absent(),
    this.isRedFlag = const Value.absent(),
    this.isReverseScored = const Value.absent(),
    this.unit = const Value.absent(),
    this.overrideFormat = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
  })  : toolConfigId = Value(toolConfigId),
        code = Value(code),
        textEn = Value(textEn),
        textTe = Value(textTe);
  static Insertable<LocalQuestion> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<int>? toolConfigId,
    Expression<String>? code,
    Expression<String>? textEn,
    Expression<String>? textTe,
    Expression<String>? domain,
    Expression<String>? domainNameEn,
    Expression<String>? domainNameTe,
    Expression<String>? category,
    Expression<String>? categoryTe,
    Expression<int>? ageMonths,
    Expression<bool>? isCritical,
    Expression<bool>? isRedFlag,
    Expression<bool>? isReverseScored,
    Expression<String>? unit,
    Expression<String>? overrideFormat,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (toolConfigId != null) 'tool_config_id': toolConfigId,
      if (code != null) 'code': code,
      if (textEn != null) 'text_en': textEn,
      if (textTe != null) 'text_te': textTe,
      if (domain != null) 'domain': domain,
      if (domainNameEn != null) 'domain_name_en': domainNameEn,
      if (domainNameTe != null) 'domain_name_te': domainNameTe,
      if (category != null) 'category': category,
      if (categoryTe != null) 'category_te': categoryTe,
      if (ageMonths != null) 'age_months': ageMonths,
      if (isCritical != null) 'is_critical': isCritical,
      if (isRedFlag != null) 'is_red_flag': isRedFlag,
      if (isReverseScored != null) 'is_reverse_scored': isReverseScored,
      if (unit != null) 'unit': unit,
      if (overrideFormat != null) 'override_format': overrideFormat,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
    });
  }

  LocalQuestionsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? remoteId,
      Value<int>? toolConfigId,
      Value<String>? code,
      Value<String>? textEn,
      Value<String>? textTe,
      Value<String?>? domain,
      Value<String?>? domainNameEn,
      Value<String?>? domainNameTe,
      Value<String?>? category,
      Value<String?>? categoryTe,
      Value<int?>? ageMonths,
      Value<bool>? isCritical,
      Value<bool>? isRedFlag,
      Value<bool>? isReverseScored,
      Value<String?>? unit,
      Value<String?>? overrideFormat,
      Value<int>? sortOrder,
      Value<bool>? isActive}) {
    return LocalQuestionsCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      toolConfigId: toolConfigId ?? this.toolConfigId,
      code: code ?? this.code,
      textEn: textEn ?? this.textEn,
      textTe: textTe ?? this.textTe,
      domain: domain ?? this.domain,
      domainNameEn: domainNameEn ?? this.domainNameEn,
      domainNameTe: domainNameTe ?? this.domainNameTe,
      category: category ?? this.category,
      categoryTe: categoryTe ?? this.categoryTe,
      ageMonths: ageMonths ?? this.ageMonths,
      isCritical: isCritical ?? this.isCritical,
      isRedFlag: isRedFlag ?? this.isRedFlag,
      isReverseScored: isReverseScored ?? this.isReverseScored,
      unit: unit ?? this.unit,
      overrideFormat: overrideFormat ?? this.overrideFormat,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (toolConfigId.present) {
      map['tool_config_id'] = Variable<int>(toolConfigId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (textEn.present) {
      map['text_en'] = Variable<String>(textEn.value);
    }
    if (textTe.present) {
      map['text_te'] = Variable<String>(textTe.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (domainNameEn.present) {
      map['domain_name_en'] = Variable<String>(domainNameEn.value);
    }
    if (domainNameTe.present) {
      map['domain_name_te'] = Variable<String>(domainNameTe.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (categoryTe.present) {
      map['category_te'] = Variable<String>(categoryTe.value);
    }
    if (ageMonths.present) {
      map['age_months'] = Variable<int>(ageMonths.value);
    }
    if (isCritical.present) {
      map['is_critical'] = Variable<bool>(isCritical.value);
    }
    if (isRedFlag.present) {
      map['is_red_flag'] = Variable<bool>(isRedFlag.value);
    }
    if (isReverseScored.present) {
      map['is_reverse_scored'] = Variable<bool>(isReverseScored.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (overrideFormat.present) {
      map['override_format'] = Variable<String>(overrideFormat.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('toolConfigId: $toolConfigId, ')
          ..write('code: $code, ')
          ..write('textEn: $textEn, ')
          ..write('textTe: $textTe, ')
          ..write('domain: $domain, ')
          ..write('domainNameEn: $domainNameEn, ')
          ..write('domainNameTe: $domainNameTe, ')
          ..write('category: $category, ')
          ..write('categoryTe: $categoryTe, ')
          ..write('ageMonths: $ageMonths, ')
          ..write('isCritical: $isCritical, ')
          ..write('isRedFlag: $isRedFlag, ')
          ..write('isReverseScored: $isReverseScored, ')
          ..write('unit: $unit, ')
          ..write('overrideFormat: $overrideFormat, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $LocalResponseOptionsTable extends LocalResponseOptions
    with TableInfo<$LocalResponseOptionsTable, LocalResponseOption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalResponseOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _toolConfigIdMeta =
      const VerificationMeta('toolConfigId');
  @override
  late final GeneratedColumn<int> toolConfigId = GeneratedColumn<int>(
      'tool_config_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
      'question_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _labelEnMeta =
      const VerificationMeta('labelEn');
  @override
  late final GeneratedColumn<String> labelEn = GeneratedColumn<String>(
      'label_en', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelTeMeta =
      const VerificationMeta('labelTe');
  @override
  late final GeneratedColumn<String> labelTe = GeneratedColumn<String>(
      'label_te', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueJsonMeta =
      const VerificationMeta('valueJson');
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
      'value_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remoteId,
        toolConfigId,
        questionId,
        labelEn,
        labelTe,
        valueJson,
        colorHex,
        sortOrder
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_response_options';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalResponseOption> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('tool_config_id')) {
      context.handle(
          _toolConfigIdMeta,
          toolConfigId.isAcceptableOrUnknown(
              data['tool_config_id']!, _toolConfigIdMeta));
    } else if (isInserting) {
      context.missing(_toolConfigIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    }
    if (data.containsKey('label_en')) {
      context.handle(_labelEnMeta,
          labelEn.isAcceptableOrUnknown(data['label_en']!, _labelEnMeta));
    } else if (isInserting) {
      context.missing(_labelEnMeta);
    }
    if (data.containsKey('label_te')) {
      context.handle(_labelTeMeta,
          labelTe.isAcceptableOrUnknown(data['label_te']!, _labelTeMeta));
    } else if (isInserting) {
      context.missing(_labelTeMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(_valueJsonMeta,
          valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta));
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalResponseOption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalResponseOption(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}remote_id']),
      toolConfigId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tool_config_id'])!,
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}question_id']),
      labelEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label_en'])!,
      labelTe: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label_te'])!,
      valueJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value_json'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $LocalResponseOptionsTable createAlias(String alias) {
    return $LocalResponseOptionsTable(attachedDatabase, alias);
  }
}

class LocalResponseOption extends DataClass
    implements Insertable<LocalResponseOption> {
  final int id;
  final int? remoteId;
  final int toolConfigId;
  final int? questionId;
  final String labelEn;
  final String labelTe;
  final String valueJson;
  final String? colorHex;
  final int sortOrder;
  const LocalResponseOption(
      {required this.id,
      this.remoteId,
      required this.toolConfigId,
      this.questionId,
      required this.labelEn,
      required this.labelTe,
      required this.valueJson,
      this.colorHex,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    map['tool_config_id'] = Variable<int>(toolConfigId);
    if (!nullToAbsent || questionId != null) {
      map['question_id'] = Variable<int>(questionId);
    }
    map['label_en'] = Variable<String>(labelEn);
    map['label_te'] = Variable<String>(labelTe);
    map['value_json'] = Variable<String>(valueJson);
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<String>(colorHex);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LocalResponseOptionsCompanion toCompanion(bool nullToAbsent) {
    return LocalResponseOptionsCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      toolConfigId: Value(toolConfigId),
      questionId: questionId == null && nullToAbsent
          ? const Value.absent()
          : Value(questionId),
      labelEn: Value(labelEn),
      labelTe: Value(labelTe),
      valueJson: Value(valueJson),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
      sortOrder: Value(sortOrder),
    );
  }

  factory LocalResponseOption.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalResponseOption(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      toolConfigId: serializer.fromJson<int>(json['toolConfigId']),
      questionId: serializer.fromJson<int?>(json['questionId']),
      labelEn: serializer.fromJson<String>(json['labelEn']),
      labelTe: serializer.fromJson<String>(json['labelTe']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      colorHex: serializer.fromJson<String?>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int?>(remoteId),
      'toolConfigId': serializer.toJson<int>(toolConfigId),
      'questionId': serializer.toJson<int?>(questionId),
      'labelEn': serializer.toJson<String>(labelEn),
      'labelTe': serializer.toJson<String>(labelTe),
      'valueJson': serializer.toJson<String>(valueJson),
      'colorHex': serializer.toJson<String?>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LocalResponseOption copyWith(
          {int? id,
          Value<int?> remoteId = const Value.absent(),
          int? toolConfigId,
          Value<int?> questionId = const Value.absent(),
          String? labelEn,
          String? labelTe,
          String? valueJson,
          Value<String?> colorHex = const Value.absent(),
          int? sortOrder}) =>
      LocalResponseOption(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        toolConfigId: toolConfigId ?? this.toolConfigId,
        questionId: questionId.present ? questionId.value : this.questionId,
        labelEn: labelEn ?? this.labelEn,
        labelTe: labelTe ?? this.labelTe,
        valueJson: valueJson ?? this.valueJson,
        colorHex: colorHex.present ? colorHex.value : this.colorHex,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  LocalResponseOption copyWithCompanion(LocalResponseOptionsCompanion data) {
    return LocalResponseOption(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      toolConfigId: data.toolConfigId.present
          ? data.toolConfigId.value
          : this.toolConfigId,
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      labelEn: data.labelEn.present ? data.labelEn.value : this.labelEn,
      labelTe: data.labelTe.present ? data.labelTe.value : this.labelTe,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalResponseOption(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('toolConfigId: $toolConfigId, ')
          ..write('questionId: $questionId, ')
          ..write('labelEn: $labelEn, ')
          ..write('labelTe: $labelTe, ')
          ..write('valueJson: $valueJson, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, remoteId, toolConfigId, questionId,
      labelEn, labelTe, valueJson, colorHex, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalResponseOption &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.toolConfigId == this.toolConfigId &&
          other.questionId == this.questionId &&
          other.labelEn == this.labelEn &&
          other.labelTe == this.labelTe &&
          other.valueJson == this.valueJson &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder);
}

class LocalResponseOptionsCompanion
    extends UpdateCompanion<LocalResponseOption> {
  final Value<int> id;
  final Value<int?> remoteId;
  final Value<int> toolConfigId;
  final Value<int?> questionId;
  final Value<String> labelEn;
  final Value<String> labelTe;
  final Value<String> valueJson;
  final Value<String?> colorHex;
  final Value<int> sortOrder;
  const LocalResponseOptionsCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.toolConfigId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.labelEn = const Value.absent(),
    this.labelTe = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  LocalResponseOptionsCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    required int toolConfigId,
    this.questionId = const Value.absent(),
    required String labelEn,
    required String labelTe,
    required String valueJson,
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
  })  : toolConfigId = Value(toolConfigId),
        labelEn = Value(labelEn),
        labelTe = Value(labelTe),
        valueJson = Value(valueJson);
  static Insertable<LocalResponseOption> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<int>? toolConfigId,
    Expression<int>? questionId,
    Expression<String>? labelEn,
    Expression<String>? labelTe,
    Expression<String>? valueJson,
    Expression<String>? colorHex,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (toolConfigId != null) 'tool_config_id': toolConfigId,
      if (questionId != null) 'question_id': questionId,
      if (labelEn != null) 'label_en': labelEn,
      if (labelTe != null) 'label_te': labelTe,
      if (valueJson != null) 'value_json': valueJson,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  LocalResponseOptionsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? remoteId,
      Value<int>? toolConfigId,
      Value<int?>? questionId,
      Value<String>? labelEn,
      Value<String>? labelTe,
      Value<String>? valueJson,
      Value<String?>? colorHex,
      Value<int>? sortOrder}) {
    return LocalResponseOptionsCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      toolConfigId: toolConfigId ?? this.toolConfigId,
      questionId: questionId ?? this.questionId,
      labelEn: labelEn ?? this.labelEn,
      labelTe: labelTe ?? this.labelTe,
      valueJson: valueJson ?? this.valueJson,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (toolConfigId.present) {
      map['tool_config_id'] = Variable<int>(toolConfigId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (labelEn.present) {
      map['label_en'] = Variable<String>(labelEn.value);
    }
    if (labelTe.present) {
      map['label_te'] = Variable<String>(labelTe.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalResponseOptionsCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('toolConfigId: $toolConfigId, ')
          ..write('questionId: $questionId, ')
          ..write('labelEn: $labelEn, ')
          ..write('labelTe: $labelTe, ')
          ..write('valueJson: $valueJson, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $LocalScoringRulesTable extends LocalScoringRules
    with TableInfo<$LocalScoringRulesTable, LocalScoringRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalScoringRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _toolConfigIdMeta =
      const VerificationMeta('toolConfigId');
  @override
  late final GeneratedColumn<int> toolConfigId = GeneratedColumn<int>(
      'tool_config_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ruleTypeMeta =
      const VerificationMeta('ruleType');
  @override
  late final GeneratedColumn<String> ruleType = GeneratedColumn<String>(
      'rule_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
      'domain', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parameterNameMeta =
      const VerificationMeta('parameterName');
  @override
  late final GeneratedColumn<String> parameterName = GeneratedColumn<String>(
      'parameter_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parameterValueJsonMeta =
      const VerificationMeta('parameterValueJson');
  @override
  late final GeneratedColumn<String> parameterValueJson =
      GeneratedColumn<String>('parameter_value_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remoteId,
        toolConfigId,
        ruleType,
        domain,
        parameterName,
        parameterValueJson,
        description
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_scoring_rules';
  @override
  VerificationContext validateIntegrity(Insertable<LocalScoringRule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('tool_config_id')) {
      context.handle(
          _toolConfigIdMeta,
          toolConfigId.isAcceptableOrUnknown(
              data['tool_config_id']!, _toolConfigIdMeta));
    } else if (isInserting) {
      context.missing(_toolConfigIdMeta);
    }
    if (data.containsKey('rule_type')) {
      context.handle(_ruleTypeMeta,
          ruleType.isAcceptableOrUnknown(data['rule_type']!, _ruleTypeMeta));
    } else if (isInserting) {
      context.missing(_ruleTypeMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(_domainMeta,
          domain.isAcceptableOrUnknown(data['domain']!, _domainMeta));
    }
    if (data.containsKey('parameter_name')) {
      context.handle(
          _parameterNameMeta,
          parameterName.isAcceptableOrUnknown(
              data['parameter_name']!, _parameterNameMeta));
    } else if (isInserting) {
      context.missing(_parameterNameMeta);
    }
    if (data.containsKey('parameter_value_json')) {
      context.handle(
          _parameterValueJsonMeta,
          parameterValueJson.isAcceptableOrUnknown(
              data['parameter_value_json']!, _parameterValueJsonMeta));
    } else if (isInserting) {
      context.missing(_parameterValueJsonMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalScoringRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalScoringRule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}remote_id']),
      toolConfigId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tool_config_id'])!,
      ruleType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rule_type'])!,
      domain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domain']),
      parameterName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parameter_name'])!,
      parameterValueJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}parameter_value_json'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
    );
  }

  @override
  $LocalScoringRulesTable createAlias(String alias) {
    return $LocalScoringRulesTable(attachedDatabase, alias);
  }
}

class LocalScoringRule extends DataClass
    implements Insertable<LocalScoringRule> {
  final int id;
  final int? remoteId;
  final int toolConfigId;
  final String ruleType;
  final String? domain;
  final String parameterName;
  final String parameterValueJson;
  final String? description;
  const LocalScoringRule(
      {required this.id,
      this.remoteId,
      required this.toolConfigId,
      required this.ruleType,
      this.domain,
      required this.parameterName,
      required this.parameterValueJson,
      this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    map['tool_config_id'] = Variable<int>(toolConfigId);
    map['rule_type'] = Variable<String>(ruleType);
    if (!nullToAbsent || domain != null) {
      map['domain'] = Variable<String>(domain);
    }
    map['parameter_name'] = Variable<String>(parameterName);
    map['parameter_value_json'] = Variable<String>(parameterValueJson);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  LocalScoringRulesCompanion toCompanion(bool nullToAbsent) {
    return LocalScoringRulesCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      toolConfigId: Value(toolConfigId),
      ruleType: Value(ruleType),
      domain:
          domain == null && nullToAbsent ? const Value.absent() : Value(domain),
      parameterName: Value(parameterName),
      parameterValueJson: Value(parameterValueJson),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory LocalScoringRule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalScoringRule(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      toolConfigId: serializer.fromJson<int>(json['toolConfigId']),
      ruleType: serializer.fromJson<String>(json['ruleType']),
      domain: serializer.fromJson<String?>(json['domain']),
      parameterName: serializer.fromJson<String>(json['parameterName']),
      parameterValueJson:
          serializer.fromJson<String>(json['parameterValueJson']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int?>(remoteId),
      'toolConfigId': serializer.toJson<int>(toolConfigId),
      'ruleType': serializer.toJson<String>(ruleType),
      'domain': serializer.toJson<String?>(domain),
      'parameterName': serializer.toJson<String>(parameterName),
      'parameterValueJson': serializer.toJson<String>(parameterValueJson),
      'description': serializer.toJson<String?>(description),
    };
  }

  LocalScoringRule copyWith(
          {int? id,
          Value<int?> remoteId = const Value.absent(),
          int? toolConfigId,
          String? ruleType,
          Value<String?> domain = const Value.absent(),
          String? parameterName,
          String? parameterValueJson,
          Value<String?> description = const Value.absent()}) =>
      LocalScoringRule(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        toolConfigId: toolConfigId ?? this.toolConfigId,
        ruleType: ruleType ?? this.ruleType,
        domain: domain.present ? domain.value : this.domain,
        parameterName: parameterName ?? this.parameterName,
        parameterValueJson: parameterValueJson ?? this.parameterValueJson,
        description: description.present ? description.value : this.description,
      );
  LocalScoringRule copyWithCompanion(LocalScoringRulesCompanion data) {
    return LocalScoringRule(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      toolConfigId: data.toolConfigId.present
          ? data.toolConfigId.value
          : this.toolConfigId,
      ruleType: data.ruleType.present ? data.ruleType.value : this.ruleType,
      domain: data.domain.present ? data.domain.value : this.domain,
      parameterName: data.parameterName.present
          ? data.parameterName.value
          : this.parameterName,
      parameterValueJson: data.parameterValueJson.present
          ? data.parameterValueJson.value
          : this.parameterValueJson,
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalScoringRule(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('toolConfigId: $toolConfigId, ')
          ..write('ruleType: $ruleType, ')
          ..write('domain: $domain, ')
          ..write('parameterName: $parameterName, ')
          ..write('parameterValueJson: $parameterValueJson, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, remoteId, toolConfigId, ruleType, domain,
      parameterName, parameterValueJson, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalScoringRule &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.toolConfigId == this.toolConfigId &&
          other.ruleType == this.ruleType &&
          other.domain == this.domain &&
          other.parameterName == this.parameterName &&
          other.parameterValueJson == this.parameterValueJson &&
          other.description == this.description);
}

class LocalScoringRulesCompanion extends UpdateCompanion<LocalScoringRule> {
  final Value<int> id;
  final Value<int?> remoteId;
  final Value<int> toolConfigId;
  final Value<String> ruleType;
  final Value<String?> domain;
  final Value<String> parameterName;
  final Value<String> parameterValueJson;
  final Value<String?> description;
  const LocalScoringRulesCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.toolConfigId = const Value.absent(),
    this.ruleType = const Value.absent(),
    this.domain = const Value.absent(),
    this.parameterName = const Value.absent(),
    this.parameterValueJson = const Value.absent(),
    this.description = const Value.absent(),
  });
  LocalScoringRulesCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    required int toolConfigId,
    required String ruleType,
    this.domain = const Value.absent(),
    required String parameterName,
    required String parameterValueJson,
    this.description = const Value.absent(),
  })  : toolConfigId = Value(toolConfigId),
        ruleType = Value(ruleType),
        parameterName = Value(parameterName),
        parameterValueJson = Value(parameterValueJson);
  static Insertable<LocalScoringRule> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<int>? toolConfigId,
    Expression<String>? ruleType,
    Expression<String>? domain,
    Expression<String>? parameterName,
    Expression<String>? parameterValueJson,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (toolConfigId != null) 'tool_config_id': toolConfigId,
      if (ruleType != null) 'rule_type': ruleType,
      if (domain != null) 'domain': domain,
      if (parameterName != null) 'parameter_name': parameterName,
      if (parameterValueJson != null)
        'parameter_value_json': parameterValueJson,
      if (description != null) 'description': description,
    });
  }

  LocalScoringRulesCompanion copyWith(
      {Value<int>? id,
      Value<int?>? remoteId,
      Value<int>? toolConfigId,
      Value<String>? ruleType,
      Value<String?>? domain,
      Value<String>? parameterName,
      Value<String>? parameterValueJson,
      Value<String?>? description}) {
    return LocalScoringRulesCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      toolConfigId: toolConfigId ?? this.toolConfigId,
      ruleType: ruleType ?? this.ruleType,
      domain: domain ?? this.domain,
      parameterName: parameterName ?? this.parameterName,
      parameterValueJson: parameterValueJson ?? this.parameterValueJson,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (toolConfigId.present) {
      map['tool_config_id'] = Variable<int>(toolConfigId.value);
    }
    if (ruleType.present) {
      map['rule_type'] = Variable<String>(ruleType.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (parameterName.present) {
      map['parameter_name'] = Variable<String>(parameterName.value);
    }
    if (parameterValueJson.present) {
      map['parameter_value_json'] = Variable<String>(parameterValueJson.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalScoringRulesCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('toolConfigId: $toolConfigId, ')
          ..write('ruleType: $ruleType, ')
          ..write('domain: $domain, ')
          ..write('parameterName: $parameterName, ')
          ..write('parameterValueJson: $parameterValueJson, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $LocalActivitiesTable extends LocalActivities
    with TableInfo<$LocalActivitiesTable, LocalActivity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _activityCodeMeta =
      const VerificationMeta('activityCode');
  @override
  late final GeneratedColumn<String> activityCode = GeneratedColumn<String>(
      'activity_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
      'domain', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleEnMeta =
      const VerificationMeta('titleEn');
  @override
  late final GeneratedColumn<String> titleEn = GeneratedColumn<String>(
      'title_en', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleTeMeta =
      const VerificationMeta('titleTe');
  @override
  late final GeneratedColumn<String> titleTe = GeneratedColumn<String>(
      'title_te', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionEnMeta =
      const VerificationMeta('descriptionEn');
  @override
  late final GeneratedColumn<String> descriptionEn = GeneratedColumn<String>(
      'description_en', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionTeMeta =
      const VerificationMeta('descriptionTe');
  @override
  late final GeneratedColumn<String> descriptionTe = GeneratedColumn<String>(
      'description_te', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _materialsEnMeta =
      const VerificationMeta('materialsEn');
  @override
  late final GeneratedColumn<String> materialsEn = GeneratedColumn<String>(
      'materials_en', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _materialsTeMeta =
      const VerificationMeta('materialsTe');
  @override
  late final GeneratedColumn<String> materialsTe = GeneratedColumn<String>(
      'materials_te', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationMinutesMeta =
      const VerificationMeta('durationMinutes');
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
      'duration_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(15));
  static const VerificationMeta _minAgeMonthsMeta =
      const VerificationMeta('minAgeMonths');
  @override
  late final GeneratedColumn<int> minAgeMonths = GeneratedColumn<int>(
      'min_age_months', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _maxAgeMonthsMeta =
      const VerificationMeta('maxAgeMonths');
  @override
  late final GeneratedColumn<int> maxAgeMonths = GeneratedColumn<int>(
      'max_age_months', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(72));
  static const VerificationMeta _riskLevelMeta =
      const VerificationMeta('riskLevel');
  @override
  late final GeneratedColumn<String> riskLevel = GeneratedColumn<String>(
      'risk_level', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('all'));
  static const VerificationMeta _hasVideoMeta =
      const VerificationMeta('hasVideo');
  @override
  late final GeneratedColumn<bool> hasVideo = GeneratedColumn<bool>(
      'has_video', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("has_video" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remoteId,
        activityCode,
        domain,
        titleEn,
        titleTe,
        descriptionEn,
        descriptionTe,
        materialsEn,
        materialsTe,
        durationMinutes,
        minAgeMonths,
        maxAgeMonths,
        riskLevel,
        hasVideo,
        isActive,
        version,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_activities';
  @override
  VerificationContext validateIntegrity(Insertable<LocalActivity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('activity_code')) {
      context.handle(
          _activityCodeMeta,
          activityCode.isAcceptableOrUnknown(
              data['activity_code']!, _activityCodeMeta));
    } else if (isInserting) {
      context.missing(_activityCodeMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(_domainMeta,
          domain.isAcceptableOrUnknown(data['domain']!, _domainMeta));
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('title_en')) {
      context.handle(_titleEnMeta,
          titleEn.isAcceptableOrUnknown(data['title_en']!, _titleEnMeta));
    } else if (isInserting) {
      context.missing(_titleEnMeta);
    }
    if (data.containsKey('title_te')) {
      context.handle(_titleTeMeta,
          titleTe.isAcceptableOrUnknown(data['title_te']!, _titleTeMeta));
    } else if (isInserting) {
      context.missing(_titleTeMeta);
    }
    if (data.containsKey('description_en')) {
      context.handle(
          _descriptionEnMeta,
          descriptionEn.isAcceptableOrUnknown(
              data['description_en']!, _descriptionEnMeta));
    } else if (isInserting) {
      context.missing(_descriptionEnMeta);
    }
    if (data.containsKey('description_te')) {
      context.handle(
          _descriptionTeMeta,
          descriptionTe.isAcceptableOrUnknown(
              data['description_te']!, _descriptionTeMeta));
    } else if (isInserting) {
      context.missing(_descriptionTeMeta);
    }
    if (data.containsKey('materials_en')) {
      context.handle(
          _materialsEnMeta,
          materialsEn.isAcceptableOrUnknown(
              data['materials_en']!, _materialsEnMeta));
    }
    if (data.containsKey('materials_te')) {
      context.handle(
          _materialsTeMeta,
          materialsTe.isAcceptableOrUnknown(
              data['materials_te']!, _materialsTeMeta));
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
          _durationMinutesMeta,
          durationMinutes.isAcceptableOrUnknown(
              data['duration_minutes']!, _durationMinutesMeta));
    }
    if (data.containsKey('min_age_months')) {
      context.handle(
          _minAgeMonthsMeta,
          minAgeMonths.isAcceptableOrUnknown(
              data['min_age_months']!, _minAgeMonthsMeta));
    }
    if (data.containsKey('max_age_months')) {
      context.handle(
          _maxAgeMonthsMeta,
          maxAgeMonths.isAcceptableOrUnknown(
              data['max_age_months']!, _maxAgeMonthsMeta));
    }
    if (data.containsKey('risk_level')) {
      context.handle(_riskLevelMeta,
          riskLevel.isAcceptableOrUnknown(data['risk_level']!, _riskLevelMeta));
    }
    if (data.containsKey('has_video')) {
      context.handle(_hasVideoMeta,
          hasVideo.isAcceptableOrUnknown(data['has_video']!, _hasVideoMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalActivity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalActivity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}remote_id']),
      activityCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_code'])!,
      domain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domain'])!,
      titleEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title_en'])!,
      titleTe: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title_te'])!,
      descriptionEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description_en'])!,
      descriptionTe: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description_te'])!,
      materialsEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}materials_en']),
      materialsTe: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}materials_te']),
      durationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_minutes'])!,
      minAgeMonths: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}min_age_months'])!,
      maxAgeMonths: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_age_months'])!,
      riskLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}risk_level'])!,
      hasVideo: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_video'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $LocalActivitiesTable createAlias(String alias) {
    return $LocalActivitiesTable(attachedDatabase, alias);
  }
}

class LocalActivity extends DataClass implements Insertable<LocalActivity> {
  final int id;
  final int? remoteId;
  final String activityCode;
  final String domain;
  final String titleEn;
  final String titleTe;
  final String descriptionEn;
  final String descriptionTe;
  final String? materialsEn;
  final String? materialsTe;
  final int durationMinutes;
  final int minAgeMonths;
  final int maxAgeMonths;
  final String riskLevel;
  final bool hasVideo;
  final bool isActive;
  final int version;
  final DateTime? lastSyncedAt;
  const LocalActivity(
      {required this.id,
      this.remoteId,
      required this.activityCode,
      required this.domain,
      required this.titleEn,
      required this.titleTe,
      required this.descriptionEn,
      required this.descriptionTe,
      this.materialsEn,
      this.materialsTe,
      required this.durationMinutes,
      required this.minAgeMonths,
      required this.maxAgeMonths,
      required this.riskLevel,
      required this.hasVideo,
      required this.isActive,
      required this.version,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    map['activity_code'] = Variable<String>(activityCode);
    map['domain'] = Variable<String>(domain);
    map['title_en'] = Variable<String>(titleEn);
    map['title_te'] = Variable<String>(titleTe);
    map['description_en'] = Variable<String>(descriptionEn);
    map['description_te'] = Variable<String>(descriptionTe);
    if (!nullToAbsent || materialsEn != null) {
      map['materials_en'] = Variable<String>(materialsEn);
    }
    if (!nullToAbsent || materialsTe != null) {
      map['materials_te'] = Variable<String>(materialsTe);
    }
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['min_age_months'] = Variable<int>(minAgeMonths);
    map['max_age_months'] = Variable<int>(maxAgeMonths);
    map['risk_level'] = Variable<String>(riskLevel);
    map['has_video'] = Variable<bool>(hasVideo);
    map['is_active'] = Variable<bool>(isActive);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalActivitiesCompanion toCompanion(bool nullToAbsent) {
    return LocalActivitiesCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      activityCode: Value(activityCode),
      domain: Value(domain),
      titleEn: Value(titleEn),
      titleTe: Value(titleTe),
      descriptionEn: Value(descriptionEn),
      descriptionTe: Value(descriptionTe),
      materialsEn: materialsEn == null && nullToAbsent
          ? const Value.absent()
          : Value(materialsEn),
      materialsTe: materialsTe == null && nullToAbsent
          ? const Value.absent()
          : Value(materialsTe),
      durationMinutes: Value(durationMinutes),
      minAgeMonths: Value(minAgeMonths),
      maxAgeMonths: Value(maxAgeMonths),
      riskLevel: Value(riskLevel),
      hasVideo: Value(hasVideo),
      isActive: Value(isActive),
      version: Value(version),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalActivity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalActivity(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      activityCode: serializer.fromJson<String>(json['activityCode']),
      domain: serializer.fromJson<String>(json['domain']),
      titleEn: serializer.fromJson<String>(json['titleEn']),
      titleTe: serializer.fromJson<String>(json['titleTe']),
      descriptionEn: serializer.fromJson<String>(json['descriptionEn']),
      descriptionTe: serializer.fromJson<String>(json['descriptionTe']),
      materialsEn: serializer.fromJson<String?>(json['materialsEn']),
      materialsTe: serializer.fromJson<String?>(json['materialsTe']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      minAgeMonths: serializer.fromJson<int>(json['minAgeMonths']),
      maxAgeMonths: serializer.fromJson<int>(json['maxAgeMonths']),
      riskLevel: serializer.fromJson<String>(json['riskLevel']),
      hasVideo: serializer.fromJson<bool>(json['hasVideo']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      version: serializer.fromJson<int>(json['version']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int?>(remoteId),
      'activityCode': serializer.toJson<String>(activityCode),
      'domain': serializer.toJson<String>(domain),
      'titleEn': serializer.toJson<String>(titleEn),
      'titleTe': serializer.toJson<String>(titleTe),
      'descriptionEn': serializer.toJson<String>(descriptionEn),
      'descriptionTe': serializer.toJson<String>(descriptionTe),
      'materialsEn': serializer.toJson<String?>(materialsEn),
      'materialsTe': serializer.toJson<String?>(materialsTe),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'minAgeMonths': serializer.toJson<int>(minAgeMonths),
      'maxAgeMonths': serializer.toJson<int>(maxAgeMonths),
      'riskLevel': serializer.toJson<String>(riskLevel),
      'hasVideo': serializer.toJson<bool>(hasVideo),
      'isActive': serializer.toJson<bool>(isActive),
      'version': serializer.toJson<int>(version),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalActivity copyWith(
          {int? id,
          Value<int?> remoteId = const Value.absent(),
          String? activityCode,
          String? domain,
          String? titleEn,
          String? titleTe,
          String? descriptionEn,
          String? descriptionTe,
          Value<String?> materialsEn = const Value.absent(),
          Value<String?> materialsTe = const Value.absent(),
          int? durationMinutes,
          int? minAgeMonths,
          int? maxAgeMonths,
          String? riskLevel,
          bool? hasVideo,
          bool? isActive,
          int? version,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      LocalActivity(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        activityCode: activityCode ?? this.activityCode,
        domain: domain ?? this.domain,
        titleEn: titleEn ?? this.titleEn,
        titleTe: titleTe ?? this.titleTe,
        descriptionEn: descriptionEn ?? this.descriptionEn,
        descriptionTe: descriptionTe ?? this.descriptionTe,
        materialsEn: materialsEn.present ? materialsEn.value : this.materialsEn,
        materialsTe: materialsTe.present ? materialsTe.value : this.materialsTe,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        minAgeMonths: minAgeMonths ?? this.minAgeMonths,
        maxAgeMonths: maxAgeMonths ?? this.maxAgeMonths,
        riskLevel: riskLevel ?? this.riskLevel,
        hasVideo: hasVideo ?? this.hasVideo,
        isActive: isActive ?? this.isActive,
        version: version ?? this.version,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  LocalActivity copyWithCompanion(LocalActivitiesCompanion data) {
    return LocalActivity(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      activityCode: data.activityCode.present
          ? data.activityCode.value
          : this.activityCode,
      domain: data.domain.present ? data.domain.value : this.domain,
      titleEn: data.titleEn.present ? data.titleEn.value : this.titleEn,
      titleTe: data.titleTe.present ? data.titleTe.value : this.titleTe,
      descriptionEn: data.descriptionEn.present
          ? data.descriptionEn.value
          : this.descriptionEn,
      descriptionTe: data.descriptionTe.present
          ? data.descriptionTe.value
          : this.descriptionTe,
      materialsEn:
          data.materialsEn.present ? data.materialsEn.value : this.materialsEn,
      materialsTe:
          data.materialsTe.present ? data.materialsTe.value : this.materialsTe,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      minAgeMonths: data.minAgeMonths.present
          ? data.minAgeMonths.value
          : this.minAgeMonths,
      maxAgeMonths: data.maxAgeMonths.present
          ? data.maxAgeMonths.value
          : this.maxAgeMonths,
      riskLevel: data.riskLevel.present ? data.riskLevel.value : this.riskLevel,
      hasVideo: data.hasVideo.present ? data.hasVideo.value : this.hasVideo,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      version: data.version.present ? data.version.value : this.version,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalActivity(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('activityCode: $activityCode, ')
          ..write('domain: $domain, ')
          ..write('titleEn: $titleEn, ')
          ..write('titleTe: $titleTe, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('descriptionTe: $descriptionTe, ')
          ..write('materialsEn: $materialsEn, ')
          ..write('materialsTe: $materialsTe, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('minAgeMonths: $minAgeMonths, ')
          ..write('maxAgeMonths: $maxAgeMonths, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('hasVideo: $hasVideo, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      remoteId,
      activityCode,
      domain,
      titleEn,
      titleTe,
      descriptionEn,
      descriptionTe,
      materialsEn,
      materialsTe,
      durationMinutes,
      minAgeMonths,
      maxAgeMonths,
      riskLevel,
      hasVideo,
      isActive,
      version,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalActivity &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.activityCode == this.activityCode &&
          other.domain == this.domain &&
          other.titleEn == this.titleEn &&
          other.titleTe == this.titleTe &&
          other.descriptionEn == this.descriptionEn &&
          other.descriptionTe == this.descriptionTe &&
          other.materialsEn == this.materialsEn &&
          other.materialsTe == this.materialsTe &&
          other.durationMinutes == this.durationMinutes &&
          other.minAgeMonths == this.minAgeMonths &&
          other.maxAgeMonths == this.maxAgeMonths &&
          other.riskLevel == this.riskLevel &&
          other.hasVideo == this.hasVideo &&
          other.isActive == this.isActive &&
          other.version == this.version &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalActivitiesCompanion extends UpdateCompanion<LocalActivity> {
  final Value<int> id;
  final Value<int?> remoteId;
  final Value<String> activityCode;
  final Value<String> domain;
  final Value<String> titleEn;
  final Value<String> titleTe;
  final Value<String> descriptionEn;
  final Value<String> descriptionTe;
  final Value<String?> materialsEn;
  final Value<String?> materialsTe;
  final Value<int> durationMinutes;
  final Value<int> minAgeMonths;
  final Value<int> maxAgeMonths;
  final Value<String> riskLevel;
  final Value<bool> hasVideo;
  final Value<bool> isActive;
  final Value<int> version;
  final Value<DateTime?> lastSyncedAt;
  const LocalActivitiesCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.activityCode = const Value.absent(),
    this.domain = const Value.absent(),
    this.titleEn = const Value.absent(),
    this.titleTe = const Value.absent(),
    this.descriptionEn = const Value.absent(),
    this.descriptionTe = const Value.absent(),
    this.materialsEn = const Value.absent(),
    this.materialsTe = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.minAgeMonths = const Value.absent(),
    this.maxAgeMonths = const Value.absent(),
    this.riskLevel = const Value.absent(),
    this.hasVideo = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  LocalActivitiesCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    required String activityCode,
    required String domain,
    required String titleEn,
    required String titleTe,
    required String descriptionEn,
    required String descriptionTe,
    this.materialsEn = const Value.absent(),
    this.materialsTe = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.minAgeMonths = const Value.absent(),
    this.maxAgeMonths = const Value.absent(),
    this.riskLevel = const Value.absent(),
    this.hasVideo = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  })  : activityCode = Value(activityCode),
        domain = Value(domain),
        titleEn = Value(titleEn),
        titleTe = Value(titleTe),
        descriptionEn = Value(descriptionEn),
        descriptionTe = Value(descriptionTe);
  static Insertable<LocalActivity> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<String>? activityCode,
    Expression<String>? domain,
    Expression<String>? titleEn,
    Expression<String>? titleTe,
    Expression<String>? descriptionEn,
    Expression<String>? descriptionTe,
    Expression<String>? materialsEn,
    Expression<String>? materialsTe,
    Expression<int>? durationMinutes,
    Expression<int>? minAgeMonths,
    Expression<int>? maxAgeMonths,
    Expression<String>? riskLevel,
    Expression<bool>? hasVideo,
    Expression<bool>? isActive,
    Expression<int>? version,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (activityCode != null) 'activity_code': activityCode,
      if (domain != null) 'domain': domain,
      if (titleEn != null) 'title_en': titleEn,
      if (titleTe != null) 'title_te': titleTe,
      if (descriptionEn != null) 'description_en': descriptionEn,
      if (descriptionTe != null) 'description_te': descriptionTe,
      if (materialsEn != null) 'materials_en': materialsEn,
      if (materialsTe != null) 'materials_te': materialsTe,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (minAgeMonths != null) 'min_age_months': minAgeMonths,
      if (maxAgeMonths != null) 'max_age_months': maxAgeMonths,
      if (riskLevel != null) 'risk_level': riskLevel,
      if (hasVideo != null) 'has_video': hasVideo,
      if (isActive != null) 'is_active': isActive,
      if (version != null) 'version': version,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  LocalActivitiesCompanion copyWith(
      {Value<int>? id,
      Value<int?>? remoteId,
      Value<String>? activityCode,
      Value<String>? domain,
      Value<String>? titleEn,
      Value<String>? titleTe,
      Value<String>? descriptionEn,
      Value<String>? descriptionTe,
      Value<String?>? materialsEn,
      Value<String?>? materialsTe,
      Value<int>? durationMinutes,
      Value<int>? minAgeMonths,
      Value<int>? maxAgeMonths,
      Value<String>? riskLevel,
      Value<bool>? hasVideo,
      Value<bool>? isActive,
      Value<int>? version,
      Value<DateTime?>? lastSyncedAt}) {
    return LocalActivitiesCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      activityCode: activityCode ?? this.activityCode,
      domain: domain ?? this.domain,
      titleEn: titleEn ?? this.titleEn,
      titleTe: titleTe ?? this.titleTe,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionTe: descriptionTe ?? this.descriptionTe,
      materialsEn: materialsEn ?? this.materialsEn,
      materialsTe: materialsTe ?? this.materialsTe,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      minAgeMonths: minAgeMonths ?? this.minAgeMonths,
      maxAgeMonths: maxAgeMonths ?? this.maxAgeMonths,
      riskLevel: riskLevel ?? this.riskLevel,
      hasVideo: hasVideo ?? this.hasVideo,
      isActive: isActive ?? this.isActive,
      version: version ?? this.version,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (activityCode.present) {
      map['activity_code'] = Variable<String>(activityCode.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (titleEn.present) {
      map['title_en'] = Variable<String>(titleEn.value);
    }
    if (titleTe.present) {
      map['title_te'] = Variable<String>(titleTe.value);
    }
    if (descriptionEn.present) {
      map['description_en'] = Variable<String>(descriptionEn.value);
    }
    if (descriptionTe.present) {
      map['description_te'] = Variable<String>(descriptionTe.value);
    }
    if (materialsEn.present) {
      map['materials_en'] = Variable<String>(materialsEn.value);
    }
    if (materialsTe.present) {
      map['materials_te'] = Variable<String>(materialsTe.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (minAgeMonths.present) {
      map['min_age_months'] = Variable<int>(minAgeMonths.value);
    }
    if (maxAgeMonths.present) {
      map['max_age_months'] = Variable<int>(maxAgeMonths.value);
    }
    if (riskLevel.present) {
      map['risk_level'] = Variable<String>(riskLevel.value);
    }
    if (hasVideo.present) {
      map['has_video'] = Variable<bool>(hasVideo.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('activityCode: $activityCode, ')
          ..write('domain: $domain, ')
          ..write('titleEn: $titleEn, ')
          ..write('titleTe: $titleTe, ')
          ..write('descriptionEn: $descriptionEn, ')
          ..write('descriptionTe: $descriptionTe, ')
          ..write('materialsEn: $materialsEn, ')
          ..write('materialsTe: $materialsTe, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('minAgeMonths: $minAgeMonths, ')
          ..write('maxAgeMonths: $maxAgeMonths, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('hasVideo: $hasVideo, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalReferralsTable extends LocalReferrals
    with TableInfo<$LocalReferralsTable, LocalReferral> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalReferralsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _childRemoteIdMeta =
      const VerificationMeta('childRemoteId');
  @override
  late final GeneratedColumn<int> childRemoteId = GeneratedColumn<int>(
      'child_remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _screeningResultLocalIdMeta =
      const VerificationMeta('screeningResultLocalId');
  @override
  late final GeneratedColumn<int> screeningResultLocalId = GeneratedColumn<int>(
      'screening_result_local_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _screeningResultRemoteIdMeta =
      const VerificationMeta('screeningResultRemoteId');
  @override
  late final GeneratedColumn<int> screeningResultRemoteId =
      GeneratedColumn<int>('screening_result_remote_id', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _referralTriggeredMeta =
      const VerificationMeta('referralTriggered');
  @override
  late final GeneratedColumn<bool> referralTriggered = GeneratedColumn<bool>(
      'referral_triggered', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("referral_triggered" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _referralTypeMeta =
      const VerificationMeta('referralType');
  @override
  late final GeneratedColumn<String> referralType = GeneratedColumn<String>(
      'referral_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referralReasonMeta =
      const VerificationMeta('referralReason');
  @override
  late final GeneratedColumn<String> referralReason = GeneratedColumn<String>(
      'referral_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referralStatusMeta =
      const VerificationMeta('referralStatus');
  @override
  late final GeneratedColumn<String> referralStatus = GeneratedColumn<String>(
      'referral_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Pending'));
  static const VerificationMeta _referredByMeta =
      const VerificationMeta('referredBy');
  @override
  late final GeneratedColumn<String> referredBy = GeneratedColumn<String>(
      'referred_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referredDateMeta =
      const VerificationMeta('referredDate');
  @override
  late final GeneratedColumn<String> referredDate = GeneratedColumn<String>(
      'referred_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _completedDateMeta =
      const VerificationMeta('completedDate');
  @override
  late final GeneratedColumn<String> completedDate = GeneratedColumn<String>(
      'completed_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        childRemoteId,
        screeningResultLocalId,
        screeningResultRemoteId,
        referralTriggered,
        referralType,
        referralReason,
        referralStatus,
        referredBy,
        referredDate,
        completedDate,
        notes,
        createdAt,
        updatedAt,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_referrals';
  @override
  VerificationContext validateIntegrity(Insertable<LocalReferral> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_remote_id')) {
      context.handle(
          _childRemoteIdMeta,
          childRemoteId.isAcceptableOrUnknown(
              data['child_remote_id']!, _childRemoteIdMeta));
    }
    if (data.containsKey('screening_result_local_id')) {
      context.handle(
          _screeningResultLocalIdMeta,
          screeningResultLocalId.isAcceptableOrUnknown(
              data['screening_result_local_id']!, _screeningResultLocalIdMeta));
    }
    if (data.containsKey('screening_result_remote_id')) {
      context.handle(
          _screeningResultRemoteIdMeta,
          screeningResultRemoteId.isAcceptableOrUnknown(
              data['screening_result_remote_id']!,
              _screeningResultRemoteIdMeta));
    }
    if (data.containsKey('referral_triggered')) {
      context.handle(
          _referralTriggeredMeta,
          referralTriggered.isAcceptableOrUnknown(
              data['referral_triggered']!, _referralTriggeredMeta));
    }
    if (data.containsKey('referral_type')) {
      context.handle(
          _referralTypeMeta,
          referralType.isAcceptableOrUnknown(
              data['referral_type']!, _referralTypeMeta));
    }
    if (data.containsKey('referral_reason')) {
      context.handle(
          _referralReasonMeta,
          referralReason.isAcceptableOrUnknown(
              data['referral_reason']!, _referralReasonMeta));
    }
    if (data.containsKey('referral_status')) {
      context.handle(
          _referralStatusMeta,
          referralStatus.isAcceptableOrUnknown(
              data['referral_status']!, _referralStatusMeta));
    }
    if (data.containsKey('referred_by')) {
      context.handle(
          _referredByMeta,
          referredBy.isAcceptableOrUnknown(
              data['referred_by']!, _referredByMeta));
    }
    if (data.containsKey('referred_date')) {
      context.handle(
          _referredDateMeta,
          referredDate.isAcceptableOrUnknown(
              data['referred_date']!, _referredDateMeta));
    }
    if (data.containsKey('completed_date')) {
      context.handle(
          _completedDateMeta,
          completedDate.isAcceptableOrUnknown(
              data['completed_date']!, _completedDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalReferral map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalReferral(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      childRemoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}child_remote_id']),
      screeningResultLocalId: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}screening_result_local_id']),
      screeningResultRemoteId: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}screening_result_remote_id']),
      referralTriggered: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}referral_triggered'])!,
      referralType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}referral_type']),
      referralReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}referral_reason']),
      referralStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}referral_status'])!,
      referredBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}referred_by']),
      referredDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}referred_date']),
      completedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}completed_date']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $LocalReferralsTable createAlias(String alias) {
    return $LocalReferralsTable(attachedDatabase, alias);
  }
}

class LocalReferral extends DataClass implements Insertable<LocalReferral> {
  final int id;
  final int? childRemoteId;
  final int? screeningResultLocalId;
  final int? screeningResultRemoteId;
  final bool referralTriggered;
  final String? referralType;
  final String? referralReason;
  final String referralStatus;
  final String? referredBy;
  final String? referredDate;
  final String? completedDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;
  const LocalReferral(
      {required this.id,
      this.childRemoteId,
      this.screeningResultLocalId,
      this.screeningResultRemoteId,
      required this.referralTriggered,
      this.referralType,
      this.referralReason,
      required this.referralStatus,
      this.referredBy,
      this.referredDate,
      this.completedDate,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || childRemoteId != null) {
      map['child_remote_id'] = Variable<int>(childRemoteId);
    }
    if (!nullToAbsent || screeningResultLocalId != null) {
      map['screening_result_local_id'] = Variable<int>(screeningResultLocalId);
    }
    if (!nullToAbsent || screeningResultRemoteId != null) {
      map['screening_result_remote_id'] =
          Variable<int>(screeningResultRemoteId);
    }
    map['referral_triggered'] = Variable<bool>(referralTriggered);
    if (!nullToAbsent || referralType != null) {
      map['referral_type'] = Variable<String>(referralType);
    }
    if (!nullToAbsent || referralReason != null) {
      map['referral_reason'] = Variable<String>(referralReason);
    }
    map['referral_status'] = Variable<String>(referralStatus);
    if (!nullToAbsent || referredBy != null) {
      map['referred_by'] = Variable<String>(referredBy);
    }
    if (!nullToAbsent || referredDate != null) {
      map['referred_date'] = Variable<String>(referredDate);
    }
    if (!nullToAbsent || completedDate != null) {
      map['completed_date'] = Variable<String>(completedDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  LocalReferralsCompanion toCompanion(bool nullToAbsent) {
    return LocalReferralsCompanion(
      id: Value(id),
      childRemoteId: childRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(childRemoteId),
      screeningResultLocalId: screeningResultLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(screeningResultLocalId),
      screeningResultRemoteId: screeningResultRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(screeningResultRemoteId),
      referralTriggered: Value(referralTriggered),
      referralType: referralType == null && nullToAbsent
          ? const Value.absent()
          : Value(referralType),
      referralReason: referralReason == null && nullToAbsent
          ? const Value.absent()
          : Value(referralReason),
      referralStatus: Value(referralStatus),
      referredBy: referredBy == null && nullToAbsent
          ? const Value.absent()
          : Value(referredBy),
      referredDate: referredDate == null && nullToAbsent
          ? const Value.absent()
          : Value(referredDate),
      completedDate: completedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(completedDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalReferral.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalReferral(
      id: serializer.fromJson<int>(json['id']),
      childRemoteId: serializer.fromJson<int?>(json['childRemoteId']),
      screeningResultLocalId:
          serializer.fromJson<int?>(json['screeningResultLocalId']),
      screeningResultRemoteId:
          serializer.fromJson<int?>(json['screeningResultRemoteId']),
      referralTriggered: serializer.fromJson<bool>(json['referralTriggered']),
      referralType: serializer.fromJson<String?>(json['referralType']),
      referralReason: serializer.fromJson<String?>(json['referralReason']),
      referralStatus: serializer.fromJson<String>(json['referralStatus']),
      referredBy: serializer.fromJson<String?>(json['referredBy']),
      referredDate: serializer.fromJson<String?>(json['referredDate']),
      completedDate: serializer.fromJson<String?>(json['completedDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childRemoteId': serializer.toJson<int?>(childRemoteId),
      'screeningResultLocalId': serializer.toJson<int?>(screeningResultLocalId),
      'screeningResultRemoteId':
          serializer.toJson<int?>(screeningResultRemoteId),
      'referralTriggered': serializer.toJson<bool>(referralTriggered),
      'referralType': serializer.toJson<String?>(referralType),
      'referralReason': serializer.toJson<String?>(referralReason),
      'referralStatus': serializer.toJson<String>(referralStatus),
      'referredBy': serializer.toJson<String?>(referredBy),
      'referredDate': serializer.toJson<String?>(referredDate),
      'completedDate': serializer.toJson<String?>(completedDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalReferral copyWith(
          {int? id,
          Value<int?> childRemoteId = const Value.absent(),
          Value<int?> screeningResultLocalId = const Value.absent(),
          Value<int?> screeningResultRemoteId = const Value.absent(),
          bool? referralTriggered,
          Value<String?> referralType = const Value.absent(),
          Value<String?> referralReason = const Value.absent(),
          String? referralStatus,
          Value<String?> referredBy = const Value.absent(),
          Value<String?> referredDate = const Value.absent(),
          Value<String?> completedDate = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      LocalReferral(
        id: id ?? this.id,
        childRemoteId:
            childRemoteId.present ? childRemoteId.value : this.childRemoteId,
        screeningResultLocalId: screeningResultLocalId.present
            ? screeningResultLocalId.value
            : this.screeningResultLocalId,
        screeningResultRemoteId: screeningResultRemoteId.present
            ? screeningResultRemoteId.value
            : this.screeningResultRemoteId,
        referralTriggered: referralTriggered ?? this.referralTriggered,
        referralType:
            referralType.present ? referralType.value : this.referralType,
        referralReason:
            referralReason.present ? referralReason.value : this.referralReason,
        referralStatus: referralStatus ?? this.referralStatus,
        referredBy: referredBy.present ? referredBy.value : this.referredBy,
        referredDate:
            referredDate.present ? referredDate.value : this.referredDate,
        completedDate:
            completedDate.present ? completedDate.value : this.completedDate,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  LocalReferral copyWithCompanion(LocalReferralsCompanion data) {
    return LocalReferral(
      id: data.id.present ? data.id.value : this.id,
      childRemoteId: data.childRemoteId.present
          ? data.childRemoteId.value
          : this.childRemoteId,
      screeningResultLocalId: data.screeningResultLocalId.present
          ? data.screeningResultLocalId.value
          : this.screeningResultLocalId,
      screeningResultRemoteId: data.screeningResultRemoteId.present
          ? data.screeningResultRemoteId.value
          : this.screeningResultRemoteId,
      referralTriggered: data.referralTriggered.present
          ? data.referralTriggered.value
          : this.referralTriggered,
      referralType: data.referralType.present
          ? data.referralType.value
          : this.referralType,
      referralReason: data.referralReason.present
          ? data.referralReason.value
          : this.referralReason,
      referralStatus: data.referralStatus.present
          ? data.referralStatus.value
          : this.referralStatus,
      referredBy:
          data.referredBy.present ? data.referredBy.value : this.referredBy,
      referredDate: data.referredDate.present
          ? data.referredDate.value
          : this.referredDate,
      completedDate: data.completedDate.present
          ? data.completedDate.value
          : this.completedDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalReferral(')
          ..write('id: $id, ')
          ..write('childRemoteId: $childRemoteId, ')
          ..write('screeningResultLocalId: $screeningResultLocalId, ')
          ..write('screeningResultRemoteId: $screeningResultRemoteId, ')
          ..write('referralTriggered: $referralTriggered, ')
          ..write('referralType: $referralType, ')
          ..write('referralReason: $referralReason, ')
          ..write('referralStatus: $referralStatus, ')
          ..write('referredBy: $referredBy, ')
          ..write('referredDate: $referredDate, ')
          ..write('completedDate: $completedDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      childRemoteId,
      screeningResultLocalId,
      screeningResultRemoteId,
      referralTriggered,
      referralType,
      referralReason,
      referralStatus,
      referredBy,
      referredDate,
      completedDate,
      notes,
      createdAt,
      updatedAt,
      syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalReferral &&
          other.id == this.id &&
          other.childRemoteId == this.childRemoteId &&
          other.screeningResultLocalId == this.screeningResultLocalId &&
          other.screeningResultRemoteId == this.screeningResultRemoteId &&
          other.referralTriggered == this.referralTriggered &&
          other.referralType == this.referralType &&
          other.referralReason == this.referralReason &&
          other.referralStatus == this.referralStatus &&
          other.referredBy == this.referredBy &&
          other.referredDate == this.referredDate &&
          other.completedDate == this.completedDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class LocalReferralsCompanion extends UpdateCompanion<LocalReferral> {
  final Value<int> id;
  final Value<int?> childRemoteId;
  final Value<int?> screeningResultLocalId;
  final Value<int?> screeningResultRemoteId;
  final Value<bool> referralTriggered;
  final Value<String?> referralType;
  final Value<String?> referralReason;
  final Value<String> referralStatus;
  final Value<String?> referredBy;
  final Value<String?> referredDate;
  final Value<String?> completedDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> syncedAt;
  const LocalReferralsCompanion({
    this.id = const Value.absent(),
    this.childRemoteId = const Value.absent(),
    this.screeningResultLocalId = const Value.absent(),
    this.screeningResultRemoteId = const Value.absent(),
    this.referralTriggered = const Value.absent(),
    this.referralType = const Value.absent(),
    this.referralReason = const Value.absent(),
    this.referralStatus = const Value.absent(),
    this.referredBy = const Value.absent(),
    this.referredDate = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  LocalReferralsCompanion.insert({
    this.id = const Value.absent(),
    this.childRemoteId = const Value.absent(),
    this.screeningResultLocalId = const Value.absent(),
    this.screeningResultRemoteId = const Value.absent(),
    this.referralTriggered = const Value.absent(),
    this.referralType = const Value.absent(),
    this.referralReason = const Value.absent(),
    this.referralStatus = const Value.absent(),
    this.referredBy = const Value.absent(),
    this.referredDate = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  static Insertable<LocalReferral> custom({
    Expression<int>? id,
    Expression<int>? childRemoteId,
    Expression<int>? screeningResultLocalId,
    Expression<int>? screeningResultRemoteId,
    Expression<bool>? referralTriggered,
    Expression<String>? referralType,
    Expression<String>? referralReason,
    Expression<String>? referralStatus,
    Expression<String>? referredBy,
    Expression<String>? referredDate,
    Expression<String>? completedDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childRemoteId != null) 'child_remote_id': childRemoteId,
      if (screeningResultLocalId != null)
        'screening_result_local_id': screeningResultLocalId,
      if (screeningResultRemoteId != null)
        'screening_result_remote_id': screeningResultRemoteId,
      if (referralTriggered != null) 'referral_triggered': referralTriggered,
      if (referralType != null) 'referral_type': referralType,
      if (referralReason != null) 'referral_reason': referralReason,
      if (referralStatus != null) 'referral_status': referralStatus,
      if (referredBy != null) 'referred_by': referredBy,
      if (referredDate != null) 'referred_date': referredDate,
      if (completedDate != null) 'completed_date': completedDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  LocalReferralsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? childRemoteId,
      Value<int?>? screeningResultLocalId,
      Value<int?>? screeningResultRemoteId,
      Value<bool>? referralTriggered,
      Value<String?>? referralType,
      Value<String?>? referralReason,
      Value<String>? referralStatus,
      Value<String?>? referredBy,
      Value<String?>? referredDate,
      Value<String?>? completedDate,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? syncedAt}) {
    return LocalReferralsCompanion(
      id: id ?? this.id,
      childRemoteId: childRemoteId ?? this.childRemoteId,
      screeningResultLocalId:
          screeningResultLocalId ?? this.screeningResultLocalId,
      screeningResultRemoteId:
          screeningResultRemoteId ?? this.screeningResultRemoteId,
      referralTriggered: referralTriggered ?? this.referralTriggered,
      referralType: referralType ?? this.referralType,
      referralReason: referralReason ?? this.referralReason,
      referralStatus: referralStatus ?? this.referralStatus,
      referredBy: referredBy ?? this.referredBy,
      referredDate: referredDate ?? this.referredDate,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childRemoteId.present) {
      map['child_remote_id'] = Variable<int>(childRemoteId.value);
    }
    if (screeningResultLocalId.present) {
      map['screening_result_local_id'] =
          Variable<int>(screeningResultLocalId.value);
    }
    if (screeningResultRemoteId.present) {
      map['screening_result_remote_id'] =
          Variable<int>(screeningResultRemoteId.value);
    }
    if (referralTriggered.present) {
      map['referral_triggered'] = Variable<bool>(referralTriggered.value);
    }
    if (referralType.present) {
      map['referral_type'] = Variable<String>(referralType.value);
    }
    if (referralReason.present) {
      map['referral_reason'] = Variable<String>(referralReason.value);
    }
    if (referralStatus.present) {
      map['referral_status'] = Variable<String>(referralStatus.value);
    }
    if (referredBy.present) {
      map['referred_by'] = Variable<String>(referredBy.value);
    }
    if (referredDate.present) {
      map['referred_date'] = Variable<String>(referredDate.value);
    }
    if (completedDate.present) {
      map['completed_date'] = Variable<String>(completedDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalReferralsCompanion(')
          ..write('id: $id, ')
          ..write('childRemoteId: $childRemoteId, ')
          ..write('screeningResultLocalId: $screeningResultLocalId, ')
          ..write('screeningResultRemoteId: $screeningResultRemoteId, ')
          ..write('referralTriggered: $referralTriggered, ')
          ..write('referralType: $referralType, ')
          ..write('referralReason: $referralReason, ')
          ..write('referralStatus: $referralStatus, ')
          ..write('referredBy: $referredBy, ')
          ..write('referredDate: $referredDate, ')
          ..write('completedDate: $completedDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalNutritionAssessmentsTable extends LocalNutritionAssessments
    with TableInfo<$LocalNutritionAssessmentsTable, LocalNutritionAssessment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalNutritionAssessmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _childRemoteIdMeta =
      const VerificationMeta('childRemoteId');
  @override
  late final GeneratedColumn<int> childRemoteId = GeneratedColumn<int>(
      'child_remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sessionLocalIdMeta =
      const VerificationMeta('sessionLocalId');
  @override
  late final GeneratedColumn<int> sessionLocalId = GeneratedColumn<int>(
      'session_local_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _heightCmMeta =
      const VerificationMeta('heightCm');
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
      'height_cm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _muacCmMeta = const VerificationMeta('muacCm');
  @override
  late final GeneratedColumn<double> muacCm = GeneratedColumn<double>(
      'muac_cm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _underweightMeta =
      const VerificationMeta('underweight');
  @override
  late final GeneratedColumn<bool> underweight = GeneratedColumn<bool>(
      'underweight', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("underweight" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _stuntingMeta =
      const VerificationMeta('stunting');
  @override
  late final GeneratedColumn<bool> stunting = GeneratedColumn<bool>(
      'stunting', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("stunting" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _wastingMeta =
      const VerificationMeta('wasting');
  @override
  late final GeneratedColumn<bool> wasting = GeneratedColumn<bool>(
      'wasting', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("wasting" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _anemiaMeta = const VerificationMeta('anemia');
  @override
  late final GeneratedColumn<bool> anemia = GeneratedColumn<bool>(
      'anemia', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("anemia" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _nutritionScoreMeta =
      const VerificationMeta('nutritionScore');
  @override
  late final GeneratedColumn<int> nutritionScore = GeneratedColumn<int>(
      'nutrition_score', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nutritionRiskMeta =
      const VerificationMeta('nutritionRisk');
  @override
  late final GeneratedColumn<String> nutritionRisk = GeneratedColumn<String>(
      'nutrition_risk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Low'));
  static const VerificationMeta _assessedDateMeta =
      const VerificationMeta('assessedDate');
  @override
  late final GeneratedColumn<String> assessedDate = GeneratedColumn<String>(
      'assessed_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        childRemoteId,
        sessionLocalId,
        heightCm,
        weightKg,
        muacCm,
        underweight,
        stunting,
        wasting,
        anemia,
        nutritionScore,
        nutritionRisk,
        assessedDate,
        createdAt,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_nutrition_assessments';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalNutritionAssessment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_remote_id')) {
      context.handle(
          _childRemoteIdMeta,
          childRemoteId.isAcceptableOrUnknown(
              data['child_remote_id']!, _childRemoteIdMeta));
    }
    if (data.containsKey('session_local_id')) {
      context.handle(
          _sessionLocalIdMeta,
          sessionLocalId.isAcceptableOrUnknown(
              data['session_local_id']!, _sessionLocalIdMeta));
    }
    if (data.containsKey('height_cm')) {
      context.handle(_heightCmMeta,
          heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta));
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    }
    if (data.containsKey('muac_cm')) {
      context.handle(_muacCmMeta,
          muacCm.isAcceptableOrUnknown(data['muac_cm']!, _muacCmMeta));
    }
    if (data.containsKey('underweight')) {
      context.handle(
          _underweightMeta,
          underweight.isAcceptableOrUnknown(
              data['underweight']!, _underweightMeta));
    }
    if (data.containsKey('stunting')) {
      context.handle(_stuntingMeta,
          stunting.isAcceptableOrUnknown(data['stunting']!, _stuntingMeta));
    }
    if (data.containsKey('wasting')) {
      context.handle(_wastingMeta,
          wasting.isAcceptableOrUnknown(data['wasting']!, _wastingMeta));
    }
    if (data.containsKey('anemia')) {
      context.handle(_anemiaMeta,
          anemia.isAcceptableOrUnknown(data['anemia']!, _anemiaMeta));
    }
    if (data.containsKey('nutrition_score')) {
      context.handle(
          _nutritionScoreMeta,
          nutritionScore.isAcceptableOrUnknown(
              data['nutrition_score']!, _nutritionScoreMeta));
    }
    if (data.containsKey('nutrition_risk')) {
      context.handle(
          _nutritionRiskMeta,
          nutritionRisk.isAcceptableOrUnknown(
              data['nutrition_risk']!, _nutritionRiskMeta));
    }
    if (data.containsKey('assessed_date')) {
      context.handle(
          _assessedDateMeta,
          assessedDate.isAcceptableOrUnknown(
              data['assessed_date']!, _assessedDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalNutritionAssessment map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalNutritionAssessment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      childRemoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}child_remote_id']),
      sessionLocalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_local_id']),
      heightCm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height_cm']),
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg']),
      muacCm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}muac_cm']),
      underweight: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}underweight'])!,
      stunting: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}stunting'])!,
      wasting: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}wasting'])!,
      anemia: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}anemia'])!,
      nutritionScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nutrition_score'])!,
      nutritionRisk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nutrition_risk'])!,
      assessedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assessed_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $LocalNutritionAssessmentsTable createAlias(String alias) {
    return $LocalNutritionAssessmentsTable(attachedDatabase, alias);
  }
}

class LocalNutritionAssessment extends DataClass
    implements Insertable<LocalNutritionAssessment> {
  final int id;
  final int? childRemoteId;
  final int? sessionLocalId;
  final double? heightCm;
  final double? weightKg;
  final double? muacCm;
  final bool underweight;
  final bool stunting;
  final bool wasting;
  final bool anemia;
  final int nutritionScore;
  final String nutritionRisk;
  final String? assessedDate;
  final DateTime createdAt;
  final DateTime? syncedAt;
  const LocalNutritionAssessment(
      {required this.id,
      this.childRemoteId,
      this.sessionLocalId,
      this.heightCm,
      this.weightKg,
      this.muacCm,
      required this.underweight,
      required this.stunting,
      required this.wasting,
      required this.anemia,
      required this.nutritionScore,
      required this.nutritionRisk,
      this.assessedDate,
      required this.createdAt,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || childRemoteId != null) {
      map['child_remote_id'] = Variable<int>(childRemoteId);
    }
    if (!nullToAbsent || sessionLocalId != null) {
      map['session_local_id'] = Variable<int>(sessionLocalId);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || muacCm != null) {
      map['muac_cm'] = Variable<double>(muacCm);
    }
    map['underweight'] = Variable<bool>(underweight);
    map['stunting'] = Variable<bool>(stunting);
    map['wasting'] = Variable<bool>(wasting);
    map['anemia'] = Variable<bool>(anemia);
    map['nutrition_score'] = Variable<int>(nutritionScore);
    map['nutrition_risk'] = Variable<String>(nutritionRisk);
    if (!nullToAbsent || assessedDate != null) {
      map['assessed_date'] = Variable<String>(assessedDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  LocalNutritionAssessmentsCompanion toCompanion(bool nullToAbsent) {
    return LocalNutritionAssessmentsCompanion(
      id: Value(id),
      childRemoteId: childRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(childRemoteId),
      sessionLocalId: sessionLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionLocalId),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      muacCm:
          muacCm == null && nullToAbsent ? const Value.absent() : Value(muacCm),
      underweight: Value(underweight),
      stunting: Value(stunting),
      wasting: Value(wasting),
      anemia: Value(anemia),
      nutritionScore: Value(nutritionScore),
      nutritionRisk: Value(nutritionRisk),
      assessedDate: assessedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(assessedDate),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalNutritionAssessment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalNutritionAssessment(
      id: serializer.fromJson<int>(json['id']),
      childRemoteId: serializer.fromJson<int?>(json['childRemoteId']),
      sessionLocalId: serializer.fromJson<int?>(json['sessionLocalId']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      muacCm: serializer.fromJson<double?>(json['muacCm']),
      underweight: serializer.fromJson<bool>(json['underweight']),
      stunting: serializer.fromJson<bool>(json['stunting']),
      wasting: serializer.fromJson<bool>(json['wasting']),
      anemia: serializer.fromJson<bool>(json['anemia']),
      nutritionScore: serializer.fromJson<int>(json['nutritionScore']),
      nutritionRisk: serializer.fromJson<String>(json['nutritionRisk']),
      assessedDate: serializer.fromJson<String?>(json['assessedDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childRemoteId': serializer.toJson<int?>(childRemoteId),
      'sessionLocalId': serializer.toJson<int?>(sessionLocalId),
      'heightCm': serializer.toJson<double?>(heightCm),
      'weightKg': serializer.toJson<double?>(weightKg),
      'muacCm': serializer.toJson<double?>(muacCm),
      'underweight': serializer.toJson<bool>(underweight),
      'stunting': serializer.toJson<bool>(stunting),
      'wasting': serializer.toJson<bool>(wasting),
      'anemia': serializer.toJson<bool>(anemia),
      'nutritionScore': serializer.toJson<int>(nutritionScore),
      'nutritionRisk': serializer.toJson<String>(nutritionRisk),
      'assessedDate': serializer.toJson<String?>(assessedDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalNutritionAssessment copyWith(
          {int? id,
          Value<int?> childRemoteId = const Value.absent(),
          Value<int?> sessionLocalId = const Value.absent(),
          Value<double?> heightCm = const Value.absent(),
          Value<double?> weightKg = const Value.absent(),
          Value<double?> muacCm = const Value.absent(),
          bool? underweight,
          bool? stunting,
          bool? wasting,
          bool? anemia,
          int? nutritionScore,
          String? nutritionRisk,
          Value<String?> assessedDate = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      LocalNutritionAssessment(
        id: id ?? this.id,
        childRemoteId:
            childRemoteId.present ? childRemoteId.value : this.childRemoteId,
        sessionLocalId:
            sessionLocalId.present ? sessionLocalId.value : this.sessionLocalId,
        heightCm: heightCm.present ? heightCm.value : this.heightCm,
        weightKg: weightKg.present ? weightKg.value : this.weightKg,
        muacCm: muacCm.present ? muacCm.value : this.muacCm,
        underweight: underweight ?? this.underweight,
        stunting: stunting ?? this.stunting,
        wasting: wasting ?? this.wasting,
        anemia: anemia ?? this.anemia,
        nutritionScore: nutritionScore ?? this.nutritionScore,
        nutritionRisk: nutritionRisk ?? this.nutritionRisk,
        assessedDate:
            assessedDate.present ? assessedDate.value : this.assessedDate,
        createdAt: createdAt ?? this.createdAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  LocalNutritionAssessment copyWithCompanion(
      LocalNutritionAssessmentsCompanion data) {
    return LocalNutritionAssessment(
      id: data.id.present ? data.id.value : this.id,
      childRemoteId: data.childRemoteId.present
          ? data.childRemoteId.value
          : this.childRemoteId,
      sessionLocalId: data.sessionLocalId.present
          ? data.sessionLocalId.value
          : this.sessionLocalId,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      muacCm: data.muacCm.present ? data.muacCm.value : this.muacCm,
      underweight:
          data.underweight.present ? data.underweight.value : this.underweight,
      stunting: data.stunting.present ? data.stunting.value : this.stunting,
      wasting: data.wasting.present ? data.wasting.value : this.wasting,
      anemia: data.anemia.present ? data.anemia.value : this.anemia,
      nutritionScore: data.nutritionScore.present
          ? data.nutritionScore.value
          : this.nutritionScore,
      nutritionRisk: data.nutritionRisk.present
          ? data.nutritionRisk.value
          : this.nutritionRisk,
      assessedDate: data.assessedDate.present
          ? data.assessedDate.value
          : this.assessedDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalNutritionAssessment(')
          ..write('id: $id, ')
          ..write('childRemoteId: $childRemoteId, ')
          ..write('sessionLocalId: $sessionLocalId, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('muacCm: $muacCm, ')
          ..write('underweight: $underweight, ')
          ..write('stunting: $stunting, ')
          ..write('wasting: $wasting, ')
          ..write('anemia: $anemia, ')
          ..write('nutritionScore: $nutritionScore, ')
          ..write('nutritionRisk: $nutritionRisk, ')
          ..write('assessedDate: $assessedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      childRemoteId,
      sessionLocalId,
      heightCm,
      weightKg,
      muacCm,
      underweight,
      stunting,
      wasting,
      anemia,
      nutritionScore,
      nutritionRisk,
      assessedDate,
      createdAt,
      syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalNutritionAssessment &&
          other.id == this.id &&
          other.childRemoteId == this.childRemoteId &&
          other.sessionLocalId == this.sessionLocalId &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.muacCm == this.muacCm &&
          other.underweight == this.underweight &&
          other.stunting == this.stunting &&
          other.wasting == this.wasting &&
          other.anemia == this.anemia &&
          other.nutritionScore == this.nutritionScore &&
          other.nutritionRisk == this.nutritionRisk &&
          other.assessedDate == this.assessedDate &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class LocalNutritionAssessmentsCompanion
    extends UpdateCompanion<LocalNutritionAssessment> {
  final Value<int> id;
  final Value<int?> childRemoteId;
  final Value<int?> sessionLocalId;
  final Value<double?> heightCm;
  final Value<double?> weightKg;
  final Value<double?> muacCm;
  final Value<bool> underweight;
  final Value<bool> stunting;
  final Value<bool> wasting;
  final Value<bool> anemia;
  final Value<int> nutritionScore;
  final Value<String> nutritionRisk;
  final Value<String?> assessedDate;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  const LocalNutritionAssessmentsCompanion({
    this.id = const Value.absent(),
    this.childRemoteId = const Value.absent(),
    this.sessionLocalId = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.muacCm = const Value.absent(),
    this.underweight = const Value.absent(),
    this.stunting = const Value.absent(),
    this.wasting = const Value.absent(),
    this.anemia = const Value.absent(),
    this.nutritionScore = const Value.absent(),
    this.nutritionRisk = const Value.absent(),
    this.assessedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  LocalNutritionAssessmentsCompanion.insert({
    this.id = const Value.absent(),
    this.childRemoteId = const Value.absent(),
    this.sessionLocalId = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.muacCm = const Value.absent(),
    this.underweight = const Value.absent(),
    this.stunting = const Value.absent(),
    this.wasting = const Value.absent(),
    this.anemia = const Value.absent(),
    this.nutritionScore = const Value.absent(),
    this.nutritionRisk = const Value.absent(),
    this.assessedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  static Insertable<LocalNutritionAssessment> custom({
    Expression<int>? id,
    Expression<int>? childRemoteId,
    Expression<int>? sessionLocalId,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<double>? muacCm,
    Expression<bool>? underweight,
    Expression<bool>? stunting,
    Expression<bool>? wasting,
    Expression<bool>? anemia,
    Expression<int>? nutritionScore,
    Expression<String>? nutritionRisk,
    Expression<String>? assessedDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childRemoteId != null) 'child_remote_id': childRemoteId,
      if (sessionLocalId != null) 'session_local_id': sessionLocalId,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (muacCm != null) 'muac_cm': muacCm,
      if (underweight != null) 'underweight': underweight,
      if (stunting != null) 'stunting': stunting,
      if (wasting != null) 'wasting': wasting,
      if (anemia != null) 'anemia': anemia,
      if (nutritionScore != null) 'nutrition_score': nutritionScore,
      if (nutritionRisk != null) 'nutrition_risk': nutritionRisk,
      if (assessedDate != null) 'assessed_date': assessedDate,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  LocalNutritionAssessmentsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? childRemoteId,
      Value<int?>? sessionLocalId,
      Value<double?>? heightCm,
      Value<double?>? weightKg,
      Value<double?>? muacCm,
      Value<bool>? underweight,
      Value<bool>? stunting,
      Value<bool>? wasting,
      Value<bool>? anemia,
      Value<int>? nutritionScore,
      Value<String>? nutritionRisk,
      Value<String?>? assessedDate,
      Value<DateTime>? createdAt,
      Value<DateTime?>? syncedAt}) {
    return LocalNutritionAssessmentsCompanion(
      id: id ?? this.id,
      childRemoteId: childRemoteId ?? this.childRemoteId,
      sessionLocalId: sessionLocalId ?? this.sessionLocalId,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      muacCm: muacCm ?? this.muacCm,
      underweight: underweight ?? this.underweight,
      stunting: stunting ?? this.stunting,
      wasting: wasting ?? this.wasting,
      anemia: anemia ?? this.anemia,
      nutritionScore: nutritionScore ?? this.nutritionScore,
      nutritionRisk: nutritionRisk ?? this.nutritionRisk,
      assessedDate: assessedDate ?? this.assessedDate,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childRemoteId.present) {
      map['child_remote_id'] = Variable<int>(childRemoteId.value);
    }
    if (sessionLocalId.present) {
      map['session_local_id'] = Variable<int>(sessionLocalId.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (muacCm.present) {
      map['muac_cm'] = Variable<double>(muacCm.value);
    }
    if (underweight.present) {
      map['underweight'] = Variable<bool>(underweight.value);
    }
    if (stunting.present) {
      map['stunting'] = Variable<bool>(stunting.value);
    }
    if (wasting.present) {
      map['wasting'] = Variable<bool>(wasting.value);
    }
    if (anemia.present) {
      map['anemia'] = Variable<bool>(anemia.value);
    }
    if (nutritionScore.present) {
      map['nutrition_score'] = Variable<int>(nutritionScore.value);
    }
    if (nutritionRisk.present) {
      map['nutrition_risk'] = Variable<String>(nutritionRisk.value);
    }
    if (assessedDate.present) {
      map['assessed_date'] = Variable<String>(assessedDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalNutritionAssessmentsCompanion(')
          ..write('id: $id, ')
          ..write('childRemoteId: $childRemoteId, ')
          ..write('sessionLocalId: $sessionLocalId, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('muacCm: $muacCm, ')
          ..write('underweight: $underweight, ')
          ..write('stunting: $stunting, ')
          ..write('wasting: $wasting, ')
          ..write('anemia: $anemia, ')
          ..write('nutritionScore: $nutritionScore, ')
          ..write('nutritionRisk: $nutritionRisk, ')
          ..write('assessedDate: $assessedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalEnvironmentAssessmentsTable extends LocalEnvironmentAssessments
    with
        TableInfo<$LocalEnvironmentAssessmentsTable,
            LocalEnvironmentAssessment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalEnvironmentAssessmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _childRemoteIdMeta =
      const VerificationMeta('childRemoteId');
  @override
  late final GeneratedColumn<int> childRemoteId = GeneratedColumn<int>(
      'child_remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sessionLocalIdMeta =
      const VerificationMeta('sessionLocalId');
  @override
  late final GeneratedColumn<int> sessionLocalId = GeneratedColumn<int>(
      'session_local_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _parentChildInteractionScoreMeta =
      const VerificationMeta('parentChildInteractionScore');
  @override
  late final GeneratedColumn<int> parentChildInteractionScore =
      GeneratedColumn<int>('parent_child_interaction_score', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _parentMentalHealthScoreMeta =
      const VerificationMeta('parentMentalHealthScore');
  @override
  late final GeneratedColumn<int> parentMentalHealthScore =
      GeneratedColumn<int>('parent_mental_health_score', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _homeStimulationScoreMeta =
      const VerificationMeta('homeStimulationScore');
  @override
  late final GeneratedColumn<int> homeStimulationScore = GeneratedColumn<int>(
      'home_stimulation_score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _playMaterialsMeta =
      const VerificationMeta('playMaterials');
  @override
  late final GeneratedColumn<bool> playMaterials = GeneratedColumn<bool>(
      'play_materials', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("play_materials" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _caregiverEngagementMeta =
      const VerificationMeta('caregiverEngagement');
  @override
  late final GeneratedColumn<String> caregiverEngagement =
      GeneratedColumn<String>('caregiver_engagement', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('Medium'));
  static const VerificationMeta _languageExposureMeta =
      const VerificationMeta('languageExposure');
  @override
  late final GeneratedColumn<String> languageExposure = GeneratedColumn<String>(
      'language_exposure', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Adequate'));
  static const VerificationMeta _safeWaterMeta =
      const VerificationMeta('safeWater');
  @override
  late final GeneratedColumn<bool> safeWater = GeneratedColumn<bool>(
      'safe_water', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("safe_water" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _toiletFacilityMeta =
      const VerificationMeta('toiletFacility');
  @override
  late final GeneratedColumn<bool> toiletFacility = GeneratedColumn<bool>(
      'toilet_facility', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("toilet_facility" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        childRemoteId,
        sessionLocalId,
        parentChildInteractionScore,
        parentMentalHealthScore,
        homeStimulationScore,
        playMaterials,
        caregiverEngagement,
        languageExposure,
        safeWater,
        toiletFacility,
        createdAt,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_environment_assessments';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalEnvironmentAssessment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_remote_id')) {
      context.handle(
          _childRemoteIdMeta,
          childRemoteId.isAcceptableOrUnknown(
              data['child_remote_id']!, _childRemoteIdMeta));
    }
    if (data.containsKey('session_local_id')) {
      context.handle(
          _sessionLocalIdMeta,
          sessionLocalId.isAcceptableOrUnknown(
              data['session_local_id']!, _sessionLocalIdMeta));
    }
    if (data.containsKey('parent_child_interaction_score')) {
      context.handle(
          _parentChildInteractionScoreMeta,
          parentChildInteractionScore.isAcceptableOrUnknown(
              data['parent_child_interaction_score']!,
              _parentChildInteractionScoreMeta));
    }
    if (data.containsKey('parent_mental_health_score')) {
      context.handle(
          _parentMentalHealthScoreMeta,
          parentMentalHealthScore.isAcceptableOrUnknown(
              data['parent_mental_health_score']!,
              _parentMentalHealthScoreMeta));
    }
    if (data.containsKey('home_stimulation_score')) {
      context.handle(
          _homeStimulationScoreMeta,
          homeStimulationScore.isAcceptableOrUnknown(
              data['home_stimulation_score']!, _homeStimulationScoreMeta));
    }
    if (data.containsKey('play_materials')) {
      context.handle(
          _playMaterialsMeta,
          playMaterials.isAcceptableOrUnknown(
              data['play_materials']!, _playMaterialsMeta));
    }
    if (data.containsKey('caregiver_engagement')) {
      context.handle(
          _caregiverEngagementMeta,
          caregiverEngagement.isAcceptableOrUnknown(
              data['caregiver_engagement']!, _caregiverEngagementMeta));
    }
    if (data.containsKey('language_exposure')) {
      context.handle(
          _languageExposureMeta,
          languageExposure.isAcceptableOrUnknown(
              data['language_exposure']!, _languageExposureMeta));
    }
    if (data.containsKey('safe_water')) {
      context.handle(_safeWaterMeta,
          safeWater.isAcceptableOrUnknown(data['safe_water']!, _safeWaterMeta));
    }
    if (data.containsKey('toilet_facility')) {
      context.handle(
          _toiletFacilityMeta,
          toiletFacility.isAcceptableOrUnknown(
              data['toilet_facility']!, _toiletFacilityMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalEnvironmentAssessment map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalEnvironmentAssessment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      childRemoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}child_remote_id']),
      sessionLocalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_local_id']),
      parentChildInteractionScore: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}parent_child_interaction_score']),
      parentMentalHealthScore: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}parent_mental_health_score']),
      homeStimulationScore: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}home_stimulation_score']),
      playMaterials: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}play_materials'])!,
      caregiverEngagement: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}caregiver_engagement'])!,
      languageExposure: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}language_exposure'])!,
      safeWater: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}safe_water'])!,
      toiletFacility: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}toilet_facility'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $LocalEnvironmentAssessmentsTable createAlias(String alias) {
    return $LocalEnvironmentAssessmentsTable(attachedDatabase, alias);
  }
}

class LocalEnvironmentAssessment extends DataClass
    implements Insertable<LocalEnvironmentAssessment> {
  final int id;
  final int? childRemoteId;
  final int? sessionLocalId;
  final int? parentChildInteractionScore;
  final int? parentMentalHealthScore;
  final int? homeStimulationScore;
  final bool playMaterials;
  final String caregiverEngagement;
  final String languageExposure;
  final bool safeWater;
  final bool toiletFacility;
  final DateTime createdAt;
  final DateTime? syncedAt;
  const LocalEnvironmentAssessment(
      {required this.id,
      this.childRemoteId,
      this.sessionLocalId,
      this.parentChildInteractionScore,
      this.parentMentalHealthScore,
      this.homeStimulationScore,
      required this.playMaterials,
      required this.caregiverEngagement,
      required this.languageExposure,
      required this.safeWater,
      required this.toiletFacility,
      required this.createdAt,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || childRemoteId != null) {
      map['child_remote_id'] = Variable<int>(childRemoteId);
    }
    if (!nullToAbsent || sessionLocalId != null) {
      map['session_local_id'] = Variable<int>(sessionLocalId);
    }
    if (!nullToAbsent || parentChildInteractionScore != null) {
      map['parent_child_interaction_score'] =
          Variable<int>(parentChildInteractionScore);
    }
    if (!nullToAbsent || parentMentalHealthScore != null) {
      map['parent_mental_health_score'] =
          Variable<int>(parentMentalHealthScore);
    }
    if (!nullToAbsent || homeStimulationScore != null) {
      map['home_stimulation_score'] = Variable<int>(homeStimulationScore);
    }
    map['play_materials'] = Variable<bool>(playMaterials);
    map['caregiver_engagement'] = Variable<String>(caregiverEngagement);
    map['language_exposure'] = Variable<String>(languageExposure);
    map['safe_water'] = Variable<bool>(safeWater);
    map['toilet_facility'] = Variable<bool>(toiletFacility);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  LocalEnvironmentAssessmentsCompanion toCompanion(bool nullToAbsent) {
    return LocalEnvironmentAssessmentsCompanion(
      id: Value(id),
      childRemoteId: childRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(childRemoteId),
      sessionLocalId: sessionLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionLocalId),
      parentChildInteractionScore:
          parentChildInteractionScore == null && nullToAbsent
              ? const Value.absent()
              : Value(parentChildInteractionScore),
      parentMentalHealthScore: parentMentalHealthScore == null && nullToAbsent
          ? const Value.absent()
          : Value(parentMentalHealthScore),
      homeStimulationScore: homeStimulationScore == null && nullToAbsent
          ? const Value.absent()
          : Value(homeStimulationScore),
      playMaterials: Value(playMaterials),
      caregiverEngagement: Value(caregiverEngagement),
      languageExposure: Value(languageExposure),
      safeWater: Value(safeWater),
      toiletFacility: Value(toiletFacility),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalEnvironmentAssessment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalEnvironmentAssessment(
      id: serializer.fromJson<int>(json['id']),
      childRemoteId: serializer.fromJson<int?>(json['childRemoteId']),
      sessionLocalId: serializer.fromJson<int?>(json['sessionLocalId']),
      parentChildInteractionScore:
          serializer.fromJson<int?>(json['parentChildInteractionScore']),
      parentMentalHealthScore:
          serializer.fromJson<int?>(json['parentMentalHealthScore']),
      homeStimulationScore:
          serializer.fromJson<int?>(json['homeStimulationScore']),
      playMaterials: serializer.fromJson<bool>(json['playMaterials']),
      caregiverEngagement:
          serializer.fromJson<String>(json['caregiverEngagement']),
      languageExposure: serializer.fromJson<String>(json['languageExposure']),
      safeWater: serializer.fromJson<bool>(json['safeWater']),
      toiletFacility: serializer.fromJson<bool>(json['toiletFacility']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childRemoteId': serializer.toJson<int?>(childRemoteId),
      'sessionLocalId': serializer.toJson<int?>(sessionLocalId),
      'parentChildInteractionScore':
          serializer.toJson<int?>(parentChildInteractionScore),
      'parentMentalHealthScore':
          serializer.toJson<int?>(parentMentalHealthScore),
      'homeStimulationScore': serializer.toJson<int?>(homeStimulationScore),
      'playMaterials': serializer.toJson<bool>(playMaterials),
      'caregiverEngagement': serializer.toJson<String>(caregiverEngagement),
      'languageExposure': serializer.toJson<String>(languageExposure),
      'safeWater': serializer.toJson<bool>(safeWater),
      'toiletFacility': serializer.toJson<bool>(toiletFacility),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalEnvironmentAssessment copyWith(
          {int? id,
          Value<int?> childRemoteId = const Value.absent(),
          Value<int?> sessionLocalId = const Value.absent(),
          Value<int?> parentChildInteractionScore = const Value.absent(),
          Value<int?> parentMentalHealthScore = const Value.absent(),
          Value<int?> homeStimulationScore = const Value.absent(),
          bool? playMaterials,
          String? caregiverEngagement,
          String? languageExposure,
          bool? safeWater,
          bool? toiletFacility,
          DateTime? createdAt,
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      LocalEnvironmentAssessment(
        id: id ?? this.id,
        childRemoteId:
            childRemoteId.present ? childRemoteId.value : this.childRemoteId,
        sessionLocalId:
            sessionLocalId.present ? sessionLocalId.value : this.sessionLocalId,
        parentChildInteractionScore: parentChildInteractionScore.present
            ? parentChildInteractionScore.value
            : this.parentChildInteractionScore,
        parentMentalHealthScore: parentMentalHealthScore.present
            ? parentMentalHealthScore.value
            : this.parentMentalHealthScore,
        homeStimulationScore: homeStimulationScore.present
            ? homeStimulationScore.value
            : this.homeStimulationScore,
        playMaterials: playMaterials ?? this.playMaterials,
        caregiverEngagement: caregiverEngagement ?? this.caregiverEngagement,
        languageExposure: languageExposure ?? this.languageExposure,
        safeWater: safeWater ?? this.safeWater,
        toiletFacility: toiletFacility ?? this.toiletFacility,
        createdAt: createdAt ?? this.createdAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  LocalEnvironmentAssessment copyWithCompanion(
      LocalEnvironmentAssessmentsCompanion data) {
    return LocalEnvironmentAssessment(
      id: data.id.present ? data.id.value : this.id,
      childRemoteId: data.childRemoteId.present
          ? data.childRemoteId.value
          : this.childRemoteId,
      sessionLocalId: data.sessionLocalId.present
          ? data.sessionLocalId.value
          : this.sessionLocalId,
      parentChildInteractionScore: data.parentChildInteractionScore.present
          ? data.parentChildInteractionScore.value
          : this.parentChildInteractionScore,
      parentMentalHealthScore: data.parentMentalHealthScore.present
          ? data.parentMentalHealthScore.value
          : this.parentMentalHealthScore,
      homeStimulationScore: data.homeStimulationScore.present
          ? data.homeStimulationScore.value
          : this.homeStimulationScore,
      playMaterials: data.playMaterials.present
          ? data.playMaterials.value
          : this.playMaterials,
      caregiverEngagement: data.caregiverEngagement.present
          ? data.caregiverEngagement.value
          : this.caregiverEngagement,
      languageExposure: data.languageExposure.present
          ? data.languageExposure.value
          : this.languageExposure,
      safeWater: data.safeWater.present ? data.safeWater.value : this.safeWater,
      toiletFacility: data.toiletFacility.present
          ? data.toiletFacility.value
          : this.toiletFacility,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalEnvironmentAssessment(')
          ..write('id: $id, ')
          ..write('childRemoteId: $childRemoteId, ')
          ..write('sessionLocalId: $sessionLocalId, ')
          ..write('parentChildInteractionScore: $parentChildInteractionScore, ')
          ..write('parentMentalHealthScore: $parentMentalHealthScore, ')
          ..write('homeStimulationScore: $homeStimulationScore, ')
          ..write('playMaterials: $playMaterials, ')
          ..write('caregiverEngagement: $caregiverEngagement, ')
          ..write('languageExposure: $languageExposure, ')
          ..write('safeWater: $safeWater, ')
          ..write('toiletFacility: $toiletFacility, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      childRemoteId,
      sessionLocalId,
      parentChildInteractionScore,
      parentMentalHealthScore,
      homeStimulationScore,
      playMaterials,
      caregiverEngagement,
      languageExposure,
      safeWater,
      toiletFacility,
      createdAt,
      syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalEnvironmentAssessment &&
          other.id == this.id &&
          other.childRemoteId == this.childRemoteId &&
          other.sessionLocalId == this.sessionLocalId &&
          other.parentChildInteractionScore ==
              this.parentChildInteractionScore &&
          other.parentMentalHealthScore == this.parentMentalHealthScore &&
          other.homeStimulationScore == this.homeStimulationScore &&
          other.playMaterials == this.playMaterials &&
          other.caregiverEngagement == this.caregiverEngagement &&
          other.languageExposure == this.languageExposure &&
          other.safeWater == this.safeWater &&
          other.toiletFacility == this.toiletFacility &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class LocalEnvironmentAssessmentsCompanion
    extends UpdateCompanion<LocalEnvironmentAssessment> {
  final Value<int> id;
  final Value<int?> childRemoteId;
  final Value<int?> sessionLocalId;
  final Value<int?> parentChildInteractionScore;
  final Value<int?> parentMentalHealthScore;
  final Value<int?> homeStimulationScore;
  final Value<bool> playMaterials;
  final Value<String> caregiverEngagement;
  final Value<String> languageExposure;
  final Value<bool> safeWater;
  final Value<bool> toiletFacility;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  const LocalEnvironmentAssessmentsCompanion({
    this.id = const Value.absent(),
    this.childRemoteId = const Value.absent(),
    this.sessionLocalId = const Value.absent(),
    this.parentChildInteractionScore = const Value.absent(),
    this.parentMentalHealthScore = const Value.absent(),
    this.homeStimulationScore = const Value.absent(),
    this.playMaterials = const Value.absent(),
    this.caregiverEngagement = const Value.absent(),
    this.languageExposure = const Value.absent(),
    this.safeWater = const Value.absent(),
    this.toiletFacility = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  LocalEnvironmentAssessmentsCompanion.insert({
    this.id = const Value.absent(),
    this.childRemoteId = const Value.absent(),
    this.sessionLocalId = const Value.absent(),
    this.parentChildInteractionScore = const Value.absent(),
    this.parentMentalHealthScore = const Value.absent(),
    this.homeStimulationScore = const Value.absent(),
    this.playMaterials = const Value.absent(),
    this.caregiverEngagement = const Value.absent(),
    this.languageExposure = const Value.absent(),
    this.safeWater = const Value.absent(),
    this.toiletFacility = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  static Insertable<LocalEnvironmentAssessment> custom({
    Expression<int>? id,
    Expression<int>? childRemoteId,
    Expression<int>? sessionLocalId,
    Expression<int>? parentChildInteractionScore,
    Expression<int>? parentMentalHealthScore,
    Expression<int>? homeStimulationScore,
    Expression<bool>? playMaterials,
    Expression<String>? caregiverEngagement,
    Expression<String>? languageExposure,
    Expression<bool>? safeWater,
    Expression<bool>? toiletFacility,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childRemoteId != null) 'child_remote_id': childRemoteId,
      if (sessionLocalId != null) 'session_local_id': sessionLocalId,
      if (parentChildInteractionScore != null)
        'parent_child_interaction_score': parentChildInteractionScore,
      if (parentMentalHealthScore != null)
        'parent_mental_health_score': parentMentalHealthScore,
      if (homeStimulationScore != null)
        'home_stimulation_score': homeStimulationScore,
      if (playMaterials != null) 'play_materials': playMaterials,
      if (caregiverEngagement != null)
        'caregiver_engagement': caregiverEngagement,
      if (languageExposure != null) 'language_exposure': languageExposure,
      if (safeWater != null) 'safe_water': safeWater,
      if (toiletFacility != null) 'toilet_facility': toiletFacility,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  LocalEnvironmentAssessmentsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? childRemoteId,
      Value<int?>? sessionLocalId,
      Value<int?>? parentChildInteractionScore,
      Value<int?>? parentMentalHealthScore,
      Value<int?>? homeStimulationScore,
      Value<bool>? playMaterials,
      Value<String>? caregiverEngagement,
      Value<String>? languageExposure,
      Value<bool>? safeWater,
      Value<bool>? toiletFacility,
      Value<DateTime>? createdAt,
      Value<DateTime?>? syncedAt}) {
    return LocalEnvironmentAssessmentsCompanion(
      id: id ?? this.id,
      childRemoteId: childRemoteId ?? this.childRemoteId,
      sessionLocalId: sessionLocalId ?? this.sessionLocalId,
      parentChildInteractionScore:
          parentChildInteractionScore ?? this.parentChildInteractionScore,
      parentMentalHealthScore:
          parentMentalHealthScore ?? this.parentMentalHealthScore,
      homeStimulationScore: homeStimulationScore ?? this.homeStimulationScore,
      playMaterials: playMaterials ?? this.playMaterials,
      caregiverEngagement: caregiverEngagement ?? this.caregiverEngagement,
      languageExposure: languageExposure ?? this.languageExposure,
      safeWater: safeWater ?? this.safeWater,
      toiletFacility: toiletFacility ?? this.toiletFacility,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childRemoteId.present) {
      map['child_remote_id'] = Variable<int>(childRemoteId.value);
    }
    if (sessionLocalId.present) {
      map['session_local_id'] = Variable<int>(sessionLocalId.value);
    }
    if (parentChildInteractionScore.present) {
      map['parent_child_interaction_score'] =
          Variable<int>(parentChildInteractionScore.value);
    }
    if (parentMentalHealthScore.present) {
      map['parent_mental_health_score'] =
          Variable<int>(parentMentalHealthScore.value);
    }
    if (homeStimulationScore.present) {
      map['home_stimulation_score'] = Variable<int>(homeStimulationScore.value);
    }
    if (playMaterials.present) {
      map['play_materials'] = Variable<bool>(playMaterials.value);
    }
    if (caregiverEngagement.present) {
      map['caregiver_engagement'] = Variable<String>(caregiverEngagement.value);
    }
    if (languageExposure.present) {
      map['language_exposure'] = Variable<String>(languageExposure.value);
    }
    if (safeWater.present) {
      map['safe_water'] = Variable<bool>(safeWater.value);
    }
    if (toiletFacility.present) {
      map['toilet_facility'] = Variable<bool>(toiletFacility.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalEnvironmentAssessmentsCompanion(')
          ..write('id: $id, ')
          ..write('childRemoteId: $childRemoteId, ')
          ..write('sessionLocalId: $sessionLocalId, ')
          ..write('parentChildInteractionScore: $parentChildInteractionScore, ')
          ..write('parentMentalHealthScore: $parentMentalHealthScore, ')
          ..write('homeStimulationScore: $homeStimulationScore, ')
          ..write('playMaterials: $playMaterials, ')
          ..write('caregiverEngagement: $caregiverEngagement, ')
          ..write('languageExposure: $languageExposure, ')
          ..write('safeWater: $safeWater, ')
          ..write('toiletFacility: $toiletFacility, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalInterventionFollowupsTable extends LocalInterventionFollowups
    with
        TableInfo<$LocalInterventionFollowupsTable, LocalInterventionFollowup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInterventionFollowupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _childRemoteIdMeta =
      const VerificationMeta('childRemoteId');
  @override
  late final GeneratedColumn<int> childRemoteId = GeneratedColumn<int>(
      'child_remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _screeningResultLocalIdMeta =
      const VerificationMeta('screeningResultLocalId');
  @override
  late final GeneratedColumn<int> screeningResultLocalId = GeneratedColumn<int>(
      'screening_result_local_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _interventionPlanGeneratedMeta =
      const VerificationMeta('interventionPlanGenerated');
  @override
  late final GeneratedColumn<bool> interventionPlanGenerated =
      GeneratedColumn<bool>('intervention_plan_generated', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("intervention_plan_generated" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _homeActivitiesAssignedMeta =
      const VerificationMeta('homeActivitiesAssigned');
  @override
  late final GeneratedColumn<int> homeActivitiesAssigned = GeneratedColumn<int>(
      'home_activities_assigned', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _followupConductedMeta =
      const VerificationMeta('followupConducted');
  @override
  late final GeneratedColumn<bool> followupConducted = GeneratedColumn<bool>(
      'followup_conducted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("followup_conducted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _followupDateMeta =
      const VerificationMeta('followupDate');
  @override
  late final GeneratedColumn<String> followupDate = GeneratedColumn<String>(
      'followup_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nextFollowupDateMeta =
      const VerificationMeta('nextFollowupDate');
  @override
  late final GeneratedColumn<String> nextFollowupDate = GeneratedColumn<String>(
      'next_followup_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _improvementStatusMeta =
      const VerificationMeta('improvementStatus');
  @override
  late final GeneratedColumn<String> improvementStatus =
      GeneratedColumn<String>('improvement_status', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reductionInDelayMonthsMeta =
      const VerificationMeta('reductionInDelayMonths');
  @override
  late final GeneratedColumn<int> reductionInDelayMonths = GeneratedColumn<int>(
      'reduction_in_delay_months', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _domainImprovementMeta =
      const VerificationMeta('domainImprovement');
  @override
  late final GeneratedColumn<bool> domainImprovement = GeneratedColumn<bool>(
      'domain_improvement', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("domain_improvement" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _autismRiskChangeMeta =
      const VerificationMeta('autismRiskChange');
  @override
  late final GeneratedColumn<String> autismRiskChange = GeneratedColumn<String>(
      'autism_risk_change', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Same'));
  static const VerificationMeta _exitHighRiskMeta =
      const VerificationMeta('exitHighRisk');
  @override
  late final GeneratedColumn<bool> exitHighRisk = GeneratedColumn<bool>(
      'exit_high_risk', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("exit_high_risk" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        childRemoteId,
        screeningResultLocalId,
        interventionPlanGenerated,
        homeActivitiesAssigned,
        followupConducted,
        followupDate,
        nextFollowupDate,
        improvementStatus,
        reductionInDelayMonths,
        domainImprovement,
        autismRiskChange,
        exitHighRisk,
        notes,
        createdBy,
        createdAt,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_intervention_followups';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalInterventionFollowup> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_remote_id')) {
      context.handle(
          _childRemoteIdMeta,
          childRemoteId.isAcceptableOrUnknown(
              data['child_remote_id']!, _childRemoteIdMeta));
    }
    if (data.containsKey('screening_result_local_id')) {
      context.handle(
          _screeningResultLocalIdMeta,
          screeningResultLocalId.isAcceptableOrUnknown(
              data['screening_result_local_id']!, _screeningResultLocalIdMeta));
    }
    if (data.containsKey('intervention_plan_generated')) {
      context.handle(
          _interventionPlanGeneratedMeta,
          interventionPlanGenerated.isAcceptableOrUnknown(
              data['intervention_plan_generated']!,
              _interventionPlanGeneratedMeta));
    }
    if (data.containsKey('home_activities_assigned')) {
      context.handle(
          _homeActivitiesAssignedMeta,
          homeActivitiesAssigned.isAcceptableOrUnknown(
              data['home_activities_assigned']!, _homeActivitiesAssignedMeta));
    }
    if (data.containsKey('followup_conducted')) {
      context.handle(
          _followupConductedMeta,
          followupConducted.isAcceptableOrUnknown(
              data['followup_conducted']!, _followupConductedMeta));
    }
    if (data.containsKey('followup_date')) {
      context.handle(
          _followupDateMeta,
          followupDate.isAcceptableOrUnknown(
              data['followup_date']!, _followupDateMeta));
    }
    if (data.containsKey('next_followup_date')) {
      context.handle(
          _nextFollowupDateMeta,
          nextFollowupDate.isAcceptableOrUnknown(
              data['next_followup_date']!, _nextFollowupDateMeta));
    }
    if (data.containsKey('improvement_status')) {
      context.handle(
          _improvementStatusMeta,
          improvementStatus.isAcceptableOrUnknown(
              data['improvement_status']!, _improvementStatusMeta));
    }
    if (data.containsKey('reduction_in_delay_months')) {
      context.handle(
          _reductionInDelayMonthsMeta,
          reductionInDelayMonths.isAcceptableOrUnknown(
              data['reduction_in_delay_months']!, _reductionInDelayMonthsMeta));
    }
    if (data.containsKey('domain_improvement')) {
      context.handle(
          _domainImprovementMeta,
          domainImprovement.isAcceptableOrUnknown(
              data['domain_improvement']!, _domainImprovementMeta));
    }
    if (data.containsKey('autism_risk_change')) {
      context.handle(
          _autismRiskChangeMeta,
          autismRiskChange.isAcceptableOrUnknown(
              data['autism_risk_change']!, _autismRiskChangeMeta));
    }
    if (data.containsKey('exit_high_risk')) {
      context.handle(
          _exitHighRiskMeta,
          exitHighRisk.isAcceptableOrUnknown(
              data['exit_high_risk']!, _exitHighRiskMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalInterventionFollowup map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInterventionFollowup(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      childRemoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}child_remote_id']),
      screeningResultLocalId: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}screening_result_local_id']),
      interventionPlanGenerated: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}intervention_plan_generated'])!,
      homeActivitiesAssigned: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}home_activities_assigned'])!,
      followupConducted: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}followup_conducted'])!,
      followupDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}followup_date']),
      nextFollowupDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}next_followup_date']),
      improvementStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}improvement_status']),
      reductionInDelayMonths: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}reduction_in_delay_months'])!,
      domainImprovement: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}domain_improvement'])!,
      autismRiskChange: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}autism_risk_change'])!,
      exitHighRisk: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}exit_high_risk'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $LocalInterventionFollowupsTable createAlias(String alias) {
    return $LocalInterventionFollowupsTable(attachedDatabase, alias);
  }
}

class LocalInterventionFollowup extends DataClass
    implements Insertable<LocalInterventionFollowup> {
  final int id;
  final int? childRemoteId;
  final int? screeningResultLocalId;
  final bool interventionPlanGenerated;
  final int homeActivitiesAssigned;
  final bool followupConducted;
  final String? followupDate;
  final String? nextFollowupDate;
  final String? improvementStatus;
  final int reductionInDelayMonths;
  final bool domainImprovement;
  final String autismRiskChange;
  final bool exitHighRisk;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? syncedAt;
  const LocalInterventionFollowup(
      {required this.id,
      this.childRemoteId,
      this.screeningResultLocalId,
      required this.interventionPlanGenerated,
      required this.homeActivitiesAssigned,
      required this.followupConducted,
      this.followupDate,
      this.nextFollowupDate,
      this.improvementStatus,
      required this.reductionInDelayMonths,
      required this.domainImprovement,
      required this.autismRiskChange,
      required this.exitHighRisk,
      this.notes,
      this.createdBy,
      required this.createdAt,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || childRemoteId != null) {
      map['child_remote_id'] = Variable<int>(childRemoteId);
    }
    if (!nullToAbsent || screeningResultLocalId != null) {
      map['screening_result_local_id'] = Variable<int>(screeningResultLocalId);
    }
    map['intervention_plan_generated'] =
        Variable<bool>(interventionPlanGenerated);
    map['home_activities_assigned'] = Variable<int>(homeActivitiesAssigned);
    map['followup_conducted'] = Variable<bool>(followupConducted);
    if (!nullToAbsent || followupDate != null) {
      map['followup_date'] = Variable<String>(followupDate);
    }
    if (!nullToAbsent || nextFollowupDate != null) {
      map['next_followup_date'] = Variable<String>(nextFollowupDate);
    }
    if (!nullToAbsent || improvementStatus != null) {
      map['improvement_status'] = Variable<String>(improvementStatus);
    }
    map['reduction_in_delay_months'] = Variable<int>(reductionInDelayMonths);
    map['domain_improvement'] = Variable<bool>(domainImprovement);
    map['autism_risk_change'] = Variable<String>(autismRiskChange);
    map['exit_high_risk'] = Variable<bool>(exitHighRisk);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  LocalInterventionFollowupsCompanion toCompanion(bool nullToAbsent) {
    return LocalInterventionFollowupsCompanion(
      id: Value(id),
      childRemoteId: childRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(childRemoteId),
      screeningResultLocalId: screeningResultLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(screeningResultLocalId),
      interventionPlanGenerated: Value(interventionPlanGenerated),
      homeActivitiesAssigned: Value(homeActivitiesAssigned),
      followupConducted: Value(followupConducted),
      followupDate: followupDate == null && nullToAbsent
          ? const Value.absent()
          : Value(followupDate),
      nextFollowupDate: nextFollowupDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextFollowupDate),
      improvementStatus: improvementStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(improvementStatus),
      reductionInDelayMonths: Value(reductionInDelayMonths),
      domainImprovement: Value(domainImprovement),
      autismRiskChange: Value(autismRiskChange),
      exitHighRisk: Value(exitHighRisk),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalInterventionFollowup.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInterventionFollowup(
      id: serializer.fromJson<int>(json['id']),
      childRemoteId: serializer.fromJson<int?>(json['childRemoteId']),
      screeningResultLocalId:
          serializer.fromJson<int?>(json['screeningResultLocalId']),
      interventionPlanGenerated:
          serializer.fromJson<bool>(json['interventionPlanGenerated']),
      homeActivitiesAssigned:
          serializer.fromJson<int>(json['homeActivitiesAssigned']),
      followupConducted: serializer.fromJson<bool>(json['followupConducted']),
      followupDate: serializer.fromJson<String?>(json['followupDate']),
      nextFollowupDate: serializer.fromJson<String?>(json['nextFollowupDate']),
      improvementStatus:
          serializer.fromJson<String?>(json['improvementStatus']),
      reductionInDelayMonths:
          serializer.fromJson<int>(json['reductionInDelayMonths']),
      domainImprovement: serializer.fromJson<bool>(json['domainImprovement']),
      autismRiskChange: serializer.fromJson<String>(json['autismRiskChange']),
      exitHighRisk: serializer.fromJson<bool>(json['exitHighRisk']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childRemoteId': serializer.toJson<int?>(childRemoteId),
      'screeningResultLocalId': serializer.toJson<int?>(screeningResultLocalId),
      'interventionPlanGenerated':
          serializer.toJson<bool>(interventionPlanGenerated),
      'homeActivitiesAssigned': serializer.toJson<int>(homeActivitiesAssigned),
      'followupConducted': serializer.toJson<bool>(followupConducted),
      'followupDate': serializer.toJson<String?>(followupDate),
      'nextFollowupDate': serializer.toJson<String?>(nextFollowupDate),
      'improvementStatus': serializer.toJson<String?>(improvementStatus),
      'reductionInDelayMonths': serializer.toJson<int>(reductionInDelayMonths),
      'domainImprovement': serializer.toJson<bool>(domainImprovement),
      'autismRiskChange': serializer.toJson<String>(autismRiskChange),
      'exitHighRisk': serializer.toJson<bool>(exitHighRisk),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalInterventionFollowup copyWith(
          {int? id,
          Value<int?> childRemoteId = const Value.absent(),
          Value<int?> screeningResultLocalId = const Value.absent(),
          bool? interventionPlanGenerated,
          int? homeActivitiesAssigned,
          bool? followupConducted,
          Value<String?> followupDate = const Value.absent(),
          Value<String?> nextFollowupDate = const Value.absent(),
          Value<String?> improvementStatus = const Value.absent(),
          int? reductionInDelayMonths,
          bool? domainImprovement,
          String? autismRiskChange,
          bool? exitHighRisk,
          Value<String?> notes = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      LocalInterventionFollowup(
        id: id ?? this.id,
        childRemoteId:
            childRemoteId.present ? childRemoteId.value : this.childRemoteId,
        screeningResultLocalId: screeningResultLocalId.present
            ? screeningResultLocalId.value
            : this.screeningResultLocalId,
        interventionPlanGenerated:
            interventionPlanGenerated ?? this.interventionPlanGenerated,
        homeActivitiesAssigned:
            homeActivitiesAssigned ?? this.homeActivitiesAssigned,
        followupConducted: followupConducted ?? this.followupConducted,
        followupDate:
            followupDate.present ? followupDate.value : this.followupDate,
        nextFollowupDate: nextFollowupDate.present
            ? nextFollowupDate.value
            : this.nextFollowupDate,
        improvementStatus: improvementStatus.present
            ? improvementStatus.value
            : this.improvementStatus,
        reductionInDelayMonths:
            reductionInDelayMonths ?? this.reductionInDelayMonths,
        domainImprovement: domainImprovement ?? this.domainImprovement,
        autismRiskChange: autismRiskChange ?? this.autismRiskChange,
        exitHighRisk: exitHighRisk ?? this.exitHighRisk,
        notes: notes.present ? notes.value : this.notes,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  LocalInterventionFollowup copyWithCompanion(
      LocalInterventionFollowupsCompanion data) {
    return LocalInterventionFollowup(
      id: data.id.present ? data.id.value : this.id,
      childRemoteId: data.childRemoteId.present
          ? data.childRemoteId.value
          : this.childRemoteId,
      screeningResultLocalId: data.screeningResultLocalId.present
          ? data.screeningResultLocalId.value
          : this.screeningResultLocalId,
      interventionPlanGenerated: data.interventionPlanGenerated.present
          ? data.interventionPlanGenerated.value
          : this.interventionPlanGenerated,
      homeActivitiesAssigned: data.homeActivitiesAssigned.present
          ? data.homeActivitiesAssigned.value
          : this.homeActivitiesAssigned,
      followupConducted: data.followupConducted.present
          ? data.followupConducted.value
          : this.followupConducted,
      followupDate: data.followupDate.present
          ? data.followupDate.value
          : this.followupDate,
      nextFollowupDate: data.nextFollowupDate.present
          ? data.nextFollowupDate.value
          : this.nextFollowupDate,
      improvementStatus: data.improvementStatus.present
          ? data.improvementStatus.value
          : this.improvementStatus,
      reductionInDelayMonths: data.reductionInDelayMonths.present
          ? data.reductionInDelayMonths.value
          : this.reductionInDelayMonths,
      domainImprovement: data.domainImprovement.present
          ? data.domainImprovement.value
          : this.domainImprovement,
      autismRiskChange: data.autismRiskChange.present
          ? data.autismRiskChange.value
          : this.autismRiskChange,
      exitHighRisk: data.exitHighRisk.present
          ? data.exitHighRisk.value
          : this.exitHighRisk,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInterventionFollowup(')
          ..write('id: $id, ')
          ..write('childRemoteId: $childRemoteId, ')
          ..write('screeningResultLocalId: $screeningResultLocalId, ')
          ..write('interventionPlanGenerated: $interventionPlanGenerated, ')
          ..write('homeActivitiesAssigned: $homeActivitiesAssigned, ')
          ..write('followupConducted: $followupConducted, ')
          ..write('followupDate: $followupDate, ')
          ..write('nextFollowupDate: $nextFollowupDate, ')
          ..write('improvementStatus: $improvementStatus, ')
          ..write('reductionInDelayMonths: $reductionInDelayMonths, ')
          ..write('domainImprovement: $domainImprovement, ')
          ..write('autismRiskChange: $autismRiskChange, ')
          ..write('exitHighRisk: $exitHighRisk, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      childRemoteId,
      screeningResultLocalId,
      interventionPlanGenerated,
      homeActivitiesAssigned,
      followupConducted,
      followupDate,
      nextFollowupDate,
      improvementStatus,
      reductionInDelayMonths,
      domainImprovement,
      autismRiskChange,
      exitHighRisk,
      notes,
      createdBy,
      createdAt,
      syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInterventionFollowup &&
          other.id == this.id &&
          other.childRemoteId == this.childRemoteId &&
          other.screeningResultLocalId == this.screeningResultLocalId &&
          other.interventionPlanGenerated == this.interventionPlanGenerated &&
          other.homeActivitiesAssigned == this.homeActivitiesAssigned &&
          other.followupConducted == this.followupConducted &&
          other.followupDate == this.followupDate &&
          other.nextFollowupDate == this.nextFollowupDate &&
          other.improvementStatus == this.improvementStatus &&
          other.reductionInDelayMonths == this.reductionInDelayMonths &&
          other.domainImprovement == this.domainImprovement &&
          other.autismRiskChange == this.autismRiskChange &&
          other.exitHighRisk == this.exitHighRisk &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class LocalInterventionFollowupsCompanion
    extends UpdateCompanion<LocalInterventionFollowup> {
  final Value<int> id;
  final Value<int?> childRemoteId;
  final Value<int?> screeningResultLocalId;
  final Value<bool> interventionPlanGenerated;
  final Value<int> homeActivitiesAssigned;
  final Value<bool> followupConducted;
  final Value<String?> followupDate;
  final Value<String?> nextFollowupDate;
  final Value<String?> improvementStatus;
  final Value<int> reductionInDelayMonths;
  final Value<bool> domainImprovement;
  final Value<String> autismRiskChange;
  final Value<bool> exitHighRisk;
  final Value<String?> notes;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  const LocalInterventionFollowupsCompanion({
    this.id = const Value.absent(),
    this.childRemoteId = const Value.absent(),
    this.screeningResultLocalId = const Value.absent(),
    this.interventionPlanGenerated = const Value.absent(),
    this.homeActivitiesAssigned = const Value.absent(),
    this.followupConducted = const Value.absent(),
    this.followupDate = const Value.absent(),
    this.nextFollowupDate = const Value.absent(),
    this.improvementStatus = const Value.absent(),
    this.reductionInDelayMonths = const Value.absent(),
    this.domainImprovement = const Value.absent(),
    this.autismRiskChange = const Value.absent(),
    this.exitHighRisk = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  LocalInterventionFollowupsCompanion.insert({
    this.id = const Value.absent(),
    this.childRemoteId = const Value.absent(),
    this.screeningResultLocalId = const Value.absent(),
    this.interventionPlanGenerated = const Value.absent(),
    this.homeActivitiesAssigned = const Value.absent(),
    this.followupConducted = const Value.absent(),
    this.followupDate = const Value.absent(),
    this.nextFollowupDate = const Value.absent(),
    this.improvementStatus = const Value.absent(),
    this.reductionInDelayMonths = const Value.absent(),
    this.domainImprovement = const Value.absent(),
    this.autismRiskChange = const Value.absent(),
    this.exitHighRisk = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  static Insertable<LocalInterventionFollowup> custom({
    Expression<int>? id,
    Expression<int>? childRemoteId,
    Expression<int>? screeningResultLocalId,
    Expression<bool>? interventionPlanGenerated,
    Expression<int>? homeActivitiesAssigned,
    Expression<bool>? followupConducted,
    Expression<String>? followupDate,
    Expression<String>? nextFollowupDate,
    Expression<String>? improvementStatus,
    Expression<int>? reductionInDelayMonths,
    Expression<bool>? domainImprovement,
    Expression<String>? autismRiskChange,
    Expression<bool>? exitHighRisk,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childRemoteId != null) 'child_remote_id': childRemoteId,
      if (screeningResultLocalId != null)
        'screening_result_local_id': screeningResultLocalId,
      if (interventionPlanGenerated != null)
        'intervention_plan_generated': interventionPlanGenerated,
      if (homeActivitiesAssigned != null)
        'home_activities_assigned': homeActivitiesAssigned,
      if (followupConducted != null) 'followup_conducted': followupConducted,
      if (followupDate != null) 'followup_date': followupDate,
      if (nextFollowupDate != null) 'next_followup_date': nextFollowupDate,
      if (improvementStatus != null) 'improvement_status': improvementStatus,
      if (reductionInDelayMonths != null)
        'reduction_in_delay_months': reductionInDelayMonths,
      if (domainImprovement != null) 'domain_improvement': domainImprovement,
      if (autismRiskChange != null) 'autism_risk_change': autismRiskChange,
      if (exitHighRisk != null) 'exit_high_risk': exitHighRisk,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  LocalInterventionFollowupsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? childRemoteId,
      Value<int?>? screeningResultLocalId,
      Value<bool>? interventionPlanGenerated,
      Value<int>? homeActivitiesAssigned,
      Value<bool>? followupConducted,
      Value<String?>? followupDate,
      Value<String?>? nextFollowupDate,
      Value<String?>? improvementStatus,
      Value<int>? reductionInDelayMonths,
      Value<bool>? domainImprovement,
      Value<String>? autismRiskChange,
      Value<bool>? exitHighRisk,
      Value<String?>? notes,
      Value<String?>? createdBy,
      Value<DateTime>? createdAt,
      Value<DateTime?>? syncedAt}) {
    return LocalInterventionFollowupsCompanion(
      id: id ?? this.id,
      childRemoteId: childRemoteId ?? this.childRemoteId,
      screeningResultLocalId:
          screeningResultLocalId ?? this.screeningResultLocalId,
      interventionPlanGenerated:
          interventionPlanGenerated ?? this.interventionPlanGenerated,
      homeActivitiesAssigned:
          homeActivitiesAssigned ?? this.homeActivitiesAssigned,
      followupConducted: followupConducted ?? this.followupConducted,
      followupDate: followupDate ?? this.followupDate,
      nextFollowupDate: nextFollowupDate ?? this.nextFollowupDate,
      improvementStatus: improvementStatus ?? this.improvementStatus,
      reductionInDelayMonths:
          reductionInDelayMonths ?? this.reductionInDelayMonths,
      domainImprovement: domainImprovement ?? this.domainImprovement,
      autismRiskChange: autismRiskChange ?? this.autismRiskChange,
      exitHighRisk: exitHighRisk ?? this.exitHighRisk,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childRemoteId.present) {
      map['child_remote_id'] = Variable<int>(childRemoteId.value);
    }
    if (screeningResultLocalId.present) {
      map['screening_result_local_id'] =
          Variable<int>(screeningResultLocalId.value);
    }
    if (interventionPlanGenerated.present) {
      map['intervention_plan_generated'] =
          Variable<bool>(interventionPlanGenerated.value);
    }
    if (homeActivitiesAssigned.present) {
      map['home_activities_assigned'] =
          Variable<int>(homeActivitiesAssigned.value);
    }
    if (followupConducted.present) {
      map['followup_conducted'] = Variable<bool>(followupConducted.value);
    }
    if (followupDate.present) {
      map['followup_date'] = Variable<String>(followupDate.value);
    }
    if (nextFollowupDate.present) {
      map['next_followup_date'] = Variable<String>(nextFollowupDate.value);
    }
    if (improvementStatus.present) {
      map['improvement_status'] = Variable<String>(improvementStatus.value);
    }
    if (reductionInDelayMonths.present) {
      map['reduction_in_delay_months'] =
          Variable<int>(reductionInDelayMonths.value);
    }
    if (domainImprovement.present) {
      map['domain_improvement'] = Variable<bool>(domainImprovement.value);
    }
    if (autismRiskChange.present) {
      map['autism_risk_change'] = Variable<String>(autismRiskChange.value);
    }
    if (exitHighRisk.present) {
      map['exit_high_risk'] = Variable<bool>(exitHighRisk.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalInterventionFollowupsCompanion(')
          ..write('id: $id, ')
          ..write('childRemoteId: $childRemoteId, ')
          ..write('screeningResultLocalId: $screeningResultLocalId, ')
          ..write('interventionPlanGenerated: $interventionPlanGenerated, ')
          ..write('homeActivitiesAssigned: $homeActivitiesAssigned, ')
          ..write('followupConducted: $followupConducted, ')
          ..write('followupDate: $followupDate, ')
          ..write('nextFollowupDate: $nextFollowupDate, ')
          ..write('improvementStatus: $improvementStatus, ')
          ..write('reductionInDelayMonths: $reductionInDelayMonths, ')
          ..write('domainImprovement: $domainImprovement, ')
          ..write('autismRiskChange: $autismRiskChange, ')
          ..write('exitHighRisk: $exitHighRisk, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalConsentsTable extends LocalConsents
    with TableInfo<$LocalConsentsTable, LocalConsent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalConsentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _childRemoteIdMeta =
      const VerificationMeta('childRemoteId');
  @override
  late final GeneratedColumn<int> childRemoteId = GeneratedColumn<int>(
      'child_remote_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _guardianNameMeta =
      const VerificationMeta('guardianName');
  @override
  late final GeneratedColumn<String> guardianName = GeneratedColumn<String>(
      'guardian_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _guardianRelationMeta =
      const VerificationMeta('guardianRelation');
  @override
  late final GeneratedColumn<String> guardianRelation = GeneratedColumn<String>(
      'guardian_relation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _guardianPhoneMeta =
      const VerificationMeta('guardianPhone');
  @override
  late final GeneratedColumn<String> guardianPhone = GeneratedColumn<String>(
      'guardian_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _consentPurposeMeta =
      const VerificationMeta('consentPurpose');
  @override
  late final GeneratedColumn<String> consentPurpose = GeneratedColumn<String>(
      'consent_purpose', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _consentGivenMeta =
      const VerificationMeta('consentGiven');
  @override
  late final GeneratedColumn<bool> consentGiven = GeneratedColumn<bool>(
      'consent_given', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("consent_given" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _consentVersionMeta =
      const VerificationMeta('consentVersion');
  @override
  late final GeneratedColumn<String> consentVersion = GeneratedColumn<String>(
      'consent_version', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('1.0'));
  static const VerificationMeta _digitalSignatureBase64Meta =
      const VerificationMeta('digitalSignatureBase64');
  @override
  late final GeneratedColumn<String> digitalSignatureBase64 =
      GeneratedColumn<String>('digital_signature_base64', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _collectedByUserIdMeta =
      const VerificationMeta('collectedByUserId');
  @override
  late final GeneratedColumn<String> collectedByUserId =
      GeneratedColumn<String>('collected_by_user_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _collectedByRoleMeta =
      const VerificationMeta('collectedByRole');
  @override
  late final GeneratedColumn<String> collectedByRole = GeneratedColumn<String>(
      'collected_by_role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageUsedMeta =
      const VerificationMeta('languageUsed');
  @override
  late final GeneratedColumn<String> languageUsed = GeneratedColumn<String>(
      'language_used', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  static const VerificationMeta _consentTimestampMeta =
      const VerificationMeta('consentTimestamp');
  @override
  late final GeneratedColumn<DateTime> consentTimestamp =
      GeneratedColumn<DateTime>('consent_timestamp', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _revokedAtMeta =
      const VerificationMeta('revokedAt');
  @override
  late final GeneratedColumn<DateTime> revokedAt = GeneratedColumn<DateTime>(
      'revoked_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _revocationReasonMeta =
      const VerificationMeta('revocationReason');
  @override
  late final GeneratedColumn<String> revocationReason = GeneratedColumn<String>(
      'revocation_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remoteId,
        childRemoteId,
        guardianName,
        guardianRelation,
        guardianPhone,
        consentPurpose,
        consentGiven,
        consentVersion,
        digitalSignatureBase64,
        collectedByUserId,
        collectedByRole,
        languageUsed,
        consentTimestamp,
        revokedAt,
        revocationReason,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_consents';
  @override
  VerificationContext validateIntegrity(Insertable<LocalConsent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('child_remote_id')) {
      context.handle(
          _childRemoteIdMeta,
          childRemoteId.isAcceptableOrUnknown(
              data['child_remote_id']!, _childRemoteIdMeta));
    } else if (isInserting) {
      context.missing(_childRemoteIdMeta);
    }
    if (data.containsKey('guardian_name')) {
      context.handle(
          _guardianNameMeta,
          guardianName.isAcceptableOrUnknown(
              data['guardian_name']!, _guardianNameMeta));
    } else if (isInserting) {
      context.missing(_guardianNameMeta);
    }
    if (data.containsKey('guardian_relation')) {
      context.handle(
          _guardianRelationMeta,
          guardianRelation.isAcceptableOrUnknown(
              data['guardian_relation']!, _guardianRelationMeta));
    } else if (isInserting) {
      context.missing(_guardianRelationMeta);
    }
    if (data.containsKey('guardian_phone')) {
      context.handle(
          _guardianPhoneMeta,
          guardianPhone.isAcceptableOrUnknown(
              data['guardian_phone']!, _guardianPhoneMeta));
    }
    if (data.containsKey('consent_purpose')) {
      context.handle(
          _consentPurposeMeta,
          consentPurpose.isAcceptableOrUnknown(
              data['consent_purpose']!, _consentPurposeMeta));
    } else if (isInserting) {
      context.missing(_consentPurposeMeta);
    }
    if (data.containsKey('consent_given')) {
      context.handle(
          _consentGivenMeta,
          consentGiven.isAcceptableOrUnknown(
              data['consent_given']!, _consentGivenMeta));
    }
    if (data.containsKey('consent_version')) {
      context.handle(
          _consentVersionMeta,
          consentVersion.isAcceptableOrUnknown(
              data['consent_version']!, _consentVersionMeta));
    }
    if (data.containsKey('digital_signature_base64')) {
      context.handle(
          _digitalSignatureBase64Meta,
          digitalSignatureBase64.isAcceptableOrUnknown(
              data['digital_signature_base64']!, _digitalSignatureBase64Meta));
    }
    if (data.containsKey('collected_by_user_id')) {
      context.handle(
          _collectedByUserIdMeta,
          collectedByUserId.isAcceptableOrUnknown(
              data['collected_by_user_id']!, _collectedByUserIdMeta));
    } else if (isInserting) {
      context.missing(_collectedByUserIdMeta);
    }
    if (data.containsKey('collected_by_role')) {
      context.handle(
          _collectedByRoleMeta,
          collectedByRole.isAcceptableOrUnknown(
              data['collected_by_role']!, _collectedByRoleMeta));
    } else if (isInserting) {
      context.missing(_collectedByRoleMeta);
    }
    if (data.containsKey('language_used')) {
      context.handle(
          _languageUsedMeta,
          languageUsed.isAcceptableOrUnknown(
              data['language_used']!, _languageUsedMeta));
    }
    if (data.containsKey('consent_timestamp')) {
      context.handle(
          _consentTimestampMeta,
          consentTimestamp.isAcceptableOrUnknown(
              data['consent_timestamp']!, _consentTimestampMeta));
    }
    if (data.containsKey('revoked_at')) {
      context.handle(_revokedAtMeta,
          revokedAt.isAcceptableOrUnknown(data['revoked_at']!, _revokedAtMeta));
    }
    if (data.containsKey('revocation_reason')) {
      context.handle(
          _revocationReasonMeta,
          revocationReason.isAcceptableOrUnknown(
              data['revocation_reason']!, _revocationReasonMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalConsent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalConsent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}remote_id']),
      childRemoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}child_remote_id'])!,
      guardianName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}guardian_name'])!,
      guardianRelation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}guardian_relation'])!,
      guardianPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}guardian_phone']),
      consentPurpose: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}consent_purpose'])!,
      consentGiven: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}consent_given'])!,
      consentVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}consent_version'])!,
      digitalSignatureBase64: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}digital_signature_base64']),
      collectedByUserId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}collected_by_user_id'])!,
      collectedByRole: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}collected_by_role'])!,
      languageUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language_used'])!,
      consentTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}consent_timestamp'])!,
      revokedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}revoked_at']),
      revocationReason: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}revocation_reason']),
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $LocalConsentsTable createAlias(String alias) {
    return $LocalConsentsTable(attachedDatabase, alias);
  }
}

class LocalConsent extends DataClass implements Insertable<LocalConsent> {
  final int id;
  final int? remoteId;
  final int childRemoteId;
  final String guardianName;
  final String guardianRelation;
  final String? guardianPhone;
  final String consentPurpose;
  final bool consentGiven;
  final String consentVersion;
  final String? digitalSignatureBase64;
  final String collectedByUserId;
  final String collectedByRole;
  final String languageUsed;
  final DateTime consentTimestamp;
  final DateTime? revokedAt;
  final String? revocationReason;
  final DateTime? syncedAt;
  const LocalConsent(
      {required this.id,
      this.remoteId,
      required this.childRemoteId,
      required this.guardianName,
      required this.guardianRelation,
      this.guardianPhone,
      required this.consentPurpose,
      required this.consentGiven,
      required this.consentVersion,
      this.digitalSignatureBase64,
      required this.collectedByUserId,
      required this.collectedByRole,
      required this.languageUsed,
      required this.consentTimestamp,
      this.revokedAt,
      this.revocationReason,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    map['child_remote_id'] = Variable<int>(childRemoteId);
    map['guardian_name'] = Variable<String>(guardianName);
    map['guardian_relation'] = Variable<String>(guardianRelation);
    if (!nullToAbsent || guardianPhone != null) {
      map['guardian_phone'] = Variable<String>(guardianPhone);
    }
    map['consent_purpose'] = Variable<String>(consentPurpose);
    map['consent_given'] = Variable<bool>(consentGiven);
    map['consent_version'] = Variable<String>(consentVersion);
    if (!nullToAbsent || digitalSignatureBase64 != null) {
      map['digital_signature_base64'] =
          Variable<String>(digitalSignatureBase64);
    }
    map['collected_by_user_id'] = Variable<String>(collectedByUserId);
    map['collected_by_role'] = Variable<String>(collectedByRole);
    map['language_used'] = Variable<String>(languageUsed);
    map['consent_timestamp'] = Variable<DateTime>(consentTimestamp);
    if (!nullToAbsent || revokedAt != null) {
      map['revoked_at'] = Variable<DateTime>(revokedAt);
    }
    if (!nullToAbsent || revocationReason != null) {
      map['revocation_reason'] = Variable<String>(revocationReason);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  LocalConsentsCompanion toCompanion(bool nullToAbsent) {
    return LocalConsentsCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      childRemoteId: Value(childRemoteId),
      guardianName: Value(guardianName),
      guardianRelation: Value(guardianRelation),
      guardianPhone: guardianPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianPhone),
      consentPurpose: Value(consentPurpose),
      consentGiven: Value(consentGiven),
      consentVersion: Value(consentVersion),
      digitalSignatureBase64: digitalSignatureBase64 == null && nullToAbsent
          ? const Value.absent()
          : Value(digitalSignatureBase64),
      collectedByUserId: Value(collectedByUserId),
      collectedByRole: Value(collectedByRole),
      languageUsed: Value(languageUsed),
      consentTimestamp: Value(consentTimestamp),
      revokedAt: revokedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedAt),
      revocationReason: revocationReason == null && nullToAbsent
          ? const Value.absent()
          : Value(revocationReason),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalConsent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalConsent(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      childRemoteId: serializer.fromJson<int>(json['childRemoteId']),
      guardianName: serializer.fromJson<String>(json['guardianName']),
      guardianRelation: serializer.fromJson<String>(json['guardianRelation']),
      guardianPhone: serializer.fromJson<String?>(json['guardianPhone']),
      consentPurpose: serializer.fromJson<String>(json['consentPurpose']),
      consentGiven: serializer.fromJson<bool>(json['consentGiven']),
      consentVersion: serializer.fromJson<String>(json['consentVersion']),
      digitalSignatureBase64:
          serializer.fromJson<String?>(json['digitalSignatureBase64']),
      collectedByUserId: serializer.fromJson<String>(json['collectedByUserId']),
      collectedByRole: serializer.fromJson<String>(json['collectedByRole']),
      languageUsed: serializer.fromJson<String>(json['languageUsed']),
      consentTimestamp: serializer.fromJson<DateTime>(json['consentTimestamp']),
      revokedAt: serializer.fromJson<DateTime?>(json['revokedAt']),
      revocationReason: serializer.fromJson<String?>(json['revocationReason']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int?>(remoteId),
      'childRemoteId': serializer.toJson<int>(childRemoteId),
      'guardianName': serializer.toJson<String>(guardianName),
      'guardianRelation': serializer.toJson<String>(guardianRelation),
      'guardianPhone': serializer.toJson<String?>(guardianPhone),
      'consentPurpose': serializer.toJson<String>(consentPurpose),
      'consentGiven': serializer.toJson<bool>(consentGiven),
      'consentVersion': serializer.toJson<String>(consentVersion),
      'digitalSignatureBase64':
          serializer.toJson<String?>(digitalSignatureBase64),
      'collectedByUserId': serializer.toJson<String>(collectedByUserId),
      'collectedByRole': serializer.toJson<String>(collectedByRole),
      'languageUsed': serializer.toJson<String>(languageUsed),
      'consentTimestamp': serializer.toJson<DateTime>(consentTimestamp),
      'revokedAt': serializer.toJson<DateTime?>(revokedAt),
      'revocationReason': serializer.toJson<String?>(revocationReason),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalConsent copyWith(
          {int? id,
          Value<int?> remoteId = const Value.absent(),
          int? childRemoteId,
          String? guardianName,
          String? guardianRelation,
          Value<String?> guardianPhone = const Value.absent(),
          String? consentPurpose,
          bool? consentGiven,
          String? consentVersion,
          Value<String?> digitalSignatureBase64 = const Value.absent(),
          String? collectedByUserId,
          String? collectedByRole,
          String? languageUsed,
          DateTime? consentTimestamp,
          Value<DateTime?> revokedAt = const Value.absent(),
          Value<String?> revocationReason = const Value.absent(),
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      LocalConsent(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        childRemoteId: childRemoteId ?? this.childRemoteId,
        guardianName: guardianName ?? this.guardianName,
        guardianRelation: guardianRelation ?? this.guardianRelation,
        guardianPhone:
            guardianPhone.present ? guardianPhone.value : this.guardianPhone,
        consentPurpose: consentPurpose ?? this.consentPurpose,
        consentGiven: consentGiven ?? this.consentGiven,
        consentVersion: consentVersion ?? this.consentVersion,
        digitalSignatureBase64: digitalSignatureBase64.present
            ? digitalSignatureBase64.value
            : this.digitalSignatureBase64,
        collectedByUserId: collectedByUserId ?? this.collectedByUserId,
        collectedByRole: collectedByRole ?? this.collectedByRole,
        languageUsed: languageUsed ?? this.languageUsed,
        consentTimestamp: consentTimestamp ?? this.consentTimestamp,
        revokedAt: revokedAt.present ? revokedAt.value : this.revokedAt,
        revocationReason: revocationReason.present
            ? revocationReason.value
            : this.revocationReason,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  LocalConsent copyWithCompanion(LocalConsentsCompanion data) {
    return LocalConsent(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      childRemoteId: data.childRemoteId.present
          ? data.childRemoteId.value
          : this.childRemoteId,
      guardianName: data.guardianName.present
          ? data.guardianName.value
          : this.guardianName,
      guardianRelation: data.guardianRelation.present
          ? data.guardianRelation.value
          : this.guardianRelation,
      guardianPhone: data.guardianPhone.present
          ? data.guardianPhone.value
          : this.guardianPhone,
      consentPurpose: data.consentPurpose.present
          ? data.consentPurpose.value
          : this.consentPurpose,
      consentGiven: data.consentGiven.present
          ? data.consentGiven.value
          : this.consentGiven,
      consentVersion: data.consentVersion.present
          ? data.consentVersion.value
          : this.consentVersion,
      digitalSignatureBase64: data.digitalSignatureBase64.present
          ? data.digitalSignatureBase64.value
          : this.digitalSignatureBase64,
      collectedByUserId: data.collectedByUserId.present
          ? data.collectedByUserId.value
          : this.collectedByUserId,
      collectedByRole: data.collectedByRole.present
          ? data.collectedByRole.value
          : this.collectedByRole,
      languageUsed: data.languageUsed.present
          ? data.languageUsed.value
          : this.languageUsed,
      consentTimestamp: data.consentTimestamp.present
          ? data.consentTimestamp.value
          : this.consentTimestamp,
      revokedAt: data.revokedAt.present ? data.revokedAt.value : this.revokedAt,
      revocationReason: data.revocationReason.present
          ? data.revocationReason.value
          : this.revocationReason,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalConsent(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('childRemoteId: $childRemoteId, ')
          ..write('guardianName: $guardianName, ')
          ..write('guardianRelation: $guardianRelation, ')
          ..write('guardianPhone: $guardianPhone, ')
          ..write('consentPurpose: $consentPurpose, ')
          ..write('consentGiven: $consentGiven, ')
          ..write('consentVersion: $consentVersion, ')
          ..write('digitalSignatureBase64: $digitalSignatureBase64, ')
          ..write('collectedByUserId: $collectedByUserId, ')
          ..write('collectedByRole: $collectedByRole, ')
          ..write('languageUsed: $languageUsed, ')
          ..write('consentTimestamp: $consentTimestamp, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('revocationReason: $revocationReason, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      remoteId,
      childRemoteId,
      guardianName,
      guardianRelation,
      guardianPhone,
      consentPurpose,
      consentGiven,
      consentVersion,
      digitalSignatureBase64,
      collectedByUserId,
      collectedByRole,
      languageUsed,
      consentTimestamp,
      revokedAt,
      revocationReason,
      syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalConsent &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.childRemoteId == this.childRemoteId &&
          other.guardianName == this.guardianName &&
          other.guardianRelation == this.guardianRelation &&
          other.guardianPhone == this.guardianPhone &&
          other.consentPurpose == this.consentPurpose &&
          other.consentGiven == this.consentGiven &&
          other.consentVersion == this.consentVersion &&
          other.digitalSignatureBase64 == this.digitalSignatureBase64 &&
          other.collectedByUserId == this.collectedByUserId &&
          other.collectedByRole == this.collectedByRole &&
          other.languageUsed == this.languageUsed &&
          other.consentTimestamp == this.consentTimestamp &&
          other.revokedAt == this.revokedAt &&
          other.revocationReason == this.revocationReason &&
          other.syncedAt == this.syncedAt);
}

class LocalConsentsCompanion extends UpdateCompanion<LocalConsent> {
  final Value<int> id;
  final Value<int?> remoteId;
  final Value<int> childRemoteId;
  final Value<String> guardianName;
  final Value<String> guardianRelation;
  final Value<String?> guardianPhone;
  final Value<String> consentPurpose;
  final Value<bool> consentGiven;
  final Value<String> consentVersion;
  final Value<String?> digitalSignatureBase64;
  final Value<String> collectedByUserId;
  final Value<String> collectedByRole;
  final Value<String> languageUsed;
  final Value<DateTime> consentTimestamp;
  final Value<DateTime?> revokedAt;
  final Value<String?> revocationReason;
  final Value<DateTime?> syncedAt;
  const LocalConsentsCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.childRemoteId = const Value.absent(),
    this.guardianName = const Value.absent(),
    this.guardianRelation = const Value.absent(),
    this.guardianPhone = const Value.absent(),
    this.consentPurpose = const Value.absent(),
    this.consentGiven = const Value.absent(),
    this.consentVersion = const Value.absent(),
    this.digitalSignatureBase64 = const Value.absent(),
    this.collectedByUserId = const Value.absent(),
    this.collectedByRole = const Value.absent(),
    this.languageUsed = const Value.absent(),
    this.consentTimestamp = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.revocationReason = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  LocalConsentsCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    required int childRemoteId,
    required String guardianName,
    required String guardianRelation,
    this.guardianPhone = const Value.absent(),
    required String consentPurpose,
    this.consentGiven = const Value.absent(),
    this.consentVersion = const Value.absent(),
    this.digitalSignatureBase64 = const Value.absent(),
    required String collectedByUserId,
    required String collectedByRole,
    this.languageUsed = const Value.absent(),
    this.consentTimestamp = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.revocationReason = const Value.absent(),
    this.syncedAt = const Value.absent(),
  })  : childRemoteId = Value(childRemoteId),
        guardianName = Value(guardianName),
        guardianRelation = Value(guardianRelation),
        consentPurpose = Value(consentPurpose),
        collectedByUserId = Value(collectedByUserId),
        collectedByRole = Value(collectedByRole);
  static Insertable<LocalConsent> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<int>? childRemoteId,
    Expression<String>? guardianName,
    Expression<String>? guardianRelation,
    Expression<String>? guardianPhone,
    Expression<String>? consentPurpose,
    Expression<bool>? consentGiven,
    Expression<String>? consentVersion,
    Expression<String>? digitalSignatureBase64,
    Expression<String>? collectedByUserId,
    Expression<String>? collectedByRole,
    Expression<String>? languageUsed,
    Expression<DateTime>? consentTimestamp,
    Expression<DateTime>? revokedAt,
    Expression<String>? revocationReason,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (childRemoteId != null) 'child_remote_id': childRemoteId,
      if (guardianName != null) 'guardian_name': guardianName,
      if (guardianRelation != null) 'guardian_relation': guardianRelation,
      if (guardianPhone != null) 'guardian_phone': guardianPhone,
      if (consentPurpose != null) 'consent_purpose': consentPurpose,
      if (consentGiven != null) 'consent_given': consentGiven,
      if (consentVersion != null) 'consent_version': consentVersion,
      if (digitalSignatureBase64 != null)
        'digital_signature_base64': digitalSignatureBase64,
      if (collectedByUserId != null) 'collected_by_user_id': collectedByUserId,
      if (collectedByRole != null) 'collected_by_role': collectedByRole,
      if (languageUsed != null) 'language_used': languageUsed,
      if (consentTimestamp != null) 'consent_timestamp': consentTimestamp,
      if (revokedAt != null) 'revoked_at': revokedAt,
      if (revocationReason != null) 'revocation_reason': revocationReason,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  LocalConsentsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? remoteId,
      Value<int>? childRemoteId,
      Value<String>? guardianName,
      Value<String>? guardianRelation,
      Value<String?>? guardianPhone,
      Value<String>? consentPurpose,
      Value<bool>? consentGiven,
      Value<String>? consentVersion,
      Value<String?>? digitalSignatureBase64,
      Value<String>? collectedByUserId,
      Value<String>? collectedByRole,
      Value<String>? languageUsed,
      Value<DateTime>? consentTimestamp,
      Value<DateTime?>? revokedAt,
      Value<String?>? revocationReason,
      Value<DateTime?>? syncedAt}) {
    return LocalConsentsCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      childRemoteId: childRemoteId ?? this.childRemoteId,
      guardianName: guardianName ?? this.guardianName,
      guardianRelation: guardianRelation ?? this.guardianRelation,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      consentPurpose: consentPurpose ?? this.consentPurpose,
      consentGiven: consentGiven ?? this.consentGiven,
      consentVersion: consentVersion ?? this.consentVersion,
      digitalSignatureBase64:
          digitalSignatureBase64 ?? this.digitalSignatureBase64,
      collectedByUserId: collectedByUserId ?? this.collectedByUserId,
      collectedByRole: collectedByRole ?? this.collectedByRole,
      languageUsed: languageUsed ?? this.languageUsed,
      consentTimestamp: consentTimestamp ?? this.consentTimestamp,
      revokedAt: revokedAt ?? this.revokedAt,
      revocationReason: revocationReason ?? this.revocationReason,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (childRemoteId.present) {
      map['child_remote_id'] = Variable<int>(childRemoteId.value);
    }
    if (guardianName.present) {
      map['guardian_name'] = Variable<String>(guardianName.value);
    }
    if (guardianRelation.present) {
      map['guardian_relation'] = Variable<String>(guardianRelation.value);
    }
    if (guardianPhone.present) {
      map['guardian_phone'] = Variable<String>(guardianPhone.value);
    }
    if (consentPurpose.present) {
      map['consent_purpose'] = Variable<String>(consentPurpose.value);
    }
    if (consentGiven.present) {
      map['consent_given'] = Variable<bool>(consentGiven.value);
    }
    if (consentVersion.present) {
      map['consent_version'] = Variable<String>(consentVersion.value);
    }
    if (digitalSignatureBase64.present) {
      map['digital_signature_base64'] =
          Variable<String>(digitalSignatureBase64.value);
    }
    if (collectedByUserId.present) {
      map['collected_by_user_id'] = Variable<String>(collectedByUserId.value);
    }
    if (collectedByRole.present) {
      map['collected_by_role'] = Variable<String>(collectedByRole.value);
    }
    if (languageUsed.present) {
      map['language_used'] = Variable<String>(languageUsed.value);
    }
    if (consentTimestamp.present) {
      map['consent_timestamp'] = Variable<DateTime>(consentTimestamp.value);
    }
    if (revokedAt.present) {
      map['revoked_at'] = Variable<DateTime>(revokedAt.value);
    }
    if (revocationReason.present) {
      map['revocation_reason'] = Variable<String>(revocationReason.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalConsentsCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('childRemoteId: $childRemoteId, ')
          ..write('guardianName: $guardianName, ')
          ..write('guardianRelation: $guardianRelation, ')
          ..write('guardianPhone: $guardianPhone, ')
          ..write('consentPurpose: $consentPurpose, ')
          ..write('consentGiven: $consentGiven, ')
          ..write('consentVersion: $consentVersion, ')
          ..write('digitalSignatureBase64: $digitalSignatureBase64, ')
          ..write('collectedByUserId: $collectedByUserId, ')
          ..write('collectedByRole: $collectedByRole, ')
          ..write('languageUsed: $languageUsed, ')
          ..write('consentTimestamp: $consentTimestamp, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('revocationReason: $revocationReason, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalAuditLogsTable extends LocalAuditLogs
    with TableInfo<$LocalAuditLogsTable, LocalAuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userRoleMeta =
      const VerificationMeta('userRole');
  @override
  late final GeneratedColumn<String> userRole = GeneratedColumn<String>(
      'user_role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
      'entity_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _auditEntityNameMeta =
      const VerificationMeta('auditEntityName');
  @override
  late final GeneratedColumn<String> auditEntityName = GeneratedColumn<String>(
      'audit_entity_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _detailsJsonMeta =
      const VerificationMeta('detailsJson');
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
      'details_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceInfoMeta =
      const VerificationMeta('deviceInfo');
  @override
  late final GeneratedColumn<String> deviceInfo = GeneratedColumn<String>(
      'device_info', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remoteId,
        userId,
        userRole,
        action,
        entityType,
        entityId,
        auditEntityName,
        detailsJson,
        deviceInfo,
        timestamp,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_audit_logs';
  @override
  VerificationContext validateIntegrity(Insertable<LocalAuditLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('user_role')) {
      context.handle(_userRoleMeta,
          userRole.isAcceptableOrUnknown(data['user_role']!, _userRoleMeta));
    } else if (isInserting) {
      context.missing(_userRoleMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    }
    if (data.containsKey('audit_entity_name')) {
      context.handle(
          _auditEntityNameMeta,
          auditEntityName.isAcceptableOrUnknown(
              data['audit_entity_name']!, _auditEntityNameMeta));
    }
    if (data.containsKey('details_json')) {
      context.handle(
          _detailsJsonMeta,
          detailsJson.isAcceptableOrUnknown(
              data['details_json']!, _detailsJsonMeta));
    }
    if (data.containsKey('device_info')) {
      context.handle(
          _deviceInfoMeta,
          deviceInfo.isAcceptableOrUnknown(
              data['device_info']!, _deviceInfoMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAuditLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}remote_id']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      userRole: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_role'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}entity_id']),
      auditEntityName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}audit_entity_name']),
      detailsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details_json']),
      deviceInfo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_info']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $LocalAuditLogsTable createAlias(String alias) {
    return $LocalAuditLogsTable(attachedDatabase, alias);
  }
}

class LocalAuditLog extends DataClass implements Insertable<LocalAuditLog> {
  final int id;
  final int? remoteId;
  final String userId;
  final String userRole;
  final String action;
  final String entityType;
  final int? entityId;
  final String? auditEntityName;
  final String? detailsJson;
  final String? deviceInfo;
  final DateTime timestamp;
  final DateTime? syncedAt;
  const LocalAuditLog(
      {required this.id,
      this.remoteId,
      required this.userId,
      required this.userRole,
      required this.action,
      required this.entityType,
      this.entityId,
      this.auditEntityName,
      this.detailsJson,
      this.deviceInfo,
      required this.timestamp,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    map['user_id'] = Variable<String>(userId);
    map['user_role'] = Variable<String>(userRole);
    map['action'] = Variable<String>(action);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<int>(entityId);
    }
    if (!nullToAbsent || auditEntityName != null) {
      map['audit_entity_name'] = Variable<String>(auditEntityName);
    }
    if (!nullToAbsent || detailsJson != null) {
      map['details_json'] = Variable<String>(detailsJson);
    }
    if (!nullToAbsent || deviceInfo != null) {
      map['device_info'] = Variable<String>(deviceInfo);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  LocalAuditLogsCompanion toCompanion(bool nullToAbsent) {
    return LocalAuditLogsCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      userId: Value(userId),
      userRole: Value(userRole),
      action: Value(action),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      auditEntityName: auditEntityName == null && nullToAbsent
          ? const Value.absent()
          : Value(auditEntityName),
      detailsJson: detailsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(detailsJson),
      deviceInfo: deviceInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceInfo),
      timestamp: Value(timestamp),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalAuditLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAuditLog(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      userId: serializer.fromJson<String>(json['userId']),
      userRole: serializer.fromJson<String>(json['userRole']),
      action: serializer.fromJson<String>(json['action']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<int?>(json['entityId']),
      auditEntityName: serializer.fromJson<String?>(json['auditEntityName']),
      detailsJson: serializer.fromJson<String?>(json['detailsJson']),
      deviceInfo: serializer.fromJson<String?>(json['deviceInfo']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int?>(remoteId),
      'userId': serializer.toJson<String>(userId),
      'userRole': serializer.toJson<String>(userRole),
      'action': serializer.toJson<String>(action),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<int?>(entityId),
      'auditEntityName': serializer.toJson<String?>(auditEntityName),
      'detailsJson': serializer.toJson<String?>(detailsJson),
      'deviceInfo': serializer.toJson<String?>(deviceInfo),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalAuditLog copyWith(
          {int? id,
          Value<int?> remoteId = const Value.absent(),
          String? userId,
          String? userRole,
          String? action,
          String? entityType,
          Value<int?> entityId = const Value.absent(),
          Value<String?> auditEntityName = const Value.absent(),
          Value<String?> detailsJson = const Value.absent(),
          Value<String?> deviceInfo = const Value.absent(),
          DateTime? timestamp,
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      LocalAuditLog(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        userId: userId ?? this.userId,
        userRole: userRole ?? this.userRole,
        action: action ?? this.action,
        entityType: entityType ?? this.entityType,
        entityId: entityId.present ? entityId.value : this.entityId,
        auditEntityName: auditEntityName.present
            ? auditEntityName.value
            : this.auditEntityName,
        detailsJson: detailsJson.present ? detailsJson.value : this.detailsJson,
        deviceInfo: deviceInfo.present ? deviceInfo.value : this.deviceInfo,
        timestamp: timestamp ?? this.timestamp,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  LocalAuditLog copyWithCompanion(LocalAuditLogsCompanion data) {
    return LocalAuditLog(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      userId: data.userId.present ? data.userId.value : this.userId,
      userRole: data.userRole.present ? data.userRole.value : this.userRole,
      action: data.action.present ? data.action.value : this.action,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      auditEntityName: data.auditEntityName.present
          ? data.auditEntityName.value
          : this.auditEntityName,
      detailsJson:
          data.detailsJson.present ? data.detailsJson.value : this.detailsJson,
      deviceInfo:
          data.deviceInfo.present ? data.deviceInfo.value : this.deviceInfo,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAuditLog(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('userId: $userId, ')
          ..write('userRole: $userRole, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('auditEntityName: $auditEntityName, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('deviceInfo: $deviceInfo, ')
          ..write('timestamp: $timestamp, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      remoteId,
      userId,
      userRole,
      action,
      entityType,
      entityId,
      auditEntityName,
      detailsJson,
      deviceInfo,
      timestamp,
      syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAuditLog &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.userId == this.userId &&
          other.userRole == this.userRole &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.auditEntityName == this.auditEntityName &&
          other.detailsJson == this.detailsJson &&
          other.deviceInfo == this.deviceInfo &&
          other.timestamp == this.timestamp &&
          other.syncedAt == this.syncedAt);
}

class LocalAuditLogsCompanion extends UpdateCompanion<LocalAuditLog> {
  final Value<int> id;
  final Value<int?> remoteId;
  final Value<String> userId;
  final Value<String> userRole;
  final Value<String> action;
  final Value<String> entityType;
  final Value<int?> entityId;
  final Value<String?> auditEntityName;
  final Value<String?> detailsJson;
  final Value<String?> deviceInfo;
  final Value<DateTime> timestamp;
  final Value<DateTime?> syncedAt;
  const LocalAuditLogsCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.userId = const Value.absent(),
    this.userRole = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.auditEntityName = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.deviceInfo = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  LocalAuditLogsCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    required String userId,
    required String userRole,
    required String action,
    required String entityType,
    this.entityId = const Value.absent(),
    this.auditEntityName = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.deviceInfo = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.syncedAt = const Value.absent(),
  })  : userId = Value(userId),
        userRole = Value(userRole),
        action = Value(action),
        entityType = Value(entityType);
  static Insertable<LocalAuditLog> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<String>? userId,
    Expression<String>? userRole,
    Expression<String>? action,
    Expression<String>? entityType,
    Expression<int>? entityId,
    Expression<String>? auditEntityName,
    Expression<String>? detailsJson,
    Expression<String>? deviceInfo,
    Expression<DateTime>? timestamp,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (userId != null) 'user_id': userId,
      if (userRole != null) 'user_role': userRole,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (auditEntityName != null) 'audit_entity_name': auditEntityName,
      if (detailsJson != null) 'details_json': detailsJson,
      if (deviceInfo != null) 'device_info': deviceInfo,
      if (timestamp != null) 'timestamp': timestamp,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  LocalAuditLogsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? remoteId,
      Value<String>? userId,
      Value<String>? userRole,
      Value<String>? action,
      Value<String>? entityType,
      Value<int?>? entityId,
      Value<String?>? auditEntityName,
      Value<String?>? detailsJson,
      Value<String?>? deviceInfo,
      Value<DateTime>? timestamp,
      Value<DateTime?>? syncedAt}) {
    return LocalAuditLogsCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      auditEntityName: auditEntityName ?? this.auditEntityName,
      detailsJson: detailsJson ?? this.detailsJson,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      timestamp: timestamp ?? this.timestamp,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (userRole.present) {
      map['user_role'] = Variable<String>(userRole.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (auditEntityName.present) {
      map['audit_entity_name'] = Variable<String>(auditEntityName.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (deviceInfo.present) {
      map['device_info'] = Variable<String>(deviceInfo.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('userId: $userId, ')
          ..write('userRole: $userRole, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('auditEntityName: $auditEntityName, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('deviceInfo: $deviceInfo, ')
          ..write('timestamp: $timestamp, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalDataGovernanceConfigTable extends LocalDataGovernanceConfig
    with
        TableInfo<$LocalDataGovernanceConfigTable,
            LocalDataGovernanceConfigData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDataGovernanceConfigTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _configKeyMeta =
      const VerificationMeta('configKey');
  @override
  late final GeneratedColumn<String> configKey = GeneratedColumn<String>(
      'config_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _configValueMeta =
      const VerificationMeta('configValue');
  @override
  late final GeneratedColumn<String> configValue = GeneratedColumn<String>(
      'config_value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, configKey, configValue, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_data_governance_config';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalDataGovernanceConfigData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('config_key')) {
      context.handle(_configKeyMeta,
          configKey.isAcceptableOrUnknown(data['config_key']!, _configKeyMeta));
    } else if (isInserting) {
      context.missing(_configKeyMeta);
    }
    if (data.containsKey('config_value')) {
      context.handle(
          _configValueMeta,
          configValue.isAcceptableOrUnknown(
              data['config_value']!, _configValueMeta));
    } else if (isInserting) {
      context.missing(_configValueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalDataGovernanceConfigData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDataGovernanceConfigData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      configKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}config_key'])!,
      configValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}config_value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalDataGovernanceConfigTable createAlias(String alias) {
    return $LocalDataGovernanceConfigTable(attachedDatabase, alias);
  }
}

class LocalDataGovernanceConfigData extends DataClass
    implements Insertable<LocalDataGovernanceConfigData> {
  final int id;
  final String configKey;
  final String configValue;
  final DateTime updatedAt;
  const LocalDataGovernanceConfigData(
      {required this.id,
      required this.configKey,
      required this.configValue,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['config_key'] = Variable<String>(configKey);
    map['config_value'] = Variable<String>(configValue);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalDataGovernanceConfigCompanion toCompanion(bool nullToAbsent) {
    return LocalDataGovernanceConfigCompanion(
      id: Value(id),
      configKey: Value(configKey),
      configValue: Value(configValue),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalDataGovernanceConfigData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDataGovernanceConfigData(
      id: serializer.fromJson<int>(json['id']),
      configKey: serializer.fromJson<String>(json['configKey']),
      configValue: serializer.fromJson<String>(json['configValue']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'configKey': serializer.toJson<String>(configKey),
      'configValue': serializer.toJson<String>(configValue),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalDataGovernanceConfigData copyWith(
          {int? id,
          String? configKey,
          String? configValue,
          DateTime? updatedAt}) =>
      LocalDataGovernanceConfigData(
        id: id ?? this.id,
        configKey: configKey ?? this.configKey,
        configValue: configValue ?? this.configValue,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalDataGovernanceConfigData copyWithCompanion(
      LocalDataGovernanceConfigCompanion data) {
    return LocalDataGovernanceConfigData(
      id: data.id.present ? data.id.value : this.id,
      configKey: data.configKey.present ? data.configKey.value : this.configKey,
      configValue:
          data.configValue.present ? data.configValue.value : this.configValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDataGovernanceConfigData(')
          ..write('id: $id, ')
          ..write('configKey: $configKey, ')
          ..write('configValue: $configValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, configKey, configValue, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDataGovernanceConfigData &&
          other.id == this.id &&
          other.configKey == this.configKey &&
          other.configValue == this.configValue &&
          other.updatedAt == this.updatedAt);
}

class LocalDataGovernanceConfigCompanion
    extends UpdateCompanion<LocalDataGovernanceConfigData> {
  final Value<int> id;
  final Value<String> configKey;
  final Value<String> configValue;
  final Value<DateTime> updatedAt;
  const LocalDataGovernanceConfigCompanion({
    this.id = const Value.absent(),
    this.configKey = const Value.absent(),
    this.configValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocalDataGovernanceConfigCompanion.insert({
    this.id = const Value.absent(),
    required String configKey,
    required String configValue,
    this.updatedAt = const Value.absent(),
  })  : configKey = Value(configKey),
        configValue = Value(configValue);
  static Insertable<LocalDataGovernanceConfigData> custom({
    Expression<int>? id,
    Expression<String>? configKey,
    Expression<String>? configValue,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (configKey != null) 'config_key': configKey,
      if (configValue != null) 'config_value': configValue,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocalDataGovernanceConfigCompanion copyWith(
      {Value<int>? id,
      Value<String>? configKey,
      Value<String>? configValue,
      Value<DateTime>? updatedAt}) {
    return LocalDataGovernanceConfigCompanion(
      id: id ?? this.id,
      configKey: configKey ?? this.configKey,
      configValue: configValue ?? this.configValue,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (configKey.present) {
      map['config_key'] = Variable<String>(configKey.value);
    }
    if (configValue.present) {
      map['config_value'] = Variable<String>(configValue.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDataGovernanceConfigCompanion(')
          ..write('id: $id, ')
          ..write('configKey: $configKey, ')
          ..write('configValue: $configValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalChildrenTable localChildren = $LocalChildrenTable(this);
  late final $LocalScreeningSessionsTable localScreeningSessions =
      $LocalScreeningSessionsTable(this);
  late final $LocalScreeningResponsesTable localScreeningResponses =
      $LocalScreeningResponsesTable(this);
  late final $LocalScreeningResultsTable localScreeningResults =
      $LocalScreeningResultsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $LocalToolConfigsTable localToolConfigs =
      $LocalToolConfigsTable(this);
  late final $LocalQuestionsTable localQuestions = $LocalQuestionsTable(this);
  late final $LocalResponseOptionsTable localResponseOptions =
      $LocalResponseOptionsTable(this);
  late final $LocalScoringRulesTable localScoringRules =
      $LocalScoringRulesTable(this);
  late final $LocalActivitiesTable localActivities =
      $LocalActivitiesTable(this);
  late final $LocalReferralsTable localReferrals = $LocalReferralsTable(this);
  late final $LocalNutritionAssessmentsTable localNutritionAssessments =
      $LocalNutritionAssessmentsTable(this);
  late final $LocalEnvironmentAssessmentsTable localEnvironmentAssessments =
      $LocalEnvironmentAssessmentsTable(this);
  late final $LocalInterventionFollowupsTable localInterventionFollowups =
      $LocalInterventionFollowupsTable(this);
  late final $LocalConsentsTable localConsents = $LocalConsentsTable(this);
  late final $LocalAuditLogsTable localAuditLogs = $LocalAuditLogsTable(this);
  late final $LocalDataGovernanceConfigTable localDataGovernanceConfig =
      $LocalDataGovernanceConfigTable(this);
  late final ChildrenDao childrenDao = ChildrenDao(this as AppDatabase);
  late final ScreeningDao screeningDao = ScreeningDao(this as AppDatabase);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  late final ScreeningConfigDao screeningConfigDao =
      ScreeningConfigDao(this as AppDatabase);
  late final ReferralDao referralDao = ReferralDao(this as AppDatabase);
  late final ChallengeDao challengeDao = ChallengeDao(this as AppDatabase);
  late final DpdpDao dpdpDao = DpdpDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localChildren,
        localScreeningSessions,
        localScreeningResponses,
        localScreeningResults,
        syncQueue,
        localToolConfigs,
        localQuestions,
        localResponseOptions,
        localScoringRules,
        localActivities,
        localReferrals,
        localNutritionAssessments,
        localEnvironmentAssessments,
        localInterventionFollowups,
        localConsents,
        localAuditLogs,
        localDataGovernanceConfig
      ];
}

typedef $$LocalChildrenTableCreateCompanionBuilder = LocalChildrenCompanion
    Function({
  Value<int> localId,
  Value<int?> remoteId,
  required String childUniqueId,
  required String name,
  required DateTime dob,
  required String gender,
  Value<int?> parentId,
  Value<String?> awwId,
  Value<int?> awcId,
  Value<String?> photoUrl,
  Value<bool> isActive,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime> localUpdatedAt,
});
typedef $$LocalChildrenTableUpdateCompanionBuilder = LocalChildrenCompanion
    Function({
  Value<int> localId,
  Value<int?> remoteId,
  Value<String> childUniqueId,
  Value<String> name,
  Value<DateTime> dob,
  Value<String> gender,
  Value<int?> parentId,
  Value<String?> awwId,
  Value<int?> awcId,
  Value<String?> photoUrl,
  Value<bool> isActive,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime> localUpdatedAt,
});

class $$LocalChildrenTableFilterComposer
    extends Composer<_$AppDatabase, $LocalChildrenTable> {
  $$LocalChildrenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get childUniqueId => $composableBuilder(
      column: $table.childUniqueId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dob => $composableBuilder(
      column: $table.dob, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get awwId => $composableBuilder(
      column: $table.awwId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get awcId => $composableBuilder(
      column: $table.awcId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));
}

class $$LocalChildrenTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalChildrenTable> {
  $$LocalChildrenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get childUniqueId => $composableBuilder(
      column: $table.childUniqueId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dob => $composableBuilder(
      column: $table.dob, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get awwId => $composableBuilder(
      column: $table.awwId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get awcId => $composableBuilder(
      column: $table.awcId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalChildrenTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalChildrenTable> {
  $$LocalChildrenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get childUniqueId => $composableBuilder(
      column: $table.childUniqueId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get dob =>
      $composableBuilder(column: $table.dob, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get awwId =>
      $composableBuilder(column: $table.awwId, builder: (column) => column);

  GeneratedColumn<int> get awcId =>
      $composableBuilder(column: $table.awcId, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);
}

class $$LocalChildrenTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalChildrenTable,
    LocalChildrenData,
    $$LocalChildrenTableFilterComposer,
    $$LocalChildrenTableOrderingComposer,
    $$LocalChildrenTableAnnotationComposer,
    $$LocalChildrenTableCreateCompanionBuilder,
    $$LocalChildrenTableUpdateCompanionBuilder,
    (
      LocalChildrenData,
      BaseReferences<_$AppDatabase, $LocalChildrenTable, LocalChildrenData>
    ),
    LocalChildrenData,
    PrefetchHooks Function()> {
  $$LocalChildrenTableTableManager(_$AppDatabase db, $LocalChildrenTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalChildrenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalChildrenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalChildrenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            Value<String> childUniqueId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> dob = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<int?> parentId = const Value.absent(),
            Value<String?> awwId = const Value.absent(),
            Value<int?> awcId = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
          }) =>
              LocalChildrenCompanion(
            localId: localId,
            remoteId: remoteId,
            childUniqueId: childUniqueId,
            name: name,
            dob: dob,
            gender: gender,
            parentId: parentId,
            awwId: awwId,
            awcId: awcId,
            photoUrl: photoUrl,
            isActive: isActive,
            lastSyncedAt: lastSyncedAt,
            localUpdatedAt: localUpdatedAt,
          ),
          createCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            required String childUniqueId,
            required String name,
            required DateTime dob,
            required String gender,
            Value<int?> parentId = const Value.absent(),
            Value<String?> awwId = const Value.absent(),
            Value<int?> awcId = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
          }) =>
              LocalChildrenCompanion.insert(
            localId: localId,
            remoteId: remoteId,
            childUniqueId: childUniqueId,
            name: name,
            dob: dob,
            gender: gender,
            parentId: parentId,
            awwId: awwId,
            awcId: awcId,
            photoUrl: photoUrl,
            isActive: isActive,
            lastSyncedAt: lastSyncedAt,
            localUpdatedAt: localUpdatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalChildrenTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalChildrenTable,
    LocalChildrenData,
    $$LocalChildrenTableFilterComposer,
    $$LocalChildrenTableOrderingComposer,
    $$LocalChildrenTableAnnotationComposer,
    $$LocalChildrenTableCreateCompanionBuilder,
    $$LocalChildrenTableUpdateCompanionBuilder,
    (
      LocalChildrenData,
      BaseReferences<_$AppDatabase, $LocalChildrenTable, LocalChildrenData>
    ),
    LocalChildrenData,
    PrefetchHooks Function()>;
typedef $$LocalScreeningSessionsTableCreateCompanionBuilder
    = LocalScreeningSessionsCompanion Function({
  Value<int> localId,
  Value<int?> remoteId,
  Value<int?> childLocalId,
  Value<int?> childRemoteId,
  required String conductedBy,
  required String assessmentDate,
  required int childAgeMonths,
  Value<String> status,
  Value<String?> deviceSessionId,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> syncedAt,
});
typedef $$LocalScreeningSessionsTableUpdateCompanionBuilder
    = LocalScreeningSessionsCompanion Function({
  Value<int> localId,
  Value<int?> remoteId,
  Value<int?> childLocalId,
  Value<int?> childRemoteId,
  Value<String> conductedBy,
  Value<String> assessmentDate,
  Value<int> childAgeMonths,
  Value<String> status,
  Value<String?> deviceSessionId,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> syncedAt,
});

class $$LocalScreeningSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalScreeningSessionsTable> {
  $$LocalScreeningSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get childLocalId => $composableBuilder(
      column: $table.childLocalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conductedBy => $composableBuilder(
      column: $table.conductedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assessmentDate => $composableBuilder(
      column: $table.assessmentDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get childAgeMonths => $composableBuilder(
      column: $table.childAgeMonths,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceSessionId => $composableBuilder(
      column: $table.deviceSessionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalScreeningSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalScreeningSessionsTable> {
  $$LocalScreeningSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get childLocalId => $composableBuilder(
      column: $table.childLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conductedBy => $composableBuilder(
      column: $table.conductedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assessmentDate => $composableBuilder(
      column: $table.assessmentDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get childAgeMonths => $composableBuilder(
      column: $table.childAgeMonths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceSessionId => $composableBuilder(
      column: $table.deviceSessionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalScreeningSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalScreeningSessionsTable> {
  $$LocalScreeningSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get childLocalId => $composableBuilder(
      column: $table.childLocalId, builder: (column) => column);

  GeneratedColumn<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId, builder: (column) => column);

  GeneratedColumn<String> get conductedBy => $composableBuilder(
      column: $table.conductedBy, builder: (column) => column);

  GeneratedColumn<String> get assessmentDate => $composableBuilder(
      column: $table.assessmentDate, builder: (column) => column);

  GeneratedColumn<int> get childAgeMonths => $composableBuilder(
      column: $table.childAgeMonths, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get deviceSessionId => $composableBuilder(
      column: $table.deviceSessionId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$LocalScreeningSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalScreeningSessionsTable,
    LocalScreeningSession,
    $$LocalScreeningSessionsTableFilterComposer,
    $$LocalScreeningSessionsTableOrderingComposer,
    $$LocalScreeningSessionsTableAnnotationComposer,
    $$LocalScreeningSessionsTableCreateCompanionBuilder,
    $$LocalScreeningSessionsTableUpdateCompanionBuilder,
    (
      LocalScreeningSession,
      BaseReferences<_$AppDatabase, $LocalScreeningSessionsTable,
          LocalScreeningSession>
    ),
    LocalScreeningSession,
    PrefetchHooks Function()> {
  $$LocalScreeningSessionsTableTableManager(
      _$AppDatabase db, $LocalScreeningSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalScreeningSessionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalScreeningSessionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalScreeningSessionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            Value<int?> childLocalId = const Value.absent(),
            Value<int?> childRemoteId = const Value.absent(),
            Value<String> conductedBy = const Value.absent(),
            Value<String> assessmentDate = const Value.absent(),
            Value<int> childAgeMonths = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> deviceSessionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalScreeningSessionsCompanion(
            localId: localId,
            remoteId: remoteId,
            childLocalId: childLocalId,
            childRemoteId: childRemoteId,
            conductedBy: conductedBy,
            assessmentDate: assessmentDate,
            childAgeMonths: childAgeMonths,
            status: status,
            deviceSessionId: deviceSessionId,
            createdAt: createdAt,
            completedAt: completedAt,
            syncedAt: syncedAt,
          ),
          createCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            Value<int?> childLocalId = const Value.absent(),
            Value<int?> childRemoteId = const Value.absent(),
            required String conductedBy,
            required String assessmentDate,
            required int childAgeMonths,
            Value<String> status = const Value.absent(),
            Value<String?> deviceSessionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalScreeningSessionsCompanion.insert(
            localId: localId,
            remoteId: remoteId,
            childLocalId: childLocalId,
            childRemoteId: childRemoteId,
            conductedBy: conductedBy,
            assessmentDate: assessmentDate,
            childAgeMonths: childAgeMonths,
            status: status,
            deviceSessionId: deviceSessionId,
            createdAt: createdAt,
            completedAt: completedAt,
            syncedAt: syncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalScreeningSessionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalScreeningSessionsTable,
        LocalScreeningSession,
        $$LocalScreeningSessionsTableFilterComposer,
        $$LocalScreeningSessionsTableOrderingComposer,
        $$LocalScreeningSessionsTableAnnotationComposer,
        $$LocalScreeningSessionsTableCreateCompanionBuilder,
        $$LocalScreeningSessionsTableUpdateCompanionBuilder,
        (
          LocalScreeningSession,
          BaseReferences<_$AppDatabase, $LocalScreeningSessionsTable,
              LocalScreeningSession>
        ),
        LocalScreeningSession,
        PrefetchHooks Function()>;
typedef $$LocalScreeningResponsesTableCreateCompanionBuilder
    = LocalScreeningResponsesCompanion Function({
  Value<int> id,
  required int sessionLocalId,
  required String toolType,
  required String responsesJson,
  Value<DateTime> createdAt,
  Value<DateTime?> syncedAt,
});
typedef $$LocalScreeningResponsesTableUpdateCompanionBuilder
    = LocalScreeningResponsesCompanion Function({
  Value<int> id,
  Value<int> sessionLocalId,
  Value<String> toolType,
  Value<String> responsesJson,
  Value<DateTime> createdAt,
  Value<DateTime?> syncedAt,
});

class $$LocalScreeningResponsesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalScreeningResponsesTable> {
  $$LocalScreeningResponsesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionLocalId => $composableBuilder(
      column: $table.sessionLocalId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toolType => $composableBuilder(
      column: $table.toolType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get responsesJson => $composableBuilder(
      column: $table.responsesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalScreeningResponsesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalScreeningResponsesTable> {
  $$LocalScreeningResponsesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionLocalId => $composableBuilder(
      column: $table.sessionLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toolType => $composableBuilder(
      column: $table.toolType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get responsesJson => $composableBuilder(
      column: $table.responsesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalScreeningResponsesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalScreeningResponsesTable> {
  $$LocalScreeningResponsesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sessionLocalId => $composableBuilder(
      column: $table.sessionLocalId, builder: (column) => column);

  GeneratedColumn<String> get toolType =>
      $composableBuilder(column: $table.toolType, builder: (column) => column);

  GeneratedColumn<String> get responsesJson => $composableBuilder(
      column: $table.responsesJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$LocalScreeningResponsesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalScreeningResponsesTable,
    LocalScreeningResponse,
    $$LocalScreeningResponsesTableFilterComposer,
    $$LocalScreeningResponsesTableOrderingComposer,
    $$LocalScreeningResponsesTableAnnotationComposer,
    $$LocalScreeningResponsesTableCreateCompanionBuilder,
    $$LocalScreeningResponsesTableUpdateCompanionBuilder,
    (
      LocalScreeningResponse,
      BaseReferences<_$AppDatabase, $LocalScreeningResponsesTable,
          LocalScreeningResponse>
    ),
    LocalScreeningResponse,
    PrefetchHooks Function()> {
  $$LocalScreeningResponsesTableTableManager(
      _$AppDatabase db, $LocalScreeningResponsesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalScreeningResponsesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalScreeningResponsesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalScreeningResponsesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionLocalId = const Value.absent(),
            Value<String> toolType = const Value.absent(),
            Value<String> responsesJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalScreeningResponsesCompanion(
            id: id,
            sessionLocalId: sessionLocalId,
            toolType: toolType,
            responsesJson: responsesJson,
            createdAt: createdAt,
            syncedAt: syncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sessionLocalId,
            required String toolType,
            required String responsesJson,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalScreeningResponsesCompanion.insert(
            id: id,
            sessionLocalId: sessionLocalId,
            toolType: toolType,
            responsesJson: responsesJson,
            createdAt: createdAt,
            syncedAt: syncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalScreeningResponsesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalScreeningResponsesTable,
        LocalScreeningResponse,
        $$LocalScreeningResponsesTableFilterComposer,
        $$LocalScreeningResponsesTableOrderingComposer,
        $$LocalScreeningResponsesTableAnnotationComposer,
        $$LocalScreeningResponsesTableCreateCompanionBuilder,
        $$LocalScreeningResponsesTableUpdateCompanionBuilder,
        (
          LocalScreeningResponse,
          BaseReferences<_$AppDatabase, $LocalScreeningResponsesTable,
              LocalScreeningResponse>
        ),
        LocalScreeningResponse,
        PrefetchHooks Function()>;
typedef $$LocalScreeningResultsTableCreateCompanionBuilder
    = LocalScreeningResultsCompanion Function({
  Value<int> id,
  required int sessionLocalId,
  Value<int?> sessionRemoteId,
  Value<int?> childLocalId,
  Value<int?> childRemoteId,
  required String overallRisk,
  Value<String> overallRiskTe,
  Value<bool> referralNeeded,
  Value<double?> gmDq,
  Value<double?> fmDq,
  Value<double?> lcDq,
  Value<double?> cogDq,
  Value<double?> seDq,
  Value<double?> compositeDq,
  Value<String?> toolResultsJson,
  Value<String?> concernsJson,
  Value<String?> concernsTeJson,
  Value<int> toolsCompleted,
  Value<int> toolsSkipped,
  Value<String> assessmentCycle,
  Value<int> baselineScore,
  Value<String> baselineCategory,
  Value<int> numDelays,
  Value<String> autismRisk,
  Value<String> adhdRisk,
  Value<String> behaviorRisk,
  Value<int> behaviorScore,
  Value<double?> predictedRiskScore,
  Value<String?> predictedRiskCategory,
  Value<String?> riskTrend,
  Value<String?> topRiskFactorsJson,
  Value<DateTime> createdAt,
  Value<DateTime?> syncedAt,
});
typedef $$LocalScreeningResultsTableUpdateCompanionBuilder
    = LocalScreeningResultsCompanion Function({
  Value<int> id,
  Value<int> sessionLocalId,
  Value<int?> sessionRemoteId,
  Value<int?> childLocalId,
  Value<int?> childRemoteId,
  Value<String> overallRisk,
  Value<String> overallRiskTe,
  Value<bool> referralNeeded,
  Value<double?> gmDq,
  Value<double?> fmDq,
  Value<double?> lcDq,
  Value<double?> cogDq,
  Value<double?> seDq,
  Value<double?> compositeDq,
  Value<String?> toolResultsJson,
  Value<String?> concernsJson,
  Value<String?> concernsTeJson,
  Value<int> toolsCompleted,
  Value<int> toolsSkipped,
  Value<String> assessmentCycle,
  Value<int> baselineScore,
  Value<String> baselineCategory,
  Value<int> numDelays,
  Value<String> autismRisk,
  Value<String> adhdRisk,
  Value<String> behaviorRisk,
  Value<int> behaviorScore,
  Value<double?> predictedRiskScore,
  Value<String?> predictedRiskCategory,
  Value<String?> riskTrend,
  Value<String?> topRiskFactorsJson,
  Value<DateTime> createdAt,
  Value<DateTime?> syncedAt,
});

class $$LocalScreeningResultsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalScreeningResultsTable> {
  $$LocalScreeningResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionLocalId => $composableBuilder(
      column: $table.sessionLocalId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionRemoteId => $composableBuilder(
      column: $table.sessionRemoteId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get childLocalId => $composableBuilder(
      column: $table.childLocalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get overallRisk => $composableBuilder(
      column: $table.overallRisk, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get overallRiskTe => $composableBuilder(
      column: $table.overallRiskTe, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get referralNeeded => $composableBuilder(
      column: $table.referralNeeded,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gmDq => $composableBuilder(
      column: $table.gmDq, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fmDq => $composableBuilder(
      column: $table.fmDq, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lcDq => $composableBuilder(
      column: $table.lcDq, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cogDq => $composableBuilder(
      column: $table.cogDq, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get seDq => $composableBuilder(
      column: $table.seDq, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get compositeDq => $composableBuilder(
      column: $table.compositeDq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toolResultsJson => $composableBuilder(
      column: $table.toolResultsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get concernsJson => $composableBuilder(
      column: $table.concernsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get concernsTeJson => $composableBuilder(
      column: $table.concernsTeJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get toolsCompleted => $composableBuilder(
      column: $table.toolsCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get toolsSkipped => $composableBuilder(
      column: $table.toolsSkipped, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assessmentCycle => $composableBuilder(
      column: $table.assessmentCycle,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get baselineScore => $composableBuilder(
      column: $table.baselineScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get baselineCategory => $composableBuilder(
      column: $table.baselineCategory,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numDelays => $composableBuilder(
      column: $table.numDelays, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get autismRisk => $composableBuilder(
      column: $table.autismRisk, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get adhdRisk => $composableBuilder(
      column: $table.adhdRisk, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get behaviorRisk => $composableBuilder(
      column: $table.behaviorRisk, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get behaviorScore => $composableBuilder(
      column: $table.behaviorScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get predictedRiskScore => $composableBuilder(
      column: $table.predictedRiskScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get predictedRiskCategory => $composableBuilder(
      column: $table.predictedRiskCategory,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get riskTrend => $composableBuilder(
      column: $table.riskTrend, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topRiskFactorsJson => $composableBuilder(
      column: $table.topRiskFactorsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalScreeningResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalScreeningResultsTable> {
  $$LocalScreeningResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionLocalId => $composableBuilder(
      column: $table.sessionLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionRemoteId => $composableBuilder(
      column: $table.sessionRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get childLocalId => $composableBuilder(
      column: $table.childLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get overallRisk => $composableBuilder(
      column: $table.overallRisk, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get overallRiskTe => $composableBuilder(
      column: $table.overallRiskTe,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get referralNeeded => $composableBuilder(
      column: $table.referralNeeded,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gmDq => $composableBuilder(
      column: $table.gmDq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fmDq => $composableBuilder(
      column: $table.fmDq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lcDq => $composableBuilder(
      column: $table.lcDq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cogDq => $composableBuilder(
      column: $table.cogDq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get seDq => $composableBuilder(
      column: $table.seDq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get compositeDq => $composableBuilder(
      column: $table.compositeDq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toolResultsJson => $composableBuilder(
      column: $table.toolResultsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get concernsJson => $composableBuilder(
      column: $table.concernsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get concernsTeJson => $composableBuilder(
      column: $table.concernsTeJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get toolsCompleted => $composableBuilder(
      column: $table.toolsCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get toolsSkipped => $composableBuilder(
      column: $table.toolsSkipped,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assessmentCycle => $composableBuilder(
      column: $table.assessmentCycle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get baselineScore => $composableBuilder(
      column: $table.baselineScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get baselineCategory => $composableBuilder(
      column: $table.baselineCategory,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numDelays => $composableBuilder(
      column: $table.numDelays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get autismRisk => $composableBuilder(
      column: $table.autismRisk, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get adhdRisk => $composableBuilder(
      column: $table.adhdRisk, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get behaviorRisk => $composableBuilder(
      column: $table.behaviorRisk,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get behaviorScore => $composableBuilder(
      column: $table.behaviorScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get predictedRiskScore => $composableBuilder(
      column: $table.predictedRiskScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get predictedRiskCategory => $composableBuilder(
      column: $table.predictedRiskCategory,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get riskTrend => $composableBuilder(
      column: $table.riskTrend, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topRiskFactorsJson => $composableBuilder(
      column: $table.topRiskFactorsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalScreeningResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalScreeningResultsTable> {
  $$LocalScreeningResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sessionLocalId => $composableBuilder(
      column: $table.sessionLocalId, builder: (column) => column);

  GeneratedColumn<int> get sessionRemoteId => $composableBuilder(
      column: $table.sessionRemoteId, builder: (column) => column);

  GeneratedColumn<int> get childLocalId => $composableBuilder(
      column: $table.childLocalId, builder: (column) => column);

  GeneratedColumn<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId, builder: (column) => column);

  GeneratedColumn<String> get overallRisk => $composableBuilder(
      column: $table.overallRisk, builder: (column) => column);

  GeneratedColumn<String> get overallRiskTe => $composableBuilder(
      column: $table.overallRiskTe, builder: (column) => column);

  GeneratedColumn<bool> get referralNeeded => $composableBuilder(
      column: $table.referralNeeded, builder: (column) => column);

  GeneratedColumn<double> get gmDq =>
      $composableBuilder(column: $table.gmDq, builder: (column) => column);

  GeneratedColumn<double> get fmDq =>
      $composableBuilder(column: $table.fmDq, builder: (column) => column);

  GeneratedColumn<double> get lcDq =>
      $composableBuilder(column: $table.lcDq, builder: (column) => column);

  GeneratedColumn<double> get cogDq =>
      $composableBuilder(column: $table.cogDq, builder: (column) => column);

  GeneratedColumn<double> get seDq =>
      $composableBuilder(column: $table.seDq, builder: (column) => column);

  GeneratedColumn<double> get compositeDq => $composableBuilder(
      column: $table.compositeDq, builder: (column) => column);

  GeneratedColumn<String> get toolResultsJson => $composableBuilder(
      column: $table.toolResultsJson, builder: (column) => column);

  GeneratedColumn<String> get concernsJson => $composableBuilder(
      column: $table.concernsJson, builder: (column) => column);

  GeneratedColumn<String> get concernsTeJson => $composableBuilder(
      column: $table.concernsTeJson, builder: (column) => column);

  GeneratedColumn<int> get toolsCompleted => $composableBuilder(
      column: $table.toolsCompleted, builder: (column) => column);

  GeneratedColumn<int> get toolsSkipped => $composableBuilder(
      column: $table.toolsSkipped, builder: (column) => column);

  GeneratedColumn<String> get assessmentCycle => $composableBuilder(
      column: $table.assessmentCycle, builder: (column) => column);

  GeneratedColumn<int> get baselineScore => $composableBuilder(
      column: $table.baselineScore, builder: (column) => column);

  GeneratedColumn<String> get baselineCategory => $composableBuilder(
      column: $table.baselineCategory, builder: (column) => column);

  GeneratedColumn<int> get numDelays =>
      $composableBuilder(column: $table.numDelays, builder: (column) => column);

  GeneratedColumn<String> get autismRisk => $composableBuilder(
      column: $table.autismRisk, builder: (column) => column);

  GeneratedColumn<String> get adhdRisk =>
      $composableBuilder(column: $table.adhdRisk, builder: (column) => column);

  GeneratedColumn<String> get behaviorRisk => $composableBuilder(
      column: $table.behaviorRisk, builder: (column) => column);

  GeneratedColumn<int> get behaviorScore => $composableBuilder(
      column: $table.behaviorScore, builder: (column) => column);

  GeneratedColumn<double> get predictedRiskScore => $composableBuilder(
      column: $table.predictedRiskScore, builder: (column) => column);

  GeneratedColumn<String> get predictedRiskCategory => $composableBuilder(
      column: $table.predictedRiskCategory, builder: (column) => column);

  GeneratedColumn<String> get riskTrend =>
      $composableBuilder(column: $table.riskTrend, builder: (column) => column);

  GeneratedColumn<String> get topRiskFactorsJson => $composableBuilder(
      column: $table.topRiskFactorsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$LocalScreeningResultsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalScreeningResultsTable,
    LocalScreeningResult,
    $$LocalScreeningResultsTableFilterComposer,
    $$LocalScreeningResultsTableOrderingComposer,
    $$LocalScreeningResultsTableAnnotationComposer,
    $$LocalScreeningResultsTableCreateCompanionBuilder,
    $$LocalScreeningResultsTableUpdateCompanionBuilder,
    (
      LocalScreeningResult,
      BaseReferences<_$AppDatabase, $LocalScreeningResultsTable,
          LocalScreeningResult>
    ),
    LocalScreeningResult,
    PrefetchHooks Function()> {
  $$LocalScreeningResultsTableTableManager(
      _$AppDatabase db, $LocalScreeningResultsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalScreeningResultsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalScreeningResultsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalScreeningResultsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionLocalId = const Value.absent(),
            Value<int?> sessionRemoteId = const Value.absent(),
            Value<int?> childLocalId = const Value.absent(),
            Value<int?> childRemoteId = const Value.absent(),
            Value<String> overallRisk = const Value.absent(),
            Value<String> overallRiskTe = const Value.absent(),
            Value<bool> referralNeeded = const Value.absent(),
            Value<double?> gmDq = const Value.absent(),
            Value<double?> fmDq = const Value.absent(),
            Value<double?> lcDq = const Value.absent(),
            Value<double?> cogDq = const Value.absent(),
            Value<double?> seDq = const Value.absent(),
            Value<double?> compositeDq = const Value.absent(),
            Value<String?> toolResultsJson = const Value.absent(),
            Value<String?> concernsJson = const Value.absent(),
            Value<String?> concernsTeJson = const Value.absent(),
            Value<int> toolsCompleted = const Value.absent(),
            Value<int> toolsSkipped = const Value.absent(),
            Value<String> assessmentCycle = const Value.absent(),
            Value<int> baselineScore = const Value.absent(),
            Value<String> baselineCategory = const Value.absent(),
            Value<int> numDelays = const Value.absent(),
            Value<String> autismRisk = const Value.absent(),
            Value<String> adhdRisk = const Value.absent(),
            Value<String> behaviorRisk = const Value.absent(),
            Value<int> behaviorScore = const Value.absent(),
            Value<double?> predictedRiskScore = const Value.absent(),
            Value<String?> predictedRiskCategory = const Value.absent(),
            Value<String?> riskTrend = const Value.absent(),
            Value<String?> topRiskFactorsJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalScreeningResultsCompanion(
            id: id,
            sessionLocalId: sessionLocalId,
            sessionRemoteId: sessionRemoteId,
            childLocalId: childLocalId,
            childRemoteId: childRemoteId,
            overallRisk: overallRisk,
            overallRiskTe: overallRiskTe,
            referralNeeded: referralNeeded,
            gmDq: gmDq,
            fmDq: fmDq,
            lcDq: lcDq,
            cogDq: cogDq,
            seDq: seDq,
            compositeDq: compositeDq,
            toolResultsJson: toolResultsJson,
            concernsJson: concernsJson,
            concernsTeJson: concernsTeJson,
            toolsCompleted: toolsCompleted,
            toolsSkipped: toolsSkipped,
            assessmentCycle: assessmentCycle,
            baselineScore: baselineScore,
            baselineCategory: baselineCategory,
            numDelays: numDelays,
            autismRisk: autismRisk,
            adhdRisk: adhdRisk,
            behaviorRisk: behaviorRisk,
            behaviorScore: behaviorScore,
            predictedRiskScore: predictedRiskScore,
            predictedRiskCategory: predictedRiskCategory,
            riskTrend: riskTrend,
            topRiskFactorsJson: topRiskFactorsJson,
            createdAt: createdAt,
            syncedAt: syncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sessionLocalId,
            Value<int?> sessionRemoteId = const Value.absent(),
            Value<int?> childLocalId = const Value.absent(),
            Value<int?> childRemoteId = const Value.absent(),
            required String overallRisk,
            Value<String> overallRiskTe = const Value.absent(),
            Value<bool> referralNeeded = const Value.absent(),
            Value<double?> gmDq = const Value.absent(),
            Value<double?> fmDq = const Value.absent(),
            Value<double?> lcDq = const Value.absent(),
            Value<double?> cogDq = const Value.absent(),
            Value<double?> seDq = const Value.absent(),
            Value<double?> compositeDq = const Value.absent(),
            Value<String?> toolResultsJson = const Value.absent(),
            Value<String?> concernsJson = const Value.absent(),
            Value<String?> concernsTeJson = const Value.absent(),
            Value<int> toolsCompleted = const Value.absent(),
            Value<int> toolsSkipped = const Value.absent(),
            Value<String> assessmentCycle = const Value.absent(),
            Value<int> baselineScore = const Value.absent(),
            Value<String> baselineCategory = const Value.absent(),
            Value<int> numDelays = const Value.absent(),
            Value<String> autismRisk = const Value.absent(),
            Value<String> adhdRisk = const Value.absent(),
            Value<String> behaviorRisk = const Value.absent(),
            Value<int> behaviorScore = const Value.absent(),
            Value<double?> predictedRiskScore = const Value.absent(),
            Value<String?> predictedRiskCategory = const Value.absent(),
            Value<String?> riskTrend = const Value.absent(),
            Value<String?> topRiskFactorsJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalScreeningResultsCompanion.insert(
            id: id,
            sessionLocalId: sessionLocalId,
            sessionRemoteId: sessionRemoteId,
            childLocalId: childLocalId,
            childRemoteId: childRemoteId,
            overallRisk: overallRisk,
            overallRiskTe: overallRiskTe,
            referralNeeded: referralNeeded,
            gmDq: gmDq,
            fmDq: fmDq,
            lcDq: lcDq,
            cogDq: cogDq,
            seDq: seDq,
            compositeDq: compositeDq,
            toolResultsJson: toolResultsJson,
            concernsJson: concernsJson,
            concernsTeJson: concernsTeJson,
            toolsCompleted: toolsCompleted,
            toolsSkipped: toolsSkipped,
            assessmentCycle: assessmentCycle,
            baselineScore: baselineScore,
            baselineCategory: baselineCategory,
            numDelays: numDelays,
            autismRisk: autismRisk,
            adhdRisk: adhdRisk,
            behaviorRisk: behaviorRisk,
            behaviorScore: behaviorScore,
            predictedRiskScore: predictedRiskScore,
            predictedRiskCategory: predictedRiskCategory,
            riskTrend: riskTrend,
            topRiskFactorsJson: topRiskFactorsJson,
            createdAt: createdAt,
            syncedAt: syncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalScreeningResultsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalScreeningResultsTable,
        LocalScreeningResult,
        $$LocalScreeningResultsTableFilterComposer,
        $$LocalScreeningResultsTableOrderingComposer,
        $$LocalScreeningResultsTableAnnotationComposer,
        $$LocalScreeningResultsTableCreateCompanionBuilder,
        $$LocalScreeningResultsTableUpdateCompanionBuilder,
        (
          LocalScreeningResult,
          BaseReferences<_$AppDatabase, $LocalScreeningResultsTable,
              LocalScreeningResult>
        ),
        LocalScreeningResult,
        PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String entityType,
  required int entityLocalId,
  required String operation,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<int> priority,
  Value<DateTime> createdAt,
  Value<DateTime?> lastAttemptAt,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> entityType,
  Value<int> entityLocalId,
  Value<String> operation,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<int> priority,
  Value<DateTime> createdAt,
  Value<DateTime?> lastAttemptAt,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get entityLocalId => $composableBuilder(
      column: $table.entityLocalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get entityLocalId => $composableBuilder(
      column: $table.entityLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<int> get entityLocalId => $composableBuilder(
      column: $table.entityLocalId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<int> entityLocalId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastAttemptAt = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            entityType: entityType,
            entityLocalId: entityLocalId,
            operation: operation,
            retryCount: retryCount,
            lastError: lastError,
            priority: priority,
            createdAt: createdAt,
            lastAttemptAt: lastAttemptAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entityType,
            required int entityLocalId,
            required String operation,
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastAttemptAt = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            entityType: entityType,
            entityLocalId: entityLocalId,
            operation: operation,
            retryCount: retryCount,
            lastError: lastError,
            priority: priority,
            createdAt: createdAt,
            lastAttemptAt: lastAttemptAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;
typedef $$LocalToolConfigsTableCreateCompanionBuilder
    = LocalToolConfigsCompanion Function({
  Value<int> id,
  Value<int?> remoteId,
  required String toolType,
  required String toolId,
  required String name,
  required String nameTe,
  Value<String> description,
  Value<String> descriptionTe,
  Value<int> minAgeMonths,
  Value<int> maxAgeMonths,
  required String responseFormat,
  Value<String> domainsJson,
  Value<String?> iconName,
  Value<String?> colorHex,
  Value<int> sortOrder,
  Value<bool> isAgeBracketFiltered,
  Value<bool> isActive,
  Value<int> version,
  Value<DateTime?> lastSyncedAt,
});
typedef $$LocalToolConfigsTableUpdateCompanionBuilder
    = LocalToolConfigsCompanion Function({
  Value<int> id,
  Value<int?> remoteId,
  Value<String> toolType,
  Value<String> toolId,
  Value<String> name,
  Value<String> nameTe,
  Value<String> description,
  Value<String> descriptionTe,
  Value<int> minAgeMonths,
  Value<int> maxAgeMonths,
  Value<String> responseFormat,
  Value<String> domainsJson,
  Value<String?> iconName,
  Value<String?> colorHex,
  Value<int> sortOrder,
  Value<bool> isAgeBracketFiltered,
  Value<bool> isActive,
  Value<int> version,
  Value<DateTime?> lastSyncedAt,
});

class $$LocalToolConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalToolConfigsTable> {
  $$LocalToolConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toolType => $composableBuilder(
      column: $table.toolType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toolId => $composableBuilder(
      column: $table.toolId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameTe => $composableBuilder(
      column: $table.nameTe, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descriptionTe => $composableBuilder(
      column: $table.descriptionTe, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minAgeMonths => $composableBuilder(
      column: $table.minAgeMonths, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxAgeMonths => $composableBuilder(
      column: $table.maxAgeMonths, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get responseFormat => $composableBuilder(
      column: $table.responseFormat,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get domainsJson => $composableBuilder(
      column: $table.domainsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAgeBracketFiltered => $composableBuilder(
      column: $table.isAgeBracketFiltered,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalToolConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalToolConfigsTable> {
  $$LocalToolConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toolType => $composableBuilder(
      column: $table.toolType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toolId => $composableBuilder(
      column: $table.toolId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameTe => $composableBuilder(
      column: $table.nameTe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descriptionTe => $composableBuilder(
      column: $table.descriptionTe,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minAgeMonths => $composableBuilder(
      column: $table.minAgeMonths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxAgeMonths => $composableBuilder(
      column: $table.maxAgeMonths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get responseFormat => $composableBuilder(
      column: $table.responseFormat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get domainsJson => $composableBuilder(
      column: $table.domainsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAgeBracketFiltered => $composableBuilder(
      column: $table.isAgeBracketFiltered,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalToolConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalToolConfigsTable> {
  $$LocalToolConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get toolType =>
      $composableBuilder(column: $table.toolType, builder: (column) => column);

  GeneratedColumn<String> get toolId =>
      $composableBuilder(column: $table.toolId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameTe =>
      $composableBuilder(column: $table.nameTe, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get descriptionTe => $composableBuilder(
      column: $table.descriptionTe, builder: (column) => column);

  GeneratedColumn<int> get minAgeMonths => $composableBuilder(
      column: $table.minAgeMonths, builder: (column) => column);

  GeneratedColumn<int> get maxAgeMonths => $composableBuilder(
      column: $table.maxAgeMonths, builder: (column) => column);

  GeneratedColumn<String> get responseFormat => $composableBuilder(
      column: $table.responseFormat, builder: (column) => column);

  GeneratedColumn<String> get domainsJson => $composableBuilder(
      column: $table.domainsJson, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isAgeBracketFiltered => $composableBuilder(
      column: $table.isAgeBracketFiltered, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$LocalToolConfigsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalToolConfigsTable,
    LocalToolConfig,
    $$LocalToolConfigsTableFilterComposer,
    $$LocalToolConfigsTableOrderingComposer,
    $$LocalToolConfigsTableAnnotationComposer,
    $$LocalToolConfigsTableCreateCompanionBuilder,
    $$LocalToolConfigsTableUpdateCompanionBuilder,
    (
      LocalToolConfig,
      BaseReferences<_$AppDatabase, $LocalToolConfigsTable, LocalToolConfig>
    ),
    LocalToolConfig,
    PrefetchHooks Function()> {
  $$LocalToolConfigsTableTableManager(
      _$AppDatabase db, $LocalToolConfigsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalToolConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalToolConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalToolConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            Value<String> toolType = const Value.absent(),
            Value<String> toolId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> nameTe = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> descriptionTe = const Value.absent(),
            Value<int> minAgeMonths = const Value.absent(),
            Value<int> maxAgeMonths = const Value.absent(),
            Value<String> responseFormat = const Value.absent(),
            Value<String> domainsJson = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<String?> colorHex = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isAgeBracketFiltered = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              LocalToolConfigsCompanion(
            id: id,
            remoteId: remoteId,
            toolType: toolType,
            toolId: toolId,
            name: name,
            nameTe: nameTe,
            description: description,
            descriptionTe: descriptionTe,
            minAgeMonths: minAgeMonths,
            maxAgeMonths: maxAgeMonths,
            responseFormat: responseFormat,
            domainsJson: domainsJson,
            iconName: iconName,
            colorHex: colorHex,
            sortOrder: sortOrder,
            isAgeBracketFiltered: isAgeBracketFiltered,
            isActive: isActive,
            version: version,
            lastSyncedAt: lastSyncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            required String toolType,
            required String toolId,
            required String name,
            required String nameTe,
            Value<String> description = const Value.absent(),
            Value<String> descriptionTe = const Value.absent(),
            Value<int> minAgeMonths = const Value.absent(),
            Value<int> maxAgeMonths = const Value.absent(),
            required String responseFormat,
            Value<String> domainsJson = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<String?> colorHex = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isAgeBracketFiltered = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              LocalToolConfigsCompanion.insert(
            id: id,
            remoteId: remoteId,
            toolType: toolType,
            toolId: toolId,
            name: name,
            nameTe: nameTe,
            description: description,
            descriptionTe: descriptionTe,
            minAgeMonths: minAgeMonths,
            maxAgeMonths: maxAgeMonths,
            responseFormat: responseFormat,
            domainsJson: domainsJson,
            iconName: iconName,
            colorHex: colorHex,
            sortOrder: sortOrder,
            isAgeBracketFiltered: isAgeBracketFiltered,
            isActive: isActive,
            version: version,
            lastSyncedAt: lastSyncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalToolConfigsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalToolConfigsTable,
    LocalToolConfig,
    $$LocalToolConfigsTableFilterComposer,
    $$LocalToolConfigsTableOrderingComposer,
    $$LocalToolConfigsTableAnnotationComposer,
    $$LocalToolConfigsTableCreateCompanionBuilder,
    $$LocalToolConfigsTableUpdateCompanionBuilder,
    (
      LocalToolConfig,
      BaseReferences<_$AppDatabase, $LocalToolConfigsTable, LocalToolConfig>
    ),
    LocalToolConfig,
    PrefetchHooks Function()>;
typedef $$LocalQuestionsTableCreateCompanionBuilder = LocalQuestionsCompanion
    Function({
  Value<int> id,
  Value<int?> remoteId,
  required int toolConfigId,
  required String code,
  required String textEn,
  required String textTe,
  Value<String?> domain,
  Value<String?> domainNameEn,
  Value<String?> domainNameTe,
  Value<String?> category,
  Value<String?> categoryTe,
  Value<int?> ageMonths,
  Value<bool> isCritical,
  Value<bool> isRedFlag,
  Value<bool> isReverseScored,
  Value<String?> unit,
  Value<String?> overrideFormat,
  Value<int> sortOrder,
  Value<bool> isActive,
});
typedef $$LocalQuestionsTableUpdateCompanionBuilder = LocalQuestionsCompanion
    Function({
  Value<int> id,
  Value<int?> remoteId,
  Value<int> toolConfigId,
  Value<String> code,
  Value<String> textEn,
  Value<String> textTe,
  Value<String?> domain,
  Value<String?> domainNameEn,
  Value<String?> domainNameTe,
  Value<String?> category,
  Value<String?> categoryTe,
  Value<int?> ageMonths,
  Value<bool> isCritical,
  Value<bool> isRedFlag,
  Value<bool> isReverseScored,
  Value<String?> unit,
  Value<String?> overrideFormat,
  Value<int> sortOrder,
  Value<bool> isActive,
});

class $$LocalQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalQuestionsTable> {
  $$LocalQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get toolConfigId => $composableBuilder(
      column: $table.toolConfigId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textEn => $composableBuilder(
      column: $table.textEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textTe => $composableBuilder(
      column: $table.textTe, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get domainNameEn => $composableBuilder(
      column: $table.domainNameEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get domainNameTe => $composableBuilder(
      column: $table.domainNameTe, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryTe => $composableBuilder(
      column: $table.categoryTe, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ageMonths => $composableBuilder(
      column: $table.ageMonths, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCritical => $composableBuilder(
      column: $table.isCritical, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRedFlag => $composableBuilder(
      column: $table.isRedFlag, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isReverseScored => $composableBuilder(
      column: $table.isReverseScored,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get overrideFormat => $composableBuilder(
      column: $table.overrideFormat,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$LocalQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalQuestionsTable> {
  $$LocalQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get toolConfigId => $composableBuilder(
      column: $table.toolConfigId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textEn => $composableBuilder(
      column: $table.textEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textTe => $composableBuilder(
      column: $table.textTe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get domainNameEn => $composableBuilder(
      column: $table.domainNameEn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get domainNameTe => $composableBuilder(
      column: $table.domainNameTe,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryTe => $composableBuilder(
      column: $table.categoryTe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ageMonths => $composableBuilder(
      column: $table.ageMonths, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCritical => $composableBuilder(
      column: $table.isCritical, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRedFlag => $composableBuilder(
      column: $table.isRedFlag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isReverseScored => $composableBuilder(
      column: $table.isReverseScored,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get overrideFormat => $composableBuilder(
      column: $table.overrideFormat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$LocalQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalQuestionsTable> {
  $$LocalQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get toolConfigId => $composableBuilder(
      column: $table.toolConfigId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get textEn =>
      $composableBuilder(column: $table.textEn, builder: (column) => column);

  GeneratedColumn<String> get textTe =>
      $composableBuilder(column: $table.textTe, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get domainNameEn => $composableBuilder(
      column: $table.domainNameEn, builder: (column) => column);

  GeneratedColumn<String> get domainNameTe => $composableBuilder(
      column: $table.domainNameTe, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get categoryTe => $composableBuilder(
      column: $table.categoryTe, builder: (column) => column);

  GeneratedColumn<int> get ageMonths =>
      $composableBuilder(column: $table.ageMonths, builder: (column) => column);

  GeneratedColumn<bool> get isCritical => $composableBuilder(
      column: $table.isCritical, builder: (column) => column);

  GeneratedColumn<bool> get isRedFlag =>
      $composableBuilder(column: $table.isRedFlag, builder: (column) => column);

  GeneratedColumn<bool> get isReverseScored => $composableBuilder(
      column: $table.isReverseScored, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get overrideFormat => $composableBuilder(
      column: $table.overrideFormat, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$LocalQuestionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalQuestionsTable,
    LocalQuestion,
    $$LocalQuestionsTableFilterComposer,
    $$LocalQuestionsTableOrderingComposer,
    $$LocalQuestionsTableAnnotationComposer,
    $$LocalQuestionsTableCreateCompanionBuilder,
    $$LocalQuestionsTableUpdateCompanionBuilder,
    (
      LocalQuestion,
      BaseReferences<_$AppDatabase, $LocalQuestionsTable, LocalQuestion>
    ),
    LocalQuestion,
    PrefetchHooks Function()> {
  $$LocalQuestionsTableTableManager(
      _$AppDatabase db, $LocalQuestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            Value<int> toolConfigId = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> textEn = const Value.absent(),
            Value<String> textTe = const Value.absent(),
            Value<String?> domain = const Value.absent(),
            Value<String?> domainNameEn = const Value.absent(),
            Value<String?> domainNameTe = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> categoryTe = const Value.absent(),
            Value<int?> ageMonths = const Value.absent(),
            Value<bool> isCritical = const Value.absent(),
            Value<bool> isRedFlag = const Value.absent(),
            Value<bool> isReverseScored = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<String?> overrideFormat = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              LocalQuestionsCompanion(
            id: id,
            remoteId: remoteId,
            toolConfigId: toolConfigId,
            code: code,
            textEn: textEn,
            textTe: textTe,
            domain: domain,
            domainNameEn: domainNameEn,
            domainNameTe: domainNameTe,
            category: category,
            categoryTe: categoryTe,
            ageMonths: ageMonths,
            isCritical: isCritical,
            isRedFlag: isRedFlag,
            isReverseScored: isReverseScored,
            unit: unit,
            overrideFormat: overrideFormat,
            sortOrder: sortOrder,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            required int toolConfigId,
            required String code,
            required String textEn,
            required String textTe,
            Value<String?> domain = const Value.absent(),
            Value<String?> domainNameEn = const Value.absent(),
            Value<String?> domainNameTe = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> categoryTe = const Value.absent(),
            Value<int?> ageMonths = const Value.absent(),
            Value<bool> isCritical = const Value.absent(),
            Value<bool> isRedFlag = const Value.absent(),
            Value<bool> isReverseScored = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<String?> overrideFormat = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              LocalQuestionsCompanion.insert(
            id: id,
            remoteId: remoteId,
            toolConfigId: toolConfigId,
            code: code,
            textEn: textEn,
            textTe: textTe,
            domain: domain,
            domainNameEn: domainNameEn,
            domainNameTe: domainNameTe,
            category: category,
            categoryTe: categoryTe,
            ageMonths: ageMonths,
            isCritical: isCritical,
            isRedFlag: isRedFlag,
            isReverseScored: isReverseScored,
            unit: unit,
            overrideFormat: overrideFormat,
            sortOrder: sortOrder,
            isActive: isActive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalQuestionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalQuestionsTable,
    LocalQuestion,
    $$LocalQuestionsTableFilterComposer,
    $$LocalQuestionsTableOrderingComposer,
    $$LocalQuestionsTableAnnotationComposer,
    $$LocalQuestionsTableCreateCompanionBuilder,
    $$LocalQuestionsTableUpdateCompanionBuilder,
    (
      LocalQuestion,
      BaseReferences<_$AppDatabase, $LocalQuestionsTable, LocalQuestion>
    ),
    LocalQuestion,
    PrefetchHooks Function()>;
typedef $$LocalResponseOptionsTableCreateCompanionBuilder
    = LocalResponseOptionsCompanion Function({
  Value<int> id,
  Value<int?> remoteId,
  required int toolConfigId,
  Value<int?> questionId,
  required String labelEn,
  required String labelTe,
  required String valueJson,
  Value<String?> colorHex,
  Value<int> sortOrder,
});
typedef $$LocalResponseOptionsTableUpdateCompanionBuilder
    = LocalResponseOptionsCompanion Function({
  Value<int> id,
  Value<int?> remoteId,
  Value<int> toolConfigId,
  Value<int?> questionId,
  Value<String> labelEn,
  Value<String> labelTe,
  Value<String> valueJson,
  Value<String?> colorHex,
  Value<int> sortOrder,
});

class $$LocalResponseOptionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalResponseOptionsTable> {
  $$LocalResponseOptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get toolConfigId => $composableBuilder(
      column: $table.toolConfigId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get labelEn => $composableBuilder(
      column: $table.labelEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get labelTe => $composableBuilder(
      column: $table.labelTe, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get valueJson => $composableBuilder(
      column: $table.valueJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$LocalResponseOptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalResponseOptionsTable> {
  $$LocalResponseOptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get toolConfigId => $composableBuilder(
      column: $table.toolConfigId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get labelEn => $composableBuilder(
      column: $table.labelEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get labelTe => $composableBuilder(
      column: $table.labelTe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get valueJson => $composableBuilder(
      column: $table.valueJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$LocalResponseOptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalResponseOptionsTable> {
  $$LocalResponseOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get toolConfigId => $composableBuilder(
      column: $table.toolConfigId, builder: (column) => column);

  GeneratedColumn<int> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => column);

  GeneratedColumn<String> get labelEn =>
      $composableBuilder(column: $table.labelEn, builder: (column) => column);

  GeneratedColumn<String> get labelTe =>
      $composableBuilder(column: $table.labelTe, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LocalResponseOptionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalResponseOptionsTable,
    LocalResponseOption,
    $$LocalResponseOptionsTableFilterComposer,
    $$LocalResponseOptionsTableOrderingComposer,
    $$LocalResponseOptionsTableAnnotationComposer,
    $$LocalResponseOptionsTableCreateCompanionBuilder,
    $$LocalResponseOptionsTableUpdateCompanionBuilder,
    (
      LocalResponseOption,
      BaseReferences<_$AppDatabase, $LocalResponseOptionsTable,
          LocalResponseOption>
    ),
    LocalResponseOption,
    PrefetchHooks Function()> {
  $$LocalResponseOptionsTableTableManager(
      _$AppDatabase db, $LocalResponseOptionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalResponseOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalResponseOptionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalResponseOptionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            Value<int> toolConfigId = const Value.absent(),
            Value<int?> questionId = const Value.absent(),
            Value<String> labelEn = const Value.absent(),
            Value<String> labelTe = const Value.absent(),
            Value<String> valueJson = const Value.absent(),
            Value<String?> colorHex = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              LocalResponseOptionsCompanion(
            id: id,
            remoteId: remoteId,
            toolConfigId: toolConfigId,
            questionId: questionId,
            labelEn: labelEn,
            labelTe: labelTe,
            valueJson: valueJson,
            colorHex: colorHex,
            sortOrder: sortOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            required int toolConfigId,
            Value<int?> questionId = const Value.absent(),
            required String labelEn,
            required String labelTe,
            required String valueJson,
            Value<String?> colorHex = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              LocalResponseOptionsCompanion.insert(
            id: id,
            remoteId: remoteId,
            toolConfigId: toolConfigId,
            questionId: questionId,
            labelEn: labelEn,
            labelTe: labelTe,
            valueJson: valueJson,
            colorHex: colorHex,
            sortOrder: sortOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalResponseOptionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalResponseOptionsTable,
        LocalResponseOption,
        $$LocalResponseOptionsTableFilterComposer,
        $$LocalResponseOptionsTableOrderingComposer,
        $$LocalResponseOptionsTableAnnotationComposer,
        $$LocalResponseOptionsTableCreateCompanionBuilder,
        $$LocalResponseOptionsTableUpdateCompanionBuilder,
        (
          LocalResponseOption,
          BaseReferences<_$AppDatabase, $LocalResponseOptionsTable,
              LocalResponseOption>
        ),
        LocalResponseOption,
        PrefetchHooks Function()>;
typedef $$LocalScoringRulesTableCreateCompanionBuilder
    = LocalScoringRulesCompanion Function({
  Value<int> id,
  Value<int?> remoteId,
  required int toolConfigId,
  required String ruleType,
  Value<String?> domain,
  required String parameterName,
  required String parameterValueJson,
  Value<String?> description,
});
typedef $$LocalScoringRulesTableUpdateCompanionBuilder
    = LocalScoringRulesCompanion Function({
  Value<int> id,
  Value<int?> remoteId,
  Value<int> toolConfigId,
  Value<String> ruleType,
  Value<String?> domain,
  Value<String> parameterName,
  Value<String> parameterValueJson,
  Value<String?> description,
});

class $$LocalScoringRulesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalScoringRulesTable> {
  $$LocalScoringRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get toolConfigId => $composableBuilder(
      column: $table.toolConfigId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ruleType => $composableBuilder(
      column: $table.ruleType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parameterName => $composableBuilder(
      column: $table.parameterName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parameterValueJson => $composableBuilder(
      column: $table.parameterValueJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));
}

class $$LocalScoringRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalScoringRulesTable> {
  $$LocalScoringRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get toolConfigId => $composableBuilder(
      column: $table.toolConfigId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ruleType => $composableBuilder(
      column: $table.ruleType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parameterName => $composableBuilder(
      column: $table.parameterName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parameterValueJson => $composableBuilder(
      column: $table.parameterValueJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));
}

class $$LocalScoringRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalScoringRulesTable> {
  $$LocalScoringRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get toolConfigId => $composableBuilder(
      column: $table.toolConfigId, builder: (column) => column);

  GeneratedColumn<String> get ruleType =>
      $composableBuilder(column: $table.ruleType, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get parameterName => $composableBuilder(
      column: $table.parameterName, builder: (column) => column);

  GeneratedColumn<String> get parameterValueJson => $composableBuilder(
      column: $table.parameterValueJson, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);
}

class $$LocalScoringRulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalScoringRulesTable,
    LocalScoringRule,
    $$LocalScoringRulesTableFilterComposer,
    $$LocalScoringRulesTableOrderingComposer,
    $$LocalScoringRulesTableAnnotationComposer,
    $$LocalScoringRulesTableCreateCompanionBuilder,
    $$LocalScoringRulesTableUpdateCompanionBuilder,
    (
      LocalScoringRule,
      BaseReferences<_$AppDatabase, $LocalScoringRulesTable, LocalScoringRule>
    ),
    LocalScoringRule,
    PrefetchHooks Function()> {
  $$LocalScoringRulesTableTableManager(
      _$AppDatabase db, $LocalScoringRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalScoringRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalScoringRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalScoringRulesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            Value<int> toolConfigId = const Value.absent(),
            Value<String> ruleType = const Value.absent(),
            Value<String?> domain = const Value.absent(),
            Value<String> parameterName = const Value.absent(),
            Value<String> parameterValueJson = const Value.absent(),
            Value<String?> description = const Value.absent(),
          }) =>
              LocalScoringRulesCompanion(
            id: id,
            remoteId: remoteId,
            toolConfigId: toolConfigId,
            ruleType: ruleType,
            domain: domain,
            parameterName: parameterName,
            parameterValueJson: parameterValueJson,
            description: description,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            required int toolConfigId,
            required String ruleType,
            Value<String?> domain = const Value.absent(),
            required String parameterName,
            required String parameterValueJson,
            Value<String?> description = const Value.absent(),
          }) =>
              LocalScoringRulesCompanion.insert(
            id: id,
            remoteId: remoteId,
            toolConfigId: toolConfigId,
            ruleType: ruleType,
            domain: domain,
            parameterName: parameterName,
            parameterValueJson: parameterValueJson,
            description: description,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalScoringRulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalScoringRulesTable,
    LocalScoringRule,
    $$LocalScoringRulesTableFilterComposer,
    $$LocalScoringRulesTableOrderingComposer,
    $$LocalScoringRulesTableAnnotationComposer,
    $$LocalScoringRulesTableCreateCompanionBuilder,
    $$LocalScoringRulesTableUpdateCompanionBuilder,
    (
      LocalScoringRule,
      BaseReferences<_$AppDatabase, $LocalScoringRulesTable, LocalScoringRule>
    ),
    LocalScoringRule,
    PrefetchHooks Function()>;
typedef $$LocalActivitiesTableCreateCompanionBuilder = LocalActivitiesCompanion
    Function({
  Value<int> id,
  Value<int?> remoteId,
  required String activityCode,
  required String domain,
  required String titleEn,
  required String titleTe,
  required String descriptionEn,
  required String descriptionTe,
  Value<String?> materialsEn,
  Value<String?> materialsTe,
  Value<int> durationMinutes,
  Value<int> minAgeMonths,
  Value<int> maxAgeMonths,
  Value<String> riskLevel,
  Value<bool> hasVideo,
  Value<bool> isActive,
  Value<int> version,
  Value<DateTime?> lastSyncedAt,
});
typedef $$LocalActivitiesTableUpdateCompanionBuilder = LocalActivitiesCompanion
    Function({
  Value<int> id,
  Value<int?> remoteId,
  Value<String> activityCode,
  Value<String> domain,
  Value<String> titleEn,
  Value<String> titleTe,
  Value<String> descriptionEn,
  Value<String> descriptionTe,
  Value<String?> materialsEn,
  Value<String?> materialsTe,
  Value<int> durationMinutes,
  Value<int> minAgeMonths,
  Value<int> maxAgeMonths,
  Value<String> riskLevel,
  Value<bool> hasVideo,
  Value<bool> isActive,
  Value<int> version,
  Value<DateTime?> lastSyncedAt,
});

class $$LocalActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalActivitiesTable> {
  $$LocalActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityCode => $composableBuilder(
      column: $table.activityCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titleEn => $composableBuilder(
      column: $table.titleEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titleTe => $composableBuilder(
      column: $table.titleTe, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descriptionEn => $composableBuilder(
      column: $table.descriptionEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descriptionTe => $composableBuilder(
      column: $table.descriptionTe, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get materialsEn => $composableBuilder(
      column: $table.materialsEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get materialsTe => $composableBuilder(
      column: $table.materialsTe, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minAgeMonths => $composableBuilder(
      column: $table.minAgeMonths, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxAgeMonths => $composableBuilder(
      column: $table.maxAgeMonths, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get riskLevel => $composableBuilder(
      column: $table.riskLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasVideo => $composableBuilder(
      column: $table.hasVideo, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalActivitiesTable> {
  $$LocalActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityCode => $composableBuilder(
      column: $table.activityCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titleEn => $composableBuilder(
      column: $table.titleEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titleTe => $composableBuilder(
      column: $table.titleTe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descriptionEn => $composableBuilder(
      column: $table.descriptionEn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descriptionTe => $composableBuilder(
      column: $table.descriptionTe,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get materialsEn => $composableBuilder(
      column: $table.materialsEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get materialsTe => $composableBuilder(
      column: $table.materialsTe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minAgeMonths => $composableBuilder(
      column: $table.minAgeMonths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxAgeMonths => $composableBuilder(
      column: $table.maxAgeMonths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get riskLevel => $composableBuilder(
      column: $table.riskLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasVideo => $composableBuilder(
      column: $table.hasVideo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalActivitiesTable> {
  $$LocalActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get activityCode => $composableBuilder(
      column: $table.activityCode, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get titleEn =>
      $composableBuilder(column: $table.titleEn, builder: (column) => column);

  GeneratedColumn<String> get titleTe =>
      $composableBuilder(column: $table.titleTe, builder: (column) => column);

  GeneratedColumn<String> get descriptionEn => $composableBuilder(
      column: $table.descriptionEn, builder: (column) => column);

  GeneratedColumn<String> get descriptionTe => $composableBuilder(
      column: $table.descriptionTe, builder: (column) => column);

  GeneratedColumn<String> get materialsEn => $composableBuilder(
      column: $table.materialsEn, builder: (column) => column);

  GeneratedColumn<String> get materialsTe => $composableBuilder(
      column: $table.materialsTe, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes, builder: (column) => column);

  GeneratedColumn<int> get minAgeMonths => $composableBuilder(
      column: $table.minAgeMonths, builder: (column) => column);

  GeneratedColumn<int> get maxAgeMonths => $composableBuilder(
      column: $table.maxAgeMonths, builder: (column) => column);

  GeneratedColumn<String> get riskLevel =>
      $composableBuilder(column: $table.riskLevel, builder: (column) => column);

  GeneratedColumn<bool> get hasVideo =>
      $composableBuilder(column: $table.hasVideo, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$LocalActivitiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalActivitiesTable,
    LocalActivity,
    $$LocalActivitiesTableFilterComposer,
    $$LocalActivitiesTableOrderingComposer,
    $$LocalActivitiesTableAnnotationComposer,
    $$LocalActivitiesTableCreateCompanionBuilder,
    $$LocalActivitiesTableUpdateCompanionBuilder,
    (
      LocalActivity,
      BaseReferences<_$AppDatabase, $LocalActivitiesTable, LocalActivity>
    ),
    LocalActivity,
    PrefetchHooks Function()> {
  $$LocalActivitiesTableTableManager(
      _$AppDatabase db, $LocalActivitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            Value<String> activityCode = const Value.absent(),
            Value<String> domain = const Value.absent(),
            Value<String> titleEn = const Value.absent(),
            Value<String> titleTe = const Value.absent(),
            Value<String> descriptionEn = const Value.absent(),
            Value<String> descriptionTe = const Value.absent(),
            Value<String?> materialsEn = const Value.absent(),
            Value<String?> materialsTe = const Value.absent(),
            Value<int> durationMinutes = const Value.absent(),
            Value<int> minAgeMonths = const Value.absent(),
            Value<int> maxAgeMonths = const Value.absent(),
            Value<String> riskLevel = const Value.absent(),
            Value<bool> hasVideo = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              LocalActivitiesCompanion(
            id: id,
            remoteId: remoteId,
            activityCode: activityCode,
            domain: domain,
            titleEn: titleEn,
            titleTe: titleTe,
            descriptionEn: descriptionEn,
            descriptionTe: descriptionTe,
            materialsEn: materialsEn,
            materialsTe: materialsTe,
            durationMinutes: durationMinutes,
            minAgeMonths: minAgeMonths,
            maxAgeMonths: maxAgeMonths,
            riskLevel: riskLevel,
            hasVideo: hasVideo,
            isActive: isActive,
            version: version,
            lastSyncedAt: lastSyncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            required String activityCode,
            required String domain,
            required String titleEn,
            required String titleTe,
            required String descriptionEn,
            required String descriptionTe,
            Value<String?> materialsEn = const Value.absent(),
            Value<String?> materialsTe = const Value.absent(),
            Value<int> durationMinutes = const Value.absent(),
            Value<int> minAgeMonths = const Value.absent(),
            Value<int> maxAgeMonths = const Value.absent(),
            Value<String> riskLevel = const Value.absent(),
            Value<bool> hasVideo = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              LocalActivitiesCompanion.insert(
            id: id,
            remoteId: remoteId,
            activityCode: activityCode,
            domain: domain,
            titleEn: titleEn,
            titleTe: titleTe,
            descriptionEn: descriptionEn,
            descriptionTe: descriptionTe,
            materialsEn: materialsEn,
            materialsTe: materialsTe,
            durationMinutes: durationMinutes,
            minAgeMonths: minAgeMonths,
            maxAgeMonths: maxAgeMonths,
            riskLevel: riskLevel,
            hasVideo: hasVideo,
            isActive: isActive,
            version: version,
            lastSyncedAt: lastSyncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalActivitiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalActivitiesTable,
    LocalActivity,
    $$LocalActivitiesTableFilterComposer,
    $$LocalActivitiesTableOrderingComposer,
    $$LocalActivitiesTableAnnotationComposer,
    $$LocalActivitiesTableCreateCompanionBuilder,
    $$LocalActivitiesTableUpdateCompanionBuilder,
    (
      LocalActivity,
      BaseReferences<_$AppDatabase, $LocalActivitiesTable, LocalActivity>
    ),
    LocalActivity,
    PrefetchHooks Function()>;
typedef $$LocalReferralsTableCreateCompanionBuilder = LocalReferralsCompanion
    Function({
  Value<int> id,
  Value<int?> childRemoteId,
  Value<int?> screeningResultLocalId,
  Value<int?> screeningResultRemoteId,
  Value<bool> referralTriggered,
  Value<String?> referralType,
  Value<String?> referralReason,
  Value<String> referralStatus,
  Value<String?> referredBy,
  Value<String?> referredDate,
  Value<String?> completedDate,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> syncedAt,
});
typedef $$LocalReferralsTableUpdateCompanionBuilder = LocalReferralsCompanion
    Function({
  Value<int> id,
  Value<int?> childRemoteId,
  Value<int?> screeningResultLocalId,
  Value<int?> screeningResultRemoteId,
  Value<bool> referralTriggered,
  Value<String?> referralType,
  Value<String?> referralReason,
  Value<String> referralStatus,
  Value<String?> referredBy,
  Value<String?> referredDate,
  Value<String?> completedDate,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> syncedAt,
});

class $$LocalReferralsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalReferralsTable> {
  $$LocalReferralsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get screeningResultLocalId => $composableBuilder(
      column: $table.screeningResultLocalId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get screeningResultRemoteId => $composableBuilder(
      column: $table.screeningResultRemoteId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get referralTriggered => $composableBuilder(
      column: $table.referralTriggered,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referralType => $composableBuilder(
      column: $table.referralType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referralReason => $composableBuilder(
      column: $table.referralReason,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referralStatus => $composableBuilder(
      column: $table.referralStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referredBy => $composableBuilder(
      column: $table.referredBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referredDate => $composableBuilder(
      column: $table.referredDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get completedDate => $composableBuilder(
      column: $table.completedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalReferralsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalReferralsTable> {
  $$LocalReferralsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get screeningResultLocalId => $composableBuilder(
      column: $table.screeningResultLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get screeningResultRemoteId => $composableBuilder(
      column: $table.screeningResultRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get referralTriggered => $composableBuilder(
      column: $table.referralTriggered,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referralType => $composableBuilder(
      column: $table.referralType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referralReason => $composableBuilder(
      column: $table.referralReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referralStatus => $composableBuilder(
      column: $table.referralStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referredBy => $composableBuilder(
      column: $table.referredBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referredDate => $composableBuilder(
      column: $table.referredDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get completedDate => $composableBuilder(
      column: $table.completedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalReferralsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalReferralsTable> {
  $$LocalReferralsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId, builder: (column) => column);

  GeneratedColumn<int> get screeningResultLocalId => $composableBuilder(
      column: $table.screeningResultLocalId, builder: (column) => column);

  GeneratedColumn<int> get screeningResultRemoteId => $composableBuilder(
      column: $table.screeningResultRemoteId, builder: (column) => column);

  GeneratedColumn<bool> get referralTriggered => $composableBuilder(
      column: $table.referralTriggered, builder: (column) => column);

  GeneratedColumn<String> get referralType => $composableBuilder(
      column: $table.referralType, builder: (column) => column);

  GeneratedColumn<String> get referralReason => $composableBuilder(
      column: $table.referralReason, builder: (column) => column);

  GeneratedColumn<String> get referralStatus => $composableBuilder(
      column: $table.referralStatus, builder: (column) => column);

  GeneratedColumn<String> get referredBy => $composableBuilder(
      column: $table.referredBy, builder: (column) => column);

  GeneratedColumn<String> get referredDate => $composableBuilder(
      column: $table.referredDate, builder: (column) => column);

  GeneratedColumn<String> get completedDate => $composableBuilder(
      column: $table.completedDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$LocalReferralsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalReferralsTable,
    LocalReferral,
    $$LocalReferralsTableFilterComposer,
    $$LocalReferralsTableOrderingComposer,
    $$LocalReferralsTableAnnotationComposer,
    $$LocalReferralsTableCreateCompanionBuilder,
    $$LocalReferralsTableUpdateCompanionBuilder,
    (
      LocalReferral,
      BaseReferences<_$AppDatabase, $LocalReferralsTable, LocalReferral>
    ),
    LocalReferral,
    PrefetchHooks Function()> {
  $$LocalReferralsTableTableManager(
      _$AppDatabase db, $LocalReferralsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalReferralsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalReferralsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalReferralsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> childRemoteId = const Value.absent(),
            Value<int?> screeningResultLocalId = const Value.absent(),
            Value<int?> screeningResultRemoteId = const Value.absent(),
            Value<bool> referralTriggered = const Value.absent(),
            Value<String?> referralType = const Value.absent(),
            Value<String?> referralReason = const Value.absent(),
            Value<String> referralStatus = const Value.absent(),
            Value<String?> referredBy = const Value.absent(),
            Value<String?> referredDate = const Value.absent(),
            Value<String?> completedDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalReferralsCompanion(
            id: id,
            childRemoteId: childRemoteId,
            screeningResultLocalId: screeningResultLocalId,
            screeningResultRemoteId: screeningResultRemoteId,
            referralTriggered: referralTriggered,
            referralType: referralType,
            referralReason: referralReason,
            referralStatus: referralStatus,
            referredBy: referredBy,
            referredDate: referredDate,
            completedDate: completedDate,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncedAt: syncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> childRemoteId = const Value.absent(),
            Value<int?> screeningResultLocalId = const Value.absent(),
            Value<int?> screeningResultRemoteId = const Value.absent(),
            Value<bool> referralTriggered = const Value.absent(),
            Value<String?> referralType = const Value.absent(),
            Value<String?> referralReason = const Value.absent(),
            Value<String> referralStatus = const Value.absent(),
            Value<String?> referredBy = const Value.absent(),
            Value<String?> referredDate = const Value.absent(),
            Value<String?> completedDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalReferralsCompanion.insert(
            id: id,
            childRemoteId: childRemoteId,
            screeningResultLocalId: screeningResultLocalId,
            screeningResultRemoteId: screeningResultRemoteId,
            referralTriggered: referralTriggered,
            referralType: referralType,
            referralReason: referralReason,
            referralStatus: referralStatus,
            referredBy: referredBy,
            referredDate: referredDate,
            completedDate: completedDate,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncedAt: syncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalReferralsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalReferralsTable,
    LocalReferral,
    $$LocalReferralsTableFilterComposer,
    $$LocalReferralsTableOrderingComposer,
    $$LocalReferralsTableAnnotationComposer,
    $$LocalReferralsTableCreateCompanionBuilder,
    $$LocalReferralsTableUpdateCompanionBuilder,
    (
      LocalReferral,
      BaseReferences<_$AppDatabase, $LocalReferralsTable, LocalReferral>
    ),
    LocalReferral,
    PrefetchHooks Function()>;
typedef $$LocalNutritionAssessmentsTableCreateCompanionBuilder
    = LocalNutritionAssessmentsCompanion Function({
  Value<int> id,
  Value<int?> childRemoteId,
  Value<int?> sessionLocalId,
  Value<double?> heightCm,
  Value<double?> weightKg,
  Value<double?> muacCm,
  Value<bool> underweight,
  Value<bool> stunting,
  Value<bool> wasting,
  Value<bool> anemia,
  Value<int> nutritionScore,
  Value<String> nutritionRisk,
  Value<String?> assessedDate,
  Value<DateTime> createdAt,
  Value<DateTime?> syncedAt,
});
typedef $$LocalNutritionAssessmentsTableUpdateCompanionBuilder
    = LocalNutritionAssessmentsCompanion Function({
  Value<int> id,
  Value<int?> childRemoteId,
  Value<int?> sessionLocalId,
  Value<double?> heightCm,
  Value<double?> weightKg,
  Value<double?> muacCm,
  Value<bool> underweight,
  Value<bool> stunting,
  Value<bool> wasting,
  Value<bool> anemia,
  Value<int> nutritionScore,
  Value<String> nutritionRisk,
  Value<String?> assessedDate,
  Value<DateTime> createdAt,
  Value<DateTime?> syncedAt,
});

class $$LocalNutritionAssessmentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalNutritionAssessmentsTable> {
  $$LocalNutritionAssessmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionLocalId => $composableBuilder(
      column: $table.sessionLocalId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get muacCm => $composableBuilder(
      column: $table.muacCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get underweight => $composableBuilder(
      column: $table.underweight, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get stunting => $composableBuilder(
      column: $table.stunting, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wasting => $composableBuilder(
      column: $table.wasting, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get anemia => $composableBuilder(
      column: $table.anemia, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nutritionScore => $composableBuilder(
      column: $table.nutritionScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nutritionRisk => $composableBuilder(
      column: $table.nutritionRisk, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assessedDate => $composableBuilder(
      column: $table.assessedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalNutritionAssessmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalNutritionAssessmentsTable> {
  $$LocalNutritionAssessmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionLocalId => $composableBuilder(
      column: $table.sessionLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get muacCm => $composableBuilder(
      column: $table.muacCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get underweight => $composableBuilder(
      column: $table.underweight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get stunting => $composableBuilder(
      column: $table.stunting, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wasting => $composableBuilder(
      column: $table.wasting, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get anemia => $composableBuilder(
      column: $table.anemia, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nutritionScore => $composableBuilder(
      column: $table.nutritionScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nutritionRisk => $composableBuilder(
      column: $table.nutritionRisk,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assessedDate => $composableBuilder(
      column: $table.assessedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalNutritionAssessmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalNutritionAssessmentsTable> {
  $$LocalNutritionAssessmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId, builder: (column) => column);

  GeneratedColumn<int> get sessionLocalId => $composableBuilder(
      column: $table.sessionLocalId, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get muacCm =>
      $composableBuilder(column: $table.muacCm, builder: (column) => column);

  GeneratedColumn<bool> get underweight => $composableBuilder(
      column: $table.underweight, builder: (column) => column);

  GeneratedColumn<bool> get stunting =>
      $composableBuilder(column: $table.stunting, builder: (column) => column);

  GeneratedColumn<bool> get wasting =>
      $composableBuilder(column: $table.wasting, builder: (column) => column);

  GeneratedColumn<bool> get anemia =>
      $composableBuilder(column: $table.anemia, builder: (column) => column);

  GeneratedColumn<int> get nutritionScore => $composableBuilder(
      column: $table.nutritionScore, builder: (column) => column);

  GeneratedColumn<String> get nutritionRisk => $composableBuilder(
      column: $table.nutritionRisk, builder: (column) => column);

  GeneratedColumn<String> get assessedDate => $composableBuilder(
      column: $table.assessedDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$LocalNutritionAssessmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalNutritionAssessmentsTable,
    LocalNutritionAssessment,
    $$LocalNutritionAssessmentsTableFilterComposer,
    $$LocalNutritionAssessmentsTableOrderingComposer,
    $$LocalNutritionAssessmentsTableAnnotationComposer,
    $$LocalNutritionAssessmentsTableCreateCompanionBuilder,
    $$LocalNutritionAssessmentsTableUpdateCompanionBuilder,
    (
      LocalNutritionAssessment,
      BaseReferences<_$AppDatabase, $LocalNutritionAssessmentsTable,
          LocalNutritionAssessment>
    ),
    LocalNutritionAssessment,
    PrefetchHooks Function()> {
  $$LocalNutritionAssessmentsTableTableManager(
      _$AppDatabase db, $LocalNutritionAssessmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalNutritionAssessmentsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalNutritionAssessmentsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalNutritionAssessmentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> childRemoteId = const Value.absent(),
            Value<int?> sessionLocalId = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<double?> muacCm = const Value.absent(),
            Value<bool> underweight = const Value.absent(),
            Value<bool> stunting = const Value.absent(),
            Value<bool> wasting = const Value.absent(),
            Value<bool> anemia = const Value.absent(),
            Value<int> nutritionScore = const Value.absent(),
            Value<String> nutritionRisk = const Value.absent(),
            Value<String?> assessedDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalNutritionAssessmentsCompanion(
            id: id,
            childRemoteId: childRemoteId,
            sessionLocalId: sessionLocalId,
            heightCm: heightCm,
            weightKg: weightKg,
            muacCm: muacCm,
            underweight: underweight,
            stunting: stunting,
            wasting: wasting,
            anemia: anemia,
            nutritionScore: nutritionScore,
            nutritionRisk: nutritionRisk,
            assessedDate: assessedDate,
            createdAt: createdAt,
            syncedAt: syncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> childRemoteId = const Value.absent(),
            Value<int?> sessionLocalId = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<double?> muacCm = const Value.absent(),
            Value<bool> underweight = const Value.absent(),
            Value<bool> stunting = const Value.absent(),
            Value<bool> wasting = const Value.absent(),
            Value<bool> anemia = const Value.absent(),
            Value<int> nutritionScore = const Value.absent(),
            Value<String> nutritionRisk = const Value.absent(),
            Value<String?> assessedDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalNutritionAssessmentsCompanion.insert(
            id: id,
            childRemoteId: childRemoteId,
            sessionLocalId: sessionLocalId,
            heightCm: heightCm,
            weightKg: weightKg,
            muacCm: muacCm,
            underweight: underweight,
            stunting: stunting,
            wasting: wasting,
            anemia: anemia,
            nutritionScore: nutritionScore,
            nutritionRisk: nutritionRisk,
            assessedDate: assessedDate,
            createdAt: createdAt,
            syncedAt: syncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalNutritionAssessmentsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalNutritionAssessmentsTable,
        LocalNutritionAssessment,
        $$LocalNutritionAssessmentsTableFilterComposer,
        $$LocalNutritionAssessmentsTableOrderingComposer,
        $$LocalNutritionAssessmentsTableAnnotationComposer,
        $$LocalNutritionAssessmentsTableCreateCompanionBuilder,
        $$LocalNutritionAssessmentsTableUpdateCompanionBuilder,
        (
          LocalNutritionAssessment,
          BaseReferences<_$AppDatabase, $LocalNutritionAssessmentsTable,
              LocalNutritionAssessment>
        ),
        LocalNutritionAssessment,
        PrefetchHooks Function()>;
typedef $$LocalEnvironmentAssessmentsTableCreateCompanionBuilder
    = LocalEnvironmentAssessmentsCompanion Function({
  Value<int> id,
  Value<int?> childRemoteId,
  Value<int?> sessionLocalId,
  Value<int?> parentChildInteractionScore,
  Value<int?> parentMentalHealthScore,
  Value<int?> homeStimulationScore,
  Value<bool> playMaterials,
  Value<String> caregiverEngagement,
  Value<String> languageExposure,
  Value<bool> safeWater,
  Value<bool> toiletFacility,
  Value<DateTime> createdAt,
  Value<DateTime?> syncedAt,
});
typedef $$LocalEnvironmentAssessmentsTableUpdateCompanionBuilder
    = LocalEnvironmentAssessmentsCompanion Function({
  Value<int> id,
  Value<int?> childRemoteId,
  Value<int?> sessionLocalId,
  Value<int?> parentChildInteractionScore,
  Value<int?> parentMentalHealthScore,
  Value<int?> homeStimulationScore,
  Value<bool> playMaterials,
  Value<String> caregiverEngagement,
  Value<String> languageExposure,
  Value<bool> safeWater,
  Value<bool> toiletFacility,
  Value<DateTime> createdAt,
  Value<DateTime?> syncedAt,
});

class $$LocalEnvironmentAssessmentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalEnvironmentAssessmentsTable> {
  $$LocalEnvironmentAssessmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionLocalId => $composableBuilder(
      column: $table.sessionLocalId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parentChildInteractionScore => $composableBuilder(
      column: $table.parentChildInteractionScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parentMentalHealthScore => $composableBuilder(
      column: $table.parentMentalHealthScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get homeStimulationScore => $composableBuilder(
      column: $table.homeStimulationScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get playMaterials => $composableBuilder(
      column: $table.playMaterials, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caregiverEngagement => $composableBuilder(
      column: $table.caregiverEngagement,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get languageExposure => $composableBuilder(
      column: $table.languageExposure,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get safeWater => $composableBuilder(
      column: $table.safeWater, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get toiletFacility => $composableBuilder(
      column: $table.toiletFacility,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalEnvironmentAssessmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalEnvironmentAssessmentsTable> {
  $$LocalEnvironmentAssessmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionLocalId => $composableBuilder(
      column: $table.sessionLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parentChildInteractionScore => $composableBuilder(
      column: $table.parentChildInteractionScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parentMentalHealthScore => $composableBuilder(
      column: $table.parentMentalHealthScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get homeStimulationScore => $composableBuilder(
      column: $table.homeStimulationScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get playMaterials => $composableBuilder(
      column: $table.playMaterials,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caregiverEngagement => $composableBuilder(
      column: $table.caregiverEngagement,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get languageExposure => $composableBuilder(
      column: $table.languageExposure,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get safeWater => $composableBuilder(
      column: $table.safeWater, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get toiletFacility => $composableBuilder(
      column: $table.toiletFacility,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalEnvironmentAssessmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalEnvironmentAssessmentsTable> {
  $$LocalEnvironmentAssessmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId, builder: (column) => column);

  GeneratedColumn<int> get sessionLocalId => $composableBuilder(
      column: $table.sessionLocalId, builder: (column) => column);

  GeneratedColumn<int> get parentChildInteractionScore => $composableBuilder(
      column: $table.parentChildInteractionScore, builder: (column) => column);

  GeneratedColumn<int> get parentMentalHealthScore => $composableBuilder(
      column: $table.parentMentalHealthScore, builder: (column) => column);

  GeneratedColumn<int> get homeStimulationScore => $composableBuilder(
      column: $table.homeStimulationScore, builder: (column) => column);

  GeneratedColumn<bool> get playMaterials => $composableBuilder(
      column: $table.playMaterials, builder: (column) => column);

  GeneratedColumn<String> get caregiverEngagement => $composableBuilder(
      column: $table.caregiverEngagement, builder: (column) => column);

  GeneratedColumn<String> get languageExposure => $composableBuilder(
      column: $table.languageExposure, builder: (column) => column);

  GeneratedColumn<bool> get safeWater =>
      $composableBuilder(column: $table.safeWater, builder: (column) => column);

  GeneratedColumn<bool> get toiletFacility => $composableBuilder(
      column: $table.toiletFacility, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$LocalEnvironmentAssessmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalEnvironmentAssessmentsTable,
    LocalEnvironmentAssessment,
    $$LocalEnvironmentAssessmentsTableFilterComposer,
    $$LocalEnvironmentAssessmentsTableOrderingComposer,
    $$LocalEnvironmentAssessmentsTableAnnotationComposer,
    $$LocalEnvironmentAssessmentsTableCreateCompanionBuilder,
    $$LocalEnvironmentAssessmentsTableUpdateCompanionBuilder,
    (
      LocalEnvironmentAssessment,
      BaseReferences<_$AppDatabase, $LocalEnvironmentAssessmentsTable,
          LocalEnvironmentAssessment>
    ),
    LocalEnvironmentAssessment,
    PrefetchHooks Function()> {
  $$LocalEnvironmentAssessmentsTableTableManager(
      _$AppDatabase db, $LocalEnvironmentAssessmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalEnvironmentAssessmentsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalEnvironmentAssessmentsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalEnvironmentAssessmentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> childRemoteId = const Value.absent(),
            Value<int?> sessionLocalId = const Value.absent(),
            Value<int?> parentChildInteractionScore = const Value.absent(),
            Value<int?> parentMentalHealthScore = const Value.absent(),
            Value<int?> homeStimulationScore = const Value.absent(),
            Value<bool> playMaterials = const Value.absent(),
            Value<String> caregiverEngagement = const Value.absent(),
            Value<String> languageExposure = const Value.absent(),
            Value<bool> safeWater = const Value.absent(),
            Value<bool> toiletFacility = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalEnvironmentAssessmentsCompanion(
            id: id,
            childRemoteId: childRemoteId,
            sessionLocalId: sessionLocalId,
            parentChildInteractionScore: parentChildInteractionScore,
            parentMentalHealthScore: parentMentalHealthScore,
            homeStimulationScore: homeStimulationScore,
            playMaterials: playMaterials,
            caregiverEngagement: caregiverEngagement,
            languageExposure: languageExposure,
            safeWater: safeWater,
            toiletFacility: toiletFacility,
            createdAt: createdAt,
            syncedAt: syncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> childRemoteId = const Value.absent(),
            Value<int?> sessionLocalId = const Value.absent(),
            Value<int?> parentChildInteractionScore = const Value.absent(),
            Value<int?> parentMentalHealthScore = const Value.absent(),
            Value<int?> homeStimulationScore = const Value.absent(),
            Value<bool> playMaterials = const Value.absent(),
            Value<String> caregiverEngagement = const Value.absent(),
            Value<String> languageExposure = const Value.absent(),
            Value<bool> safeWater = const Value.absent(),
            Value<bool> toiletFacility = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalEnvironmentAssessmentsCompanion.insert(
            id: id,
            childRemoteId: childRemoteId,
            sessionLocalId: sessionLocalId,
            parentChildInteractionScore: parentChildInteractionScore,
            parentMentalHealthScore: parentMentalHealthScore,
            homeStimulationScore: homeStimulationScore,
            playMaterials: playMaterials,
            caregiverEngagement: caregiverEngagement,
            languageExposure: languageExposure,
            safeWater: safeWater,
            toiletFacility: toiletFacility,
            createdAt: createdAt,
            syncedAt: syncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalEnvironmentAssessmentsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalEnvironmentAssessmentsTable,
        LocalEnvironmentAssessment,
        $$LocalEnvironmentAssessmentsTableFilterComposer,
        $$LocalEnvironmentAssessmentsTableOrderingComposer,
        $$LocalEnvironmentAssessmentsTableAnnotationComposer,
        $$LocalEnvironmentAssessmentsTableCreateCompanionBuilder,
        $$LocalEnvironmentAssessmentsTableUpdateCompanionBuilder,
        (
          LocalEnvironmentAssessment,
          BaseReferences<_$AppDatabase, $LocalEnvironmentAssessmentsTable,
              LocalEnvironmentAssessment>
        ),
        LocalEnvironmentAssessment,
        PrefetchHooks Function()>;
typedef $$LocalInterventionFollowupsTableCreateCompanionBuilder
    = LocalInterventionFollowupsCompanion Function({
  Value<int> id,
  Value<int?> childRemoteId,
  Value<int?> screeningResultLocalId,
  Value<bool> interventionPlanGenerated,
  Value<int> homeActivitiesAssigned,
  Value<bool> followupConducted,
  Value<String?> followupDate,
  Value<String?> nextFollowupDate,
  Value<String?> improvementStatus,
  Value<int> reductionInDelayMonths,
  Value<bool> domainImprovement,
  Value<String> autismRiskChange,
  Value<bool> exitHighRisk,
  Value<String?> notes,
  Value<String?> createdBy,
  Value<DateTime> createdAt,
  Value<DateTime?> syncedAt,
});
typedef $$LocalInterventionFollowupsTableUpdateCompanionBuilder
    = LocalInterventionFollowupsCompanion Function({
  Value<int> id,
  Value<int?> childRemoteId,
  Value<int?> screeningResultLocalId,
  Value<bool> interventionPlanGenerated,
  Value<int> homeActivitiesAssigned,
  Value<bool> followupConducted,
  Value<String?> followupDate,
  Value<String?> nextFollowupDate,
  Value<String?> improvementStatus,
  Value<int> reductionInDelayMonths,
  Value<bool> domainImprovement,
  Value<String> autismRiskChange,
  Value<bool> exitHighRisk,
  Value<String?> notes,
  Value<String?> createdBy,
  Value<DateTime> createdAt,
  Value<DateTime?> syncedAt,
});

class $$LocalInterventionFollowupsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalInterventionFollowupsTable> {
  $$LocalInterventionFollowupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get screeningResultLocalId => $composableBuilder(
      column: $table.screeningResultLocalId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get interventionPlanGenerated => $composableBuilder(
      column: $table.interventionPlanGenerated,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get homeActivitiesAssigned => $composableBuilder(
      column: $table.homeActivitiesAssigned,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get followupConducted => $composableBuilder(
      column: $table.followupConducted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get followupDate => $composableBuilder(
      column: $table.followupDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nextFollowupDate => $composableBuilder(
      column: $table.nextFollowupDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get improvementStatus => $composableBuilder(
      column: $table.improvementStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reductionInDelayMonths => $composableBuilder(
      column: $table.reductionInDelayMonths,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get domainImprovement => $composableBuilder(
      column: $table.domainImprovement,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get autismRiskChange => $composableBuilder(
      column: $table.autismRiskChange,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get exitHighRisk => $composableBuilder(
      column: $table.exitHighRisk, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalInterventionFollowupsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalInterventionFollowupsTable> {
  $$LocalInterventionFollowupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get screeningResultLocalId => $composableBuilder(
      column: $table.screeningResultLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get interventionPlanGenerated => $composableBuilder(
      column: $table.interventionPlanGenerated,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get homeActivitiesAssigned => $composableBuilder(
      column: $table.homeActivitiesAssigned,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get followupConducted => $composableBuilder(
      column: $table.followupConducted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get followupDate => $composableBuilder(
      column: $table.followupDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nextFollowupDate => $composableBuilder(
      column: $table.nextFollowupDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get improvementStatus => $composableBuilder(
      column: $table.improvementStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reductionInDelayMonths => $composableBuilder(
      column: $table.reductionInDelayMonths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get domainImprovement => $composableBuilder(
      column: $table.domainImprovement,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get autismRiskChange => $composableBuilder(
      column: $table.autismRiskChange,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get exitHighRisk => $composableBuilder(
      column: $table.exitHighRisk,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalInterventionFollowupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalInterventionFollowupsTable> {
  $$LocalInterventionFollowupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId, builder: (column) => column);

  GeneratedColumn<int> get screeningResultLocalId => $composableBuilder(
      column: $table.screeningResultLocalId, builder: (column) => column);

  GeneratedColumn<bool> get interventionPlanGenerated => $composableBuilder(
      column: $table.interventionPlanGenerated, builder: (column) => column);

  GeneratedColumn<int> get homeActivitiesAssigned => $composableBuilder(
      column: $table.homeActivitiesAssigned, builder: (column) => column);

  GeneratedColumn<bool> get followupConducted => $composableBuilder(
      column: $table.followupConducted, builder: (column) => column);

  GeneratedColumn<String> get followupDate => $composableBuilder(
      column: $table.followupDate, builder: (column) => column);

  GeneratedColumn<String> get nextFollowupDate => $composableBuilder(
      column: $table.nextFollowupDate, builder: (column) => column);

  GeneratedColumn<String> get improvementStatus => $composableBuilder(
      column: $table.improvementStatus, builder: (column) => column);

  GeneratedColumn<int> get reductionInDelayMonths => $composableBuilder(
      column: $table.reductionInDelayMonths, builder: (column) => column);

  GeneratedColumn<bool> get domainImprovement => $composableBuilder(
      column: $table.domainImprovement, builder: (column) => column);

  GeneratedColumn<String> get autismRiskChange => $composableBuilder(
      column: $table.autismRiskChange, builder: (column) => column);

  GeneratedColumn<bool> get exitHighRisk => $composableBuilder(
      column: $table.exitHighRisk, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$LocalInterventionFollowupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalInterventionFollowupsTable,
    LocalInterventionFollowup,
    $$LocalInterventionFollowupsTableFilterComposer,
    $$LocalInterventionFollowupsTableOrderingComposer,
    $$LocalInterventionFollowupsTableAnnotationComposer,
    $$LocalInterventionFollowupsTableCreateCompanionBuilder,
    $$LocalInterventionFollowupsTableUpdateCompanionBuilder,
    (
      LocalInterventionFollowup,
      BaseReferences<_$AppDatabase, $LocalInterventionFollowupsTable,
          LocalInterventionFollowup>
    ),
    LocalInterventionFollowup,
    PrefetchHooks Function()> {
  $$LocalInterventionFollowupsTableTableManager(
      _$AppDatabase db, $LocalInterventionFollowupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalInterventionFollowupsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalInterventionFollowupsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalInterventionFollowupsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> childRemoteId = const Value.absent(),
            Value<int?> screeningResultLocalId = const Value.absent(),
            Value<bool> interventionPlanGenerated = const Value.absent(),
            Value<int> homeActivitiesAssigned = const Value.absent(),
            Value<bool> followupConducted = const Value.absent(),
            Value<String?> followupDate = const Value.absent(),
            Value<String?> nextFollowupDate = const Value.absent(),
            Value<String?> improvementStatus = const Value.absent(),
            Value<int> reductionInDelayMonths = const Value.absent(),
            Value<bool> domainImprovement = const Value.absent(),
            Value<String> autismRiskChange = const Value.absent(),
            Value<bool> exitHighRisk = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalInterventionFollowupsCompanion(
            id: id,
            childRemoteId: childRemoteId,
            screeningResultLocalId: screeningResultLocalId,
            interventionPlanGenerated: interventionPlanGenerated,
            homeActivitiesAssigned: homeActivitiesAssigned,
            followupConducted: followupConducted,
            followupDate: followupDate,
            nextFollowupDate: nextFollowupDate,
            improvementStatus: improvementStatus,
            reductionInDelayMonths: reductionInDelayMonths,
            domainImprovement: domainImprovement,
            autismRiskChange: autismRiskChange,
            exitHighRisk: exitHighRisk,
            notes: notes,
            createdBy: createdBy,
            createdAt: createdAt,
            syncedAt: syncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> childRemoteId = const Value.absent(),
            Value<int?> screeningResultLocalId = const Value.absent(),
            Value<bool> interventionPlanGenerated = const Value.absent(),
            Value<int> homeActivitiesAssigned = const Value.absent(),
            Value<bool> followupConducted = const Value.absent(),
            Value<String?> followupDate = const Value.absent(),
            Value<String?> nextFollowupDate = const Value.absent(),
            Value<String?> improvementStatus = const Value.absent(),
            Value<int> reductionInDelayMonths = const Value.absent(),
            Value<bool> domainImprovement = const Value.absent(),
            Value<String> autismRiskChange = const Value.absent(),
            Value<bool> exitHighRisk = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalInterventionFollowupsCompanion.insert(
            id: id,
            childRemoteId: childRemoteId,
            screeningResultLocalId: screeningResultLocalId,
            interventionPlanGenerated: interventionPlanGenerated,
            homeActivitiesAssigned: homeActivitiesAssigned,
            followupConducted: followupConducted,
            followupDate: followupDate,
            nextFollowupDate: nextFollowupDate,
            improvementStatus: improvementStatus,
            reductionInDelayMonths: reductionInDelayMonths,
            domainImprovement: domainImprovement,
            autismRiskChange: autismRiskChange,
            exitHighRisk: exitHighRisk,
            notes: notes,
            createdBy: createdBy,
            createdAt: createdAt,
            syncedAt: syncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalInterventionFollowupsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalInterventionFollowupsTable,
        LocalInterventionFollowup,
        $$LocalInterventionFollowupsTableFilterComposer,
        $$LocalInterventionFollowupsTableOrderingComposer,
        $$LocalInterventionFollowupsTableAnnotationComposer,
        $$LocalInterventionFollowupsTableCreateCompanionBuilder,
        $$LocalInterventionFollowupsTableUpdateCompanionBuilder,
        (
          LocalInterventionFollowup,
          BaseReferences<_$AppDatabase, $LocalInterventionFollowupsTable,
              LocalInterventionFollowup>
        ),
        LocalInterventionFollowup,
        PrefetchHooks Function()>;
typedef $$LocalConsentsTableCreateCompanionBuilder = LocalConsentsCompanion
    Function({
  Value<int> id,
  Value<int?> remoteId,
  required int childRemoteId,
  required String guardianName,
  required String guardianRelation,
  Value<String?> guardianPhone,
  required String consentPurpose,
  Value<bool> consentGiven,
  Value<String> consentVersion,
  Value<String?> digitalSignatureBase64,
  required String collectedByUserId,
  required String collectedByRole,
  Value<String> languageUsed,
  Value<DateTime> consentTimestamp,
  Value<DateTime?> revokedAt,
  Value<String?> revocationReason,
  Value<DateTime?> syncedAt,
});
typedef $$LocalConsentsTableUpdateCompanionBuilder = LocalConsentsCompanion
    Function({
  Value<int> id,
  Value<int?> remoteId,
  Value<int> childRemoteId,
  Value<String> guardianName,
  Value<String> guardianRelation,
  Value<String?> guardianPhone,
  Value<String> consentPurpose,
  Value<bool> consentGiven,
  Value<String> consentVersion,
  Value<String?> digitalSignatureBase64,
  Value<String> collectedByUserId,
  Value<String> collectedByRole,
  Value<String> languageUsed,
  Value<DateTime> consentTimestamp,
  Value<DateTime?> revokedAt,
  Value<String?> revocationReason,
  Value<DateTime?> syncedAt,
});

class $$LocalConsentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalConsentsTable> {
  $$LocalConsentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guardianName => $composableBuilder(
      column: $table.guardianName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guardianRelation => $composableBuilder(
      column: $table.guardianRelation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guardianPhone => $composableBuilder(
      column: $table.guardianPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get consentPurpose => $composableBuilder(
      column: $table.consentPurpose,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get consentGiven => $composableBuilder(
      column: $table.consentGiven, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get consentVersion => $composableBuilder(
      column: $table.consentVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get digitalSignatureBase64 => $composableBuilder(
      column: $table.digitalSignatureBase64,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectedByUserId => $composableBuilder(
      column: $table.collectedByUserId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectedByRole => $composableBuilder(
      column: $table.collectedByRole,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get languageUsed => $composableBuilder(
      column: $table.languageUsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get consentTimestamp => $composableBuilder(
      column: $table.consentTimestamp,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get revokedAt => $composableBuilder(
      column: $table.revokedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get revocationReason => $composableBuilder(
      column: $table.revocationReason,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalConsentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalConsentsTable> {
  $$LocalConsentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guardianName => $composableBuilder(
      column: $table.guardianName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guardianRelation => $composableBuilder(
      column: $table.guardianRelation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guardianPhone => $composableBuilder(
      column: $table.guardianPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get consentPurpose => $composableBuilder(
      column: $table.consentPurpose,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get consentGiven => $composableBuilder(
      column: $table.consentGiven,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get consentVersion => $composableBuilder(
      column: $table.consentVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get digitalSignatureBase64 => $composableBuilder(
      column: $table.digitalSignatureBase64,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectedByUserId => $composableBuilder(
      column: $table.collectedByUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectedByRole => $composableBuilder(
      column: $table.collectedByRole,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get languageUsed => $composableBuilder(
      column: $table.languageUsed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get consentTimestamp => $composableBuilder(
      column: $table.consentTimestamp,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get revokedAt => $composableBuilder(
      column: $table.revokedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get revocationReason => $composableBuilder(
      column: $table.revocationReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalConsentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalConsentsTable> {
  $$LocalConsentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get childRemoteId => $composableBuilder(
      column: $table.childRemoteId, builder: (column) => column);

  GeneratedColumn<String> get guardianName => $composableBuilder(
      column: $table.guardianName, builder: (column) => column);

  GeneratedColumn<String> get guardianRelation => $composableBuilder(
      column: $table.guardianRelation, builder: (column) => column);

  GeneratedColumn<String> get guardianPhone => $composableBuilder(
      column: $table.guardianPhone, builder: (column) => column);

  GeneratedColumn<String> get consentPurpose => $composableBuilder(
      column: $table.consentPurpose, builder: (column) => column);

  GeneratedColumn<bool> get consentGiven => $composableBuilder(
      column: $table.consentGiven, builder: (column) => column);

  GeneratedColumn<String> get consentVersion => $composableBuilder(
      column: $table.consentVersion, builder: (column) => column);

  GeneratedColumn<String> get digitalSignatureBase64 => $composableBuilder(
      column: $table.digitalSignatureBase64, builder: (column) => column);

  GeneratedColumn<String> get collectedByUserId => $composableBuilder(
      column: $table.collectedByUserId, builder: (column) => column);

  GeneratedColumn<String> get collectedByRole => $composableBuilder(
      column: $table.collectedByRole, builder: (column) => column);

  GeneratedColumn<String> get languageUsed => $composableBuilder(
      column: $table.languageUsed, builder: (column) => column);

  GeneratedColumn<DateTime> get consentTimestamp => $composableBuilder(
      column: $table.consentTimestamp, builder: (column) => column);

  GeneratedColumn<DateTime> get revokedAt =>
      $composableBuilder(column: $table.revokedAt, builder: (column) => column);

  GeneratedColumn<String> get revocationReason => $composableBuilder(
      column: $table.revocationReason, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$LocalConsentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalConsentsTable,
    LocalConsent,
    $$LocalConsentsTableFilterComposer,
    $$LocalConsentsTableOrderingComposer,
    $$LocalConsentsTableAnnotationComposer,
    $$LocalConsentsTableCreateCompanionBuilder,
    $$LocalConsentsTableUpdateCompanionBuilder,
    (
      LocalConsent,
      BaseReferences<_$AppDatabase, $LocalConsentsTable, LocalConsent>
    ),
    LocalConsent,
    PrefetchHooks Function()> {
  $$LocalConsentsTableTableManager(_$AppDatabase db, $LocalConsentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalConsentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalConsentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalConsentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            Value<int> childRemoteId = const Value.absent(),
            Value<String> guardianName = const Value.absent(),
            Value<String> guardianRelation = const Value.absent(),
            Value<String?> guardianPhone = const Value.absent(),
            Value<String> consentPurpose = const Value.absent(),
            Value<bool> consentGiven = const Value.absent(),
            Value<String> consentVersion = const Value.absent(),
            Value<String?> digitalSignatureBase64 = const Value.absent(),
            Value<String> collectedByUserId = const Value.absent(),
            Value<String> collectedByRole = const Value.absent(),
            Value<String> languageUsed = const Value.absent(),
            Value<DateTime> consentTimestamp = const Value.absent(),
            Value<DateTime?> revokedAt = const Value.absent(),
            Value<String?> revocationReason = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalConsentsCompanion(
            id: id,
            remoteId: remoteId,
            childRemoteId: childRemoteId,
            guardianName: guardianName,
            guardianRelation: guardianRelation,
            guardianPhone: guardianPhone,
            consentPurpose: consentPurpose,
            consentGiven: consentGiven,
            consentVersion: consentVersion,
            digitalSignatureBase64: digitalSignatureBase64,
            collectedByUserId: collectedByUserId,
            collectedByRole: collectedByRole,
            languageUsed: languageUsed,
            consentTimestamp: consentTimestamp,
            revokedAt: revokedAt,
            revocationReason: revocationReason,
            syncedAt: syncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            required int childRemoteId,
            required String guardianName,
            required String guardianRelation,
            Value<String?> guardianPhone = const Value.absent(),
            required String consentPurpose,
            Value<bool> consentGiven = const Value.absent(),
            Value<String> consentVersion = const Value.absent(),
            Value<String?> digitalSignatureBase64 = const Value.absent(),
            required String collectedByUserId,
            required String collectedByRole,
            Value<String> languageUsed = const Value.absent(),
            Value<DateTime> consentTimestamp = const Value.absent(),
            Value<DateTime?> revokedAt = const Value.absent(),
            Value<String?> revocationReason = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalConsentsCompanion.insert(
            id: id,
            remoteId: remoteId,
            childRemoteId: childRemoteId,
            guardianName: guardianName,
            guardianRelation: guardianRelation,
            guardianPhone: guardianPhone,
            consentPurpose: consentPurpose,
            consentGiven: consentGiven,
            consentVersion: consentVersion,
            digitalSignatureBase64: digitalSignatureBase64,
            collectedByUserId: collectedByUserId,
            collectedByRole: collectedByRole,
            languageUsed: languageUsed,
            consentTimestamp: consentTimestamp,
            revokedAt: revokedAt,
            revocationReason: revocationReason,
            syncedAt: syncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalConsentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalConsentsTable,
    LocalConsent,
    $$LocalConsentsTableFilterComposer,
    $$LocalConsentsTableOrderingComposer,
    $$LocalConsentsTableAnnotationComposer,
    $$LocalConsentsTableCreateCompanionBuilder,
    $$LocalConsentsTableUpdateCompanionBuilder,
    (
      LocalConsent,
      BaseReferences<_$AppDatabase, $LocalConsentsTable, LocalConsent>
    ),
    LocalConsent,
    PrefetchHooks Function()>;
typedef $$LocalAuditLogsTableCreateCompanionBuilder = LocalAuditLogsCompanion
    Function({
  Value<int> id,
  Value<int?> remoteId,
  required String userId,
  required String userRole,
  required String action,
  required String entityType,
  Value<int?> entityId,
  Value<String?> auditEntityName,
  Value<String?> detailsJson,
  Value<String?> deviceInfo,
  Value<DateTime> timestamp,
  Value<DateTime?> syncedAt,
});
typedef $$LocalAuditLogsTableUpdateCompanionBuilder = LocalAuditLogsCompanion
    Function({
  Value<int> id,
  Value<int?> remoteId,
  Value<String> userId,
  Value<String> userRole,
  Value<String> action,
  Value<String> entityType,
  Value<int?> entityId,
  Value<String?> auditEntityName,
  Value<String?> detailsJson,
  Value<String?> deviceInfo,
  Value<DateTime> timestamp,
  Value<DateTime?> syncedAt,
});

class $$LocalAuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAuditLogsTable> {
  $$LocalAuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userRole => $composableBuilder(
      column: $table.userRole, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get auditEntityName => $composableBuilder(
      column: $table.auditEntityName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detailsJson => $composableBuilder(
      column: $table.detailsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceInfo => $composableBuilder(
      column: $table.deviceInfo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalAuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAuditLogsTable> {
  $$LocalAuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userRole => $composableBuilder(
      column: $table.userRole, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get auditEntityName => $composableBuilder(
      column: $table.auditEntityName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detailsJson => $composableBuilder(
      column: $table.detailsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceInfo => $composableBuilder(
      column: $table.deviceInfo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalAuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAuditLogsTable> {
  $$LocalAuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get userRole =>
      $composableBuilder(column: $table.userRole, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get auditEntityName => $composableBuilder(
      column: $table.auditEntityName, builder: (column) => column);

  GeneratedColumn<String> get detailsJson => $composableBuilder(
      column: $table.detailsJson, builder: (column) => column);

  GeneratedColumn<String> get deviceInfo => $composableBuilder(
      column: $table.deviceInfo, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$LocalAuditLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalAuditLogsTable,
    LocalAuditLog,
    $$LocalAuditLogsTableFilterComposer,
    $$LocalAuditLogsTableOrderingComposer,
    $$LocalAuditLogsTableAnnotationComposer,
    $$LocalAuditLogsTableCreateCompanionBuilder,
    $$LocalAuditLogsTableUpdateCompanionBuilder,
    (
      LocalAuditLog,
      BaseReferences<_$AppDatabase, $LocalAuditLogsTable, LocalAuditLog>
    ),
    LocalAuditLog,
    PrefetchHooks Function()> {
  $$LocalAuditLogsTableTableManager(
      _$AppDatabase db, $LocalAuditLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> userRole = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<int?> entityId = const Value.absent(),
            Value<String?> auditEntityName = const Value.absent(),
            Value<String?> detailsJson = const Value.absent(),
            Value<String?> deviceInfo = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalAuditLogsCompanion(
            id: id,
            remoteId: remoteId,
            userId: userId,
            userRole: userRole,
            action: action,
            entityType: entityType,
            entityId: entityId,
            auditEntityName: auditEntityName,
            detailsJson: detailsJson,
            deviceInfo: deviceInfo,
            timestamp: timestamp,
            syncedAt: syncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> remoteId = const Value.absent(),
            required String userId,
            required String userRole,
            required String action,
            required String entityType,
            Value<int?> entityId = const Value.absent(),
            Value<String?> auditEntityName = const Value.absent(),
            Value<String?> detailsJson = const Value.absent(),
            Value<String?> deviceInfo = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              LocalAuditLogsCompanion.insert(
            id: id,
            remoteId: remoteId,
            userId: userId,
            userRole: userRole,
            action: action,
            entityType: entityType,
            entityId: entityId,
            auditEntityName: auditEntityName,
            detailsJson: detailsJson,
            deviceInfo: deviceInfo,
            timestamp: timestamp,
            syncedAt: syncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalAuditLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalAuditLogsTable,
    LocalAuditLog,
    $$LocalAuditLogsTableFilterComposer,
    $$LocalAuditLogsTableOrderingComposer,
    $$LocalAuditLogsTableAnnotationComposer,
    $$LocalAuditLogsTableCreateCompanionBuilder,
    $$LocalAuditLogsTableUpdateCompanionBuilder,
    (
      LocalAuditLog,
      BaseReferences<_$AppDatabase, $LocalAuditLogsTable, LocalAuditLog>
    ),
    LocalAuditLog,
    PrefetchHooks Function()>;
typedef $$LocalDataGovernanceConfigTableCreateCompanionBuilder
    = LocalDataGovernanceConfigCompanion Function({
  Value<int> id,
  required String configKey,
  required String configValue,
  Value<DateTime> updatedAt,
});
typedef $$LocalDataGovernanceConfigTableUpdateCompanionBuilder
    = LocalDataGovernanceConfigCompanion Function({
  Value<int> id,
  Value<String> configKey,
  Value<String> configValue,
  Value<DateTime> updatedAt,
});

class $$LocalDataGovernanceConfigTableFilterComposer
    extends Composer<_$AppDatabase, $LocalDataGovernanceConfigTable> {
  $$LocalDataGovernanceConfigTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get configKey => $composableBuilder(
      column: $table.configKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get configValue => $composableBuilder(
      column: $table.configValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalDataGovernanceConfigTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalDataGovernanceConfigTable> {
  $$LocalDataGovernanceConfigTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get configKey => $composableBuilder(
      column: $table.configKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get configValue => $composableBuilder(
      column: $table.configValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalDataGovernanceConfigTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalDataGovernanceConfigTable> {
  $$LocalDataGovernanceConfigTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get configKey =>
      $composableBuilder(column: $table.configKey, builder: (column) => column);

  GeneratedColumn<String> get configValue => $composableBuilder(
      column: $table.configValue, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalDataGovernanceConfigTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalDataGovernanceConfigTable,
    LocalDataGovernanceConfigData,
    $$LocalDataGovernanceConfigTableFilterComposer,
    $$LocalDataGovernanceConfigTableOrderingComposer,
    $$LocalDataGovernanceConfigTableAnnotationComposer,
    $$LocalDataGovernanceConfigTableCreateCompanionBuilder,
    $$LocalDataGovernanceConfigTableUpdateCompanionBuilder,
    (
      LocalDataGovernanceConfigData,
      BaseReferences<_$AppDatabase, $LocalDataGovernanceConfigTable,
          LocalDataGovernanceConfigData>
    ),
    LocalDataGovernanceConfigData,
    PrefetchHooks Function()> {
  $$LocalDataGovernanceConfigTableTableManager(
      _$AppDatabase db, $LocalDataGovernanceConfigTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDataGovernanceConfigTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDataGovernanceConfigTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDataGovernanceConfigTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> configKey = const Value.absent(),
            Value<String> configValue = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              LocalDataGovernanceConfigCompanion(
            id: id,
            configKey: configKey,
            configValue: configValue,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String configKey,
            required String configValue,
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              LocalDataGovernanceConfigCompanion.insert(
            id: id,
            configKey: configKey,
            configValue: configValue,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalDataGovernanceConfigTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalDataGovernanceConfigTable,
        LocalDataGovernanceConfigData,
        $$LocalDataGovernanceConfigTableFilterComposer,
        $$LocalDataGovernanceConfigTableOrderingComposer,
        $$LocalDataGovernanceConfigTableAnnotationComposer,
        $$LocalDataGovernanceConfigTableCreateCompanionBuilder,
        $$LocalDataGovernanceConfigTableUpdateCompanionBuilder,
        (
          LocalDataGovernanceConfigData,
          BaseReferences<_$AppDatabase, $LocalDataGovernanceConfigTable,
              LocalDataGovernanceConfigData>
        ),
        LocalDataGovernanceConfigData,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalChildrenTableTableManager get localChildren =>
      $$LocalChildrenTableTableManager(_db, _db.localChildren);
  $$LocalScreeningSessionsTableTableManager get localScreeningSessions =>
      $$LocalScreeningSessionsTableTableManager(
          _db, _db.localScreeningSessions);
  $$LocalScreeningResponsesTableTableManager get localScreeningResponses =>
      $$LocalScreeningResponsesTableTableManager(
          _db, _db.localScreeningResponses);
  $$LocalScreeningResultsTableTableManager get localScreeningResults =>
      $$LocalScreeningResultsTableTableManager(_db, _db.localScreeningResults);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$LocalToolConfigsTableTableManager get localToolConfigs =>
      $$LocalToolConfigsTableTableManager(_db, _db.localToolConfigs);
  $$LocalQuestionsTableTableManager get localQuestions =>
      $$LocalQuestionsTableTableManager(_db, _db.localQuestions);
  $$LocalResponseOptionsTableTableManager get localResponseOptions =>
      $$LocalResponseOptionsTableTableManager(_db, _db.localResponseOptions);
  $$LocalScoringRulesTableTableManager get localScoringRules =>
      $$LocalScoringRulesTableTableManager(_db, _db.localScoringRules);
  $$LocalActivitiesTableTableManager get localActivities =>
      $$LocalActivitiesTableTableManager(_db, _db.localActivities);
  $$LocalReferralsTableTableManager get localReferrals =>
      $$LocalReferralsTableTableManager(_db, _db.localReferrals);
  $$LocalNutritionAssessmentsTableTableManager get localNutritionAssessments =>
      $$LocalNutritionAssessmentsTableTableManager(
          _db, _db.localNutritionAssessments);
  $$LocalEnvironmentAssessmentsTableTableManager
      get localEnvironmentAssessments =>
          $$LocalEnvironmentAssessmentsTableTableManager(
              _db, _db.localEnvironmentAssessments);
  $$LocalInterventionFollowupsTableTableManager
      get localInterventionFollowups =>
          $$LocalInterventionFollowupsTableTableManager(
              _db, _db.localInterventionFollowups);
  $$LocalConsentsTableTableManager get localConsents =>
      $$LocalConsentsTableTableManager(_db, _db.localConsents);
  $$LocalAuditLogsTableTableManager get localAuditLogs =>
      $$LocalAuditLogsTableTableManager(_db, _db.localAuditLogs);
  $$LocalDataGovernanceConfigTableTableManager get localDataGovernanceConfig =>
      $$LocalDataGovernanceConfigTableTableManager(
          _db, _db.localDataGovernanceConfig);
}
