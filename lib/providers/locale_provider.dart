// lib/providers/locale_provider.dart

import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  // ★初期状態をnullに変更
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }
}
