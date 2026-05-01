// lib/screens/initial_setup_coordinator.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import '../helpers/shared_prefs_helper.dart';
import '../managers/sfx_manager.dart';
import 'child/child_home_screen.dart';
import 'child/character_customize_screen.dart';

class InitialSetupCoordinator extends StatefulWidget {
  const InitialSetupCoordinator({super.key});

  @override
  State<InitialSetupCoordinator> createState() =>
      _InitialSetupCoordinatorState();
}

class _InitialSetupCoordinatorState extends State<InitialSetupCoordinator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'なんさい ですか？',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),
              // 年齢選択のリスト
              _buildAgeButton(
                context,
                label: '〜 7さい',
                onTap: () {
                  FirebaseAnalytics.instance.logEvent(name: 'setup_age_-7');
                  _startPatternB(context);
                }, // パターンB: こども ➔ おとな
              ),
              _buildAgeButton(
                context,
                label: '8 〜 12さい',
                onTap: () {
                  FirebaseAnalytics.instance.logEvent(name: 'setup_age_8-12');
                  _startPatternC(context);
                }, // パターンC: こども ➔ おとな（バトンなし）
              ),
              _buildAgeButton(
                context,
                label: '13 〜 18さい',
                onTap: () {
                  FirebaseAnalytics.instance.logEvent(name: 'setup_age_13-18');
                  _startPatternC(context);
                }, // パターンC: こども ➔ おとな（バトンなし）
              ),
              _buildAgeButton(
                context,
                label: '18さい 〜 (ほごしゃ)',
                isAdult: true,
                onTap: () {
                  FirebaseAnalytics.instance.logEvent(name: 'setup_age_18-');
                  _startPatternA(context);
                }, // パターンA: おとな ➔ こども
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgeButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    bool isAdult = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isAdult ? Colors.blueAccent : Colors.white,
          foregroundColor: isAdult ? Colors.white : Colors.black87,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(
            color: isAdult ? Colors.blue : Colors.orangeAccent,
            width: 2,
          ),
          elevation: 2,
        ),
        onPressed: () {
          try {
            SfxManager.instance.playTapSound();
          } catch (e) {}
          onTap();
        },
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ==============================================================
  // 🌟 パターンA: おとな ➔ 子供（バトンタッチあり）
  // ==============================================================
  Future<void> _startPatternA(BuildContext context) async {
    // 1. おとな（親）向け設定
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DummyParentSetupScreen()),
    );
    if (!context.mounted) return;

    // 2. スマホを子供に渡す画面
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PassDeviceScreen(isToChild: true),
      ),
    );
    if (!context.mounted) return;

    // 3. 子供向け設定（アバターなど）
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CharacterCustomizeScreen(isInitialSetup: true),
      ),
    );
    if (!context.mounted) return;

    _finishSetup(context);
  }

  // ==============================================================
  // 🌟 パターンB: 子供 ➔ おとな（バトンタッチあり）
  // ==============================================================
  Future<void> _startPatternB(BuildContext context) async {
    // 1. 子供向け設定
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CharacterCustomizeScreen(isInitialSetup: true),
      ),
    );
    if (!context.mounted) return;

    // 2. スマホを親に渡す画面
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PassDeviceScreen(isToChild: false),
      ),
    );
    if (!context.mounted) return;

    // 3. おとな（親）向け設定
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DummyParentSetupScreen()),
    );
    if (!context.mounted) return;

    _finishSetup(context);
  }

  // ==============================================================
  // 🌟 パターンC: 子供 ➔ おとな（バトンタッチなし）
  // ==============================================================
  Future<void> _startPatternC(BuildContext context) async {
    // 1. 子供向け設定
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CharacterCustomizeScreen(isInitialSetup: true),
      ),
    );
    if (!context.mounted) return;

    // 2. おとな（親）向け設定（そのまま連続して表示）
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DummyParentSetupScreen()),
    );
    if (!context.mounted) return;

    _finishSetup(context);
  }

  void _finishSetup(BuildContext context) async {
    await SharedPrefsHelper.setFirstLaunchCompleted();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
    );
  }
}

// ==============================================================
// 🌟 バトンタッチ（スマホを渡す）画面
// ==============================================================
class PassDeviceScreen extends StatelessWidget {
  final bool isToChild;

  const PassDeviceScreen({super.key, required this.isToChild});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isToChild
          ? const Color(0xFFFFF3E0)
          : const Color(0xFFE3F2FD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isToChild ? Icons.child_care : Icons.face_retouching_natural,
              size: 100,
              color: isToChild ? Colors.orangeAccent : Colors.blueAccent,
            ),
            const SizedBox(height: 24),
            Text(
              isToChild ? 'スマホを お子さまに\nわたしてね！' : 'スマホを おうちの人に\nわたしてね！',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                try {
                  SfxManager.instance.playTapSound();
                } catch (e) {}
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isToChild
                    ? Colors.orangeAccent
                    : Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'うけとった！',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================
// 🌟 親向け設定のダミー画面
// ==============================================================
class DummyParentSetupScreen extends StatelessWidget {
  const DummyParentSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text('保護者向け設定'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '「約束」と「通知」の設定をします。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                try {
                  SfxManager.instance.playTapSound();
                } catch (e) {}
                Navigator.pop(context);
              },
              child: const Text('設定を完了する'),
            ),
          ],
        ),
      ),
    );
  }
}
