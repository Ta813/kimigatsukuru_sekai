// lib/screens/parent_mode/add_edit_promise_screen.dart

import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    // ★もし編集モードなら (initialPromiseがnullでなければ)
    if (widget.initialPromise != null) {
      // 各コントローラーに初期値を設定する
      _titleController.text = widget.initialPromise!['title'] ?? '';
      _startTimeController.text = widget.initialPromise!['time'] ?? '';
      _durationController.text =
          widget.initialPromise!['duration']?.toString() ?? '';
      _pointsController.text =
          widget.initialPromise!['points']?.toString() ?? '';
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
      };
      // "結果"として新しいやくそくのデータを渡しつつ、前の画面に戻る
      Navigator.of(context).pop(newPromise);
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
        title: Text(
          widget.initialPromise == null
              ? AppLocalizations.of(context)!.addRegularPromiseTitle
              : AppLocalizations.of(context)!.editRegularPromiseTitle,
        ),
      ),
      body: SingleChildScrollView(
        // キーボード表示で画面がはみ出ないようにする
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.promiseNameLabel,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.promiseNameHint;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startTimeController,
                readOnly: true, // テキストの手入力を不可にする
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.startTimeLabel,
                  suffixIcon: Icon(Icons.access_time), // 時計アイコンを追加
                ),
                onTap: () {
                  // タップされたら、タイムピッカーを呼び出す
                  _selectTime(context);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.durationLabel,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ], // 数字のみ入力可
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pointsController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.points,
                ),
                keyboardType: TextInputType.number,
                maxLength: kDebugMode ? null : 2,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(kDebugMode ? 10 : 2),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _savePromise,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(AppLocalizations.of(context)!.registerButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
