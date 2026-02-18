import 'package:drift/drift.dart';

QueryExecutor openConnection() {
  throw UnsupportedError(
    'Drift database is not supported on web. Use Supabase directly.',
  );
}
