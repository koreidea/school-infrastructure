import 'package:flutter/material.dart';

class L10n {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('te'),
  ];

  static Locale? localeResolutionCallback(Locale? locale, Iterable<Locale> supportedLocales) {
    if (locale == null) return const Locale('en');
    
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }
    
    return const Locale('en');
  }
}
