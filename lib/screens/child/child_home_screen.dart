// lib/screens/child_home_screen.dart

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as import_ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kimigatsukuru_sekai/helpers/image_share_helper.dart';
import 'package:kimigatsukuru_sekai/managers/app_update_manager.dart';
import 'package:kimigatsukuru_sekai/managers/notification_manager.dart';
import 'package:kimigatsukuru_sekai/managers/purchase_manager.dart';
import 'package:kimigatsukuru_sekai/managers/trophy_manager.dart';
import 'package:kimigatsukuru_sekai/screens/child/trophy_screen.dart';
import 'package:kimigatsukuru_sekai/screens/initial_setup_coordinator.dart';
import 'package:kimigatsukuru_sekai/screens/parent/emergency_promise_screen.dart';
import 'package:kimigatsukuru_sekai/screens/parent/settings_screen.dart';
import 'package:kimigatsukuru_sekai/screens/point_addition_screen.dart';
import 'package:kimigatsukuru_sekai/screens/premium_paywall_screen.dart';
import 'package:kimigatsukuru_sekai/widgets/breathing_avatar.dart';
import 'package:kimigatsukuru_sekai/widgets/tutorial_character_bubble.dart';
import '../../models/lock_mode.dart';
import '../../widgets/draggable_character.dart';
import 'bgm_selection_screen.dart';
import 'mission_screen.dart';
import 'passcode_lock_dialog.dart';
import 'promise_board_screen.dart';
import 'timer_screen.dart';
import '../parent/parent_top_screen.dart';
import '../../helpers/shared_prefs_helper.dart';
import 'character_customize_screen.dart';
import '../../managers/permission_manager.dart';
import '../../managers/bgm_manager.dart';
import '../../managers/sfx_manager.dart';
import 'math_lock_dialog.dart';
import '../../l10n/app_localizations.dart';
import 'house_interior_screen.dart';
import 'world_map_screen.dart';
import 'package:flutter/services.dart';

import 'package:in_app_review/in_app_review.dart';
import 'help_menu_dialog.dart';
import '../../managers/login_bonus_manager.dart';
import '../../widgets/blinking_effect.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/avatar_display.dart';
import '../../widgets/animated_tap_finger.dart';
import 'package:kimigatsukuru_sekai/managers/reward_ad_manager.dart';
import 'package:home_widget/home_widget.dart'; // 🌟 追加
import '../../widgets/widget_action_selection_dialog.dart'; // 🌟 追加
import '../../helpers/widget_capture_helper.dart';

class ChildHomeScreen extends StatefulWidget {
  final bool isInitialSetup;
  const ChildHomeScreen({super.key, this.isInitialSetup = false});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _pointsAddedAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  OverlayEntry? _currentPointOverlay;

  String _equippedFace = 'assets/images/face/face_default.png';
  String _equippedHair = 'assets/images/hair/hair_default.png';
  String _equippedClothes = 'assets/images/clothes/clothes_default.png';
  String? _equippedHeadgear;
  String? _equippedAccessory;
  String _equippedHousePath = 'assets/images/house.png'; // デフォルト画像
  List<String> _equippedCharacters = [
    'assets/images/character_usagi.gif',
  ]; // デフォルト画像
  String _equippedWorldPath = 'assets/images/world.png';

  List<String> _equippedItems = [];
  Map<String, Offset> _itemPositionsMap = {};

  // ポイント数の状態を管理するための変数
  int _points = 0;

  Map<String, dynamic>? _displayPromise; // 実際に下のバーに表示するやくそく
  bool _isDisplayPromiseEmergency = false; // 表示しているのが緊急かどうか

  Offset _avatarPosition = const Offset(205, 190);

  // 各応援キャラの位置を管理するためのMap
  Map<String, Offset> _characterPositionsMap = {};

  bool _showHouseHint = false; // 吹き出しを表示するかどうかの旗
  Timer? _hintTimer; // 吹き出しを自動で消すためのタイマー

  // 各種点滅フラグ
  bool _showStartBlinking = false;
  bool _showEmergencyStartBlinking = false;
  bool _hasEnteredHouse = false;
  bool _showParentSettingsBlinking = false;
  bool _isTutorialParentSettingsFocus = false;
  bool _showCustomizeBlinking = false;
  late AnimationController _hintAnimationController;
  bool _hasUnclaimedMissions = true;
  bool _showMissionBubble = false; // 🌟 追加：吹き出しを出すかどうかのフラグ
  bool _hasVisitedPointAddition = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 今日のやくそくの達成状況
  int _totalPromisesCount = 0;
  List<bool> _isPromiseCompletedList = [];
  late AnimationController _allCompletedAnimationController;

  final List<int> requiredExpForLevelUp = [
    0,
    3,
    9,
    18,
    30,
    45,
    60,
    75,
    90,
    105,
    120,
    150,
    180,
    210,
    240,
    270,
    300,
    330,
    360,
    390,
    420,
    450,
    480,
    510,
    540,
    570,
    600,
    630,
    660,
    690,
    720,
    750,
    780,
    810,
    840,
    870,
    900,
    930,
    960,
    990,
    1020,
    1050,
    1080,
    1110,
    1140,
    1170,
    1200,
    1230,
    1260,
    1290,
    1350,
    1410,
    1470,
    1530,
    1590,
    1650,
    1710,
    1770,
    1830,
    1890,
    1950,
    2010,
    2070,
    2130,
    2190,
    2250,
    2310,
    2370,
    2430,
    2490,
    2590,
    2690,
    2790,
    2890,
    2990,
    3090,
    3190,
    3290,
    3390,
    3490,
    3590,
    3690,
    3790,
    3890,
    3990,
    4090,
    4190,
    4290,
    4390,
    4490,
  ];

  int _level = 1;
  int _experience = 0;
  int _requiredExpForNextLevel = 3;
  double _experienceFraction = 0.0;

  Timer? _midnightTimer;

  int _homeBoostMultiplier = 1;
  int _boostRemainingDays = 0;
  String _boostRemainingHms = '';
  Timer? _boostCountdownTimer;
  int _multiplier = 1;

  // 画像として切り取る枠を指定するためのキー
  final GlobalKey _shareKey = GlobalKey();

  bool _showWatermarkForCapture = false;

  // 🌟 iOS専用: ウィジェットからのURIを初期化完了まで保留するための変数
  Uri? _pendingWidgetUri;

  // 🔒 重複処理防止: 同じURIを短時間に何度も処理しないためのガード変数
  String? _lastHandledWidgetUri;
  DateTime? _lastHandledWidgetTime;

  // 🌟 追加: 現在誘導中のミッションIDを保持する変数
  String? _activeMissionTarget;

  // 🌟 追加: 誘導中のキャラクターのセリフ
  String _getMissionTargetBubbleText(String target) {
    // 🌟 AppLocalizations の取得
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return "";

    switch (target) {
      case 'mission_enter_house':
        return l10n.missionTryEnterHouse;
      case 'mission_promise_board':
        return l10n.missionTryPromiseBoard;
      case 'mission_world_map':
        return l10n.missionTryWorldMap;
      case 'mission_bgm':
        return l10n.missionTryBgm;
      default:
        return l10n.missionTryDefault;
    }
  }

  bool _isDrawingMode = false; // おえかきモードかどうか
  List<DrawingPoint?> _drawingPoints = []; // 描いた線のデータ
  Color _selectedColor = Colors.redAccent; // とりあえず最初は赤色
  final double _strokeWidth = 6.0; // 線の太さ

  bool _isEraserMode = false;
  bool _isStampMode = false; // スタンプモードON/OFF
  String _selectedEmoji = '⭐'; // 初期状態のスタンプ

  final List<Color> _paletteColors = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.white,
    Colors.black87,
  ];

  // 🌟 追加: スタンプに使う絵文字のリスト（自由に増やせます！）
  final List<String> _paletteEmojis = [
    '⭐',
    '❤️',
    '🎵',
    '🌸',
    '✨',
    '🍀',
    '🍎',
    '🍦',
    '🐶',
    '🐱',
    '🐘',
    '🚀',
    '🌈',
    '🎁',
    '💎',
  ];

  @override
  void initState() {
    super.initState();

    _hintAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _allCompletedAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _pointsAddedAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, -0.8),
        ).animate(
          CurvedAnimation(
            parent: _pointsAddedAnimationController,
            curve: Curves.easeOut,
          ),
        );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _pointsAddedAnimationController,
        curve: const Interval(0.5, 1.0),
      ),
    );

    _playSavedBgm();

    _loadAndDetermineDisplayPromise();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await AppUpdateManager.instance.checkUpdateAndShowDialog(context);

        int earnedPoints = 0;
        if (!widget.isInitialSetup) {
          earnedPoints = await LoginBonusManager().checkLoginBonus(context);
          await TrophyManager.checkAndShowTrophies(context);
        } else {
          _promptTutorialChoice();
        }

        await _loadAndDetermineDisplayPromise();
        await SharedPrefsHelper.recordLoginDay();

        if (earnedPoints > 0 && mounted) {
          try {
            SfxManager.instance.playSuccessSound();
          } catch (e) {
            print('再生エラー: $e');
          }
          _showHugePointAnimation(earnedPoints);
          if (!_hasVisitedPointAddition) {
            _animationController.forward(from: 0.0);
          }
          // 🌟 超重要: アニメーションが綺麗に終わるまで「2秒」待つ
          // _pointsAddedAnimationController の duration が 2000ms なので、
          // 星が飛び終わるのを待ってから重い処理に入ります。これによりカクつきを防ぎます！
          await Future.delayed(const Duration(milliseconds: 2000));
        }

        await _initializeConsent();
      }
    });

    _checkTutorial();
    _scheduleMidnightRefresh();

    // 🌟 追加: ウィジェットからの起動を監視
    HomeWidget.setAppGroupId('group.com.kotoapp.kimigatsukurusekai');
    // Android / iOS 共通: widgetClicked ストリームで受け取り（ウォームスタート）
    HomeWidget.widgetClicked.listen(_handleWidgetAction);
    // コールドスタート: WidgetTree 構築後に確認
    // iOS はホーム画面の初期化完了後（_loadAndDetermineDisplayPromise内）に処理するため
    // ここでは Android のみ initiallyLaunchedFromHomeWidget を使用する
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!Platform.isIOS) {
        HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleWidgetAction);
      } else {
        // iOS: UserDefaults に保存済みの URL を読み取り、pending に積む
        // （実際の処理は _loadAndDetermineDisplayPromise 完了後に行う）
        await _checkIosWidgetAction();
      }
    });
  }

  @override
  void dispose() {
    _currentPointOverlay?.remove();
    _allCompletedAnimationController.dispose();
    _midnightTimer?.cancel();
    _hintAnimationController.dispose();
    _animationController.dispose();
    _pointsAddedAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _boostCountdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 🌟 自分がカレント画面の場合のみBGMを操作する。
      // TimerScreen等が上に乗っている場合は何もしない（フォーカスBGMを上書きしない）
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        _handleAppResumed();
      }
      // 注意: iOSのウォームスタートは AppDelegate が super を呼ぶことで
      // home_widget の widgetClicked ストリームが処理する。
      // ここで _checkIosWidgetAction を呼ぶと重複ダイアログになるため呼ばない。
    }
  }

  // 🌟 追加: チュートリアルをやるかスキップするか選ばせるダイアログ
  Future<void> _promptTutorialChoice() async {
    final bool? startTutorial = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 外側タップで閉じられないようにする
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.tutorialPromptTitle,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // 👈 ダイアログが縦いっぱいに広がるのを防ぐ
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.tutorialPromptDesc),
              Text(
                AppLocalizations.of(context)!.tutorialPromptNote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                try {
                  SfxManager.instance.playTapSound();
                } catch (e) {}
                FirebaseAnalytics.instance.logEvent(name: 'tutorial_skip');
                Navigator.of(context).pop(false); // スキップ
              },
              child: Text(
                AppLocalizations.of(context)!.skip,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: () {
                try {
                  SfxManager.instance.playTapSound();
                } catch (e) {}
                Navigator.of(context).pop(true); // 今からやる
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                AppLocalizations.of(
                  context,
                )!.missionButtonTry, // 🌟 必要に応じて多言語化してください
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );

    int earnedPoints = 0;

    // ダイアログの結果に応じた処理
    if (startTutorial == true) {
      // 「今からやる」を選んだ場合、本来のチュートリアル処理を開始
      await SharedPrefsHelper.setChildTutorial(
        SharedPrefsHelper.tutorialPhaseStart,
      );
      _showChildTutorial();
    } else {
      earnedPoints = await LoginBonusManager().checkLoginBonus(context);
      await TrophyManager.checkAndShowTrophies(context);

      if (earnedPoints > 0 && mounted) {
        try {
          SfxManager.instance.playSuccessSound();
        } catch (e) {
          print('再生エラー: $e');
        }
        _showHugePointAnimation(earnedPoints);
        if (!_hasVisitedPointAddition) {
          _animationController.forward(from: 0.0);
        }
      }
    }
  }

  // ==========================================
  // 🌟 追加: 最前面にアニメーションを表示するメソッド
  // ==========================================
  void _showHugePointAnimation(int points) {
    // すでに表示中のものがあれば一旦消す（連打対策）
    _currentPointOverlay?.remove();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 60),
                      const SizedBox(width: 12),
                      Text(
                        '+$points', // 引数で受け取ったポイントを表示
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF7043),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _currentPointOverlay = overlayEntry;
    overlay.insert(overlayEntry); // 最前面のガラス（Overlay）に貼り付け！

    // アニメーションを最初から再生し、終わったらガラスから剥がす
    _pointsAddedAnimationController.forward(from: 0.0).then((_) {
      if (_currentPointOverlay == overlayEntry && mounted) {
        _currentPointOverlay?.remove();
        _currentPointOverlay = null;
      }
    });
  }

  Future<void> _initializeConsent() async {
    // 🌟 【修正1】RevenueCatの初期化を先に行う！
    // (この後のUMPダイアログ等で「プレミアムかどうか」を正しく判定するため)
    try {
      await PurchaseManager.instance.init();
    } catch (e) {
      print("RevenueCat初期化エラー: $e");
    }

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

  void _initializeSDKs() async {
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
    } catch (e) {}

    if (!PurchaseManager.instance.isPremium.value) {
      try {
        await MobileAds.instance.initialize();
      } catch (e) {}
    }

    // 🌟 アプリ起動時にリワード広告をあらかじめ読み込んでおく
    try {
      RewardAdManager.instance.loadAd();
    } catch (e) {}
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 1);
    final durationUntilMidnight = midnight.difference(now);

    _midnightTimer = Timer(durationUntilMidnight, () {
      SharedPrefsHelper.clearTodaysCompletedPromises();
      _loadAndDetermineDisplayPromise();
      _scheduleMidnightRefresh();
    });
  }

  Future<void> _handleAppResumed() async {
    _playSavedBgm();
    PurchaseManager.instance.refreshCustomerInfo();

    final lastActiveDateStr = await SharedPrefsHelper.loadLastActiveDate();
    final today = await SharedPrefsHelper.getSimulatedDate();
    final todayStr = "${today.year}-${today.month}-${today.day}";

    if (lastActiveDateStr != todayStr) {
      await SharedPrefsHelper.clearTodaysCompletedPromises();
      await SharedPrefsHelper.recordLoginDay();
      _loadAndDetermineDisplayPromise();

      // 🌟 Check login bonus on resume/warm start!
      if (mounted) {
        int earnedPoints = await LoginBonusManager().checkLoginBonus(context);
        if (earnedPoints > 0 && mounted) {
          try {
            SfxManager.instance.playSuccessSound();
          } catch (e) {}
          _showHugePointAnimation(earnedPoints);
          if (!_hasVisitedPointAddition) {
            _animationController.forward(from: 0.0);
          }
        }
      }

      // 🌟 追加: ログイントロフィーのチェック
      if (mounted) TrophyManager.checkAndShowTrophies(context);
    }
    await SharedPrefsHelper.saveLastActiveDate(todayStr);
    _scheduleMidnightRefresh();
  }

  Future<void> _playSavedBgm() async {
    final trackName = await SharedPrefsHelper.loadSelectedBgm();
    final track = BgmTrack.values.firstWhere(
      (e) => e.name == trackName,
      orElse: () => BgmTrack.main,
    );
    try {
      BgmManager.instance.play(track);
    } catch (e) {}
  }

  Future<void> _onHelpButtonPressed() async {
    final String? selectedMenu = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return const HelpMenuDialog();
      },
    );
    if (selectedMenu == null) return;

    switch (selectedMenu) {
      case 'rules':
        // 「あそびかた」画面へ遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AppRulesInstructionScreen(),
          ),
        );
        break;
      case 'yakusoku':
        if (!await _showGuideDialog(
          title: AppLocalizations.of(context)!.guideNextPromiseTitle,
          content: AppLocalizations.of(context)!.guideNextPromiseDesc,
        ))
          return;
        final emergencyPromise = {
          'title': AppLocalizations.of(context)!.trialPromiseTitle,
          'duration': 10,
          'points': 1,
          'isTrial': true,
        };
        await SharedPrefsHelper.saveEmergencyPromise(emergencyPromise);
        await _loadAndDetermineDisplayPromise();
        if (mounted) {
          setState(() {
            _showStartBlinking = true;
          });
        }
        break;
      case 'dressup':
        if (!await _showGuideDialog(
          title: AppLocalizations.of(context)!.guideCustomizeTitle,
          content: AppLocalizations.of(context)!.guideCustomizeDesc,
        ))
          return;
        if (mounted) {
          setState(() {
            _showCustomizeBlinking = true;
          });
        }
        break;
      case 'promise_settings':
        if (!await _showGuideDialog(
          title: AppLocalizations.of(context)!.guideSettingsTitle,
          content: AppLocalizations.of(context)!.guideSettingsDesc,
        ))
          return;
        if (mounted) {
          setState(() {
            _showParentSettingsBlinking = true;
          });
        }
        break;
      case 'others':
        if (!await _showGuideDialog(
          title: AppLocalizations.of(context)!.guidePromiseBoardTitle,
          content: AppLocalizations.of(context)!.guidePromiseBoardDesc,
        ))
          return;
        if (!await _showGuideDialog(
          title: AppLocalizations.of(context)!.guideBgmButtonTitle,
          content: AppLocalizations.of(context)!.guideBgmButtonDesc,
        ))
          return;
        await _showGuideDialog(
          title: AppLocalizations.of(context)!.guideWorldMapButtonTitle,
          content: AppLocalizations.of(context)!.guideWorldMapButtonDesc,
        );
        break;
    }
  }

  void _checkTutorial() async {
    bool isChildGuideShown =
        await SharedPrefsHelper.getChildTutorial() ==
        SharedPrefsHelper.tutorialPhaseStart;
    if (isChildGuideShown) {
      await _showContinueTutorialDialog();
      _showChildTutorial();
      return;
    }
    bool isParentGuideShown =
        await SharedPrefsHelper.getParentTutorial() ==
        SharedPrefsHelper.tutorialPhaseStart;
    if (isParentGuideShown) {
      await _showContinueTutorialDialog();
      _showParentTutorial();
      return;
    }
  }

  Future<void> _showContinueTutorialDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.missionTabTutorial,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(context)!.tutorialResumeDesc,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () {
              try {
                SfxManager.instance.playTapSound();
              } catch (e) {}
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043),
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 60),
              side: const BorderSide(color: Color(0xFFFFCA28), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.tutorialResumeBtn,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showChildTutorial() async {
    bool wasStepShown = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepPromiseKey,
    );
    if (!wasStepShown) {
      final emergencyPromise = {
        'title': AppLocalizations.of(context)!.trialPromiseTitle,
        'duration': 10,
        'points': 100,
      };
      await SharedPrefsHelper.saveEmergencyPromise(emergencyPromise);
      await _loadAndDetermineDisplayPromise();

      if (_displayPromise != null && mounted) {
        setState(() {
          _showStartBlinking = true;
        });
      }
      FirebaseAnalytics.instance.logEvent(name: 'start_tutorial_promise');
      return;
    }

    bool wasCustomizeStepShown = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepCustomizeKey,
    );
    if (!wasCustomizeStepShown && mounted) {
      FirebaseAnalytics.instance.logEvent(
        name: 'start_tutorial_home_to_dress_up',
      );
      setState(() {
        _showCustomizeBlinking = true;
      });
      return;
    }

    bool wasMissionStepShown = await SharedPrefsHelper.isTutorialStepShown(
      'tutorial_step_mission',
    );
    if (!wasMissionStepShown && mounted) {
      setState(() {
        _showMissionBubble = true;
      });
    }
  }

  void _showParentTutorial() async {
    bool wasParentSetupShown = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepParentSetupShownKey,
    );
    if (!wasParentSetupShown && mounted) {
      final emergency = await SharedPrefsHelper.loadEmergencyPromise();
      if (emergency != null && emergency['isTrial'] == true) {
        setState(() {
          _showParentSettingsBlinking = false;
          _isTutorialParentSettingsFocus = false;
          _showEmergencyStartBlinking = true;
          _showStartBlinking = true;
        });
      } else {
        setState(() {
          _showParentSettingsBlinking = true;
          _isTutorialParentSettingsFocus = true;
        });
      }
      return;
    }
  }

  Future<bool> _showTutorialDialog({
    required String title,
    required String content,
    String? buttonText,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: <Widget>[
          FilledButton(
            onPressed: () {
              try {
                SfxManager.instance.playTapSound();
              } catch (e) {}
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(true);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043),
              foregroundColor: Colors.white,
              minimumSize: const Size(220, 64),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: Text(
              buttonText ?? AppLocalizations.of(context)!.okAction,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _showGuideDialog({
    required String title,
    required String content,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(false);
              }
            },
            child: Text(
              AppLocalizations.of(context)!.skip,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: () {
              try {
                SfxManager.instance.playTapSound();
              } catch (e) {}
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(true);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.okAction,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _openParentMode() async {
    if (_isTutorialParentSettingsFocus) {
      FirebaseAnalytics.instance.logEvent(
        name: 'tutorial_start_parent_settings',
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ParentTopScreen(isTutorial: true),
        ),
      );
      if (mounted) {
        await _loadAndDetermineDisplayPromise();
        final emergency = await SharedPrefsHelper.loadEmergencyPromise();
        if (emergency != null && emergency['isTrial'] == true) {
          setState(() {
            _showParentSettingsBlinking = false;
            _isTutorialParentSettingsFocus = false;
            _showEmergencyStartBlinking = true;
            _showStartBlinking = true;
          });
        } else {
          await _onParentTutorialCompleted();
        }
      }
      return;
    }

    if (_showParentSettingsBlinking) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ParentTopScreen(isTutorial: true),
        ),
      );
      setState(() {
        _showParentSettingsBlinking = false;
      });
      return;
    }

    final lockMode = await SharedPrefsHelper.loadLockMode();

    bool? isCorrect;
    if (lockMode == LockMode.none) {
      isCorrect = true;
    } else {
      if (!mounted) return;
      isCorrect = await showDialog<bool>(
        context: context,
        builder: (context) {
          if (lockMode == LockMode.passcode) {
            return FutureBuilder<String?>(
              future: SharedPrefsHelper.loadPasscode(),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty) {
                  return const PasscodeLockDialog();
                }
                return const MathLockDialog();
              },
            );
          }
          return const MathLockDialog();
        },
      );
    }

    if (isCorrect == true) {
      if (!mounted) return;
      FirebaseAnalytics.instance.logEvent(
        name: 'start_child_home_parent_settings',
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ParentTopScreen()),
      ).then((_) async {
        _loadAndDetermineDisplayPromise();
      });
    }
  }

  Future<void> _skipPastPromisesForTutorial() async {
    final now = DateTime.now();
    final regularPromises = await SharedPrefsHelper.loadRegularPromises(
      context,
    );
    final todaysCompletedTitles =
        await SharedPrefsHelper.loadTodaysCompletedPromiseTitles();

    for (var promise in regularPromises) {
      if (!todaysCompletedTitles.contains(promise['title'])) {
        final timeStr = promise['time'] as String?;
        if (timeStr != null && timeStr.contains(':')) {
          final parts = timeStr.split(':');
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          final promiseTime = DateTime(
            now.year,
            now.month,
            now.day,
            hour,
            minute,
          );

          if (promiseTime.isBefore(now)) {
            await SharedPrefsHelper.addSkippedRecord(promise['title']);
          }
        }
      }
    }
  }

  Future<void> _onParentTutorialCompleted() async {
    if (!mounted) return;
    await SharedPrefsHelper.setTutorialStepShown(
      SharedPrefsHelper.tutorialStepParentSetupShownKey,
    );
    await SharedPrefsHelper.setParentTutorial(
      SharedPrefsHelper.tutorialPhaseFinish,
    );
    if (mounted) {
      setState(() {
        _showParentSettingsBlinking = false;
        _isTutorialParentSettingsFocus = false;
      });
    }
    if (mounted) {
      await _showTutorialDialog(
        title: AppLocalizations.of(context)!.tutorialParentCompleteTitle,
        content: AppLocalizations.of(context)!.tutorialParentCompleteDesc,
        buttonText: AppLocalizations.of(context)!.gotIt,
      );

      if (mounted) {
        await _requestNotificationPermission(context, _level, forceShow: true);
      }
    }

    await _skipPastPromisesForTutorial();
    _loadAndDetermineDisplayPromise();
  }

  Future<void> _loadAndDetermineDisplayPromise() async {
    if (!mounted) return;
    final loadedPoints = await SharedPrefsHelper.loadPoints();
    if (!mounted) return;
    final regular = await SharedPrefsHelper.loadRegularPromises(context);
    final emergency = await SharedPrefsHelper.loadEmergencyPromise();
    var todaysCompletedTitles =
        await SharedPrefsHelper.loadTodaysCompletedPromiseTitles();
    var todaysSkippedTitles =
        await SharedPrefsHelper.loadTodaysSkippedPromiseTitles();
    final int multiplier = await SharedPrefsHelper.getCurrentBoostMultiplier();

    _checkUnclaimedMissions();

    Offset? loadedAvatarPos = await SharedPrefsHelper.loadCharacterPosition(
      'avatar',
    );
    final entered = await SharedPrefsHelper.getHasEnteredHouse();
    final level = await SharedPrefsHelper.loadLevel();
    final experience = await SharedPrefsHelper.loadExperience();

    final face = await SharedPrefsHelper.loadEquippedFace();
    final hair = await SharedPrefsHelper.loadEquippedHairstyle();
    final clothes = await SharedPrefsHelper.loadEquippedClothes();
    final headgear = await SharedPrefsHelper.loadEquippedHeadgear();
    final accessory = await SharedPrefsHelper.loadEquippedAccessory();

    Map<String, dynamic>? nextPromise;
    bool isEmergency = false;

    if (emergency != null) {
      nextPromise = emergency;
      isEmergency = true;
    } else if (regular.isNotEmpty) {
      final uncompletedPromises = regular.where((promise) {
        return !todaysCompletedTitles.contains(promise['title']) &&
            !todaysSkippedTitles.contains(promise['title']);
      }).toList();

      if (uncompletedPromises.isNotEmpty) {
        uncompletedPromises.sort((a, b) {
          final timeA = a['time'] ?? '00:00';
          final timeB = b['time'] ?? '00:00';
          return timeA.compareTo(timeB);
        });
        nextPromise = uncompletedPromises.first;
      }
    }

    final house = await SharedPrefsHelper.loadEquippedHouse();
    final world = await SharedPrefsHelper.loadEquippedWorld();
    final characters = await SharedPrefsHelper.loadEquippedCharacters();
    final items = await SharedPrefsHelper.loadEquippedItems();
    final mediaQuery = MediaQuery.maybeOf(context);
    final orientation = mediaQuery?.orientation ?? Orientation.landscape;
    final hasVisitedPointAddition = await SharedPrefsHelper.isTutorialStepShown(
      'tutorial_step_point_addition',
    );

    late double screenWidth;
    late double screenHeight;
    late double rightPadding;
    late double safeAreaWidth;

    if (orientation == Orientation.landscape) {
      screenWidth = mediaQuery?.size.width ?? 0;
      screenHeight = mediaQuery?.size.height ?? 0;
      rightPadding = mediaQuery?.padding.right ?? 0;
      safeAreaWidth = screenWidth - rightPadding;
    } else {
      screenWidth = mediaQuery?.size.height ?? 0;
      screenHeight = mediaQuery?.size.width ?? 0;
      rightPadding = mediaQuery?.padding.right ?? 0;
      safeAreaWidth = screenWidth - rightPadding;
    }

    if (loadedAvatarPos != null &&
        (loadedAvatarPos.dx > screenWidth ||
            loadedAvatarPos.dy > screenHeight ||
            loadedAvatarPos.dx < 0 ||
            loadedAvatarPos.dy < 0)) {
      loadedAvatarPos = null;
    }

    final loadedPositions = {};
    final charactersToLoad = characters.isEmpty
        ? ['assets/images/character_usagi.gif']
        : characters;

    for (var charPath in charactersToLoad) {
      final loadedPos = await SharedPrefsHelper.loadCharacterPosition(charPath);
      loadedPositions[charPath] = loadedPos ?? Offset(safeAreaWidth - 240, 190);
    }

    final itemsToLoad = items.isEmpty ? [] : items;

    for (var itemPath in itemsToLoad) {
      final loadedPos = await SharedPrefsHelper.loadCharacterPosition(itemPath);
      loadedPositions[itemPath] = loadedPos ?? const Offset(100, 190);
    }

    setState(() {
      _hasEnteredHouse = entered;
      _hasVisitedPointAddition = hasVisitedPointAddition;
      _points = loadedPoints;
      _displayPromise = nextPromise;
      _isDisplayPromiseEmergency = isEmergency;
      _totalPromisesCount = regular.length;
      _isPromiseCompletedList = regular
          .map((p) => todaysCompletedTitles.contains(p["title"]))
          .toList();

      final areAllCompleted =
          _totalPromisesCount > 0 &&
          _isPromiseCompletedList.every((completed) => completed);
      if (areAllCompleted) {
        _allCompletedAnimationController.repeat(reverse: true);
      } else {
        _allCompletedAnimationController.stop();
        _allCompletedAnimationController.value = 0.0;
      }

      _equippedFace = face ?? 'assets/images/face/face_default.png';
      _equippedHair = hair ?? 'assets/images/hair/hair_default.png';
      _equippedClothes = clothes ?? 'assets/images/clothes/clothes_default.png';
      _equippedHeadgear = headgear;
      _equippedAccessory = accessory;

      _equippedHousePath = house ?? 'assets/images/house.png';
      _equippedWorldPath = world ?? 'assets/images/world.png';
      _equippedCharacters = characters.isEmpty
          ? ['assets/images/character_usagi.gif']
          : characters;
      _equippedItems = items;
      _avatarPosition = loadedAvatarPos ?? const Offset(205, 190);

      _characterPositionsMap = {};
      for (var charPath in _equippedCharacters) {
        if (loadedPositions[charPath] != null &&
            (loadedPositions[charPath].dx > screenWidth ||
                loadedPositions[charPath].dy > screenHeight ||
                loadedPositions[charPath].dx < 0 ||
                loadedPositions[charPath].dy < 0)) {
          loadedPositions[charPath] = null;
        }
        _characterPositionsMap[charPath] =
            loadedPositions[charPath] ?? Offset(safeAreaWidth - 240, 190);
      }

      _itemPositionsMap = {};
      for (var itemPath in _equippedItems) {
        if (loadedPositions[itemPath] != null &&
            (loadedPositions[itemPath].dx > screenWidth ||
                loadedPositions[itemPath].dy > screenHeight ||
                loadedPositions[itemPath].dx < 0 ||
                loadedPositions[itemPath].dy < 0)) {
          loadedPositions[itemPath] = null;
        }
        _itemPositionsMap[itemPath] =
            loadedPositions[itemPath] ?? const Offset(100, 190);
      }

      _level = level;
      _experience = experience;
      _requiredExpForNextLevel = (_level < requiredExpForLevelUp.length)
          ? requiredExpForLevelUp[_level]
          : requiredExpForLevelUp.last;
      _multiplier = multiplier;
      if (_level < requiredExpForLevelUp.length - 1) {
        _requiredExpForNextLevel = requiredExpForLevelUp[_level];

        final expForCurrentLevel = requiredExpForLevelUp[_level - 1];
        final totalExpNeededForThisLevel =
            _requiredExpForNextLevel - expForCurrentLevel;

        if (totalExpNeededForThisLevel > 0) {
          final progressInThisLevel = _experience - expForCurrentLevel;
          _experienceFraction =
              progressInThisLevel / totalExpNeededForThisLevel;
        } else {
          _experienceFraction = 0.0;
        }
      } else {
        _requiredExpForNextLevel = _experience;
        _experienceFraction = 1.0;
      }
    });
    _checkHomeBoostStatus();

    // 🌟 iOS: _loadAndDetermineDisplayPromise 完了後に pending URI を処理
    // （ホーム画面が完全に安定してからダイアログを表示するため）
    if (Platform.isIOS && _pendingWidgetUri != null) {
      final uri = _pendingWidgetUri;
      _pendingWidgetUri = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleWidgetAction(uri);
      });
    }
  }

  void _startPromise() async {
    if (_displayPromise == null) return;

    final bool isEmergencyTutorial = _showEmergencyStartBlinking;

    if (_showStartBlinking) {
      setState(() {
        _showStartBlinking = false;
        if (isEmergencyTutorial) {
          _showEmergencyStartBlinking = false;
        }
      });
    }

    final isInTutorial =
        !await SharedPrefsHelper.isTutorialStepShown(
          SharedPrefsHelper.tutorialStepPromiseKey,
        ) &&
        await SharedPrefsHelper.getChildTutorial() ==
            SharedPrefsHelper.tutorialPhaseStart;
    if (isInTutorial) {
      FirebaseAnalytics.instance.logEvent(
        name: 'tutorial_child_start_promise_button',
      );
    } else if (_showEmergencyStartBlinking) {
      FirebaseAnalytics.instance.logEvent(
        name: 'tutorial_parent_start_promise_button',
      );
    } else {
      FirebaseAnalytics.instance.logEvent(
        name: 'start_child_start_promise_button',
      );
    }

    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute<Map<String, dynamic>?>(
        builder: (context) => TimerScreen(
          promise: _displayPromise!,
          isEmergency: _isDisplayPromiseEmergency,
        ),
      ),
    );

    // 1. トレース（ストップウォッチ）を用意して、名前をつける
    final Trace trace = FirebasePerformance.instance.newTrace(
      'timer_end_trace',
    );

    // 2. 計測スタート！
    await trace.start();

    try {
      final pointsAwarded = result != null ? result['points'] as int? : null;
      final exp = result != null ? result['exp'] as int? : null;

      _playSavedBgm();

      if (isEmergencyTutorial) {
        if (pointsAwarded != null && mounted) {
          await _onParentTutorialCompleted();
        } else {
          setState(() {
            _showEmergencyStartBlinking = true;
            _showStartBlinking = true;
          });
        }
      }

      if (pointsAwarded != null && pointsAwarded > 0) {
        if (!_isDisplayPromiseEmergency) {
          await SharedPrefsHelper.addCompletionRecord(
            _displayPromise!['title'],
          );
        }
        final newTotalPoints = _points + pointsAwarded;

        await SharedPrefsHelper.savePoints(newTotalPoints);
        await SharedPrefsHelper.addCumulativePoints(pointsAwarded);

        try {
          SfxManager.instance.playSuccessSound();
        } catch (e) {
          print('再生エラー: $e');
        }

        setState(() {
          _experience += exp ?? 0;
        });
        if (!_hasVisitedPointAddition) {
          _animationController.forward(from: 0.0);
        }
        _showHugePointAnimation(pointsAwarded);
        _loadAndDetermineDisplayPromise();

        // チュートリアル中の場合はトロフィーチェック不要
        if (!isInTutorial) {
          _checkLevelUp();
          // 🌟 追加: タイマー完了、レベルアップ後のトロフィーチェック
          if (mounted) TrophyManager.checkAndShowTrophies(context);
        }

        bool wasCustomizeStepShown =
            await SharedPrefsHelper.isTutorialStepShown(
              SharedPrefsHelper.tutorialStepCustomizeKey,
            );
        bool isShown =
            await SharedPrefsHelper.getChildTutorial() ==
            SharedPrefsHelper.tutorialPhaseStart;
        if (!wasCustomizeStepShown && isShown && mounted) {
          await SharedPrefsHelper.setTutorialStepShown(
            SharedPrefsHelper.tutorialStepPromiseKey,
          );
          setState(() {
            _showCustomizeBlinking = true;
          });
          FirebaseAnalytics.instance.logEvent(name: 'start_tutorial_dress_up');
        }
      } else {
        if (isInTutorial && mounted) {
          setState(() {
            _showStartBlinking = true;
          });
        }
      }
    } finally {
      // 3. 計測ストップ！（データがFirebaseに送信されます）
      // ※ エラーが起きても確実に止まるように finally の中に入れるのが鉄則です
      await trace.stop();
    }
  }

  // 🌟 iOS専用: AppDelegate が App Group UserDefaults に保存した URL を読み取る
  // コールドスタート時は _pendingWidgetUri に積んで、ホーム画面安定後に処理する
  // ウォームスタート（resumed）時は直接 _handleWidgetAction を呼ぶ
  Future<void> _checkIosWidgetAction({bool immediate = false}) async {
    try {
      final urlStr = await HomeWidget.getWidgetData<String>(
        'ios_widget_action_url',
      );
      print('🍎 iOS widget URL check: $urlStr (immediate: $immediate)');
      if (urlStr != null && urlStr.isNotEmpty) {
        // 読み取り済みとして空にする（二重処理防止）
        await HomeWidget.saveWidgetData<String>('ios_widget_action_url', '');
        if (!mounted) return;
        final uri = Uri.tryParse(urlStr);
        if (immediate) {
          // ウォームスタート: ホーム画面はすでに安定しているので直接処理
          _handleWidgetAction(uri);
        } else {
          // コールドスタート: _loadAndDetermineDisplayPromise 完了まで保留
          _pendingWidgetUri = uri;
        }
      }
    } catch (e) {
      print('🍎 iOS widget URL check error: $e');
    }
  }

  // 🌟 追加: ウィジェットから起動されたときのアクション処理
  void _handleWidgetAction(Uri? uri) {
    print('🔥 ウィジェットアクション発火: $uri');

    if (uri == null) return;

    // 🔒 重複処理防止: 同じURIを 5秒以内に再度処理しない
    final now = DateTime.now();
    final uriStr = uri.toString();
    if (_lastHandledWidgetUri == uriStr &&
        _lastHandledWidgetTime != null &&
        now.difference(_lastHandledWidgetTime!).inSeconds < 5) {
      print('🔥 ウィジェットアクション重複スキップ: $uri');
      return;
    }
    _lastHandledWidgetUri = uriStr;
    _lastHandledWidgetTime = now;

    if (uri.host == 'open_action_dialog') {
      FirebaseAnalytics.instance.logEvent(name: 'open_widget_action_dialog');

      WidgetActionSelectionDialog.show(
        context: context,
        onGoHome: () {
          Navigator.pop(context); // ダイアログを閉じてそのまま
          FirebaseAnalytics.instance.logEvent(
            name: 'widget_action_dialog_go_home',
          );
        },
        onGoSettings: () async {
          Navigator.pop(context); // ダイアログを閉じる
          FirebaseAnalytics.instance.logEvent(
            name: 'widget_action_dialog_go_settings',
          );
          // 親のロック画面などを経由する場合は _openParentMode() でもOKです
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EmergencyPromiseScreen(isTutorial: false),
            ),
          );

          // 🌟 戻ってきたら必ずここが実行されるので、画面を更新する
          if (mounted) {
            _loadAndDetermineDisplayPromise();
          }
        },
        onGoPromise: () {
          Navigator.pop(context); // ダイアログを閉じる
          FirebaseAnalytics.instance.logEvent(
            name: 'widget_action_dialog_go_promise',
          );
          // 🌟 既存のやくそく開始メソッドをそのまま流用！
          if (_displayPromise != null) {
            _startPromise();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.nothingToDoRightNow,
                ),
              ),
            );
          }
        },
      );
    }
  }

  void _checkLevelUp() {
    bool isLeveledUp = false;
    int newLevel = _level;

    // 🌟 変更: if ではなく while を使い、経験値が条件を満たす限り何度でもレベルを上げる
    while (newLevel < requiredExpForLevelUp.length &&
        _experience >= requiredExpForLevelUp[newLevel]) {
      newLevel++;
      isLeveledUp = true; // 1回でもレベルが上がったらフラグを立てる
    }

    // 🌟 変更: レベルアップが発生した場合のみ、ダイアログや効果音の処理を行う
    if (isLeveledUp) {
      setState(() {
        _level = newLevel;
      });
      SharedPrefsHelper.saveLevel(newLevel);

      final List<String> soundsToPlay = [];
      final String lang = AppLocalizations.of(context)!.localeName;
      if (lang == 'ja') {
        try {
          SfxManager.instance.playTimeYattaSound();
        } catch (e) {}
      } else {
        final String voiceDir = SfxManager.instance.getVoiceDir(lang);
        soundsToPlay.addAll(['se/$voiceDir/level_up.mp3']);
      }
      try {
        SfxManager.instance.playSequentialSounds(soundsToPlay);
      } catch (e) {}

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.levelUpTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            // 🌟 ここはそのまま newLevel を渡すだけで「レベル〇〇になったよ！」と正しく表示されます
            AppLocalizations.of(context)!.levelUpMessage(newLevel),
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () {
                try {
                  SfxManager.instance.playTapSound();
                } catch (e) {}
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 60),
                side: const BorderSide(color: Color(0xFFFFCA28), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.okAction,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ).then((_) async {
        await _requestReviewIfTargetLevel(newLevel);

        // ※補足: 4レベルから6レベルに一気に上がった場合、ここは「6 % 5 == 0」ではないためスルーされます。
        // もし飛び級でも5の倍数の案内を出したい場合は別の計算が必要ですが、基本はこのままで十分機能します！
        if (newLevel % 5 == 0 && !PurchaseManager.instance.isPremium.value) {
          SharedPrefsHelper.recordLevelUpSaleTime();
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.upgradeToPremium,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF7043).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.premiumFeaturesDesc,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  FilledButton(
                    onPressed: () async {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'premium_open_levelup',
                      );
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumPaywallScreen(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7043),
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFFFFCA28),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.seeDetails,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }
        }
      });
    }

    // レベルアップしてもしなくても、最終的な経験値は保存しておく
    SharedPrefsHelper.saveExperience(_experience);
  }

  Future<void> _requestReviewIfTargetLevel(int level) async {
    if (level >= 4) {
      try {
        final InAppReview inAppReview = InAppReview.instance;
        if (await inAppReview.isAvailable()) {
          await inAppReview.requestReview();
        }
      } catch (e) {}
    }
  }

  Future<bool> _requestNotificationPermission(
    BuildContext context,
    int level, {
    bool forceShow = false,
  }) async {
    if (level <= 2 && !forceShow) return false;

    PermissionStatus status = await Permission.notification.status;
    if (status.isGranted) return false;

    bool? shouldRequest = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.notificationRequestTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF7043).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.notificationRequestMessage,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () {
              if (forceShow) {
                FirebaseAnalytics.instance.logEvent(
                  name: 'tutorial_notification_later',
                );
              }
              Navigator.pop(context, false);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: Text(
              AppLocalizations.of(context)!.notificationLater,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton(
            onPressed: () {
              if (forceShow) {
                FirebaseAnalytics.instance.logEvent(
                  name: 'tutorial_notification_force',
                );
              }
              Navigator.pop(context, true);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043),
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFFFCA28), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.notificationAccept,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldRequest == true) {
      final bool granted = await NotificationManager.instance
          .requestPermission();
      if (granted) {
        FirebaseAnalytics.instance.logEvent(
          name: 'notification_permission_granted',
        );
      } else {
        FirebaseAnalytics.instance.logEvent(
          name: 'notification_permission_denied',
        );
      }
    }
    return true;
  }

  void _skipPromise() async {
    FirebaseAnalytics.instance.logEvent(name: 'start_child_home_skip_promise');
    try {
      SfxManager.instance.playTapSound();
    } catch (e) {}
    if (_displayPromise == null) return;

    if (_isDisplayPromiseEmergency) {
      await SharedPrefsHelper.saveEmergencyPromise(null);
    } else {
      await SharedPrefsHelper.addSkippedRecord(_displayPromise!['title']);
    }

    _loadAndDetermineDisplayPromise();
  }

  double _getItemSize(String itemPath) {
    if (itemPath.contains('assets/images/item_kuruma.png')) {
      return 100.0;
    } else if (itemPath.contains('assets/images/item_sea_toudai.png')) {
      return 200.0;
    } else if (itemPath.contains('assets/images/item_sky_kikyuu.png')) {
      return 200.0;
    } else if (itemPath.contains('assets/images/item_sky_hikouki.png')) {
      return 120.0;
    } else if (itemPath.contains('assets/images/item_sky_niji.png')) {
      return 120.0;
    } else if (itemPath.contains('assets/images/item_space_kuruma.png')) {
      return 120.0;
    } else if (itemPath.contains('assets/images/item_space_roketto.png')) {
      return 120.0;
    } else if (itemPath.contains('assets/images/item_space_antena.png')) {
      return 100.0;
    } else if (itemPath.contains('assets/images/item_space_kousenjuu.png')) {
      return 30.0;
    } else if (itemPath.contains('assets/images/item_jitensya.png')) {
      return 70.0;
    } else if (itemPath.contains('assets/images/item_jouro.png')) {
      return 35.0;
    } else if (itemPath.contains('assets/images/item_ki.png')) {
      return 150.0;
    } else if (itemPath.contains('assets/images/item_happa1.png')) {
      return 30.0;
    }
    return 50.0;
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // 背景を透過させてカスタムデザインに
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.stampSelectTitle,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // 15個の絵文字をグリッドで表示
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10, // 5列
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _paletteEmojis.length,
                  itemBuilder: (context, index) {
                    final emoji = _paletteEmojis[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEmoji = emoji;
                          _isStampMode = true;
                          _isEraserMode = false;
                        });
                        Navigator.pop(context); // 閉じる
                        try {
                          SfxManager.instance.playTapSound();
                        } catch (_) {}
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedEmoji == emoji && _isStampMode
                              ? Colors.pink[50]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _selectedEmoji == emoji && _isStampMode
                                ? Colors.pink
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkUnclaimedMissions() async {
    final claimedIds = await SharedPrefsHelper.loadClaimedMissionIds();
    final cumulativeShop = await SharedPrefsHelper.loadCumulativeShopCount();
    final currentLevel = await SharedPrefsHelper.loadLevel();
    final cumulativePoints = await SharedPrefsHelper.loadCumulativePoints();
    final cumulativeLoginDays =
        await SharedPrefsHelper.loadCumulativeLoginDays();

    bool hasUnclaimed = false;

    if (!claimedIds.contains('mission_enter_house')) hasUnclaimed = true;
    if (!claimedIds.contains('mission_promise_board')) hasUnclaimed = true;
    if (!claimedIds.contains('mission_bgm')) hasUnclaimed = true;
    if (!claimedIds.contains('mission_world_map')) hasUnclaimed = true;

    if (!claimedIds.contains('mission_big_island') && currentLevel >= 5)
      hasUnclaimed = true;
    if (!claimedIds.contains('mission_sea') && currentLevel >= 10)
      hasUnclaimed = true;
    if (!claimedIds.contains('mission_sky') && currentLevel >= 15)
      hasUnclaimed = true;
    if (!claimedIds.contains('mission_space') && currentLevel >= 20)
      hasUnclaimed = true;

    for (int target in SharedPrefsHelper.loginTargets) {
      if (cumulativeLoginDays >= target &&
          !claimedIds.contains('mission_login_$target'))
        hasUnclaimed = true;
    }
    for (int target in SharedPrefsHelper.shopTargets) {
      if (cumulativeShop >= target &&
          !claimedIds.contains('mission_shop_$target'))
        hasUnclaimed = true;
    }
    for (int target in SharedPrefsHelper.levelTargets) {
      if (currentLevel >= target &&
          !claimedIds.contains('mission_level_$target'))
        hasUnclaimed = true;
    }
    for (int target in SharedPrefsHelper.pointTargets) {
      if (cumulativePoints >= target &&
          !claimedIds.contains('mission_points_$target'))
        hasUnclaimed = true;
    }

    if (mounted) {
      setState(() {
        _hasUnclaimedMissions = hasUnclaimed;
      });
    }
  }

  // 🌟 変更: メイン機能かサブ機能かでボタンのサイズ・デザインを変えるように修正
  Widget _buildRoundMenuButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color backgroundColor,
    VoidCallback? onTap,
    bool isMain = false, // 🌟 新しいパラメータ: これが true だと目立つデザインになります
  }) {
    // isMain の値によってサイズを変える
    final double buttonSize = isMain ? 58.0 : 46.0;
    final double iconSize = isMain ? 38.0 : 24.0;
    final double fontSize = isMain ? 10.0 : 9.0;
    final double borderWidth = isMain ? 3.0 : 2.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: borderWidth),
            ),
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
          Transform.translate(
            offset: const Offset(0, -8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  color: const Color(0xFF5D4037),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================
  // 🌟 追加: ホーム画面用 ポイントブーストカウントダウン
  // =========================================
  Future<void> _checkHomeBoostStatus() async {
    final multiplier = await SharedPrefsHelper.getCurrentBoostMultiplier();
    final endTime = await SharedPrefsHelper.getBoostEndTime();

    if (mounted) {
      setState(() {
        _homeBoostMultiplier = multiplier;
      });
    }

    if (multiplier > 1 && endTime != null) {
      _startBoostCountdown(endTime);
    } else {
      _boostCountdownTimer?.cancel();
    }
  }

  void _startBoostCountdown(DateTime endTime) {
    _boostCountdownTimer?.cancel();
    _updateBoostCountdown(endTime);
    _boostCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateBoostCountdown(endTime);
    });
  }

  void _updateBoostCountdown(DateTime endTime) {
    final now = DateTime.now();
    final diff = endTime.difference(now);

    final days = diff.inDays;
    final hours = (diff.inHours % 24).toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

    if (diff.isNegative || diff.inSeconds <= 0) {
      _boostCountdownTimer?.cancel();
      if (mounted) {
        setState(() {
          _homeBoostMultiplier = 1;
          _boostRemainingDays = 0;
          _boostRemainingHms = '';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _boostRemainingDays = days;
        _boostRemainingHms = '$hours:$minutes:$seconds';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double rightPadding = MediaQuery.of(context).padding.right;
    final double safeAreaWidth = screenWidth - rightPadding;

    final bool isAnyTutorialBlinking =
        _showCustomizeBlinking ||
        _showParentSettingsBlinking ||
        _showEmergencyStartBlinking ||
        _showMissionBubble ||
        _activeMissionTarget != null;

    final bool isAnyTutorialActive =
        _showCustomizeBlinking ||
        _showParentSettingsBlinking ||
        _showStartBlinking ||
        _showEmergencyStartBlinking ||
        _showMissionBubble ||
        _activeMissionTarget != null;

    return DefaultTabController(
      length: 1, // タブ数は適切に調整してください
      child: Scaffold(
        key: _scaffoldKey, // 🌟 追加
        backgroundColor: const Color(0xFFFFF3E0),

        // 🌟 追加: 右から出てくるメニュー画面（ドロワー）
        endDrawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.7, // 画面幅の70%の広さ
          backgroundColor: const Color(0xFFFFF3E0),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // ドロワーのヘッダー（タイトル）
              Container(
                height: 60,
                width: double.infinity,
                color: const Color(0xFFFF7043),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.grid_view_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.navMenu,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 👇 ① おんがくメニュー
              _buildDrawerItem(
                context: context,
                icon: Icons.music_note,
                iconColor: Colors.purple,
                text: AppLocalizations.of(context)!.navMusic,
                isTutorialBlinking:
                    isAnyTutorialBlinking &&
                    _activeMissionTarget != 'mission_bgm',
                isBlinking: _activeMissionTarget == 'mission_bgm',
                onTap: () async {
                  try {
                    SfxManager.instance.playTapSound();
                  } catch (e) {}
                  FirebaseAnalytics.instance.logEvent(
                    name: 'start_child_home_bgm',
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BgmSelectionScreen(),
                    ),
                  ).then((_) {
                    // 🌟 追加: 戻ってきたらリセット
                    if (_activeMissionTarget == 'mission_bgm') {
                      setState(() => _activeMissionTarget = null);
                    }
                  });
                },
              ),

              const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),

              // ②トロフィールーム メニュー
              _buildDrawerItem(
                context: context,
                icon: Icons.emoji_events, // トロフィーのアイコン
                iconColor: Colors.amber, // ゴールド色
                text: AppLocalizations.of(
                  context,
                )!.trophyRoom, // ※必要に応じてAppLocalizationsに追加してください
                isTutorialBlinking: isAnyTutorialBlinking,
                onTap: () async {
                  FirebaseAnalytics.instance.logEvent(
                    name: 'start_child_home_trophy_room',
                  );
                  try {
                    SfxManager.instance.playTapSound();
                  } catch (e) {}

                  // 作成したTrophyScreenへ遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrophyScreen(),
                    ),
                  ).then((_) {
                    // 戻ってきた時に状態を更新したい場合はここに書く
                    _loadAndDetermineDisplayPromise();
                  });
                },
              ),

              const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),

              // ③ 設定メニュー
              _buildDrawerItem(
                context: context,
                icon: Icons.settings_outlined,
                iconColor: Colors.grey,
                text: AppLocalizations.of(context)!.settingsTitle,
                isTutorialBlinking: isAnyTutorialBlinking,
                onTap: () async {
                  FirebaseAnalytics.instance.logEvent(
                    name: 'start_child_home_settings',
                  );
                  try {
                    SfxManager.instance.playTapSound();
                  } catch (e) {}
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            // 背景
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_equippedWorldPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SafeArea(
              child: Stack(
                children: [
                  if (!_isDrawingMode)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 420,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.levelLabel(_level),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          LinearProgressIndicator(
                                            value: _experienceFraction,
                                            backgroundColor: Colors.grey[300],
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(Colors.green),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 30,
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.todaysPromise,
                                              style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: List.generate(
                                                  _totalPromisesCount == 0
                                                      ? 1
                                                      : _totalPromisesCount,
                                                  (index) {
                                                    if (_totalPromisesCount ==
                                                        0) {
                                                      return const Text(
                                                        'なし',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      );
                                                    }
                                                    final isCompleted =
                                                        index <
                                                            _isPromiseCompletedList
                                                                .length
                                                        ? _isPromiseCompletedList[index]
                                                        : false;

                                                    final starIcon = Icon(
                                                      Icons.star,
                                                      size: 18,
                                                      color: (isCompleted)
                                                          ? Colors.amber
                                                          : Colors.grey[300],
                                                    );

                                                    if (isCompleted) {
                                                      return AnimatedBuilder(
                                                        animation:
                                                            _allCompletedAnimationController,
                                                        builder: (context, child) {
                                                          final animValue =
                                                              _allCompletedAnimationController
                                                                  .value;
                                                          final scale =
                                                              1.0 +
                                                              (animValue * 0.3);
                                                          final rotationY =
                                                              animValue *
                                                              2 *
                                                              math.pi;

                                                          return Transform(
                                                            transform:
                                                                Matrix4.identity()
                                                                  ..setEntry(
                                                                    3,
                                                                    2,
                                                                    0.002,
                                                                  )
                                                                  ..rotateY(
                                                                    rotationY,
                                                                  )
                                                                  ..scale(
                                                                    scale,
                                                                    scale,
                                                                  ),
                                                            alignment: Alignment
                                                                .center,
                                                            child: child,
                                                          );
                                                        },
                                                        child: starIcon,
                                                      );
                                                    }
                                                    return starIcon;
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 30,
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Stack(
                                        alignment: Alignment.centerLeft,
                                        clipBehavior: Clip.none,
                                        children: [
                                          ScaleTransition(
                                            scale: _scaleAnimation,
                                            child: GestureDetector(
                                              onTap: () async {
                                                try {
                                                  SfxManager.instance
                                                      .playTapSound();
                                                } catch (_) {}

                                                if (!_hasVisitedPointAddition) {
                                                  await SharedPrefsHelper.setTutorialStepShown(
                                                    'tutorial_step_point_addition',
                                                  );
                                                  if (mounted) {
                                                    setState(() {
                                                      _hasVisitedPointAddition =
                                                          true;
                                                    });
                                                  }
                                                }

                                                FirebaseAnalytics.instance.logEvent(
                                                  name:
                                                      'open_point_addition_home',
                                                );
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const PointAdditionScreen(),
                                                  ),
                                                ).then((_) {
                                                  _loadAndDetermineDisplayPromise();
                                                });
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 24,
                                                  ),
                                                  Text(
                                                    '$_points',
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    width: 25, // 🌟 明示的にサイズを指定
                                                    height: 25,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Color(
                                                            0xFFFF7043,
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    child: const Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ★右上の「？」アイコン (Drawerメニュー用)
                  if (!_isDrawingMode)
                    Positioned(
                      top: 0, // 上部バーの高さに合わせて調整してください
                      right: 10,
                      child: SafeArea(
                        child: Stack(
                          // 🌟 Stackを追加して指マークを重ねる
                          clipBehavior: Clip.none,
                          children: [
                            IgnorePointer(
                              ignoring:
                                  isAnyTutorialBlinking &&
                                  _activeMissionTarget != 'mission_bgm',
                              child: Opacity(
                                opacity:
                                    isAnyTutorialBlinking &&
                                        _activeMissionTarget != 'mission_bgm'
                                    ? 0.6
                                    : 1.0,
                                child: BlinkingEffect(
                                  // 🌟 変更
                                  isBlinking:
                                      _activeMissionTarget == 'mission_bgm',
                                  child: FloatingActionButton.small(
                                    // 小さめのFABを使って浮かせる
                                    onPressed: () {
                                      try {
                                        SfxManager.instance.playTapSound();
                                      } catch (_) {}
                                      // 🌟 keyを使って右側のドロワーを開く
                                      _scaffoldKey.currentState
                                          ?.openEndDrawer();
                                    },
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black54,
                                    child: const Icon(
                                      Icons.menu,
                                    ), // ハンバーガーメニューアイコン
                                  ),
                                ),
                              ),
                            ),
                            if (_activeMissionTarget ==
                                'mission_bgm') // 🌟 指マーク
                              const Positioned(
                                right: -10,
                                bottom: -10,
                                child: AnimatedTapFinger(),
                              ),
                          ],
                        ),
                      ),
                    ),

                  // 🌟 右側のボタン群
                  if (!_isDrawingMode)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 10,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ① やくそくボード
                            Builder(
                              builder: (context) {
                                final isPromiseTarget =
                                    _activeMissionTarget ==
                                    'mission_promise_board'; // 🌟 追加
                                return Stack(
                                  // 🌟 Stackで囲む
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    IgnorePointer(
                                      ignoring:
                                          isAnyTutorialBlinking &&
                                          !isPromiseTarget,
                                      child: Opacity(
                                        opacity:
                                            isAnyTutorialBlinking &&
                                                !isPromiseTarget
                                            ? 0.6
                                            : 1.0,
                                        child: BlinkingEffect(
                                          // 🌟 追加
                                          isBlinking: isPromiseTarget,
                                          child: _buildRoundMenuButton(
                                            icon: Icons.article_rounded,
                                            label: AppLocalizations.of(
                                              context,
                                            )!.navPromiseBoard,
                                            iconColor: Colors.black,
                                            backgroundColor: Colors.white, // 白
                                            isMain: false,
                                            onTap: () async {
                                              FirebaseAnalytics.instance.logEvent(
                                                name:
                                                    'start_child_home_promise_board',
                                              );
                                              try {
                                                SfxManager.instance
                                                    .playTapSound();
                                              } catch (e) {}
                                              final result =
                                                  await Navigator.push<
                                                    Map<String, int?>
                                                  >(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const PromiseBoardScreen(),
                                                    ),
                                                  );
                                              final pointsFromBoard =
                                                  result != null
                                                  ? result['points']
                                                  : null;
                                              final expFromBoard =
                                                  result != null
                                                  ? result['exp']
                                                  : null;

                                              if (pointsFromBoard != null) {
                                                // 1. トレース（ストップウォッチ）を用意して、名前をつける
                                                final Trace trace =
                                                    FirebasePerformance.instance
                                                        .newTrace(
                                                          'timer_end_trace',
                                                        );
                                                // 2. 計測スタート！
                                                await trace.start();

                                                try {
                                                  try {
                                                    SfxManager.instance
                                                        .playSuccessSound();
                                                  } catch (e) {}
                                                  setState(() {
                                                    _points += pointsFromBoard;
                                                    _experience +=
                                                        expFromBoard ?? 0;
                                                  });
                                                  if (!_hasVisitedPointAddition) {
                                                    _animationController
                                                        .forward(from: 0.0);
                                                  }
                                                  _showHugePointAnimation(
                                                    pointsFromBoard,
                                                  );
                                                  await SharedPrefsHelper.addCumulativePoints(
                                                    pointsFromBoard,
                                                  );
                                                } finally {
                                                  // 3. 計測ストップ！（データがFirebaseに送信されます）
                                                  // ※ エラーが起きても確実に止まるように finally の中に入れるのが鉄則です
                                                  await trace.stop();
                                                }
                                              }
                                              _checkLevelUp();
                                              await SharedPrefsHelper.savePoints(
                                                _points,
                                              );
                                              _loadAndDetermineDisplayPromise();
                                              // 🌟 追加: 戻ってきたらリセット
                                              if (_activeMissionTarget ==
                                                  'mission_promise_board') {
                                                setState(
                                                  () => _activeMissionTarget =
                                                      null,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isPromiseTarget) // 🌟 指マーク
                                      const Positioned(
                                        right: -10,
                                        bottom: -10,
                                        child: AnimatedTapFinger(),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 4),

                            // ② せかい
                            Builder(
                              builder: (context) {
                                final isWorldTarget =
                                    _activeMissionTarget ==
                                    'mission_world_map'; // 🌟 追加
                                return Stack(
                                  // 🌟 Stackで囲む
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    IgnorePointer(
                                      ignoring:
                                          isAnyTutorialBlinking &&
                                          !isWorldTarget,
                                      child: Opacity(
                                        opacity:
                                            isAnyTutorialBlinking &&
                                                !isWorldTarget
                                            ? 0.6
                                            : 1.0,
                                        child: BlinkingEffect(
                                          // 🌟 追加
                                          isBlinking: isWorldTarget,
                                          child: _buildRoundMenuButton(
                                            icon: Icons.public,
                                            label: AppLocalizations.of(
                                              context,
                                            )!.navWorldMap,
                                            iconColor: Colors.black,
                                            backgroundColor: Colors.white, // 白
                                            isMain: false,
                                            onTap: () async {
                                              try {
                                                SfxManager.instance
                                                    .playTapSound();
                                              } catch (e) {}
                                              FirebaseAnalytics.instance.logEvent(
                                                name:
                                                    'start_child_home_world_map',
                                              );
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      WorldMapScreen(
                                                        currentLevel: _level,
                                                        currentPoints: _points,
                                                        requiredExpForNextLevel:
                                                            _requiredExpForNextLevel,
                                                        experience: _experience,
                                                        experienceFraction:
                                                            _experienceFraction,
                                                      ),
                                                ),
                                              ).then((_) {
                                                _loadAndDetermineDisplayPromise();
                                                // 🌟 追加: 戻ってきたらリセット
                                                if (_activeMissionTarget ==
                                                    'mission_world_map') {
                                                  setState(
                                                    () => _activeMissionTarget =
                                                        null,
                                                  );
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isWorldTarget) // 🌟 指マーク
                                      const Positioned(
                                        right: -10,
                                        bottom: -10,
                                        child: AnimatedTapFinger(),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 4),

                            // ③ ミッション
                            Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.topRight,
                              children: [
                                IgnorePointer(
                                  ignoring:
                                      isAnyTutorialBlinking &&
                                      !_showMissionBubble,
                                  child: Opacity(
                                    opacity:
                                        (isAnyTutorialBlinking &&
                                            !_showMissionBubble)
                                        ? 0.6
                                        : 1.0,
                                    child: BlinkingEffect(
                                      isBlinking: _showMissionBubble,
                                      child: _buildRoundMenuButton(
                                        icon: Icons.assignment_turned_in,
                                        label: AppLocalizations.of(
                                          context,
                                        )!.missionScreenTitle,
                                        iconColor: Colors.black,
                                        backgroundColor: Colors.white, // 白
                                        isMain: false,
                                        onTap: () async {
                                          try {
                                            SfxManager.instance.playTapSound();
                                          } catch (e) {}
                                          if (_showMissionBubble) {
                                            FirebaseAnalytics.instance.logEvent(
                                              name:
                                                  'start_child_home_mission_tutorial',
                                            );
                                          } else {
                                            FirebaseAnalytics.instance.logEvent(
                                              name: 'start_child_home_mission',
                                            );
                                          }
                                          final bool isTutorial =
                                              _showMissionBubble;
                                          if (!mounted) return;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MissionScreen(
                                                    isTutorialMode: isTutorial,
                                                  ),
                                            ),
                                          ).then((result) async {
                                            _loadAndDetermineDisplayPromise();
                                            _checkUnclaimedMissions();

                                            if (isTutorial) {
                                              final claimedIds =
                                                  await SharedPrefsHelper.loadClaimedMissionIds();
                                              if (claimedIds.contains(
                                                'mission_first_promise',
                                              )) {
                                                await SharedPrefsHelper.setTutorialStepShown(
                                                  'tutorial_step_mission',
                                                );
                                                await SharedPrefsHelper.setMissionTutorialCompleted();
                                                await SharedPrefsHelper.setChildTutorial(
                                                  SharedPrefsHelper
                                                      .tutorialPhaseFinish,
                                                );
                                                if (mounted) {
                                                  await _showTutorialDialog(
                                                    title: AppLocalizations.of(
                                                      context,
                                                    )!.tutorialFirstPromiseCompleteTitle,
                                                    content: AppLocalizations.of(
                                                      context,
                                                    )!.tutorialFirstPromiseCompleteDesc,
                                                    buttonText:
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.gotIt,
                                                  );
                                                  setState(() {
                                                    _showMissionBubble = false;
                                                  });
                                                }
                                              }
                                            } else {
                                              // 🌟 追加: 「やってみる」でIDが返ってきたらターゲットにセットする！
                                              if (result is String &&
                                                  result.startsWith(
                                                    'mission_',
                                                  )) {
                                                if (result ==
                                                    'mission_first_promise') {
                                                  SharedPrefsHelper.setChildTutorial(
                                                    SharedPrefsHelper
                                                        .tutorialPhaseStart,
                                                  );
                                                  _showChildTutorial();
                                                } else if (result ==
                                                    'mission_parent_setup') {
                                                  SharedPrefsHelper.setParentTutorial(
                                                    SharedPrefsHelper
                                                        .tutorialPhaseStart,
                                                  );
                                                  _showParentTutorial();
                                                } else {
                                                  setState(() {
                                                    _activeMissionTarget =
                                                        result;
                                                  });
                                                }
                                              }
                                            }
                                            int earnedPoints =
                                                await LoginBonusManager()
                                                    .checkLoginBonus(context);
                                            await TrophyManager.checkAndShowTrophies(
                                              context,
                                            );
                                            if (earnedPoints > 0 && mounted) {
                                              try {
                                                SfxManager.instance
                                                    .playSuccessSound();
                                              } catch (e) {}
                                              _showHugePointAnimation(
                                                earnedPoints,
                                              );

                                              if (!_hasVisitedPointAddition) {
                                                _animationController.forward(
                                                  from: 0.0,
                                                );
                                              }
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                if (_showMissionBubble)
                                  const Positioned(
                                    right: -10,
                                    bottom: -10,
                                    child: AnimatedTapFinger(),
                                  )
                                else if (_hasUnclaimedMissions)
                                  Positioned(
                                    top: -4,
                                    right: 0,
                                    child: ScaleTransition(
                                      scale: Tween<double>(begin: 1.0, end: 1.3)
                                          .animate(
                                            CurvedAnimation(
                                              parent: _hintAnimationController,
                                              curve: Curves.easeInOut,
                                            ),
                                          ),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2.0,
                                          ),
                                        ),
                                        child: const Text(
                                          '!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // ④ きせかえ
                            Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                IgnorePointer(
                                  ignoring:
                                      isAnyTutorialBlinking &&
                                      !_showCustomizeBlinking,
                                  child: Opacity(
                                    opacity:
                                        (isAnyTutorialBlinking &&
                                            !_showCustomizeBlinking)
                                        ? 0.6
                                        : 1.0,
                                    child: BlinkingEffect(
                                      isBlinking: _showCustomizeBlinking,
                                      child: _buildRoundMenuButton(
                                        icon: Icons.checkroom,
                                        label: AppLocalizations.of(
                                          context,
                                        )!.navDressUp,
                                        iconColor: Colors.black,
                                        backgroundColor: Colors.white, // 白
                                        isMain: false,
                                        onTap: () async {
                                          bool isShown =
                                              await SharedPrefsHelper.getChildTutorial() ==
                                              SharedPrefsHelper
                                                  .tutorialPhaseStart;
                                          if (isShown) {
                                            FirebaseAnalytics.instance.logEvent(
                                              name:
                                                  'tutorial_tap_customize_button',
                                            );
                                          } else {
                                            FirebaseAnalytics.instance.logEvent(
                                              name: 'start_child_home_dress_up',
                                            );
                                          }
                                          try {
                                            SfxManager.instance.playTapSound();
                                          } catch (e) {}
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const CharacterCustomizeScreen(),
                                            ),
                                          ).then((_) async {
                                            setState(() {
                                              _showCustomizeBlinking = false;
                                            });
                                            if (isShown) {
                                              FirebaseAnalytics.instance.logEvent(
                                                name:
                                                    'tutorial_tap_customize_back',
                                              );
                                              await SharedPrefsHelper.setTutorialStepShown(
                                                SharedPrefsHelper
                                                    .tutorialStepCustomizeKey,
                                              );
                                              if (!mounted) return;
                                              setState(() {
                                                _showMissionBubble = true;
                                              });
                                            }
                                            await _loadAndDetermineDisplayPromise();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                if (_showCustomizeBlinking)
                                  const Positioned(
                                    right: -10,
                                    bottom: -10,
                                    child: AnimatedTapFinger(),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 🌟 左側のボタン群
                  if (!_isDrawingMode)
                    Positioned(
                      top: 0,
                      left: 10,
                      child: Center(
                        child: SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ① おやのせってい（サブ機能として小さく）
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  IgnorePointer(
                                    ignoring:
                                        isAnyTutorialBlinking &&
                                        !_showParentSettingsBlinking,
                                    child: Opacity(
                                      opacity:
                                          (isAnyTutorialBlinking &&
                                              !_showParentSettingsBlinking)
                                          ? 0.6
                                          : 1.0,
                                      child: BlinkingEffect(
                                        isBlinking: _showParentSettingsBlinking,
                                        child: _buildRoundMenuButton(
                                          icon: Icons.settings,
                                          label: AppLocalizations.of(
                                            context,
                                          )!.parentSettings,
                                          iconColor: Colors.black,
                                          backgroundColor: Colors.white, // 白
                                          isMain: false, // 🌟 サブ機能なので小さく
                                          onTap:
                                              (isAnyTutorialBlinking &&
                                                  !_showParentSettingsBlinking)
                                              ? null
                                              : () async {
                                                  try {
                                                    SfxManager.instance
                                                        .playTapSound();
                                                  } catch (e) {}
                                                  await _openParentMode();
                                                },
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_showParentSettingsBlinking)
                                    const Positioned(
                                      right: -5,
                                      bottom: -5,
                                      child: AnimatedTapFinger(),
                                    ),
                                  if (_isTutorialParentSettingsFocus)
                                    Positioned(
                                      top: 10,
                                      left: 60,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF9C4),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.orange,
                                              width: 2,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.tutorialParentSettingsBubble,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // ② おえかき
                              IgnorePointer(
                                ignoring: isAnyTutorialBlinking,
                                child: Opacity(
                                  opacity: (isAnyTutorialBlinking) ? 0.6 : 1.0,
                                  child: _buildRoundMenuButton(
                                    icon: Icons.brush,
                                    label: AppLocalizations.of(
                                      context,
                                    )!.drawingButton,
                                    iconColor: Colors.black,
                                    backgroundColor: Colors.white, // 白
                                    isMain: false, // 🌟 サブ機能なので小さく
                                    onTap: () async {
                                      FirebaseAnalytics.instance.logEvent(
                                        name: 'start_home_drawing',
                                      );
                                      setState(() {
                                        _isDrawingMode = true;
                                      });
                                      try {
                                        SfxManager.instance.playTapSound();
                                      } catch (_) {}
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // ③ あそびかた（ヘルプ）
                              IgnorePointer(
                                ignoring: isAnyTutorialBlinking,
                                child: Opacity(
                                  opacity: (isAnyTutorialBlinking) ? 0.6 : 1.0,
                                  child: _buildRoundMenuButton(
                                    icon: Icons.help_outline,
                                    label: AppLocalizations.of(context)!.help,
                                    iconColor: Colors.black,
                                    backgroundColor: Colors.white, // オレンジ系の可愛い色
                                    isMain: false, // 🌟 サブ機能なので小さく
                                    onTap: () async {
                                      FirebaseAnalytics.instance.logEvent(
                                        name: 'start_child_home_help',
                                      );
                                      try {
                                        SfxManager.instance.playTapSound();
                                      } catch (e) {}
                                      _onHelpButtonPressed();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (_showStartBlinking)
              Positioned.fill(
                child: Container(
                  color: Colors.black38, // 薄暗くする
                ),
              ),

            // 🌟 追加: つぎのやくそくバーのちょっと上に表示するブースト帯
            if (_homeBoostMultiplier > 1 && _boostRemainingHms.isNotEmpty)
              if (!_isDrawingMode)
                Positioned(
                  bottom:
                      65, // 💡「つぎのやくそく」バーの高さが 70 前後であれば、90〜100 付与すると少し上に浮きます
                  left: 10,
                  child: IgnorePointer(
                    // タップを裏に透過させる
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.orangeAccent,
                              Colors.deepOrangeAccent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              // UIをすっきりさせるためショップ用を流用するか、新キーを作ってください
                              // ここではショップ用「🔥 現在ポイント 〇倍中！」をそのまま流用するイメージです
                              AppLocalizations.of(
                                context,
                              )!.pointAdditionBoostActive(_homeBoostMultiplier),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.access_time_filled,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Builder(
                              builder: (context) {
                                // 1. まず時間の文字列を作る（例: "2日 14:30:00" または "14:30:00"）
                                String timeString = '';
                                if (_boostRemainingDays > 0) {
                                  final daysText = AppLocalizations.of(
                                    context,
                                  )!.homeBoostTimeDays(_boostRemainingDays);
                                  timeString = '$daysText$_boostRemainingHms';
                                } else {
                                  timeString = _boostRemainingHms;
                                }

                                // 2. 「あと {time}」の形に当てはめる
                                final finalText = AppLocalizations.of(
                                  context,
                                )!.homeBoostTimeRemaining(timeString);

                                return Text(
                                  finalText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Courier', // デジタル時計っぽく等幅フォントに
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

            // 下のバー（つぎのやくそく / はじめる）
            if (!_isDrawingMode)
              _displayPromise != null
                  ? Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _showStartBlinking
                                ? Colors.transparent
                                : (_isDisplayPromiseEmergency
                                      ? Colors.red[400]
                                      : Colors.white.withOpacity(0.85)),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: IgnorePointer(
                                  ignoring: isAnyTutorialBlinking,
                                  child: Opacity(
                                    opacity: isAnyTutorialBlinking ? 0.3 : 1.0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (_isDisplayPromiseEmergency)
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.emergency,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        if (!_isDisplayPromiseEmergency)
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.nextPromise,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isAnyTutorialBlinking
                                                  ? Colors.white70
                                                  : Colors.grey[700],
                                            ),
                                          ),
                                        Text(
                                          _isDisplayPromiseEmergency
                                              ? '${_displayPromise!['title']} / ${_displayPromise!['points'] * _multiplier}${AppLocalizations.of(context)!.points}'
                                              : '${_displayPromise!['time']}〜 ${_displayPromise!['icon']} ${_displayPromise!['title']} / ${_displayPromise!['points'] * _multiplier}${AppLocalizations.of(context)!.points}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                (_isDisplayPromiseEmergency ||
                                                    isAnyTutorialBlinking)
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // やらなかったボタン
                              IgnorePointer(
                                ignoring: isAnyTutorialBlinking,
                                child: Opacity(
                                  opacity: isAnyTutorialBlinking ? 0.3 : 1.0,
                                  child: TextButton(
                                    onPressed: _skipPromise,
                                    child: Text(
                                      AppLocalizations.of(context)!.didNotDo,
                                      style: TextStyle(
                                        color:
                                            (_isDisplayPromiseEmergency ||
                                                _showStartBlinking)
                                            ? Colors.white70
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  BlinkingEffect(
                                    isBlinking: _showStartBlinking,
                                    borderRadius: 30, // 🌟 丸いボタンに合わせて角丸を変更
                                    child: IgnorePointer(
                                      ignoring:
                                          isAnyTutorialBlinking &&
                                          !_showStartBlinking,
                                      child: Opacity(
                                        opacity:
                                            (isAnyTutorialBlinking &&
                                                !_showStartBlinking)
                                            ? 0.3
                                            : 1.0,
                                        child: FilledButton(
                                          onPressed: _startPromise,
                                          style: FilledButton.styleFrom(
                                            // 🌟 変更: はじめるボタンをより大きく・目立たせる！
                                            backgroundColor:
                                                _isDisplayPromiseEmergency
                                                ? Colors.white
                                                : const Color(
                                                    0xFFFF7043,
                                                  ), // ビビッドなオレンジ
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 32,
                                              vertical: 9,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: Text(
                                            _isDisplayPromiseEmergency
                                                ? AppLocalizations.of(
                                                    context,
                                                  )!.startNow
                                                : AppLocalizations.of(
                                                    context,
                                                  )!.startPromise,
                                            style: TextStyle(
                                              color: _isDisplayPromiseEmergency
                                                  ? Colors.red[400]
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16, // 🌟 テキストも少し大きく
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_showStartBlinking)
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: AnimatedTapFinger(),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.allPromisesDone,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

            // ==========================================
            // 📸 画像として切り取る「世界」のレイヤー
            // ==========================================
            RepaintBoundary(
              key: _shareKey,
              child: Stack(
                children: [
                  // 背景
                  if (_showWatermarkForCapture)
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_equippedWorldPath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  // 真ん中のエリア（アバターと家）
                  Builder(
                    builder: (context) {
                      final isHouseTarget =
                          _activeMissionTarget ==
                          'mission_enter_house'; // 🌟 追加
                      return IgnorePointer(
                        ignoring: isAnyTutorialActive && !isHouseTarget,
                        child: Opacity(
                          opacity: isAnyTutorialActive && !isHouseTarget
                              ? 0.6
                              : 1.0,
                          child: Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                _hintTimer?.cancel();
                                setState(() {
                                  _showHouseHint = true;
                                });
                                _hintTimer = Timer(
                                  const Duration(seconds: 3),
                                  () {
                                    setState(() {
                                      _showHouseHint = false;
                                    });
                                  },
                                );
                              },
                              onLongPress: () async {
                                try {
                                  SfxManager.instance.playSuccessSound();
                                } catch (e) {}

                                if (!_hasEnteredHouse) {
                                  await SharedPrefsHelper.setHasEnteredHouse(
                                    true,
                                  );
                                  setState(() {
                                    _hasEnteredHouse = true;
                                  });
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HouseInteriorScreen(
                                      equippedHousePath: _equippedHousePath,
                                      requiredExpForNextLevel:
                                          _requiredExpForNextLevel,
                                      experience: _experience,
                                      experienceFraction: _experienceFraction,
                                    ),
                                  ),
                                ).then((_) {
                                  _loadAndDetermineDisplayPromise();
                                  // 🌟 追加: 戻ってきたら誘導リセット
                                  if (_activeMissionTarget ==
                                      'mission_enter_house') {
                                    setState(() => _activeMissionTarget = null);
                                  }
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // 🌟 変更: 家を点滅させて指マークをつける
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      BlinkingEffect(
                                        isBlinking: isHouseTarget,
                                        child: Image.asset(
                                          _equippedHousePath,
                                          height: 200,
                                        ),
                                      ),
                                      if (isHouseTarget)
                                        const Positioned(
                                          right: 50,
                                          bottom: 50,
                                          child: AnimatedTapFinger(),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  if (!_hasEnteredHouse &&
                      !_showCustomizeBlinking &&
                      !_showParentSettingsBlinking &&
                      !_showStartBlinking &&
                      !_showMissionBubble &&
                      !_isDrawingMode &&
                      !_showWatermarkForCapture)
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.45,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.longPressToEnter,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ScaleTransition(
                              scale: Tween<double>(begin: 1.0, end: 1.3)
                                  .animate(
                                    CurvedAnimation(
                                      parent: _hintAnimationController,
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                              child: const Icon(
                                Icons.touch_app,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_showHouseHint)
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.45,
                      left: MediaQuery.of(context).size.width * 0.4,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.longPressToEnter,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // アイテムの表示と操作
                  ..._equippedItems.map((itemPath) {
                    return DraggableCharacter(
                      id: itemPath,
                      imagePath: itemPath,
                      position:
                          _itemPositionsMap[itemPath] ?? const Offset(100, 190),
                      size: _getItemSize(itemPath),
                      isInteractive: !isAnyTutorialActive,
                      onPositionChanged: (delta) {
                        setState(() {
                          _itemPositionsMap[itemPath] =
                              (_itemPositionsMap[itemPath] ??
                                  const Offset(100, 190)) +
                              delta;
                        });
                      },
                    );
                  }).toList(),

                  // 応援キャラクターの表示と操作
                  // チュートリアル中は表示しない
                  if (!isAnyTutorialActive)
                    ..._equippedCharacters.map((charPath) {
                      return DraggableCharacter(
                        id: charPath,
                        imagePath: charPath,
                        position:
                            _characterPositionsMap[charPath] ??
                            Offset(safeAreaWidth - 240, 190),
                        size: 80,
                        isInteractive: !isAnyTutorialActive,
                        onPositionChanged: (delta) {
                          setState(() {
                            _characterPositionsMap[charPath] =
                                (_characterPositionsMap[charPath] ??
                                    Offset(safeAreaWidth - 240, 190)) +
                                delta;
                          });
                        },
                      );
                    }).toList(),

                  // アバターの表示と操作
                  DraggableCharacter(
                    id: 'avatar',
                    customWidget: AnimatedAvatar(
                      child: AvatarDisplay(
                        face: _equippedFace,
                        clothes: _equippedClothes,
                        hair: _equippedHair,
                        headgear: _equippedHeadgear,
                        accessory: _equippedAccessory,
                        size: 80,
                      ),
                    ),
                    position: _avatarPosition,
                    size: 80,
                    isInteractive: !isAnyTutorialActive,
                    onPositionChanged: (delta) {
                      setState(() {
                        _avatarPosition += delta;
                      });
                    },
                  ),

                  // ==========================================
                  // 🎨 追加: おえかきキャンバスレイヤー
                  // ==========================================
                  if (_isDrawingMode)
                    // モードONの時：指の動きを検知して線を描く
                    GestureDetector(
                      onPanStart: (details) {
                        setState(() {
                          RenderBox renderBox =
                              context.findRenderObject() as RenderBox;
                          final localOffset = renderBox.globalToLocal(
                            details.globalPosition,
                          );

                          if (_isStampMode && !_isEraserMode) {
                            // 🌟 スタンプモードの処理
                            _drawingPoints.add(
                              DrawingPoint(
                                offset: localOffset,
                                isEmoji: true,
                                emoji: _selectedEmoji,
                              ),
                            );
                            _drawingPoints.add(null); // スタンプは1点で完結するので直後に線を切る
                          } else {
                            // 🌟 ペン・消しゴムモードの処理
                            _drawingPoints.add(
                              DrawingPoint(
                                offset: localOffset,
                                paint: Paint()
                                  ..color = _isEraserMode
                                      ? Colors.transparent
                                      : _selectedColor
                                  ..blendMode = _isEraserMode
                                      ? BlendMode.clear
                                      : BlendMode.srcOver
                                  ..strokeCap = StrokeCap.round
                                  ..strokeWidth = _isEraserMode
                                      ? _strokeWidth * 3
                                      : _strokeWidth,
                              ),
                            );
                          }
                        });
                      },
                      onPanUpdate: (details) {
                        // 🌟 スタンプモード中はドラッグしても何もしない（連続して出ないようにする）
                        if (_isStampMode && !_isEraserMode) return;

                        setState(() {
                          RenderBox renderBox =
                              context.findRenderObject() as RenderBox;
                          _drawingPoints.add(
                            DrawingPoint(
                              offset: renderBox.globalToLocal(
                                details.globalPosition,
                              ),
                              paint: Paint()
                                ..color = _isEraserMode
                                    ? Colors.transparent
                                    : _selectedColor
                                ..blendMode = _isEraserMode
                                    ? BlendMode.clear
                                    : BlendMode.srcOver
                                ..strokeCap = StrokeCap.round
                                ..strokeWidth = _isEraserMode
                                    ? _strokeWidth * 3
                                    : _strokeWidth,
                            ),
                          );
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          if (!_isStampMode || _isEraserMode) {
                            _drawingPoints.add(null);
                          }
                        });
                      },
                      child: Container(
                        color: Colors.white.withOpacity(
                          0.01,
                        ), // 透明だと検知しない場合があるためごく僅かに色をつける
                        width: double.infinity,
                        height: double.infinity,
                        child: CustomPaint(
                          painter: DrawingPainter(points: _drawingPoints),
                        ),
                      ),
                    )
                  else
                    // モードOFFの時：線は表示するが、タッチは家具に貫通させる
                    IgnorePointer(
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: CustomPaint(
                          painter: DrawingPainter(points: _drawingPoints),
                        ),
                      ),
                    ),

                  // シェア画像にだけ写る「宣伝用ロゴ（ウォーターマーク）」
                  if (_showWatermarkForCapture)
                    Positioned(
                      bottom: 16.0,
                      right: 16.0,
                      child: Text(
                        AppLocalizations.of(context)!.appName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_showCustomizeBlinking)
              Positioned(
                bottom: 20,
                right: 90,
                child: TutorialCharacterBubble(
                  text: AppLocalizations.of(context)!.tutorialCustomizeBubble,
                  currentStep: 2,
                  totalSteps: 3,
                ),
              ),
            // 🌟 追加: やってみる！の誘導中の吹き出し
            if (_activeMissionTarget != null)
              Positioned(
                bottom: _activeMissionTarget == 'mission_enter_house'
                    ? 0
                    : 120, // ミッションボタンより少し上の見やすい位置
                right: 80,
                child: TutorialCharacterBubble(
                  text: _getMissionTargetBubbleText(_activeMissionTarget!),
                  currentStep: 3,
                  totalSteps: 3,
                ),
              ),
            if (_showStartBlinking)
              Positioned(
                bottom: 50,
                right: 0,
                child: _showEmergencyStartBlinking
                    ? TutorialCharacterBubble(
                        text: AppLocalizations.of(
                          context,
                        )!.tutorialEmergencyStartBubble,
                      )
                    : TutorialCharacterBubble(
                        text: AppLocalizations.of(context)!.tutorialStartBubble,
                        currentStep: 1,
                        totalSteps: 3,
                      ),
              ),
            if (_showMissionBubble)
              Positioned(
                bottom: 80,
                right: 80,
                child: TutorialCharacterBubble(
                  text: AppLocalizations.of(context)!.missionHintBubble,
                ),
              ),

            // 🎨 おえかきモード中のボタン群
            if (!_showWatermarkForCapture)
              if (_isDrawingMode)
                Positioned(
                  top: 10.0,
                  right: 10.0,
                  child: SafeArea(
                    child: Column(
                      children: [
                        // 全消しボタン
                        _buildRoundMenuButton(
                          icon: Icons.delete_outline,
                          label: AppLocalizations.of(context)!.drawingClear,
                          iconColor: Colors.white,
                          backgroundColor: Colors.grey,
                          isMain: true,
                          onTap: () {
                            setState(() {
                              _drawingPoints.clear();
                            });
                            try {
                              SfxManager.instance.playTapSound();
                            } catch (_) {}
                          },
                        ),
                        const SizedBox(height: 16),
                        // シェアボタン
                        _buildRoundMenuButton(
                          icon: Icons.camera_alt,
                          label: AppLocalizations.of(context)!.shareLabel,
                          iconColor: const Color(0xFF5D4037),
                          backgroundColor: const Color(0xFFFFD54F), // 目立つ黄色
                          isMain: true,
                          onTap: () async {
                            // モードを終了しつつ、すぐにシェア処理へ移行
                            setState(() {
                              _isDrawingMode = false;
                            });

                            FirebaseAnalytics.instance.logEvent(
                              name: 'share_home_image',
                            );
                            try {
                              SfxManager.instance.playTapSound();
                            } catch (_) {}

                            // 1. ロード画面を表示 (画面のチカつきを隠す)
                            if (!mounted) return;
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            // 2. フラグを true にして build メソッドでロゴを表示させる
                            if (mounted) {
                              setState(() {
                                _showWatermarkForCapture = true;
                              });
                            }

                            // 3. 次のフレームの描画（ロゴあり状態のペイント）が完了するのを待つ
                            await WidgetsBinding.instance.endOfFrame;

                            // 4. 画像を切り取ってシェアする処理 (ImageShareHelper の中で boundary.toImage() が呼ばれる)
                            await ImageShareHelper.shareWidget(
                              globalKey: _shareKey,
                              shareText: AppLocalizations.of(
                                context,
                              )!.shareWorldText,
                            );

                            // 5. OSのシェアメニューが開いたら（またはエラーになっても）、ロード画面を閉じる
                            if (mounted) {
                              Navigator.of(context).pop(); // ロード画面を閉じる
                            }

                            // 6. フラグを false に戻して build メソッドでロゴを非表示にする
                            if (mounted) {
                              setState(() {
                                _showWatermarkForCapture = false;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // 👇 🌟 ここから追加：ウィジェットにするボタン
                        _buildRoundMenuButton(
                          icon: Icons.widgets_rounded,
                          label: AppLocalizations.of(context)!.widget,
                          iconColor: Colors.white,
                          backgroundColor: Colors.teal,
                          isMain: true,
                          onTap: () async {
                            FirebaseAnalytics.instance.logEvent(
                              name: 'widget_home_screen_button_tap',
                            );
                            // おえかきモードのUIを消すために一旦falseにする
                            setState(() {
                              _isDrawingMode = false;
                            });

                            // ロード画面を表示
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            if (mounted) {
                              setState(() {
                                _showWatermarkForCapture = true;
                              });
                            }

                            // 描画が終わるのを待ってからキャプチャ実行！
                            await WidgetsBinding.instance.endOfFrame;

                            // 🌟 さっき作ったヘルパーを呼び出す（_shareKeyは既存のものを使います）
                            if (mounted) {
                              await WidgetCaptureHelper.captureAndSetWidget(
                                context,
                                _shareKey,
                              );
                            }

                            // フラグを false に戻して build メソッドでロゴを非表示にする
                            if (mounted) {
                              setState(() {
                                _showWatermarkForCapture = false;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // やめる（キャンセル）ボタン
                        _buildRoundMenuButton(
                          icon: Icons.close,
                          label: AppLocalizations.of(context)!.drawingCancel,
                          iconColor: Colors.white,
                          backgroundColor: Colors.red,
                          isMain: true,
                          onTap: () {
                            try {
                              SfxManager.instance.playTapSound();
                            } catch (_) {}
                            setState(() {
                              _isDrawingMode = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

            // ==========================================
            // 🎨 追加: カラーパレット ＆ 絵文字 ＆ 消しゴム
            // ==========================================
            if (_isDrawingMode)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ① カラーボタンのリスト
                          ..._paletteColors.map((color) {
                            final isSelected =
                                !_isEraserMode &&
                                !_isStampMode &&
                                _selectedColor == color;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = color;
                                  _isEraserMode = false;
                                  _isStampMode = false;
                                });
                                try {
                                  SfxManager.instance.playTapSound();
                                } catch (_) {}
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                width: isSelected ? 36 : 28,
                                height: isSelected ? 36 : 28,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black54
                                        : Colors.grey[300]!,
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),

                          // 仕切り線
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 1.5,
                            height: 30,
                            color: Colors.grey[300],
                          ),

                          // 🌟 ② スタンプ選択ボタン（今選んでいる絵文字が表示される）
                          GestureDetector(
                            onTap: _showEmojiPicker, // メニューを開く
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _isStampMode && !_isEraserMode
                                    ? Colors.pink[50]
                                    : Colors.grey[100],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isStampMode && !_isEraserMode
                                      ? Colors.pink
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    _selectedEmoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  // ＋マークをつけて「選べる感」を出す
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.pink,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 仕切り線
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 1.5,
                            height: 30,
                            color: Colors.grey[300],
                          ),

                          // ③ 消しゴムボタン
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isEraserMode = true;
                                _isStampMode = false;
                              });
                              try {
                                SfxManager.instance.playTapSound();
                              } catch (_) {}
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _isEraserMode
                                    ? Colors.pink[100]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isEraserMode
                                      ? Colors.pink
                                      : Colors.grey[400]!,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.cleaning_services_rounded,
                                size: 22,
                                color: _isEraserMode
                                    ? Colors.pink
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String text,
    required bool isTutorialBlinking,
    bool isBlinking = false,
    required VoidCallback onTap,
  }) {
    return IgnorePointer(
      ignoring: isTutorialBlinking,
      child: Opacity(
        opacity: isTutorialBlinking ? 0.6 : 1.0,
        child: BlinkingEffect(
          // 🌟 追加: 対象の項目を点滅させる
          isBlinking: isBlinking,
          child: ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: 0),
            leading: Icon(icon, color: iconColor, size: 26),
            title: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            onTap: () {
              Navigator.pop(context); // 🌟 タップしたらまずドロワーを閉じる
              onTap(); // その後に遷移処理を実行
            },
          ),
        ),
      ),
    );
  }
}

class SpeechBubbleTailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ==========================================
// 🎨 おえかき用のデータクラスとペインター
// ==========================================
class DrawingPoint {
  final Offset offset;
  final Paint? paint;
  final bool isEmoji; // 🌟 追加: 絵文字かどうか
  final String? emoji; // 🌟 追加: 描画する絵文字

  DrawingPoint({
    required this.offset,
    this.paint,
    this.isEmoji = false,
    this.emoji,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;
  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      if (point == null) continue;

      if (point.isEmoji) {
        // 🌟 絵文字（スタンプ）の描画
        final textPainter = TextPainter(
          text: TextSpan(
            text: point.emoji,
            style: const TextStyle(fontSize: 45), // スタンプの大きさ
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        // タップした指の中心にスタンプが来るようにオフセットを調整
        textPainter.paint(
          canvas,
          Offset(
            point.offset.dx - textPainter.width / 2,
            point.offset.dy - textPainter.height / 2,
          ),
        );
      } else {
        // 🌟 線または点の描画
        final nextPoint = (i + 1 < points.length) ? points[i + 1] : null;
        if (nextPoint != null && !nextPoint.isEmoji) {
          canvas.drawLine(point.offset, nextPoint.offset, point.paint!);
        } else {
          canvas.drawPoints(import_ui.PointMode.points, [
            point.offset,
          ], point.paint!);
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
