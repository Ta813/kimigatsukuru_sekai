// lib/screens/parent_mode/add_edit_promise_screen.dart

import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/widgets/ad_banner.dart';
import '../../widgets/custom_back_button.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/services.dart'; // キーボード入力制御が不要になったためコメントアウト可ですが残しておいても問題ありません
import '../../managers/sfx_manager.dart';
import '../../l10n/app_localizations.dart';

class AddEditPromiseScreen extends StatefulWidget {
  final Map<String, dynamic>? initialPromise;
  const AddEditPromiseScreen({super.key, this.initialPromise});

  @override
  State<AddEditPromiseScreen> createState() => _AddEditPromiseScreenState();
}

class _AddEditPromiseScreenState extends State<AddEditPromiseScreen> {
  // フォームの状態を管理するためのキー
  final _formKey = GlobalKey<FormState>();

  // やくそくの名前用コントローラーのみ残す
  final _titleController = TextEditingController();

  // ▼ 追加: 各ドロップダウン用の選択肢リストを生成
  final List<String> _hours = List.generate(
    24,
    (index) => index.toString().padLeft(2, '0'),
  ); // 00〜23
  final List<String> _minutes = List.generate(
    60,
    (index) => index.toString().padLeft(2, '0'),
  ); // 00〜59
  final List<String> _durationOptions = List.generate(
    120,
    (index) => (index + 1).toString(),
  ); // 1〜120分
  final List<String> _pointOptions = List.generate(
    50,
    (index) => (index + 1).toString(),
  ); // 1〜50ポイント

  // ▼ 追加: 選択中の値を保持する変数
  String _selectedHour = '07';
  String _selectedMinute = '00';
  String _selectedDuration = '10';
  String _selectedPoints = '10';

  // アイコンの選択肢
  final List<String> _emojiList = [
    '🪥', // はみがき（あさ・よる）
    '👕', // おきがえ
    '👚', // パジャマにきがえる
    '👟', // くつそろえ
    '🧼', // てあらい
    '✍️', // しゅくだい
    '🎹', // おけいこ・れんしゅう
    '📚', // どくしょ
    '✨', // おてつだい
    '🧸', // おかたづけ
    '🎒', // あしたのじゅんび
    '💤', // ねる
    '⭐', // その他（デフォルト用）
  ];

  // 現在選択されているアイコンのキー
  late String _selectedIconKey;

  @override
  void initState() {
    super.initState();

    _selectedIconKey = '⭐';
    // もし編集モードなら (initialPromiseがnullでなければ)
    if (widget.initialPromise != null) {
      _titleController.text = widget.initialPromise!['title'] ?? '';

      // ▼ 追加: 保存されている時間を「時」と「分」に分けてセット
      final timeStr = widget.initialPromise!['time'] as String?;
      if (timeStr != null && timeStr.contains(':')) {
        final parts = timeStr.split(':');
        if (_hours.contains(parts[0])) _selectedHour = parts[0];
        if (_minutes.contains(parts[1])) _selectedMinute = parts[1];
      }

      // ▼ 追加: 保存されている「長さ」と「ポイント」をセット
      final dur = widget.initialPromise!['duration']?.toString();
      if (dur != null) {
        if (!_durationOptions.contains(dur))
          _durationOptions.add(dur); // リストになければ追加（安全対策）
        _selectedDuration = dur;
      }

      final pts = widget.initialPromise!['points']?.toString();
      if (pts != null) {
        if (!_pointOptions.contains(pts)) _pointOptions.add(pts);
        _selectedPoints = pts;
      }

      // アイコンの初期値を設定
      _selectedIconKey = widget.initialPromise!['icon'] ?? '⭐';

      if (!_emojiList.contains(_selectedIconKey)) {
        _emojiList.add(_selectedIconKey);
      }
    }
  }

  // 画面が閉じられる時にお片付け
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // 保存ボタンが押された時の処理
  void _savePromise() {
    try {
      SfxManager.instance.playTapSound();
    } catch (e) {
      // エラーが発生した場合
      print('再生エラー: $e');
    }
    // バリデーション（入力チェック）を実行
    if (_formKey.currentState!.validate()) {
      // 全ての入力が正しければ、入力されたデータをMapにまとめる
      final newPromise = {
        'title': _titleController.text,
        // ▼ 変更: 選択された時と分を結合して保存
        'time': '$_selectedHour:$_selectedMinute',
        // ▼ 変更: 文字列から数値に変換して保存
        'duration': int.tryParse(_selectedDuration) ?? 0,
        'points': int.tryParse(_selectedPoints) ?? 0,
        // 選択されたアイコンのキーを保存
        'icon': _selectedIconKey,
      };
      // "結果"として新しいやくそくのデータを渡しつつ、前の画面に戻る
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(newPromise);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text(
          widget.initialPromise == null
              ? AppLocalizations.of(context)!.addRegularPromiseTitle
              : AppLocalizations.of(context)!.editRegularPromiseTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // キーボード表示で画面がはみ出ないようにする
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // やくそくの名前と開始時間を横並びにする
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // エラーテキスト表示時に上端を揃える
                  children: [
                    Expanded(
                      flex: 3, // 少し名前の方を広めにとる
                      child: TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.promiseNameLabel,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(
                              context,
                            )!.promiseNameHint;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 2, // 時間
                      // ▼ 変更: 開始時間をドロップダウン（時・分）に変更
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.startTimeLabel,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: DropdownButton<String>(
                                  value: _selectedHour,
                                  isExpanded: true,
                                  isDense: true,
                                  items: _hours.map((String h) {
                                    return DropdownMenuItem<String>(
                                      value: h,
                                      child: Center(child: Text(h)),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() => _selectedHour = newValue);
                                    }
                                  },
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  ':',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: DropdownButton<String>(
                                  value: _selectedMinute,
                                  isExpanded: true,
                                  isDense: true,
                                  items: _minutes.map((String m) {
                                    return DropdownMenuItem<String>(
                                      value: m,
                                      child: Center(child: Text(m)),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(
                                        () => _selectedMinute = newValue,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      // ▼ 変更: 時間（長さ）をドロップダウンに変更
                      child: DropdownButtonFormField<String>(
                        value: _selectedDuration,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.durationLabel,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                        ),
                        items: _durationOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() => _selectedDuration = newValue);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      // ▼ 変更: ポイントをドロップダウンに変更
                      child: DropdownButtonFormField<String>(
                        value: _selectedPoints,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.points,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                        ),
                        items: _pointOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() => _selectedPoints = newValue);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                // アイコン選択エリア
                const SizedBox(height: 5),
                Text(
                  'アイコン', // 多言語対応する場合は AppLocalizations に追加してください
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _emojiList.map((emoji) {
                    final isSelected = _selectedIconKey == emoji;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIconKey = emoji;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.15)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade400,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    FirebaseAnalytics.instance.logEvent(
                      name: 'start_add_edit_promise_save',
                    );
                    _savePromise();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(AppLocalizations.of(context)!.registerButton),
                ),
              ],
            ),
          ),
        ),
      ),
      // 画面下部にバナーを設置（初回起動時は広告を表示しない）
      bottomNavigationBar: const AdBanner(),
    );
  }
}
