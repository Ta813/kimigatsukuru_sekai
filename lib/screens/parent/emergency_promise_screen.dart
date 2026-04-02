// lib/screens/parent_mode/emergency_promise_screen.dart

import 'package:flutter/material.dart';
import '../child/child_home_screen.dart';
import 'package:kimigatsukuru_sekai/widgets/ad_banner.dart';
import '../../widgets/custom_back_button.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';

class EmergencyPromiseScreen extends StatefulWidget {
  const EmergencyPromiseScreen({super.key});

  @override
  State<EmergencyPromiseScreen> createState() => _EmergencyPromiseScreenState();
}

class _EmergencyPromiseScreenState extends State<EmergencyPromiseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController(text: '10'); // 初期値を10分に
  final _pointsController = TextEditingController(text: '10'); // 初期値を10ポイントに

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _pointsController.dispose();
    super.dispose();
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
        'duration': int.tryParse(_durationController.text) ?? 10,
        'points': int.tryParse(_pointsController.text) ?? 10,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.promiseNameHint;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _durationController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.durationLabel,
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                TextFormField(
                  controller: _pointsController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.points,
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: kDebugMode ? null : 2,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(kDebugMode ? 10 : 2),
                  ],
                ),
                const SizedBox(height: 16),
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
      // 画面下部にバナーを設置（初回起動時は広告を表示しない）
      bottomNavigationBar: const AdBanner(),
    );
  }
}
