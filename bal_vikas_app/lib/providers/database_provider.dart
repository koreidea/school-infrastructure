import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../services/database_service.dart';

final databaseProvider = Provider<AppDatabase?>((ref) {
  if (kIsWeb) return null; // Drift not available on web
  return DatabaseService.db;
});
