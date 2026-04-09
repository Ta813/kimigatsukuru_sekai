// lib/screens/parent_mode/add_edit_promise_screen.dart

import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/widgets/ad_banner.dart';
import '../../widgets/custom_back_button.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import '../../managers/sfx_manager.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';

class AddEditPromiseScreen extends StatefulWidget {
  final Map<String, dynamic>? initialPromise;
  const AddEditPromiseScreen({super.key, this.initialPromise});

  @override
  State<AddEditPromiseScreen> createState() => _AddEditPromiseScreenState();
}

class _AddEditPromiseScreenState extends State<AddEditPromiseScreen> {
  // フォームの状態を管理するためのキー
  final _formKey = GlobalKey<FormState>();

  // 各入力欄の値を保持するためのコントローラー
  final _titleController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _durationController = TextEditingController();
  final _pointsController = TextEditingController();

  TimeOfDay? _selectedTime;

  // アイコンの選択肢を定義（キー名：アイコンデータ）
  final Map<String, IconData> _iconMap = {
    'star': Icons.star,
    'school': Icons.school,
    'book': Icons.menu_book,
    'sports': Icons.sports_baseball,
    'game': Icons.sports_esports,
    'clean': Icons.cleaning_services,
    'pets': Icons.pets,
    'music': Icons.music_note,
  };

  // 現在選択されているアイコンのキー（デフォルトは星）
  String _selectedIconKey = 'star';

  @override
  void initState() {
    super.initState();
    // もし編集モードなら (initialPromiseがnullでなければ)
    if (widget.initialPromise != null) {
      // 各コントローラーに初期値を設定する
      _titleController.text = widget.initialPromise!['title'] ?? '';
      _startTimeController.text = widget.initialPromise!['time'] ?? '';
      _durationController.text =
          widget.initialPromise!['duration']?.toString() ?? '';
      _pointsController.text =
          widget.initialPromise!['points']?.toString() ?? '';

      // アイコンの初期値を設定
      _selectedIconKey = widget.initialPromise!['icon'] ?? 'star';
    }
  }

  // 画面が閉じられる時にお片付け
  @override
  void dispose() {
    _titleController.dispose();
    _startTimeController.dispose();
    _durationController.dispose();
    _pointsController.dispose();
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
        'time': _startTimeController.text,
        // intに変換。失敗したら0にする
        'duration': int.tryParse(_durationController.text) ?? 0,
        'points': int.tryParse(_pointsController.text) ?? 0,
        // 選択されたアイコンのキーを保存
        'icon': _selectedIconKey,
      };
      // "結果"として新しいやくそくのデータを渡しつつ、前の画面に戻る
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(newPromise);
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    // タイムピッカーを呼び出し、ユーザーが時刻を選ぶのを待ちます
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      // ピッカーの初期時刻を、現在選択されている時刻か、現在時刻に設定
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    // もしユーザーが時刻を選んでくれたら
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        // TextEditingControllerのテキストを、選ばれた時刻で更新
        _startTimeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // ▼ 変更: やくそくの名前と開始時間を横並びにする
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
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2, // 時間は少し狭くてもOK
                      child: TextFormField(
                        controller: _startTimeController,
                        readOnly: true, // テキストの手入力を不可にする
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.startTimeLabel,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                          suffixIcon: const Icon(
                            Icons.access_time,
                          ), // 時計アイコンを追加
                        ),
                        onTap: () {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'start_add_edit_promise_time_picker',
                          );
                          // タップされたら、タイムピッカーを呼び出す
                          _selectTime(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
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
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ], // 数字のみ入力可
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _pointsController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.points,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: kDebugMode ? null : 2,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(kDebugMode ? 10 : 2),
                        ],
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
                const SizedBox(height: 5),
                Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: _iconMap.entries.map((entry) {
                    final isSelected = _selectedIconKey == entry.key;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIconKey = entry.key;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade400,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          entry.value,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 15),
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
