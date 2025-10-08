import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/child/child_home_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart'; // flutterfire configureで生成されたファイル
import 'dart:async';
import 'dart:ui';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeProvider = LocaleProvider();
  await localeProvider.init();
  // Firebaseを初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 子供向けアプリとして、広告IDなどのデータ収集を無効化する
  await FirebaseAnalytics.instance.setConsent(
    analyticsStorageConsentGranted: false,
    adStorageConsentGranted: false,
  );

  // Flutterフレームワーク内でキャッチされなかったエラーをCrashlyticsに送信
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Flutterフレームワーク内で処理されたエラーをCrashlyticsに送信
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // ★広告SDKを初期化する
  await MobileAds.instance.initialize();

  // 全ての広告リクエストを子供向けとして扱う
  final requestConfiguration = RequestConfiguration(
    tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
    maxAdContentRating: MaxAdContentRating.g,
  );
  await MobileAds.instance.updateRequestConfiguration(requestConfiguration);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft, // 横向き左
    DeviceOrientation.landscapeRight, // 横向き右
  ]);

  // すべての準備が終わってから、アプリを起動します
  runApp(
    ChangeNotifierProvider.value(value: localeProvider, child: const MyApp()),
  );
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
        if (deviceLocale != null && deviceLocale.languageCode == 'ja') {
          return const Locale('ja');
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
    );
  }
}
