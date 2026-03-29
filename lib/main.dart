import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/child/child_home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart'; // flutterfire configureで生成されたファイル
import 'dart:async';
import 'dart:ui';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:audio_session/audio_session.dart';
import 'managers/notification_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🌟 1. 画面の描画（UI）に絶対必要なもの「だけ」を先に待つ
  // 多言語対応の初期化
  final localeProvider = LocaleProvider();
  await localeProvider.init();

  // Firebaseの初期化（※オフラインでも絶対に初期化してOKです！）
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // クラッシュレポートの設定
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
  } catch (e) {
    print('Firebaseの初期化に失敗しました: $e');
  }

  // 🌟 2. 画面の描画を邪魔しないように、重い処理は「裏側」に投げる
  // （await をつけずに呼び出すことで、処理を裏で走らせたまま次に進みます）
  _initializeBackgroundServices();

  // 🌟 3. UIに最低限必要な準備が終わったら、爆速でアプリを起動します！
  runApp(
    ChangeNotifierProvider.value(value: localeProvider, child: const MyApp()),
  );
}

// ----------------------------------------------------
// 🌟 画面の裏側で走らせる重い初期化処理をまとめたメソッド
// ----------------------------------------------------
Future<void> _initializeBackgroundServices() async {
  // ① 音声セッションの初期化
  try {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.ambient,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.game,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientMayDuck,
      ),
    );
  } catch (e) {
    print("AudioSessionの初期化エラー: $e");
  }

  // ② 通知の初期化とスケジュール登録
  try {
    await NotificationManager.instance.init();
    await NotificationManager.instance.scheduleWeeklyMonday11AM();
  } catch (e) {
    print("通知マネージャーの初期化エラー: $e");
  }

  // ③ Facebook SDKの初期化
  try {
    //final facebookAppEvents = FacebookAppEvents();
    FacebookAppEvents();
    // 💡 既にキッズカテゴリから脱却しているため、大人向けの広告最適化ができるよう、
    // ここは enabled: false を消すか、必要に応じて true に切り替えるのがおすすめです。
    // await facebookAppEvents.setAdvertiserTracking(enabled: true);
  } catch (e) {
    print("Facebook SDKの初期化エラー: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      locale: localeProvider.locale,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // 端末の言語設定が日本語だったら、日本語を選択
        if (deviceLocale != null) {
          if (deviceLocale.languageCode == 'ja') {
            return const Locale('ja');
          }
          if (deviceLocale.languageCode == 'hi') {
            return const Locale('hi');
          }
        }
        // それ以外の場合は、すべて英語をデフォルトにする
        return const Locale('en');
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // 英語
        Locale('ja', ''), // 日本語
        Locale('hi', ''), // ヒンディー語
      ],

      // アプリのテーマカラーなどを後で設定できます
      theme: ThemeData(
        fontFamily: 'MochiyPopOne',
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
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
    );
  }
}
