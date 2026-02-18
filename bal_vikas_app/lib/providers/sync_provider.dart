import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';

/// Stream of pending sync item count — updates when queue changes
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  // On web, no sync queue — always return 0
  if (kIsWeb) return Stream.value(0);
  return DatabaseService.db.syncQueueDao.watchPendingCount();
});

/// Trigger a manual sync
final syncTriggerProvider = FutureProvider<void>((ref) async {
  if (kIsWeb) return; // No sync needed on web
  await SyncService.processQueue();
});
