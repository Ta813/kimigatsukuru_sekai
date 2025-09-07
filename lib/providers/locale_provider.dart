// lib/providers/locale_provider.dart

import 'package:flutter/material.dart';
import '../helpers/shared_prefs_helper.dart'; // ★インポート

class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  // ★初期化メソッドを追加
  Future<void> init() async {
    final languageCode = await SharedPrefsHelper.loadLocale();
    if (languageCode != null) {
      _locale = Locale(languageCode);
    } else {
      _locale = null;
    }
    notifyListeners();
  }

  // ★言語を設定する際に、SharedPreferencesにも保存
  void setLocale(Locale newLocale) {
    _locale = newLocale;
    SharedPrefsHelper.saveLocale(newLocale.languageCode);
    notifyListeners();
  }

  // ★言語設定をクリアする際に、SharedPreferencesからも削除
  void clearLocale() {
    _locale = null;
    SharedPrefsHelper.saveLocale(null);
    notifyListeners();
  }
}
