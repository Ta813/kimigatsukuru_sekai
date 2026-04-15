import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import 'managers/purchase_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

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
    if (kDebugMode) {
      // デバッグモード時はクラッシュレポートを無効化
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      // リリースモード時は有効化し、エラー捕捉を設定
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
    }
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

  // ③ RevenueCatの初期化 (広告の要否を判断するために先に実行)
  try {
    await PurchaseManager.instance.init();
  } catch (e) {
    print("RevenueCat初期化エラー: $e");
  }

  // ④ 広告同意・トラッキング許可・SDK初期化の一連の流れを実行
  // (プレミアム会員でない、またはFacebook等のトラッキングが必要な場合)
  // 💡 ここでは await せずに、他の初期化（音声や通知）と並行して走らせますが、
  // 内部的には UMP -> ATT -> SDK の順序を厳守します。
  _initTrackingAndAdsFlow();
}

// ----------------------------------------------------
// 🌟 トラッキングと広告の初期化フロー
// [UMPダイアログ] ➡ [ATTダイアログ] ➡ [SDK初期化] の順序を保証する
// ----------------------------------------------------
Future<void> _initTrackingAndAdsFlow() async {
  try {
    // 1. UMP (同意ダイアログ) の確認と表示
    // ※ 内部的に非プレミアムかつオンラインの場合のみ実行される
    await _initializeConsent();

    // 2. ATT (iOSトラッキング許可) のリクエスト
    // ※ iOSかつ、UMPが完了した直後に実行
    await _requestATT();

    // 3. 各種SDKの初期化 (Facebook, AdMob)
    // ※ ATTの返答を受け取った後に実行
    await _initializeSDKs();
  } catch (e) {
    print("初期化フローエラー: $e");
    // エラー時も最低限の初期化を試みる
    await _initializeSDKs();
  }
}

Future<void> _initializeConsent() async {
  // プレミアム会員の場合はUMPをスキップ
  if (PurchaseManager.instance.isPremium.value) return;

  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) return;

  final completer = Completer<void>();
  final params = ConsentRequestParameters();

  ConsentInformation.instance.requestConsentInfoUpdate(
    params,
    () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        ConsentForm.loadConsentForm(
          (ConsentForm consentForm) async {
            var status = await ConsentInformation.instance.getConsentStatus();
            if (status == ConsentStatus.required) {
              consentForm.show((FormError? formError) {
                completer.complete();
              });
            } else {
              completer.complete();
            }
          },
          (FormError formError) {
            completer.complete();
          },
        );
      } else {
        completer.complete();
      }
    },
    (FormError error) {
      completer.complete();
    },
  );

  return completer.future;
}

Future<void> _requestATT() async {
  if (!Platform.isIOS) return;

  try {
    await Permission.appTrackingTransparency.request();
  } catch (e) {
    print("ATTリクエストエラー: $e");
  }
}

Future<void> _initializeSDKs() async {
  // ① Facebook SDKの初期化
  try {
    final facebookAppEvents = FacebookAppEvents();
    if (Platform.isIOS) {
      final status = await Permission.appTrackingTransparency.status;
      await facebookAppEvents.setAdvertiserTracking(enabled: status.isGranted);
    }
  } catch (e) {
    print("Facebook SDK初期化エラー: $e");
  }

  // ② AdMob SDKの初期化 (プレミアム会員でない場合のみ)
  if (!PurchaseManager.instance.isPremium.value) {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      print("AdMob初期化エラー: $e");
    }
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
          if (deviceLocale.languageCode == 'ur') {
            return const Locale('ur');
          }
          if (deviceLocale.languageCode == 'bn') {
            return const Locale('bn');
          }
          if (deviceLocale.languageCode == 'ar') {
            return const Locale('ar');
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
        Locale('ur', ''), // ウルドゥー語
        Locale('bn', ''), // ベンガル語
        Locale('ar', ''), // アラビア語
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
