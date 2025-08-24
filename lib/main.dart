import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/child/child_home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart'; // flutterfire configureで生成されたファイル
import 'dart:async';
import 'dart:ui';

Future<void> main() async {
  // Firebaseを初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Flutterフレームワーク内でキャッチされなかったエラーをCrashlyticsに送信
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Flutterフレームワーク内で処理されたエラーをCrashlyticsに送信
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  WidgetsFlutterBinding.ensureInitialized();

  // ★広告SDKを初期化する
  await MobileAds.instance.initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft, // 横向き左
    DeviceOrientation.landscapeRight, // 横向き右
  ]);

  // すべての準備が終わってから、アプリを起動します
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'きみがつくる世界',
      // アプリのテーマカラーなどを後で設定できます
      theme: ThemeData(
        fontFamily: GoogleFonts.mochiyPopOne().fontFamily,
        // 2. メインカラー（温かいオレンジ）
        primaryColor: const Color(0xFFFF7043),

        // 3. アクセントカラー（ハニーイエロー）
        // colorSchemeを使い、secondary（2番目の色）に設定します
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF7043), // メインカラーを元に配色を自動生成
          secondary: const Color(0xFFFFCA28), // アクセントカラーを上書き
        ),

        // 4. アプリ全体の背景色（ピーチクリーム）
        scaffoldBackgroundColor: const Color(0xFFFFF3E0),

        // 5. AppBarのデフォルトデザイン
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF7043), // 背景をメインカラーに
          foregroundColor: Colors.white, // 文字やアイコンの色を白に
        ),

        // 6. フローティングアクションボタンのデフォルトデザイン
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFCA28), // 背景をアクセントカラーに
          foregroundColor: Colors.white,
        ),

        // その他のウィジェットのデフォルト色もここで設定できます
        useMaterial3: true,
      ),
      // このアプリの「玄関」となる画面を指定します
      home: const ChildHomeScreen(),
    );
  }
}
