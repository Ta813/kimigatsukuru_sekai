// lib/screens/parent_mode/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/widgets/ad_banner.dart';
import '../../widgets/custom_back_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../models/lock_mode.dart';
import '../../screens/child/passcode_lock_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import '../../services/backup_service.dart';

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

  // ▼ 追加: ポイント管理用変数とコントローラー
  int _currentPoints = 0;
  final _pointsController = TextEditingController();

  BackupServiceKbn _linkedService = BackupServiceKbn.none; // ★ 連携状態を管理
  bool _isLoading = false; // ★ バックアップ/復元中のローディングフラグ

  // ▼ 追加: デバッグ用シミュレート日付
  DateTime? _simulatedDate;

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
    // ▼ 追加: ポイントを読み込む
    final points = await SharedPrefsHelper.loadPoints();

    final service = await SharedPrefsHelper.loadBackupService();

    // シミュレート日付を読む
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString('debug_simulated_date');
    DateTime? simDate;
    if (dateStr != null) {
      try {
        simDate = DateTime.parse(dateStr);
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _selectedLockMode = lockMode;
        _currentPasscode = passcode;
        _currentLevel = level;

        _currentExperience = experience;
        _expController.text = _currentExperience.toString();

        // ▼ 追加: 読み込んだポイントをセット
        _currentPoints = points;
        _pointsController.text = _currentPoints.toString();

        _linkedService = service;
        _simulatedDate = simDate;
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

  // ★ バックアップ処理
  Future<void> _handleBackup(BackupServiceKbn service) async {
    setState(() {
      _isLoading = true;
    });
    bool success = false;
    if (service == BackupServiceKbn.googleDrive) {
      success = await BackupService.backupToGoogleDrive();
    } else if (service == BackupServiceKbn.icloud) {
      success = await BackupService.backupToiCloud();
    }

    if (success) {
      await SharedPrefsHelper.saveBackupService(service);
      setState(() {
        _linkedService = service;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.backupSuccess)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.backupFailure)),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  // ★ 復元処理（仮）
  Future<void> _handleRestore(BackupServiceKbn service) async {
    setState(() {
      _isLoading = true;
    });
    bool success = false;
    if (service == BackupServiceKbn.googleDrive) {
      success = await BackupService.restoreFromGoogleDrive();
    } else if (service == BackupServiceKbn.icloud) {
      success = await BackupService.restoreFromiCloud();
    }

    if (success) {
      await SharedPrefsHelper.saveBackupService(service);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.restoreSuccess)),
      );
      // ★ 復元したデータをUIに反映させるために、設定を再読み込み
      _loadSettings();
      // TODO: ホーム画面など、他の画面もリフレッシュする必要があるかもしれない
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.restoreFailure)),
      );
    }

    await Future.delayed(const Duration(seconds: 2));
    print('復元処理 ($service) を実行');

    setState(() {
      _isLoading = false;
    });
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
    } else if (currentLocale == 'hi') {
      currentValue = 'hi';
    } else if (currentLocale == 'ur') {
      currentValue = 'ur';
    } else if (currentLocale == 'bn') {
      currentValue = 'bn';
    } else if (currentLocale == 'ar') {
      currentValue = 'ar';
    } else {
      // 手動設定がなければ、端末の言語で判断
      if (deviceLocale == 'ja') {
        currentValue = 'ja';
      } else if (deviceLocale == 'hi') {
        currentValue = 'hi';
      } else if (deviceLocale == 'ur') {
        currentValue = 'ur';
      } else if (deviceLocale == 'bn') {
        currentValue = 'bn';
      } else if (deviceLocale == 'ar') {
        currentValue = 'ar';
      } else {
        currentValue = 'en';
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text(l10n.settingsTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // ★ ローディング中は操作不可に
          : SafeArea(
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
                          FirebaseAnalytics.instance.logEvent(
                            name: 'start_settings_language_ja',
                          );
                          localeProvider.setLocale(const Locale('ja'));
                        } else if (newValue == 'en') {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'start_settings_language_en',
                          );
                          localeProvider.setLocale(const Locale('en'));
                        } else if (newValue == 'hi') {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'start_settings_language_hi',
                          );
                          localeProvider.setLocale(const Locale('hi'));
                        } else if (newValue == 'ur') {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'start_settings_language_ur',
                          );
                          localeProvider.setLocale(const Locale('ur'));
                        } else if (newValue == 'bn') {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'start_settings_language_bn',
                          );
                          localeProvider.setLocale(const Locale('bn'));
                        } else if (newValue == 'ar') {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'start_settings_language_ar',
                          );
                          localeProvider.setLocale(const Locale('ar'));
                        }
                      },
                      // ★プルダウンの選択肢から「端末の設定」を削除
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: 'ja',
                          child: Text('日本語'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'en',
                          child: Text('English'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'hi',
                          child: Text('हिन्दी'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'ur',
                          child: Text('اردو'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'bn',
                          child: Text('বাংলা'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'ar',
                          child: Text('العربية'),
                        ),
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
                          if (newValue == LockMode.math) {
                            FirebaseAnalytics.instance.logEvent(
                              name: 'start_settings_lock_multiplication',
                            );
                          } else if (newValue == LockMode.passcode) {
                            FirebaseAnalytics.instance.logEvent(
                              name: 'start_settings_lock_passcode',
                            );
                          }
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
                        FirebaseAnalytics.instance.logEvent(
                          name: 'start_settings_set_passcode',
                        );
                        // ★ パスワード設定ダイアログを呼び出す処理を修正
                        _showSetPasscodeDialog().then((_) {
                          // ダイアログが閉じた後に、設定を再読み込みして表示を更新する
                          _loadSettings();
                        });
                      },
                    ),
                  const Divider(),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      l10n.backupRestoreTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),

                  // --- Google Drive ボタン (Androidは常時表示, iOSはiCloud未連携時のみ) ---
                  if (Platform.isAndroid ||
                      (Platform.isIOS &&
                          _linkedService != BackupServiceKbn.icloud))
                    ListTile(
                      leading: const Icon(Icons.cloud_upload_outlined),
                      title: const Text('Google Drive'),
                      subtitle: Text(
                        _linkedService == BackupServiceKbn.googleDrive
                            ? l10n.backupServiceLinked
                            : l10n.backupServiceGoogleDriveDesc,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            child: Text(l10n.backupAction),
                            onPressed: () {
                              FirebaseAnalytics.instance.logEvent(
                                name: 'start_settings_backup_google_drive',
                              );
                              _handleBackup(BackupServiceKbn.googleDrive);
                            },
                          ),
                          TextButton(
                            child: Text(l10n.restoreAction),
                            onPressed: () {
                              FirebaseAnalytics.instance.logEvent(
                                name: 'start_settings_restore_google_drive',
                              );
                              _handleRestore(BackupServiceKbn.googleDrive);
                            },
                          ),
                        ],
                      ),
                    ),

                  const Divider(),

                  // ここから寄付の導線を追加
                  ListTile(
                    leading: const Icon(Icons.favorite, color: Colors.pink),
                    title: Text(l10n.supportThisApp), // 文言は規約を意識
                    subtitle: Text(l10n.supportEncouragement),
                    onTap: () async {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'start_settings_support',
                      );
                      // ★ 寄付ページのURLに書き換えてください
                      final url = Uri.parse(
                        'https://www.buymeacoffee.com/kotoapp',
                      );

                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
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

                    // --- ポイント操作 ---
                    const Text('ポイント設定'),
                    TextField(
                      controller: _pointsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(suffixText: 'P'),
                      onSubmitted: (String value) async {
                        final newPoints = int.tryParse(value) ?? 0;
                        setState(() {
                          _currentPoints = newPoints;
                        });
                        await SharedPrefsHelper.savePoints(newPoints);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('ポイントを $newPoints P に変更しました！'),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    // --- レベル操作 ---
                    Text('レベル設定: $_currentLevel'),
                    Slider(
                      value: _currentLevel.toDouble(),
                      min: 1,
                      max: 90, // 最大レベルを適当に設定
                      divisions: 89, // max - min
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
                      decoration: InputDecoration(suffixText: 'EXP'),
                      onSubmitted: (String value) async {
                        final newExp = int.tryParse(value) ?? 0;
                        setState(() {
                          _currentExperience = newExp;
                        });
                        await SharedPrefsHelper.saveExperience(newExp);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('経験値を $newExp EXP に変更しました！'),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    if (Platform.isAndroid)
                      ListTile(
                        leading: const Icon(Icons.mediation),
                        title: const Text('メディエーション テストスイート'),
                        onTap: () {
                          // ★ この一行でテストスイートが起動します
                          MobileAds.instance.openAdInspector((error) {
                            if (error != null) {
                              // エラー処理
                              print("メディエーションERROR：" + error.message!);
                            }
                          });
                        },
                      ),
                    // タイムトラベル（日付移動）ボタン
                    ListTile(
                      leading: const Icon(
                        Icons.calendar_month,
                        color: Colors.purple,
                      ),
                      title: const Text('【テスト用】現在の日付を変更する'),
                      subtitle: Text(
                        _simulatedDate == null
                            ? '現在の日付（実際の日時）'
                            : '設定中: ${_simulatedDate!.year}/${_simulatedDate!.month}/${_simulatedDate!.day}',
                        style: const TextStyle(color: Colors.purple),
                      ),
                      trailing: _simulatedDate != null
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.purple,
                              ),
                              onPressed: () async {
                                await SharedPrefsHelper.setDebugSimulatedDate(
                                  null,
                                );
                                // 最終アクセス日をクリアして、変更を確実に反映させる
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('last_active_date');
                                setState(() {
                                  _simulatedDate = null;
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('実際の日時に戻しました。'),
                                    ),
                                  );
                                }
                              },
                            )
                          : null,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _simulatedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          await SharedPrefsHelper.setDebugSimulatedDate(picked);

                          // ホーム画面に戻った際に新しい日として認識されるように最終アクセス日をリセットする
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('last_active_date');

                          setState(() {
                            _simulatedDate = picked;
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '日付を ${picked.year}/${picked.month}/${picked.day} に設定しました！\nホーム画面に戻って確認してください。',
                                ),
                                backgroundColor: Colors.purple,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    // チュートリアルリセットボタン
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () async {
                        await SharedPrefsHelper.resetTutorialStatus();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✨ チュートリアルとガイドをリセットしました！\nアプリを再起動すると最初から始まります。',
                              ),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        '【デバッグ】チュートリアルをリセット',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.refresh, color: Colors.orange),
                      title: Text(l10n.resetPromisesAction),
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.confirmation),
                            content: Text(l10n.resetPromisesConfirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.cancelAction),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(l10n.okAction),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'start_settings_reset_promises',
                          );
                          await SharedPrefsHelper.resetToDefaultRegularPromises(
                            context,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.resetPromisesSuccess),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 2, color: Colors.red),
                  ],
                ],
              ),
            ),
      // 画面下部にバナーを設置（初回起動時は広告を表示しない）
      bottomNavigationBar: const AdBanner(),
    );
  }
}
