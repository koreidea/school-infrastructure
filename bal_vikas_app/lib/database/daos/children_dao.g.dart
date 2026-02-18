// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'children_dao.dart';

// ignore_for_file: type=lint
mixin _$ChildrenDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalChildrenTable get localChildren => attachedDatabase.localChildren;
  ChildrenDaoManager get managers => ChildrenDaoManager(this);
}

class ChildrenDaoManager {
  final _$ChildrenDaoMixin _db;
  ChildrenDaoManager(this._db);
  $$LocalChildrenTableTableManager get localChildren =>
      $$LocalChildrenTableTableManager(_db.attachedDatabase, _db.localChildren);
}
