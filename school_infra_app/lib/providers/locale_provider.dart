import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  void toggleLocale() {
    state = state.languageCode == 'en'
        ? const Locale('te')
        : const Locale('en');
  }

  void setLocale(Locale locale) {
    state = locale;
  }

  bool get isTelugu => state.languageCode == 'te';
}
