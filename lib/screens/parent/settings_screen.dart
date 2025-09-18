// lib/screens/parent_mode/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/bgm_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  BgmTrack _selectedFocusTrack = BgmTrack.focus_original; // デフォルト値

  @override
  void initState() {
    super.initState();
    // ★ 画面の初期化時に、保存されている設定値を読み込む
    _loadSettings();
  }

  @override
  void dispose() {
    // この画面を抜ける時に、普段のBGMを再生し直す
    _playSavedMainBgm();
    super.dispose(); // 必ず最後にsuper.dispose()を呼ぶ
  }

  Future<void> _playSavedMainBgm() async {
    final trackName = await SharedPrefsHelper.loadSelectedBgm();
    final track = BgmTrack.values.firstWhere(
      (e) => e.name == trackName,
      orElse: () => BgmTrack.main, // 保存されていなければデフォルト
    );
    BgmManager.instance.play(track);
  }

  // ★ 設定値を読み込むメソッド
  Future<void> _loadSettings() async {
    final trackName = await SharedPrefsHelper.loadSelectedFocusBgm();
    if (trackName != null && mounted) {
      setState(() {
        _selectedFocusTrack = BgmTrack.values.firstWhere(
          (e) => e.name == trackName,
          orElse: () => BgmTrack.focus_original, // 見つからなければデフォルト
        );
      });
    }
  }

  // ★ BGMの表示名を取得するヘルパーメソッド
  String _getFocusBgmDisplayName(BgmTrack track) {
    final l10n = AppLocalizations.of(context)!; // l10nを呼び出す

    switch (track) {
      case BgmTrack.focus_original:
        return l10n.focusBgmDefault;
      case BgmTrack.focus_cute:
        return l10n.focusBgmCute;
      case BgmTrack.focus_cool:
        return l10n.focusBgmCool;
      case BgmTrack.focus_hurry:
        return l10n.focusBgmHurry;
      case BgmTrack.focus_nature:
        return l10n.focusBgmNature;
      case BgmTrack.focus_relaxing:
        return l10n.focusBgmRelaxing;
      case BgmTrack.focus_none:
        return l10n.bgmNone; // 「BGMなし」は普段のBGMと共通のキーでOK
      default:
        return l10n.focusBgmDefault; // 不明な場合はデフォルトを返す
    }
  }

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
          const Divider(), // ★ 区切り線を追加
          // ★ ーーー ここから集中BGM設定UIを追加 ーーー ★
          ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(AppLocalizations.of(context)!.focusBgmSettingTitle),
            trailing: DropdownButton<BgmTrack>(
              value: _selectedFocusTrack,
              items: [
                // ドロップダウンの選択肢
                DropdownMenuItem(
                  value: BgmTrack.focus_original,
                  child: Text(_getFocusBgmDisplayName(BgmTrack.focus_original)),
                ),
                DropdownMenuItem(
                  value: BgmTrack.focus_cute,
                  child: Text(_getFocusBgmDisplayName(BgmTrack.focus_cute)),
                ),
                DropdownMenuItem(
                  value: BgmTrack.focus_cool,
                  child: Text(_getFocusBgmDisplayName(BgmTrack.focus_cool)),
                ),
                DropdownMenuItem(
                  value: BgmTrack.focus_hurry,
                  child: Text(_getFocusBgmDisplayName(BgmTrack.focus_hurry)),
                ),
                DropdownMenuItem(
                  value: BgmTrack.focus_nature,
                  child: Text(_getFocusBgmDisplayName(BgmTrack.focus_nature)),
                ),
                DropdownMenuItem(
                  value: BgmTrack.focus_relaxing,
                  child: Text(_getFocusBgmDisplayName(BgmTrack.focus_relaxing)),
                ),
                DropdownMenuItem(
                  value: BgmTrack.focus_none,
                  child: Text(_getFocusBgmDisplayName(BgmTrack.focus_none)),
                ),
              ],
              // ★ ユーザーが新しい項目を選択した時の処理
              onChanged: (BgmTrack? newValue) async {
                if (newValue != null) {
                  // 画面を更新
                  setState(() {
                    _selectedFocusTrack = newValue;
                  });
                  // 選択を保存
                  await SharedPrefsHelper.saveSelectedFocusBgm(newValue.name);
                  // どんな曲か確認できるように、試聴再生する
                  BgmManager.instance.play(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
