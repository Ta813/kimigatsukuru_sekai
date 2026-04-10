// lib/screens/parent_mode/emergency_promise_screen.dart

import 'package:flutter/material.dart';
import '../child/child_home_screen.dart';
import '../../widgets/custom_back_button.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../l10n/app_localizations.dart';

class EmergencyPromiseScreen extends StatefulWidget {
  const EmergencyPromiseScreen({super.key});

  @override
  State<EmergencyPromiseScreen> createState() => _EmergencyPromiseScreenState();
}

class _EmergencyPromiseScreenState extends State<EmergencyPromiseScreen> {
  final _formKey = GlobalKey<FormState>();

  // やくそくの名前用コントローラー
  final _titleController = TextEditingController();

  // ▼ 追加: 各ドロップダウン用の選択肢リストを生成
  final List<String> _durationOptions = List.generate(
    120,
    (index) => (index + 1).toString(),
  ); // 1〜120分
  final List<String> _pointOptions = List.generate(
    100,
    (index) => (index + 1).toString(),
  ); // 1〜100ポイント

  // ▼ 追加: 選択中の値を保持する変数（初期値は10）
  String _selectedDuration = '10';
  String _selectedPoints = '10';

  // おすすめのリスト
  final List<Map<String, dynamic>> _recommendedPromises = [
    {'icon': '✨', 'title': 'おてつだい', 'duration': 15, 'points': 15},
    {'icon': '✍️', 'title': 'しゅくだい', 'duration': 30, 'points': 20},
    {'icon': '🧸', 'title': 'おかたづけ', 'duration': 10, 'points': 10},
    {'icon': '📚', 'title': 'ほんをよむ', 'duration': 20, 'points': 10},
    {'icon': '🛁', 'title': 'おふろそうじ', 'duration': 10, 'points': 15},
    {'icon': '🛍️', 'title': 'おつかい', 'duration': 20, 'points': 20},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // おすすめリストの「＋」が押された時の処理
  void _applyRecommended(Map<String, dynamic> promise) {
    try {
      SfxManager.instance.playTapSound();
    } catch (e) {
      print('再生エラー: $e');
    }

    setState(() {
      _titleController.text = promise['title'] as String;
      // ▼ 変更: ドロップダウンの選択値を更新
      _selectedDuration = promise['duration'].toString();
      _selectedPoints = promise['points'].toString();
    });
  }

  void _savePromise() async {
    try {
      SfxManager.instance.playTapSound();
    } catch (e) {
      // エラーが発生した場合
      print('再生エラー: $e');
    }
    if (_formKey.currentState!.validate()) {
      final emergencyPromise = {
        'title': _titleController.text,
        // ▼ 変更: 選択されている値を数値に変換して保存
        'duration': int.tryParse(_selectedDuration) ?? 10,
        'points': int.tryParse(_selectedPoints) ?? 10,
      };
      // SharedPreferencesに保存
      await SharedPrefsHelper.saveEmergencyPromise(emergencyPromise);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.emergencyPromiseSet(_titleController.text),
            ),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ChildHomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text(
          AppLocalizations.of(context)!.emergencyPromiseSettingsTitle,
        ),
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==============================
            // 左側エリア：おすすめリスト
            // ==============================
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        '💡 おすすめ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _recommendedPromises.length,
                        itemBuilder: (context, index) {
                          final promise = _recommendedPromises[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            elevation: 1,
                            child: ListTile(
                              leading: Text(
                                promise['icon'] as String,
                                style: const TextStyle(fontSize: 24),
                              ),
                              contentPadding: const EdgeInsets.only(
                                left: 8,
                                right: 4,
                                top: 0,
                                bottom: 0,
                              ),
                              title: Text(
                                promise['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${promise['duration']}分 / ${promise['points']}ポイント',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.add_circle,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () => _applyRecommended(promise),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // ==============================
            // 右側エリア：入力フォーム
            // ==============================
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.promiseNameExampleHint,
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
                      const SizedBox(height: 10),

                      // ▼ 変更: 時間（長さ）をドロップダウンに変更
                      DropdownButtonFormField<String>(
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
                            child: Text('$value'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() => _selectedDuration = newValue);
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      // ▼ 変更: ポイントをドロップダウンに変更
                      DropdownButtonFormField<String>(
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
                            child: Text('$value'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() => _selectedPoints = newValue);
                          }
                        },
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'start_emergency_promise_set',
                          );
                          _savePromise();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.setThisPromiseButton,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
