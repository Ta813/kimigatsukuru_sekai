// lib/screens/splash_screen.dart

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audio_session/audio_session.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kimigatsukuru_sekai/firebase_options.dart';
import 'package:kimigatsukuru_sekai/managers/notification_manager.dart';
import 'package:kimigatsukuru_sekai/managers/permission_manager.dart';
import 'package:kimigatsukuru_sekai/managers/purchase_manager.dart';
import 'package:kimigatsukuru_sekai/managers/reward_ad_manager.dart';
import 'package:kimigatsukuru_sekai/managers/tts_manager.dart';
import 'package:kimigatsukuru_sekai/providers/locale_provider.dart';
import 'package:kimigatsukuru_sekai/screens/initial_setup_coordinator.dart';
import 'package:permission_handler/permission_handler.dart';
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
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAll();
  }

  // 🌟 プログレスバーの描画を確実に更新させるためのメソッド
  Future<void> _updateProgress(double value) async {
    if (!mounted) return;
    setState(() {
      _progress = value;
    });
    // 💡 これが魔法の1行！ 50ミリ秒だけUIスレッドに隙間を作り、画面のバーを再描画させる
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> _initializeAll() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (kDebugMode) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          false,
        );
        await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
        await FirebasePerformance.instance.setPerformanceCollectionEnabled(
          false,
        );
      } else {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          true,
        );
        await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
        await FirebasePerformance.instance.setPerformanceCollectionEnabled(
          true,
        );

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
    FirebaseAnalytics.instance.logEvent(name: 'splash_screen_start');
    await _updateProgress(0.1);

    // 🌟 1. 画面の準備が始まった瞬間に計測スタート！
    final Trace renderTrace = FirebasePerformance.instance.newTrace(
      'splash_screen_trace',
    );
    await renderTrace.start();
    try {
      // revenueCatの初期化
      final Trace revenueCatTrace = FirebasePerformance.instance.newTrace(
        'revenue_cat_init_trace',
      );
      await revenueCatTrace.start();
      try {
        await PurchaseManager.instance.init();
      } catch (e) {
        print("RevenueCat初期化エラー: $e");
      } finally {
        await revenueCatTrace.stop();
      }
      await _updateProgress(0.3); // 30%

      // 初回起動かどうかの判定
      final isFirstLaunch = await SharedPrefsHelper.isFirstLaunch();

      if (isFirstLaunch) {
        // その他の裏側の処理（通知、音声）
        await _initializeBackgroundServices(isFirstLaunch);

        // 広告とパーミッションの初期化（同時に走らせる）
        await _initializeConsent(isFirstLaunch);
        await _updateProgress(1.0); // 100%
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        // 2回目以降の起動は待たない
        // その他の裏側の処理（通知、音声）
        _initializeBackgroundServices(isFirstLaunch);

        // 広告とパーミッションの初期化（同時に走らせる）
        _initializeConsent(isFirstLaunch);
        await _updateProgress(1.0); // 100%
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } finally {
      // 3. 画面が完全に描画された直後に計測を停止！
      await renderTrace.stop();
    }

    // 🌟 4. 初回起動チェック（UI表示の遷移）
    await _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    // 初回起動かどうかの判定
    final isFirstLaunch = await SharedPrefsHelper.isFirstLaunch();

    if (!mounted) return;

    if (isFirstLaunch) {
      //🌟 初回起動：初期設定画面（アバターウィザード）へ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const InitialSetupCoordinator(),
        ),
      );
    } else {
      FirebaseAnalytics.instance.logEvent(name: 'splash_screen_end');
      // 🌟 2回目以降：いつものホーム画面へ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChildHomeScreen()),
      );
    }
  }

  Future<void> _initializeConsent(bool isFirstLaunch) async {
    if (PurchaseManager.instance.isPremium.value) {
      _initializeSDKs();
      return;
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _initializeSDKs();
      return;
    }
    await _runUMPFlow();
    if (isFirstLaunch) {
      await _updateProgress(0.8);
    }
    if (Platform.isIOS) {
      try {
        final status = await Permission.appTrackingTransparency.status;
        if (status == PermissionStatus.denied ||
            status == PermissionStatus.provisional) {
          await Future.delayed(const Duration(milliseconds: 800));
          await PermissionManager.instance.request(
            Permission.appTrackingTransparency,
          );
        }
      } catch (e) {}
    }
    if (isFirstLaunch) {
      await _updateProgress(0.9);
    }
    _initializeSDKs();
  }

  Future<void> _runUMPFlow() async {
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

  Future<void> _initializeSDKs() async {
    final Trace facebookTrace = FirebasePerformance.instance.newTrace(
      'facebook_app_events_trace',
    );
    await facebookTrace.start();
    try {
      final facebookAppEvents = FacebookAppEvents();
      if (Platform.isIOS) {
        final status = await Permission.appTrackingTransparency.status;
        await facebookAppEvents.setAdvertiserTracking(
          enabled: status.isGranted,
        );
      } else {
        await facebookAppEvents.setAdvertiserTracking(enabled: true);
      }
    } catch (e) {
    } finally {
      await facebookTrace.stop();
    }

    if (!PurchaseManager.instance.isPremium.value) {
      final Trace adsTrace = FirebasePerformance.instance.newTrace('ads_trace');
      await adsTrace.start();
      try {
        await MobileAds.instance.initialize();
      } catch (e) {
      } finally {
        await adsTrace.stop();
      }
    }

    // 🌟 アプリ起動時にリワード広告をあらかじめ読み込んでおく
    final Trace rewareAdTrace = FirebasePerformance.instance.newTrace(
      'reward_ad_trace',
    );
    await rewareAdTrace.start();
    try {
      await RewardAdManager.instance.loadAd();
    } catch (e) {
    } finally {
      await rewareAdTrace.stop();
    }
  }

  // ----------------------------------------------------
  // 🌟 画面の裏側で走らせる重い初期化処理をまとめたメソッド
  // ----------------------------------------------------
  Future<void> _initializeBackgroundServices(bool isFirstLaunch) async {
    // ★ 追加: TTS（読み上げ機能）の初期化を先に行う！
    final Trace ttsTrace = FirebasePerformance.instance.newTrace(
      'tts_init_trace',
    );
    await ttsTrace.start();
    try {
      final localeProvider = LocaleProvider();
      final lang = localeProvider.locale!.languageCode;
      await TtsManager().initialize(lang);
    } catch (e) {
      print("TTS初期化エラー: $e");
    } finally {
      await ttsTrace.stop();
    }
    if (isFirstLaunch) {
      await _updateProgress(0.4);
    }
    // ① 音声セッションの初期化
    final Trace audioSessionTrace = FirebasePerformance.instance.newTrace(
      'audio_session_init_trace',
    );
    await audioSessionTrace.start();
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
    } finally {
      await audioSessionTrace.stop();
    }
    if (isFirstLaunch) {
      await _updateProgress(0.5);
    }

    // ② 通知の初期化とスケジュール登録
    final Trace notificationTrace = FirebasePerformance.instance.newTrace(
      'notification_init_trace',
    );
    await notificationTrace.start();
    try {
      await NotificationManager.instance.init();
      await NotificationManager.instance.scheduleWeeklyMonday11AM();
      await NotificationManager.instance
          .rescheduleAllExistingPromises(); // ★追加: 古い通知の不具合を解消するため再スケジュール
    } catch (e) {
      print("通知マネージャーの初期化エラー: $e");
    } finally {
      await notificationTrace.stop();
    }
    if (isFirstLaunch) {
      await _updateProgress(0.6);
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress, // 進捗を反映
                      minHeight: 12,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF7043),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_progress * 100).toInt()}%', // 「40%」のようなテキスト表示
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
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
