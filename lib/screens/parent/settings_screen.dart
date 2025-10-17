// lib/screens/parent_mode/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../models/lock_mode.dart';
import '../../screens/child/passcode_lock_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  LockMode _selectedLockMode = LockMode.math;

  String? _currentPasscode; // 現在のパスワードを保持
  bool _isPasscodeVisible = false; // パスワードを表示するかどうかの旗

  int _currentLevel = 1;
  int _currentExperience = 0;
  final _expController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final lockMode = await SharedPrefsHelper.loadLockMode();
    final passcode = await SharedPrefsHelper.loadPasscode();
    final level = await SharedPrefsHelper.loadLevel();
    final experience = await SharedPrefsHelper.loadExperience();
    if (mounted) {
      setState(() {
        _selectedLockMode = lockMode;
        _currentPasscode = passcode;
        _currentLevel = level;
        _currentExperience = experience;
        _expController.text = _currentExperience.toString();
      });
    }
  }

  // パスワード設定ダイアログを表示するメソッド
  Future<void> _showSetPasscodeDialog() {
    String enteredPasscode = ''; // このダイアログ内でのみ使う入力中のパスワード

    return showDialog(
      context: context,
      // ユーザーがダイアログの外側をタップしても閉じないようにする
      barrierDismissible: false,
      builder: (context) {
        // ★ ダイアログ内で状態を管理するためにStatefulBuilderを使う
        return StatefulBuilder(
          builder: (context, setState) {
            // 数字が押された時の処理
            void onNumberPressed(String number) {
              if (enteredPasscode.length < 4) {
                setState(() {
                  enteredPasscode += number;
                });
              }
            }

            // 削除が押された時の処理
            void onDeletePressed() {
              if (enteredPasscode.isNotEmpty) {
                setState(() {
                  enteredPasscode = enteredPasscode.substring(
                    0,
                    enteredPasscode.length - 1,
                  );
                });
              }
            }

            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 入力中のパスワード表示
                  Text(
                    enteredPasscode.padRight(4, '◦'),
                    style: const TextStyle(fontSize: 20, letterSpacing: 8),
                  ),
                  // 数字キーパッド
                  Container(
                    width: 240,
                    height: 160,
                    child: NumericKeypad(
                      onNumberPressed: onNumberPressed,
                      onDeletePressed: onDeletePressed,
                    ),
                  ),
                ],
              ),
              actions: [
                // キャンセル（閉じる）ボタン
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancelAction),
                  onPressed: () {
                    // 何もせずにダイアログを閉じる
                    Navigator.pop(context);
                  },
                ),
                // 設定するボタン
                ElevatedButton(
                  // 4桁入力されていない場合はボタンを無効化
                  onPressed: enteredPasscode.length == 4
                      ? () async {
                          await SharedPrefsHelper.savePasscode(enteredPasscode);
                          if (mounted) Navigator.pop(context);
                        }
                      : null,
                  child: Text(AppLocalizations.of(context)!.setAction),
                ),
              ],
            );
          },
        );
      },
    );
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
      body: SafeArea(
        child: ListView(
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock),
              title: Text(l10n.lockMethod),
              trailing: DropdownButton<LockMode>(
                value: _selectedLockMode,
                items: [
                  DropdownMenuItem(
                    value: LockMode.math,
                    child: Text(l10n.multiplication),
                  ),
                  DropdownMenuItem(
                    value: LockMode.passcode,
                    child: Text(l10n.fourDigitPasscode),
                  ),
                ],
                onChanged: (LockMode? newValue) async {
                  if (newValue != null) {
                    await SharedPrefsHelper.saveLockMode(newValue);
                    setState(() {
                      _selectedLockMode = newValue;
                    });
                    // もしパスワードモードが選ばれて、まだパスワードが設定されていなければ設定を促す
                    if (newValue == LockMode.passcode &&
                        await SharedPrefsHelper.loadPasscode() == null) {
                      _showSetPasscodeDialog();
                    }
                  }
                },
              ),
            ),
            // パスワードモードの時だけ「パスワード設定」を表示
            if (_selectedLockMode == LockMode.passcode)
              ListTile(
                leading: const Icon(Icons.password),
                title: Text(l10n.setPasscode),
                subtitle: Row(
                  children: [
                    // パスワードを表示するか、●で隠すかを三項演算子で切り替え
                    Text(
                      _currentPasscode == null
                          ? l10n.notSet
                          : _isPasscodeVisible
                          ? _currentPasscode!
                          : '●●●●',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    // 表示/非表示を切り替えるアイコンボタン
                    IconButton(
                      icon: Icon(
                        _isPasscodeVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasscodeVisible = !_isPasscodeVisible;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                onTap: () {
                  // ★ パスワード設定ダイアログを呼び出す処理を修正
                  _showSetPasscodeDialog().then((_) {
                    // ダイアログが閉じた後に、設定を再読み込みして表示を更新する
                    _loadSettings();
                  });
                },
              ),
            const Divider(),

            // ここから寄付の導線を追加
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.pink),
              title: Text(l10n.supportThisApp), // 文言は規約を意識
              subtitle: Text(l10n.supportEncouragement),
              onTap: () async {
                // ★ 寄付ページのURLに書き換えてください
                final url = Uri.parse('https://www.buymeacoffee.com/kotoapp');

                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  // URLが開けなかった場合の予備処理
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.supportPageOpenError)),
                  );
                }
              },
            ),
            if (kDebugMode) ...[
              // kDebugModeがtrueの時だけ以下のウィジェットを表示
              const Divider(thickness: 2, color: Colors.red),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'デバッグメニュー (Debug Menu)',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // --- レベル操作 ---
              Text('レベル設定: $_currentLevel'),
              Slider(
                value: _currentLevel.toDouble(),
                min: 1,
                max: 50, // 最大レベルを適当に設定
                divisions: 49, // max - min
                label: _currentLevel.toString(),
                onChanged: (double value) {
                  setState(() {
                    _currentLevel = value.toInt();
                  });
                },
                // ★ スライダーを離した時に値を保存
                onChangeEnd: (double value) async {
                  await SharedPrefsHelper.saveLevel(value.toInt());
                  // ホーム画面に戻った時に更新が反映されるようにする
                },
              ),

              // --- 経験値操作 ---
              const Text('経験値設定'),
              TextField(
                controller: _expController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text('EXP')),
                onSubmitted: (String value) async {
                  final newExp = int.tryParse(value) ?? 0;
                  setState(() {
                    _currentExperience = newExp;
                  });
                  await SharedPrefsHelper.saveExperience(newExp);
                },
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 2, color: Colors.red),
            ],
          ],
        ),
      ),
    );
  }
}
