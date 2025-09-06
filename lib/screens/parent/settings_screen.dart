// lib/screens/parent_mode/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    // ★現在の言語設定から、プルダウンの初期値を決定
    //    null（端末設定）の場合は、システムの言語をチェックして 'ja' か 'en' に振り分ける
    String currentValue;
    final deviceLocale = View.of(
      context,
    ).platformDispatcher.locale.languageCode;
    final currentLocale = localeProvider.locale?.languageCode;

    if (currentLocale == 'ja') {
      currentValue = 'ja';
    } else if (currentLocale == 'en') {
      currentValue = 'en';
    } else {
      // 手動設定がなければ、端末の言語で判断
      currentValue = (deviceLocale == 'ja') ? 'ja' : 'en';
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.languageSetting),
            trailing: DropdownButton<String>(
              value: currentValue,
              onChanged: (String? newValue) {
                if (newValue == 'ja') {
                  localeProvider.setLocale(const Locale('ja'));
                } else if (newValue == 'en') {
                  localeProvider.setLocale(const Locale('en'));
                }
              },
              // ★プルダウンの選択肢から「端末の設定」を削除
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'ja', child: Text('日本語')),
                DropdownMenuItem<String>(value: 'en', child: Text('English')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
