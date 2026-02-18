import 'package:flutter/foundation.dart' show kIsWeb;
import '../database/app_database.dart';

class DatabaseService {
  static AppDatabase? _db;

  static bool get isAvailable => !kIsWeb && _db != null;

  static AppDatabase get db {
    if (kIsWeb) {
      throw UnsupportedError('Drift database is not available on web. Use Supabase directly.');
    }
    if (_db == null) {
      throw StateError('DatabaseService not initialized. Call initialize() first.');
    }
    return _db!;
  }

  static Future<void> initialize() async {
    if (kIsWeb) return; // No local DB on web
    _db = AppDatabase();
  }

  static void dispose() {
    _db?.close();
    _db = null;
  }
}
