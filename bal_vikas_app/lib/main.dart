import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app.dart';
import 'services/supabase_service.dart';
import 'services/database_service.dart';
import 'services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseService.initialize();
    await DatabaseService.initialize(); // no-op on web
    if (!kIsWeb) {
      ConnectivityService.startListening();
    }
  } catch (e) {
    debugPrint('INIT ERROR: $e');
  }
  runApp(
    const ProviderScope(
      child: BalVikasApp(),
    ),
  );
}

class BalVikasApp extends StatelessWidget {
  const BalVikasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bal Vikas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          primary: const Color(0xFF2196F3),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('te'), // Telugu
      ],
      home: const App(),
    );
  }
}
