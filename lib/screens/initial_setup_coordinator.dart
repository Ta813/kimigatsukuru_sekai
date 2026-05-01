// lib/screens/initial_setup_coordinator.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/managers/bgm_manager.dart';
import 'package:kimigatsukuru_sekai/screens/parent/regular_promise_settings_screen.dart'; // 本物の画面
import 'package:kimigatsukuru_sekai/screens/premium_paywall_screen.dart'; // 🌟 プレミアム画面をインポート
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
  // 最初のイントロ画面を表示するかどうかのフラグ
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    _playSavedBgm();
  }

  Future<void> _playSavedBgm() async {
    final trackName = await SharedPrefsHelper.loadSelectedBgm();
    final track = BgmTrack.values.firstWhere(
      (e) => e.name == trackName,
      orElse: () => BgmTrack.main,
    );
    try {
      BgmManager.instance.play(track);
    } catch (e) {
      print('再生エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntro) {
      return _buildIntroScreen();
    }

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
                  _startPatternB(context); // パターンB: こども ➔ おとな
                },
              ),
              _buildAgeButton(
                context,
                label: '8 〜 12さい',
                onTap: () {
                  FirebaseAnalytics.instance.logEvent(name: 'setup_age_8-12');
                  _startPatternC(context); // パターンC: こども ➔ おとな（バトンなし）
                },
              ),
              _buildAgeButton(
                context,
                label: '13 〜 18さい',
                onTap: () {
                  FirebaseAnalytics.instance.logEvent(name: 'setup_age_13-18');
                  _startPatternC(context); // パターンC: こども ➔ おとな（バトンなし）
                },
              ),
              _buildAgeButton(
                context,
                label: '18さい 〜 (ほごしゃ)',
                isAdult: true,
                onTap: () {
                  FirebaseAnalytics.instance.logEvent(name: 'setup_age_18-');
                  _startPatternA(context); // パターンA: おとな ➔ こども
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 年齢を聞く前のイントロ画面
  Widget _buildIntroScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset('assets/images/character_panda.gif', height: 100),
                  const SizedBox(width: 20),
                  Image.asset('assets/images/character_kuma.gif', height: 100),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'アプリの せってい を はじめます！\nおよそ 3分 ていどで おわります。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  try {
                    FirebaseAnalytics.instance.logEvent(name: 'setup_start');
                    SfxManager.instance.playTapSound();
                  } catch (e) {}
                  setState(() {
                    _showIntro = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7043),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'つぎへ',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const RegularPromiseSettingsScreen(isInitialSetup: true),
      ),
    );
    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PassDeviceScreen(isToChild: true, progress: 0.5),
      ),
    );
    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CharacterCustomizeScreen(isInitialSetup: true),
      ),
    );
    if (!context.mounted) return;

    await _finishSetup(context);
  }

  // ==============================================================
  // 🌟 パターンB: 子供 ➔ おとな（バトンタッチあり）
  // ==============================================================
  Future<void> _startPatternB(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CharacterCustomizeScreen(isInitialSetup: true),
      ),
    );
    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PassDeviceScreen(isToChild: false, progress: 0.5),
      ),
    );
    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const RegularPromiseSettingsScreen(isInitialSetup: true),
      ),
    );
    if (!context.mounted) return;

    await _finishSetup(context);
  }

  // ==============================================================
  // 🌟 パターンC: 子供 ➔ おとな（バトンタッチなし）
  // ==============================================================
  Future<void> _startPatternC(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CharacterCustomizeScreen(isInitialSetup: true),
      ),
    );
    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const RegularPromiseSettingsScreen(isInitialSetup: true),
      ),
    );
    if (!context.mounted) return;

    await _finishSetup(context);
  }

  // ==============================================================
  // 🌟 すべての設定が終わったあとの処理（Paywall ➔ 100%完了画面 ➔ ホーム）
  // ==============================================================
  Future<void> _finishSetup(BuildContext context) async {
    // 1. プレミアムプランへの誘導
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
    );
    if (!context.mounted) return;

    // 2. ダイアログではなく、「100%完了画面（全画面）」へ遷移
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SetupCompleteScreen()),
    );
    if (!context.mounted) return;

    // 3. 全て完了したのでフラグを保存してホームへ
    await SharedPrefsHelper.setFirstLaunchCompleted();
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
    );
  }
}

// ==============================================================
// 🌟 最終のセットアップ100%完了画面 (全画面)
// ==============================================================
class SetupCompleteScreen extends StatelessWidget {
  const SetupCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🌟 100%の進捗バー
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  const Text(
                    'セットアップ 100% かんりょう！',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                      value: 1.0, // 100%完了
                      backgroundColor: Colors.white54,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.orangeAccent,
                      ),
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset('assets/images/character_panda.gif', height: 100),
                const SizedBox(width: 20),
                Image.asset('assets/images/character_kuma.gif', height: 100),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'きみだけの せかいへ\nしゅっぱつしよう！',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                try {
                  SfxManager.instance.playTapSound();
                } catch (_) {}
                Navigator.pop(context); // 画面を閉じて、呼び出し元(_finishSetup)へ返す
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              child: const Text(
                'しゅっぱつ！',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================
// 🌟 バトンタッチ（スマホを渡す）画面
// ==============================================================
class PassDeviceScreen extends StatelessWidget {
  final bool isToChild;
  final double progress;

  const PassDeviceScreen({
    super.key,
    required this.isToChild,
    this.progress = 0.5,
  });

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  Text(
                    'セットアップ ${(progress * 100).toInt()}% かんりょう！',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white54,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isToChild ? Colors.orangeAccent : Colors.blueAccent,
                      ),
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),

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
