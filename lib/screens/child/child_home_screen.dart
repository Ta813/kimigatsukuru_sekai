// lib/screens/child_home_screen.dart

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kimigatsukuru_sekai/managers/notification_manager.dart';
import 'package:kimigatsukuru_sekai/managers/purchase_manager.dart';
import 'package:kimigatsukuru_sekai/screens/premium_paywall_screen.dart';
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
import '../../widgets/speech_bubble.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/avatar_display.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

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
  int? _pointsAdded;

  String _equippedFace = 'assets/images/face/face_default.png';
  String _equippedHair = 'assets/images/hair/hair_default.png';
  String _equippedClothes = 'assets/images/clothes/clothes_default.png';
  String? _equippedHeadgear;
  String? _equippedAccessory;
  String _equippedHousePath = 'assets/images/house.png'; // デフォルト画像
  List<String> _equippedCharacters = [
    'assets/images/character_usagi.gif',
  ]; // デフォルト画像

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
  bool _hasEnteredHouse = false;
  bool _showParentSettingsBlinking = false;
  bool _isTutorialParentSettingsFocus = false;
  bool _showCustomizeBlinking = false;
  late AnimationController _hintAnimationController;
  bool _hasUnclaimedMissions = true;
  bool _isTutorialMissionIncomplete = false;

  // 今日のやくそくの達成状況
  int _totalPromisesCount = 0;
  List<bool> _isPromiseCompletedList = [];
  int? _currentPromiseIndex;
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
      duration: const Duration(milliseconds: 3000),
    );
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, -1.5),
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
      _initializeConsent();
      if (mounted) {
        final earnedPoints = await LoginBonusManager().checkLoginBonus(context);
        await _loadAndDetermineDisplayPromise();
        await SharedPrefsHelper.recordLoginDay();

        if (earnedPoints > 0 && mounted) {
          try {
            SfxManager.instance.playSuccessSound();
          } catch (e) {
            print('再生エラー: $e');
          }
          setState(() {
            _pointsAdded = earnedPoints;
          });
          _animationController.forward(from: 0.0);
          _pointsAddedAnimationController.forward(from: 0.0);
        }
      }
    });

    _checkTutorial();
    _scheduleMidnightRefresh();
  }

  @override
  void dispose() {
    _allCompletedAnimationController.dispose();
    _midnightTimer?.cancel();
    _hintAnimationController.dispose();
    _animationController.dispose();
    _pointsAddedAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        _handleAppResumed();
      }
    }
  }

  Future<void> _initializeConsent() async {
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
          await Permission.appTrackingTransparency.request();
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
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";

    if (lastActiveDateStr != todayStr) {
      await SharedPrefsHelper.clearTodaysCompletedPromises();
      await SharedPrefsHelper.recordLoginDay();
      _loadAndDetermineDisplayPromise();
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
            AppLocalizations.of(context)!.tutorialResumeDesc,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/character_panda.gif', height: 60),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  try {
                    SfxManager.instance.playTapSound();
                  } catch (e) {}
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7043),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 60),
                  side: const BorderSide(color: Color(0xFFFFCA28), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  AppLocalizations.of(context)!.tutorialResumeBtn,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Image.asset('assets/images/character_kuma.gif', height: 60),
            ],
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

      await _showTutorialDialog(
        title: AppLocalizations.of(context)!.guideWelcomeTitle,
        content: AppLocalizations.of(context)!.guideWelcomeDesc,
        buttonText: AppLocalizations.of(context)!.tutorialBtnStart,
      );
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
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _showTutorialDialog(
          title: AppLocalizations.of(context)!.tutorialCustomizeTitle,
          content: AppLocalizations.of(context)!.tutorialCustomizeDesc,
          buttonText: AppLocalizations.of(context)!.tutorialBtnCustomize,
        );
      });
      return;
    }
  }

  void _showParentTutorial() async {
    bool wasParentSetupShown = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepParentSetupShownKey,
    );
    if (!wasParentSetupShown && mounted) {
      setState(() {
        _showParentSettingsBlinking = true;
        _isTutorialParentSettingsFocus = true;
      });
      return;
    }
  }

  Widget _buildRichText(
    String text, {
    required bool isTitle,
    TextAlign textAlign = TextAlign.center,
  }) {
    final List<TextSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE64A19),
            fontSize: isTitle ? 18 : 16,
          ),
        ),
      );
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: TextStyle(
          fontSize: isTitle ? 18 : 16,
          fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
          height: 1.5,
        ),
        children: spans,
      ),
    );
  }

  Future<bool> _showTutorialDialog({
    required String title,
    required String content,
    String? buttonText,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset('assets/images/character_panda.gif', height: 90),
                  const SizedBox(width: 16),
                  Image.asset('assets/images/character_kuma.gif', height: 90),
                ],
              ),
              ClipPath(
                clipper: SpeechBubbleTailClipper(),
                child: Container(
                  width: 24,
                  height: 16,
                  color: const Color(0xFFFFF7E6),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRichText(title, isTitle: true),
                    const SizedBox(height: 10),
                    _buildRichText(content, isTitle: false),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          SfxManager.instance.playTapSound();
                        } catch (e) {}
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop(true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7043),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(220, 64),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 8,
                      ),
                      child: Text(
                        buttonText ?? AppLocalizations.of(context)!.okAction,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset('assets/images/character_panda.gif', height: 90),
                  const SizedBox(width: 8),
                  Image.asset('assets/images/character_kuma.gif', height: 90),
                ],
              ),
              ClipPath(
                clipper: SpeechBubbleTailClipper(),
                child: Container(
                  width: 24,
                  height: 16,
                  color: const Color(0xFFFFF7E6),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRichText(title, isTitle: true),
                    const SizedBox(height: 10),
                    _buildRichText(content, isTitle: false),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                        ElevatedButton(
                          onPressed: () {
                            try {
                              SfxManager.instance.playTapSound();
                            } catch (e) {}
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop(true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7043),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.okAction,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  Future<void> _openParentMode() async {
    if (_isTutorialParentSettingsFocus) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ParentTopScreen(isTutorial: true),
        ),
      );
      if (mounted) {
        await _onParentTutorialCompleted();
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

    final now = DateTime.now();
    bool hasAutoSkipped = false;

    for (var promise in regular) {
      if (!todaysCompletedTitles.contains(promise['title']) &&
          !todaysSkippedTitles.contains(promise['title'])) {
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

          if (now.difference(promiseTime).inMinutes >= 60) {
            await SharedPrefsHelper.addSkippedRecord(promise['title']);
            hasAutoSkipped = true;
          }
        }
      }
    }

    _checkUnclaimedMissions();

    if (hasAutoSkipped) {
      todaysCompletedTitles =
          await SharedPrefsHelper.loadTodaysCompletedPromiseTitles();
      todaysSkippedTitles =
          await SharedPrefsHelper.loadTodaysSkippedPromiseTitles();
    }

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
    final characters = await SharedPrefsHelper.loadEquippedCharacters();
    final items = await SharedPrefsHelper.loadEquippedItems();
    final mediaQuery = MediaQuery.maybeOf(context);
    final orientation = mediaQuery?.orientation ?? Orientation.landscape;

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
      _points = loadedPoints;
      _displayPromise = nextPromise;
      _isDisplayPromiseEmergency = isEmergency;
      _totalPromisesCount = regular.length;
      _isPromiseCompletedList = regular
          .map((p) => todaysCompletedTitles.contains(p["title"]))
          .toList();

      _currentPromiseIndex = null;
      if (nextPromise != null && !isEmergency) {
        final nextTitle = nextPromise["title"];
        for (int i = 0; i < regular.length; i++) {
          if (regular[i]["title"] == nextTitle) {
            _currentPromiseIndex = i;
            break;
          }
        }
      }

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
  }

  void _startPromise() async {
    if (_displayPromise == null) return;

    if (_showStartBlinking) {
      setState(() {
        _showStartBlinking = false;
      });
    }

    FirebaseAnalytics.instance.logEvent(name: 'start_child_home_start_promise');
    final isInTutorial =
        !await SharedPrefsHelper.isTutorialStepShown(
          SharedPrefsHelper.tutorialStepPromiseKey,
        ) &&
        await SharedPrefsHelper.getChildTutorial() ==
            SharedPrefsHelper.tutorialPhaseStart;
    if (isInTutorial) {
      await SharedPrefsHelper.setTutorialStepShown(
        SharedPrefsHelper.tutorialStepPromiseKey,
      );
      FirebaseAnalytics.instance.logEvent(name: 'tutorial_tap_start_button');
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

    final pointsAwarded = result != null ? result['points'] as int? : null;
    final exp = result != null ? result['exp'] as int? : null;

    _playSavedBgm();

    if (pointsAwarded != null && pointsAwarded > 0) {
      if (!_isDisplayPromiseEmergency) {
        await SharedPrefsHelper.addCompletionRecord(_displayPromise!['title']);
      }
      final newTotalPoints = _points + pointsAwarded;

      await SharedPrefsHelper.savePoints(newTotalPoints);

      try {
        SfxManager.instance.playSuccessSound();
      } catch (e) {
        print('再生エラー: $e');
      }

      setState(() {
        _pointsAdded = pointsAwarded;
        _experience += exp ?? 0;
      });
      _animationController.forward(from: 0.0);
      _pointsAddedAnimationController.forward(from: 0.0);
      _checkLevelUp();
      _loadAndDetermineDisplayPromise();

      bool wasCustomizeStepShown = await SharedPrefsHelper.isTutorialStepShown(
        SharedPrefsHelper.tutorialStepCustomizeKey,
      );
      bool isShown =
          await SharedPrefsHelper.getChildTutorial() ==
          SharedPrefsHelper.tutorialPhaseStart;
      if (!wasCustomizeStepShown && isShown && mounted) {
        setState(() {
          _showCustomizeBlinking = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _showTutorialDialog(
            title: AppLocalizations.of(context)!.tutorialCustomizeTitle,
            content: AppLocalizations.of(context)!.tutorialCustomizeDesc,
            buttonText: AppLocalizations.of(context)!.tutorialBtnCustomize,
          );
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
  }

  void _checkLevelUp() {
    if (_level < requiredExpForLevelUp.length &&
        _experience >= requiredExpForLevelUp[_level]) {
      final newLevel = _level + 1;
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
              AppLocalizations.of(context)!.levelUpMessage(newLevel),
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/character_panda.gif', height: 60),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    try {
                      SfxManager.instance.playTapSound();
                    } catch (e) {}
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7043),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 60),
                    side: const BorderSide(color: Color(0xFFFFCA28), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.okAction,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Image.asset('assets/images/character_kuma.gif', height: 60),
              ],
            ),
          ],
        ),
      ).then((_) async {
        bool didRequestNotification = await _requestNotificationPermission(
          context,
          newLevel,
        );

        if (!didRequestNotification) {
          await _requestReviewIfTargetLevel(newLevel);
        }

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
                  ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7043),
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFFFFCA28),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
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
    SharedPrefsHelper.saveExperience(_experience);
  }

  Future<void> _requestReviewIfTargetLevel(int level) async {
    if (level >= 3) {
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
          ElevatedButton(
            onPressed: () {
              if (forceShow) {
                FirebaseAnalytics.instance.logEvent(
                  name: 'tutorial_notification_force',
                );
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043),
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFFFCA28), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
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

  Future<void> _checkUnclaimedMissions() async {
    final claimedIds = await SharedPrefsHelper.loadClaimedMissionIds();
    final cumulativeShop = await SharedPrefsHelper.loadCumulativeShopCount();
    final currentLevel = await SharedPrefsHelper.loadLevel();
    final cumulativePoints = await SharedPrefsHelper.loadCumulativePoints();
    final cumulativeLoginDays =
        await SharedPrefsHelper.loadCumulativeLoginDays();

    bool hasUnclaimed = false;

    if (!claimedIds.contains('mission_parent_setup')) hasUnclaimed = true;
    if (!claimedIds.contains('mission_first_promise')) hasUnclaimed = true;

    final bool isTutorialUnclaimed =
        !claimedIds.contains('mission_parent_setup') ||
        !claimedIds.contains('mission_first_promise');

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
        _isTutorialMissionIncomplete = isTutorialUnclaimed;
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
    final double buttonSize = isMain ? 78.0 : 46.0;
    final double iconSize = isMain ? 48.0 : 24.0;
    final double fontSize = isMain ? 12.0 : 9.0;
    final double borderWidth = isMain ? 4.0 : 2.0;

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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
          Transform.translate(
            offset: const Offset(0, -8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double rightPadding = MediaQuery.of(context).padding.right;
    final double safeAreaWidth = screenWidth - rightPadding;

    final bool isAnyTutorialBlinking =
        _showCustomizeBlinking || _showParentSettingsBlinking;

    final bool isAnyTutorialActive =
        _showCustomizeBlinking ||
        _showParentSettingsBlinking ||
        _showStartBlinking;

    return Scaffold(
      body: Stack(
        children: [
          // 背景
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/world.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 真ん中のエリア（アバターと家）
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                _hintTimer?.cancel();
                setState(() {
                  _showHouseHint = true;
                });
                _hintTimer = Timer(const Duration(seconds: 3), () {
                  setState(() {
                    _showHouseHint = false;
                  });
                });
              },
              onLongPress: () async {
                try {
                  SfxManager.instance.playSuccessSound();
                } catch (e) {}

                if (!_hasEnteredHouse) {
                  await SharedPrefsHelper.setHasEnteredHouse(true);
                  setState(() {
                    _hasEnteredHouse = true;
                  });
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HouseInteriorScreen(
                      equippedHousePath: _equippedHousePath,
                      requiredExpForNextLevel: _requiredExpForNextLevel,
                      experience: _experience,
                      experienceFraction: _experienceFraction,
                    ),
                  ),
                ).then((_) {
                  _loadAndDetermineDisplayPromise();
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [Image.asset(_equippedHousePath, height: 200)],
              ),
            ),
          ),

          if (!_hasEnteredHouse &&
              !_showCustomizeBlinking &&
              !_showParentSettingsBlinking &&
              !_showStartBlinking)
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
                      scale: Tween<double>(begin: 1.0, end: 1.3).animate(
                        CurvedAnimation(
                          parent: _hintAnimationController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: const Icon(
                        Icons.touch_app,
                        color: Colors.white,
                        size: 40,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
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
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),

          SafeArea(
            child: Stack(
              children: [
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 600,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
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
                                            const AlwaysStoppedAnimation<Color>(
                                              Colors.green,
                                            ),
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
                                            fontSize: 10,
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
                                                if (_totalPromisesCount == 0) {
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

                                                final isCurrent =
                                                    index ==
                                                    _currentPromiseIndex;

                                                final starIcon = Icon(
                                                  Icons.star,
                                                  size: 18,
                                                  color: (isCompleted)
                                                      ? Colors.amber
                                                      : Colors.grey[300],
                                                );

                                                if (isCurrent && !isCompleted) {
                                                  return BlinkingEffect(
                                                    isBlinking: true,
                                                    color: Colors.amber,
                                                    borderRadius: 10,
                                                    child: starIcon,
                                                  );
                                                }

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
                                                        alignment:
                                                            Alignment.center,
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
                                  flex: 2,
                                  child: Stack(
                                    alignment: Alignment.centerLeft,
                                    clipBehavior: Clip.none,
                                    children: [
                                      ScaleTransition(
                                        scale: _scaleAnimation,
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
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_pointsAdded != null)
                                        Positioned(
                                          top: -20,
                                          left: 20,
                                          child: SlideTransition(
                                            position: _slideAnimation,
                                            child: FadeTransition(
                                              opacity: _fadeAnimation,
                                              child: Text(
                                                '+$_pointsAdded',
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.redAccent,
                                                  shadows: [
                                                    Shadow(
                                                      blurRadius: 2,
                                                      color: Colors.white,
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
                                Container(
                                  height: 30,
                                  width: 1,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IgnorePointer(
                                        ignoring: isAnyTutorialBlinking,
                                        child: Opacity(
                                          opacity: (isAnyTutorialBlinking)
                                              ? 0.6
                                              : 1.0,
                                          child: InkWell(
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
                                                try {
                                                  SfxManager.instance
                                                      .playSuccessSound();
                                                } catch (e) {}
                                                setState(() {
                                                  _points += pointsFromBoard;
                                                  _pointsAdded =
                                                      pointsFromBoard;
                                                  _experience +=
                                                      expFromBoard ?? 0;
                                                });
                                                _animationController.forward(
                                                  from: 0.0,
                                                );
                                                _pointsAddedAnimationController
                                                    .forward(from: 0.0);
                                              }
                                              _checkLevelUp();
                                              await SharedPrefsHelper.savePoints(
                                                _points,
                                              );
                                              _loadAndDetermineDisplayPromise();
                                            },
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 0.0,
                                                  ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.article_rounded,
                                                    size: 20,
                                                  ),
                                                  Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.navPromiseBoard,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // おんがく（サブ機能として小さく）
                                      IgnorePointer(
                                        ignoring: isAnyTutorialBlinking,
                                        child: Opacity(
                                          opacity: isAnyTutorialBlinking
                                              ? 0.6
                                              : 1.0,
                                          child: InkWell(
                                            onTap: () async {
                                              try {
                                                SfxManager.instance
                                                    .playTapSound();
                                              } catch (e) {}
                                              FirebaseAnalytics.instance
                                                  .logEvent(
                                                    name:
                                                        'start_child_home_bgm',
                                                  );
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const BgmSelectionScreen(),
                                                ),
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 0.0,
                                                  ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.music_note,
                                                    size: 20,
                                                  ),
                                                  Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.navMusic,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // せかい（サブ機能として小さく）
                                      IgnorePointer(
                                        ignoring: isAnyTutorialBlinking,
                                        child: Opacity(
                                          opacity: isAnyTutorialBlinking
                                              ? 0.6
                                              : 1.0,
                                          child: InkWell(
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
                                              });
                                            },
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 0.0,
                                                  ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.public,
                                                    size: 20,
                                                  ),
                                                  Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.navWorldMap,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 🌟 左側のボタン（おやのせってい、きせかえ）
                Positioned(
                  top: 70,
                  left: 10,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // おやのせってい（サブ機能として小さく）
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
                                    backgroundColor: Colors.grey.shade300,
                                    isMain: false, // 🌟 サブ機能なので小さく
                                    onTap:
                                        (isAnyTutorialBlinking &&
                                            !_showParentSettingsBlinking)
                                        ? null
                                        : () async {
                                            FirebaseAnalytics.instance.logEvent(
                                              name:
                                                  'start_child_home_parent_settings',
                                            );
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
                            if (_isTutorialParentSettingsFocus)
                              Positioned(
                                top: 10,
                                left: 60, // サイズが小さくなったので吹き出しの位置を少し左に調整
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF9C4),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.orange,
                                        width: 2,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 4,
                                          color: Colors.black26,
                                        ),
                                      ],
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
                                            fontSize: 12,
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
                        // ヘルプ（サブ機能として小さく）
                        IgnorePointer(
                          ignoring: isAnyTutorialBlinking,
                          child: Opacity(
                            opacity: isAnyTutorialBlinking ? 0.6 : 1.0,
                            child: _buildRoundMenuButton(
                              icon: Icons.question_mark,
                              label: AppLocalizations.of(context)!.help,
                              iconColor: Colors.black, // オレンジ
                              backgroundColor: Colors.yellow.shade100, // 白背景
                              isMain: false,
                              onTap: () {
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

                // 🌟 右側のボタン群
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 10,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ミッション（メイン機能として大きく目立たせる！）
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topRight,
                          children: [
                            IgnorePointer(
                              ignoring: isAnyTutorialBlinking,
                              child: Opacity(
                                opacity: (isAnyTutorialBlinking) ? 0.6 : 1.0,
                                child: BlinkingEffect(
                                  isBlinking: _isTutorialMissionIncomplete,
                                  child: _buildRoundMenuButton(
                                    icon: Icons.assignment_turned_in,
                                    label: AppLocalizations.of(
                                      context,
                                    )!.missionScreenTitle,
                                    iconColor: Colors.black,
                                    backgroundColor: Colors.purple.shade100,
                                    isMain: true, // 🌟 メイン機能なので大きく！
                                    onTap: () async {
                                      try {
                                        SfxManager.instance.playTapSound();
                                      } catch (e) {}
                                      FirebaseAnalytics.instance.logEvent(
                                        name: 'start_child_home_mission',
                                      );

                                      if (!mounted) return;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MissionScreen(),
                                        ),
                                      ).then((result) {
                                        _loadAndDetermineDisplayPromise();
                                        _checkUnclaimedMissions();

                                        if (result != null &&
                                            result is String) {
                                          if (result ==
                                              'mission_parent_setup') {
                                            SharedPrefsHelper.setParentTutorial(
                                              SharedPrefsHelper
                                                  .tutorialPhaseStart,
                                            );
                                            _showParentTutorial();
                                          } else if (result ==
                                              'mission_first_promise') {
                                            SharedPrefsHelper.setChildTutorial(
                                              SharedPrefsHelper
                                                  .tutorialPhaseStart,
                                            );
                                            _showChildTutorial();
                                          }
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            // 「！」バッジの表示
                            if (_hasUnclaimedMissions)
                              Positioned(
                                top: -4, // バッジの位置を微調整
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
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 2,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
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
                        const SizedBox(height: 8),
                        // きせかえ（メイン機能として大きく目立たせる！）
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.centerLeft,
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
                                    icon: Icons.checkroom, // 服のアイコンでわかりやすく
                                    label: AppLocalizations.of(
                                      context,
                                    )!.navDressUp,
                                    iconColor: Colors.black,
                                    backgroundColor: Colors.green.shade100,
                                    isMain: true, // 🌟 メイン機能なので大きく！
                                    onTap: () async {
                                      bool isShown =
                                          await SharedPrefsHelper.getChildTutorial() ==
                                          SharedPrefsHelper.tutorialPhaseStart;
                                      if (isShown) {
                                        FirebaseAnalytics.instance.logEvent(
                                          name: 'tutorial_tap_customize_button',
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
                                        bool isShown =
                                            await SharedPrefsHelper.getChildTutorial() ==
                                            SharedPrefsHelper
                                                .tutorialPhaseStart;
                                        if (isShown) {
                                          FirebaseAnalytics.instance.logEvent(
                                            name: 'tutorial_tap_customize_back',
                                          );
                                          await SharedPrefsHelper.setChildTutorial(
                                            SharedPrefsHelper
                                                .tutorialPhaseFinish,
                                          );
                                          await SharedPrefsHelper.setTutorialStepShown(
                                            SharedPrefsHelper
                                                .tutorialStepCustomizeKey,
                                          );
                                          if (!mounted) return;
                                          await _showTutorialDialog(
                                            title: AppLocalizations.of(
                                              context,
                                            )!.tutorialFirstPromiseCompleteTitle,
                                            content: AppLocalizations.of(
                                              context,
                                            )!.tutorialFirstPromiseCompleteDesc,
                                            buttonText: AppLocalizations.of(
                                              context,
                                            )!.gotIt,
                                          );
                                        }
                                        await _loadAndDetermineDisplayPromise();
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

          // 下のバー（つぎのやくそく / はじめる）
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
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _showStartBlinking
                            ? Colors.transparent
                            : (_isDisplayPromiseEmergency
                                  ? Colors.red[400]
                                  : Colors.white.withOpacity(0.85)),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: _showStartBlinking
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: IgnorePointer(
                              ignoring: isAnyTutorialBlinking,
                              child: Opacity(
                                opacity: isAnyTutorialBlinking ? 0.3 : 1.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_isDisplayPromiseEmergency)
                                      Text(
                                        AppLocalizations.of(context)!.emergency,
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
                                          ? '${_displayPromise!['title']} / ${_displayPromise!['points']}${AppLocalizations.of(context)!.points}'
                                          : '${_displayPromise!['time']}〜 ${_displayPromise!['icon']} ${_displayPromise!['title']} / ${_displayPromise!['points']}${AppLocalizations.of(context)!.points}',
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
                                    child: ElevatedButton(
                                      onPressed: _startPromise,
                                      style: ElevatedButton.styleFrom(
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
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        elevation: 6,
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
                                          fontSize: 20, // 🌟 テキストも少し大きく
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_showStartBlinking)
                                Positioned(
                                  top: -60,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.tutorialStartBubble,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      ClipPath(
                                        clipper: SpeechBubbleTailDownClipper(),
                                        child: Container(
                                          width: 16,
                                          height: 8,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
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

          // アバターの表示と操作
          DraggableCharacter(
            id: 'avatar',
            customWidget: AvatarDisplay(
              face: _equippedFace,
              clothes: _equippedClothes,
              hair: _equippedHair,
              headgear: _equippedHeadgear,
              accessory: _equippedAccessory,
              size: 80,
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

          // 応援キャラクターの表示と操作
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

          // アイテムの表示と操作
          ..._equippedItems.map((itemPath) {
            return DraggableCharacter(
              id: itemPath,
              imagePath: itemPath,
              position: _itemPositionsMap[itemPath] ?? const Offset(100, 190),
              size: _getItemSize(itemPath),
              isInteractive: !isAnyTutorialActive,
              onPositionChanged: (delta) {
                setState(() {
                  _itemPositionsMap[itemPath] =
                      (_itemPositionsMap[itemPath] ?? const Offset(100, 190)) +
                      delta;
                });
              },
            );
          }).toList(),
          if (_showCustomizeBlinking)
            Positioned(
              bottom: 130, // サイズが大きくなったので位置を調整
              right: 70,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SpeechBubble(
                      text: AppLocalizations.of(
                        context,
                      )!.tutorialCustomizeBubble,
                      tailDirection: TailDirection.right,
                    ),
                  ],
                ),
              ),
            ),
        ],
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
