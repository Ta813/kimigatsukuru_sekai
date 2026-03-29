// lib/screens/parent_mode/parent_top_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/custom_back_button.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'regular_promise_settings_screen.dart';
import 'emergency_promise_screen.dart';
import '../../managers/sfx_manager.dart';
import 'advice_screen.dart';
import '../../l10n/app_localizations.dart';
import 'settings_screen.dart';
import 'child_name_settings_screen.dart';
import '../../widgets/blinking_effect.dart';

class ParentTopScreen extends StatefulWidget {
  const ParentTopScreen({super.key});

  @override
  State<ParentTopScreen> createState() => _ParentTopScreenState();
}

class _ParentTopScreenState extends State<ParentTopScreen> {
  // ボタンごとの初回フラグ
  bool _isFirstAdvice = false; // 「最初にお読みください」
  bool _isFirstRegular = false; // 「定例のやくそく設定」

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isFirstAdvice = prefs.getBool('is_first_home_advice') ?? true;
        _isFirstRegular = prefs.getBool('is_first_home_regular') ?? true;
      });
    }
  }

  /// 「最初にお読みください」を押したら点滅解除
  Future<void> _markAdviceDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_home_advice', false);
    if (mounted) setState(() => _isFirstAdvice = false);
  }

  /// 「定例のやくそく設定」を押したら点滅解除
  Future<void> _markRegularDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_home_regular', false);
    if (mounted) setState(() => _isFirstRegular = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text(AppLocalizations.of(context)!.parentScreenTitle),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChildNameSettingsScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.face_retouching_natural),
                  Text(
                    AppLocalizations.of(context)!.nameSetting,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.settings),
                  Text(
                    AppLocalizations.of(context)!.settingsTitle,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            // 画面いっぱいに広げる
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 「最初にお読みください」ボタン
              BlinkingEffect(
                isBlinking: _isFirstAdvice,
                borderRadius: 4,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.lightbulb_outline),
                  label: Text(AppLocalizations.of(context)!.readFirstButton),
                  onPressed: () {
                    FirebaseAnalytics.instance.logEvent(
                      name: 'start_parent_top_read_first',
                    );
                    // 押した瞬間に点滅解除
                    _markAdviceDone();
                    try {
                      SfxManager.instance.playTapSound();
                    } catch (e) {
                      // エラーが発生した場合
                      print('再生エラー: $e');
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdviceScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(fontSize: 16),
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // 「定例のやくそく設定」ボタン
              BlinkingEffect(
                isBlinking: _isFirstRegular,
                borderRadius: 4,
                child: ElevatedButton(
                  onPressed: () async {
                    FirebaseAnalytics.instance.logEvent(
                      name: 'start_parent_top_regular_promise',
                    );
                    // 押した瞬間に点滅解除
                    await _markRegularDone();
                    try {
                      SfxManager.instance.playTapSound();
                    } catch (e) {
                      // エラーが発生した場合
                      print('再生エラー: $e');
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const RegularPromiseSettingsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    // main.dartで設定したテーマカラーが適用されます
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.regularPromiseSettingsButton,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // 「緊急のやくそく設定」ボタン
              ElevatedButton(
                onPressed: () {
                  FirebaseAnalytics.instance.logEvent(
                    name: 'start_parent_top_emergency_promise',
                  );
                  try {
                    SfxManager.instance.playTapSound();
                  } catch (e) {
                    // エラーが発生した場合
                    print('再生エラー: $e');
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmergencyPromiseScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(
                  AppLocalizations.of(context)!.emergencyPromiseSettingsButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
