// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import '../helpers/shared_prefs_helper.dart';
import '../l10n/app_localizations.dart'; // 🌟 追加: ローカライズ用のインポート
import 'child/child_home_screen.dart'; // ホーム画面のパスに合わせてください
//import 'initial_setup_coordinator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    // 🌟 アプリ起動時の最低限の待機時間（ロゴを見せるため。不要なら短くしてもOK）
    await Future.delayed(const Duration(seconds: 2));

    // 初回起動かどうかの判定
    final isFirstLaunch = await SharedPrefsHelper.isFirstLaunch();

    if (!mounted) return;

    if (isFirstLaunch) {
      // 🌟 修正: アバターを選択させる画面へ遷移する前に、タイマーをセット
      await SharedPrefsHelper.recordFirstLaunchTime();

      // スキップした場合はデフォルトアバターを保存してホームへ直行
      await SharedPrefsHelper.saveEquippedCharacters([
        'assets/images/character_usagi.gif',
      ]);
      await SharedPrefsHelper.addPurchasedItem('ウサギ');

      await SharedPrefsHelper.setFirstLaunchCompleted();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ChildHomeScreen(isInitialSetup: true),
        ),
      );

      // 🌟 初回起動：初期設定画面（アバターウィザード）へ
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => const InitialSetupCoordinator(),
      //   ),
      // );
    } else {
      // 🌟 2回目以降：いつものホーム画面へ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChildHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // 優しいオレンジの背景
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 💡 もしアプリのロゴ画像があれば、ここのコメントを外して表示できます
            // Image.asset('assets/images/app_icon.png', width: 150),
            // const SizedBox(height: 24),
            const CircularProgressIndicator(color: Color(0xFFFF7043)),
            const SizedBox(height: 24),
            // 🌟 修正: ローカライズ対応
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/character_hime.gif',
                  height: 100,
                  cacheWidth: 200,
                ),
                const SizedBox(width: 20),
                Text(
                  AppLocalizations.of(context)!.splashLoadingMessage,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),
                Image.asset(
                  'assets/images/character_kuma.gif',
                  height: 100,
                  cacheWidth: 200,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
