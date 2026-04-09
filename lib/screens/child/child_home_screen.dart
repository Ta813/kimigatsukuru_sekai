import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/lock_mode.dart';
import '../../widgets/draggable_character.dart';
import 'bgm_selection_screen.dart';
import 'passcode_lock_dialog.dart';
import 'promise_board_screen.dart';
import 'timer_screen.dart';
import 'shop_screen.dart';
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
// import 'dart:io';

import 'package:in_app_review/in_app_review.dart';
import 'help_menu_dialog.dart';
import '../../managers/login_bonus_manager.dart';
import '../../widgets/blinking_effect.dart';
import 'package:permission_handler/permission_handler.dart';

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

  String _equippedClothesPath = 'assets/images/avatar.png'; // デフォルト画像
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
  // キーはキャラクターのパス、値はOffset
  Map<String, Offset> _characterPositionsMap = {};

  bool _showHouseHint = false; // 吹き出しを表示するかどうかの旗
  Timer? _hintTimer; // 吹き出しを自動で消すためのタイマー

  // 「はじめる」ボタンを点滅させるフラグ
  bool _showStartBlinking = false;
  bool _hasEnteredHouse = false; // 家に入ったことがあるかのローカルな旗
  bool _isTutorialMoveCompleted = false; // 移動チュートリアルが完了したかどうか
  bool _showParentSettingsBlinking = false; // おやの設定ボタンを点滅させるフラグ
  bool _isTutorialParentSettingsFocus = false; // チュートリアルでおやの設定へ誘導中か
  bool _showShopBlinking = false; // おみせボタンを点滅させるフラグ（チュートリアル）
  bool _showCustomizeBlinking = false; // きせかえボタンを点滅させるフラグ（チュートリアル）
  bool _showDraggableBlinking = false; // キャラ・アイテムを点滅させるフラグ（チュートリアル）
  bool _isWaitingForMove = false; // チュートリアルで移動を待っているかのフラグ
  late AnimationController _hintAnimationController; // 吹き出しアニメーション用

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

  int _level = 1; // レベル
  int _experience = 0; // 経験値
  int _requiredExpForNextLevel = 3; // 次のレベルまでに必要な経験値
  double _experienceFraction = 0.0;

  Timer? _midnightTimer;
  Timer? _tutorialMoveTimer; // ★ チュートリアル移動判定用タイマー

  @override
  void initState() {
    super.initState();

    // ★ 吹き出し用のヒントアニメーションコントローラーを初期化
    _hintAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true); // 繰り返し再生（ポワンポワンさせる）

    // 1. リモコンの準備（アニメーション全体の長さを少し長くする）
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 2. アニメーションの動きを「3回弾む」ように変更
    _scaleAnimation =
        TweenSequence<double>([
          // 1回目のポヨン
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
          // 2回目のポヨン
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
          // 3回目のポヨン
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
    // 下から上に移動しながら消えるアニメーション
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

    _playSavedBgm(); // 保存されたBGMを再生

    _loadAndDetermineDisplayPromise(); // 定例のやくそくを読み込む（既存の処理）
    // ★アプリの状態変化の監視を開始
    WidgetsBinding.instance.addObserver(this);

    // ★ 最初のフレーム描画後に、ダイアログの表示チェックを順番に行う
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. 同意ダイアログ (Androidのみ、こども向け設定のため不要)
      // if (Platform.isAndroid) {
      //   await _showDisclosureDialogIfNeeded();
      // }

      // 2. ログインボーナスチェック
      if (mounted) {
        final earnedPoints = await LoginBonusManager().checkLoginBonus(context);
        // 🌟 ダイアログが閉じた後に最新のポイントなどを再読み込み
        await _loadAndDetermineDisplayPromise();

        if (earnedPoints > 0 && mounted) {
          // ポイント獲得のアニメーションと音を実行
          try {
            SfxManager.instance.playSuccessSound();
          } catch (e) {
            print('再生エラー: $e');
          }

          setState(() {
            _pointsAdded = earnedPoints;
          });

          // アニメーション開始
          _animationController.forward(from: 0.0);
          _pointsAddedAnimationController.forward(from: 0.0);
        }
      }
    });

    _showGuideIfNeeded(); // 必要ならガイドを表示

    _scheduleMidnightRefresh(); // 日付変更チェックのスケジュール設定
  }

  @override
  void dispose() {
    _midnightTimer?.cancel(); // ★ disposeでタイマーをキャンセル
    _tutorialMoveTimer?.cancel(); // ★ チュートリアルタイマーもキャンセル
    _hintAnimationController.dispose();
    _animationController.dispose();
    _pointsAddedAnimationController.dispose();
    // ★アプリの状態変化の監視を終了
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ★アプリの状態が変化した時に呼ばれるメソッド
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // ★ 自分が現在表示されている画面の場合のみ、BGM再生を行う
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        // アプリが前面に戻ってきたら、日付のチェックとBGM再生を行う
        _handleAppResumed();
      }
    } else if (state == AppLifecycleState.paused) {
      // アプリが完全にバックグラウンドへ移行した時のみBGMを停止
      // ※ inactive（ネイティブオーバーレイ表示中など）では止めない
      try {
        BgmManager.instance.stopBgm();
      } catch (e) {
        // エラーが発生した場合
        print('再生エラー: $e');
      }
    }
  }

  // ★ 同意ダイアログ表示メソッド(こども向け設定のため不要)
  // Future<void> _showDisclosureDialogIfNeeded() async {
  //   final hasConsented = await SharedPrefsHelper.hasConsentedToDataCollection();

  //   // まだ同意していない場合のみダイアログを表示
  //   if (!hasConsented && mounted) {
  //     final l10n = AppLocalizations.of(context)!;

  //     await showDialog<void>(
  //       context: context,
  //       barrierDismissible: false, // ダイアログの外をタップしても閉じない
  //       builder: (context) => AlertDialog(
  //         title: Text(l10n.disclosureTitle),
  //         content: SingleChildScrollView(
  //           child: Text(
  //             // Googleが要求する文言のテンプレートに沿った文章
  //             l10n.disclosureMessage,
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text(l10n.disagreeAction),
  //             onPressed: () {
  //               // 同意しない場合はアプリを終了する
  //               SystemNavigator.pop();
  //             },
  //           ),
  //           ElevatedButton(
  //             child: Text(l10n.agreeAction),
  //             onPressed: () async {
  //               // 同意したことを記録
  //               await SharedPrefsHelper.setDataCollectionConsent(true);
  //               if (mounted) {
  //                 if (Navigator.of(context).canPop()) {
  //                   Navigator.of(context).pop();
  //                 }
  //               }
  //             },
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel(); // 既存のタイマーがあればキャンセル

    final now = DateTime.now();
    // 次の日の午前0時0分1秒を計算
    final midnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 1);
    final durationUntilMidnight = midnight.difference(now);

    // 次の午前0時になったらデータを更新するタイマーをセット
    _midnightTimer = Timer(durationUntilMidnight, () {
      // 日付が変わったので、「今日達成したやくそく」をリセット
      SharedPrefsHelper.clearTodaysCompletedPromises();
      // やくそくリストを再読み込み
      _loadAndDetermineDisplayPromise();
      // さらに次の日のタイマーをセット
      _scheduleMidnightRefresh();
    });
  }

  // アプリが前面に戻ってきた時の処理
  Future<void> _handleAppResumed() async {
    // 保存されたBGMを再生
    _playSavedBgm();

    // --- 日付変更チェック ---
    final lastActiveDateStr = await SharedPrefsHelper.loadLastActiveDate();
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";

    // 保存された日付が今日と違う場合、または初めての場合
    if (lastActiveDateStr != todayStr) {
      // 「今日達成したやくそく」のリストをリセットする
      await SharedPrefsHelper.clearTodaysCompletedPromises();
      // その後、やくそくリストを再読み込み
      _loadAndDetermineDisplayPromise();
    }

    // 最後に、今日の日付を「最終利用日」として保存
    await SharedPrefsHelper.saveLastActiveDate(todayStr);
    _scheduleMidnightRefresh(); // タイマーを再設定
  }

  Future<void> _playSavedBgm() async {
    final trackName = await SharedPrefsHelper.loadSelectedBgm();
    final track = BgmTrack.values.firstWhere(
      (e) => e.name == trackName,
      orElse: () => BgmTrack.main, // デフォルトはmain
    );
    try {
      BgmManager.instance.play(track);
    } catch (e) {
      // エラーが発生した場合
      print('再生エラー: $e');
    }
  }

  // ヘルプボタンが押された時に実行されるメソッド
  Future<void> _onHelpButtonPressed() async {
    // 1. ダイアログを表示して、ユーザーの選択結果（String）を待つ
    final String? selectedMenu = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return const HelpMenuDialog();
      },
    );

    // 2. 選択されずに閉じられた場合は何もしない
    if (selectedMenu == null) return;

    // 3. 選ばれた項目に応じて、関連するガイドを表示する
    switch (selectedMenu) {
      case 'yakusoku':
        // つぎのやくそくのガイド
        if (!await _showGuideDialog(
          title: AppLocalizations.of(context)!.guideNextPromiseTitle,
          content: AppLocalizations.of(context)!.guideNextPromiseDesc,
        )) {
          return;
        }

        // チュートリアルと同様に、0ポイントの「おためしやくそく」をセット
        final emergencyPromise = {
          'title': AppLocalizations.of(context)!.trialPromiseTitle,
          'duration': 10,
          'points': 0,
        };
        await SharedPrefsHelper.saveEmergencyPromise(emergencyPromise);
        await _loadAndDetermineDisplayPromise();

        // 「はじめる」ボタンを点滅させ、他を触れないようにする
        if (mounted) {
          setState(() {
            _showStartBlinking = true;
          });
        }
        break;
      case 'shop':
        // ショップのガイド
        if (!await _showGuideDialog(
          title: AppLocalizations.of(context)!.guideShopTitle,
          content: AppLocalizations.of(context)!.guideShopDesc,
        )) {
          return;
        }

        // チュートリアルと同様に「おみせ」ボタンを点滅させ、他を触れないようにする
        if (mounted) {
          setState(() {
            _showShopBlinking = true;
          });
        }
        break;
      case 'dressup':
        // キャラクター選択（きせかえ）のガイド
        if (!await _showGuideDialog(
          title: AppLocalizations.of(context)!.guideCustomizeTitle,
          content: AppLocalizations.of(context)!.guideCustomizeDesc,
        )) {
          return;
        }

        // チュートリアルと同様に「きせかえ」ボタンを点滅させ、他を触れないようにする
        if (mounted) {
          setState(() {
            _showCustomizeBlinking = true;
          });
        }
        break;
      case 'others':
        // やくそくボードのガイド
        if (!await _showGuideDialog(
          title: AppLocalizations.of(context)!.guidePromiseBoardTitle,
          content: AppLocalizations.of(context)!.guidePromiseBoardDesc,
        )) {
          return;
        }

        // 親モード設定のガイド
        if (!await _showGuideDialog(
          title: AppLocalizations.of(context)!.guideSettingsTitle,
          content: AppLocalizations.of(context)!.guideSettingsDesc,
        ))
          return;
        // BGMボタンのガイド
        if (!await _showGuideDialog(
          title: AppLocalizations.of(context)!.guideBgmButtonTitle,
          content: AppLocalizations.of(context)!.guideBgmButtonDesc,
        ))
          return;
        // 外の世界に出るボタンのガイド
        await _showGuideDialog(
          title: AppLocalizations.of(context)!.guideWorldMapButtonTitle,
          content: AppLocalizations.of(context)!.guideWorldMapButtonDesc,
        );
        break;
    }
  }

  void _showTutorial() async {
    // すでに表示済みなら何もしない
    bool wasStepShown = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepPromiseKey,
    );
    if (!wasStepShown) {
      // チュートリアル用の「おためしやくそく」をセットして待機
      final emergencyPromise = {
        'title': AppLocalizations.of(context)!.trialPromiseTitle,
        'duration': 10,
        'points': 100,
      };
      await SharedPrefsHelper.saveEmergencyPromise(emergencyPromise);
      await _loadAndDetermineDisplayPromise();

      // やくそくがセットされたら「はじめる」ボタンを点滅させる
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

    // チュートリアル: 最初の100ポイントゲット後にお店へ誘導
    bool wasShopStepShown = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepShopKey,
    );
    if (!wasShopStepShown && mounted) {
      setState(() {
        _showShopBlinking = true; // おみせボタンを点滅させる
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _showTutorialDialog(
          title: AppLocalizations.of(context)!.tutorialShopTitle,
          content: AppLocalizations.of(context)!.tutorialShopDesc,
          buttonText: AppLocalizations.of(context)!.tutorialBtnShop,
        );
      });
      FirebaseAnalytics.instance.logEvent(name: 'start_tutorial_home_to_shop');
      return;
    }

    bool wasCustomizeStepShown = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepCustomizeKey,
    );
    if (!wasCustomizeStepShown && mounted) {
      FirebaseAnalytics.instance.logEvent(
        name: 'start_tutorial_home_to_dress_up',
      );
      // チュートリアル: アイテム購入後にきせかえへ誘導
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

    // チュートリアル: アイテム移動へ誘導
    bool wasMoveShown = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepMoveKey,
    );
    if (!wasMoveShown && mounted) {
      FirebaseAnalytics.instance.logEvent(
        name: 'start_tutorial_home_to_move_interaction',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _showTutorialDialog(
          title: AppLocalizations.of(context)!.tutorialMoveTitle,
          content: AppLocalizations.of(context)!.tutorialMoveDesc,
          buttonText: AppLocalizations.of(context)!.tutorialBtnMove,
        );
        // ★ 移動を促す状態にする（紫点滅開始）
        if (!_isWaitingForMove) {
          setState(() {
            _isWaitingForMove = true;
            _showDraggableBlinking = true;
          });
        }
      });
      return;
    }
    // チュートリアル: 全ての体験が終わったので、親のやくそく設定へ誘導
    bool wasParentSetupShown = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepParentSetupShownKey,
    );
    if (!wasParentSetupShown && mounted) {
      await _showTutorialDialog(
        title: AppLocalizations.of(context)!.tutorialParentSetupTitle,
        content: AppLocalizations.of(context)!.tutorialParentSetupDesc,
        buttonText: AppLocalizations.of(context)!.tutorialBtnParent,
      );
      // おやの設定画面へ誘導
      setState(() {
        _showParentSettingsBlinking = true;
        _isTutorialParentSettingsFocus = true;
      });
      return;
    }
  }

  // ★ チュートリアルで移動が行われた時に呼ばれる
  void _onTutorialMove() {
    if (!_isWaitingForMove) return;

    // 既存のタイマーがあればキャンセルして、新しく1秒のタイマーを開始
    _tutorialMoveTimer?.cancel();
    _tutorialMoveTimer = Timer(const Duration(seconds: 1), () async {
      if (!mounted) return;
      // 終了フラグを立てる
      await SharedPrefsHelper.setTutorialStepShown(
        SharedPrefsHelper.tutorialStepMoveKey,
      );

      setState(() {
        _isWaitingForMove = false;
        _showDraggableBlinking = false;
        _isTutorialMoveCompleted = true;

        // ★ おやの設定へ誘導開始（紫点滅 + 吹き出し）
        _showParentSettingsBlinking = true;
        _isTutorialParentSettingsFocus = true;
      });

      FirebaseAnalytics.instance.logEvent(name: 'start_tutorial_parent_setup');

      await _showTutorialDialog(
        title: AppLocalizations.of(context)!.tutorialParentSetupTitle,
        content: AppLocalizations.of(context)!.tutorialParentSetupDesc,
        buttonText: AppLocalizations.of(context)!.gotIt,
      );
    });
  }

  void _showGuideIfNeeded() async {
    bool isShown = await SharedPrefsHelper.isGuideShown();
    if (!isShown && mounted) {
      // 画面の描画が終わってから、最初のダイアログを表示
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        //ガイド表示
        _showTutorial();
      });
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
            color: const Color(0xFFE64A19), // 濃いオレンジ / 赤み
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

  // チュートリアルダイアログを表示するための共通メソッド
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
              // キャラクター
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/clothes_dress_red.gif',
                    height: 90,
                  ),
                  const SizedBox(width: 16),
                  Image.asset('assets/images/character_kuma.gif', height: 90),
                ],
              ),
              // 吹き出しのしっぽ（上向き三角）
              ClipPath(
                clipper: _SpeechBubbleTailClipper(),
                child: Container(
                  width: 24,
                  height: 16,
                  color: const Color(0xFFFFF7E6), // 枠線なしの薄いベージュ
                ),
              ),
              // 吹き出し本体
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6), // 枠線なしの薄いベージュ
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
                    // タイトル
                    _buildRichText(title, isTitle: true),
                    const SizedBox(height: 10),
                    // コンテンツ
                    _buildRichText(content, isTitle: false),
                    const SizedBox(height: 10),
                    // ボタン
                    ElevatedButton(
                      onPressed: () {
                        try {
                          SfxManager.instance.playTapSound();
                        } catch (e) {
                          print('再生エラー: $e');
                        }
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop(true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7043), // オレンジ
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

  // 説明ダイアログを表示するための共通メソッド
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
              // キャラクター
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/clothes_dress_red.gif',
                    height: 90,
                  ),
                  const SizedBox(width: 8),
                  Image.asset('assets/images/character_kuma.gif', height: 90),
                ],
              ),
              // 吹き出しのしっぽ（上向き三角）
              ClipPath(
                clipper: _SpeechBubbleTailClipper(),
                child: Container(
                  width: 24,
                  height: 16,
                  color: const Color(0xFFFFF7E6),
                ),
              ),
              // 吹き出し本体
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6), // 枠線なしの薄いベージュ
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
                            } catch (e) {
                              print('再生エラー: $e');
                            }
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop(true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7043), // オレンジ
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24, // パディングを少し広げてバランス調整
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

  // ★ 親モード（設定画面）を開く共通メソッド
  Future<void> _openParentMode() async {
    // チュートリアル中の場合
    if (_isTutorialParentSettingsFocus) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ParentTopScreen(isTutorial: true),
        ),
      );
      // 戻ってきたらチュートリアル完了
      if (mounted) {
        await _onParentTutorialCompleted();
      }
      return;
    }

    // ★ 保存されているロックモードを読み込む
    final lockMode = await SharedPrefsHelper.loadLockMode();

    // ★ モードに応じて表示するダイアログを切り替える
    final bool? isCorrect = await showDialog<bool>(
      context: context,
      builder: (context) {
        if (lockMode == LockMode.passcode) {
          // ★ 保存されているパスワードがなければ、掛け算モードにフォールバック
          // (親がパスワード設定を忘れた場合の安全策)
          return FutureBuilder<String?>(
            future: SharedPrefsHelper.loadPasscode(),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data!.isNotEmpty) {
                return const PasscodeLockDialog();
              }
              return const MathLockDialog(); // パスワード未設定なら掛け算
            },
          );
        }
        return const MathLockDialog(); // デフォルトは掛け算
      },
    );

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

  /// 親チュートリアル完了時の処理
  Future<void> _onParentTutorialCompleted() async {
    if (!mounted) return;
    // フラグを立てる
    await SharedPrefsHelper.setTutorialStepShown(
      SharedPrefsHelper.tutorialStepParentSetupShownKey,
    );
    // チュートリアル完了のフラグを立てる
    await SharedPrefsHelper.setGuideShown();
    // 画面状態をリセット
    if (mounted) {
      setState(() {
        _showParentSettingsBlinking = false;
        _isTutorialParentSettingsFocus = false;
      });
    }
    // 完了ダイアログを表示
    if (mounted) {
      await _showTutorialDialog(
        title: AppLocalizations.of(context)!.tutorialParentCompleteTitle,
        content: AppLocalizations.of(context)!.tutorialParentCompleteDesc,
        buttonText: AppLocalizations.of(context)!.gotIt,
      );
    }
    // プロミスを再読み込む
    _loadAndDetermineDisplayPromise();
  }

  // データを読み込み、表示するやくそくを決定する
  Future<void> _loadAndDetermineDisplayPromise() async {
    // まず、SharedPreferencesから両方のデータを読み込む
    final loadedPoints = await SharedPrefsHelper.loadPoints();
    final regular = await SharedPrefsHelper.loadRegularPromises(context);
    final emergency = await SharedPrefsHelper.loadEmergencyPromise();
    final todaysCompletedTitles =
        await SharedPrefsHelper.loadTodaysCompletedPromiseTitles();

    Offset? loadedAvatarPos = await SharedPrefsHelper.loadCharacterPosition(
      'avatar',
    );
    final entered = await SharedPrefsHelper.getHasEnteredHouse();
    final level = await SharedPrefsHelper.loadLevel();
    final experience = await SharedPrefsHelper.loadExperience();

    Map<String, dynamic>? nextPromise;
    bool isEmergency = false;

    // 1. 緊急のやくそくがあれば、それを最優先する
    if (emergency != null) {
      nextPromise = emergency;
      isEmergency = true;
    }
    // 2. 緊急がなければ、定例のやくそくから探す
    else if (regular.isNotEmpty) {
      final uncompletedPromises = regular.where((promise) {
        return !todaysCompletedTitles.contains(promise['title']);
      }).toList();

      // 未達成のやくそくがあれば
      if (uncompletedPromises.isNotEmpty) {
        // 時間で並び替えて、一番古い（最初の）ものを選択する
        uncompletedPromises.sort((a, b) {
          final timeA = a['time'] ?? '00:00';
          final timeB = b['time'] ?? '00:00';
          return timeA.compareTo(timeB);
        });
        nextPromise = uncompletedPromises.first;
      }
    }

    final clothes = await SharedPrefsHelper.loadEquippedClothes();
    final house = await SharedPrefsHelper.loadEquippedHouse();
    final characters = await SharedPrefsHelper.loadEquippedCharacters();
    final items = await SharedPrefsHelper.loadEquippedItems();
    final moveCompleted = await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepMoveKey,
    );
    bool isShown = await SharedPrefsHelper.isGuideShown();

    final orientation = MediaQuery.of(context).orientation;

    late double screenWidth;
    late double screenHeight;
    late double rightPadding;
    late double safeAreaWidth;

    // 画面の向きに応じて幅と高さを設定
    if (orientation == Orientation.landscape) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
      // 右のノッチ（セーフエリア外）の幅を足す
      rightPadding = MediaQuery.of(context).padding.right;
      safeAreaWidth = screenWidth - rightPadding;
    } else {
      screenWidth = MediaQuery.of(context).size.height;
      screenHeight = MediaQuery.of(context).size.width;
      // 右のノッチ（セーフエリア外）の幅を足す
      rightPadding = MediaQuery.of(context).padding.right;
      safeAreaWidth = screenWidth - rightPadding;
    }

    if (loadedAvatarPos != null &&
        (loadedAvatarPos.dx > screenWidth ||
            loadedAvatarPos.dy > screenHeight ||
            loadedAvatarPos.dx < 0 ||
            loadedAvatarPos.dy < 0)) {
      loadedAvatarPos = null; // 範囲外ならリセット
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
      loadedPositions[itemPath] = loadedPos ?? Offset(100, 190);
    }
    // 最後に、画面の状態を更新
    setState(() {
      _hasEnteredHouse = entered;
      _isTutorialMoveCompleted = moveCompleted || isShown;
      _points = loadedPoints;
      _displayPromise = nextPromise;
      _isDisplayPromiseEmergency = isEmergency;
      _equippedClothesPath = clothes ?? 'assets/images/avatar.png';
      _equippedHousePath = house ?? 'assets/images/house.png';
      _equippedCharacters = characters.isEmpty
          ? ['assets/images/character_usagi.gif'] // デフォルトキャラ
          : characters;
      _equippedItems = items;
      _avatarPosition = loadedAvatarPos ?? Offset(205, 190);
      _characterPositionsMap = {}; // 一旦クリア
      for (var charPath in _equippedCharacters) {
        if (loadedPositions[charPath] != null &&
            (loadedPositions[charPath].dx > screenWidth ||
                loadedPositions[charPath].dy > screenHeight ||
                loadedPositions[charPath].dx < 0 ||
                loadedPositions[charPath].dy < 0)) {
          loadedPositions[charPath] = null; // 範囲外ならリセット
        }
        _characterPositionsMap[charPath] =
            loadedPositions[charPath] ??
            Offset(safeAreaWidth - 240, 190); // 読み込んだ位置を保存
      }
      _itemPositionsMap = {};
      for (var itemPath in _equippedItems) {
        if (loadedPositions[itemPath] != null &&
            (loadedPositions[itemPath].dx > screenWidth ||
                loadedPositions[itemPath].dy > screenHeight ||
                loadedPositions[itemPath].dx < 0 ||
                loadedPositions[itemPath].dy < 0)) {
          loadedPositions[itemPath] = null; // 範囲外ならリセット
        }
        _itemPositionsMap[itemPath] =
            loadedPositions[itemPath] ?? Offset(100, 190); // 読み込んだ位置を保存
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
        // 最大レベルに達した場合
        _requiredExpForNextLevel = _experience;
        _experienceFraction = 1.0;
      }
    });
  }

  // 「はじめる」ボタンを押した時の処理を修正
  void _startPromise() async {
    if (_displayPromise == null) return;

    // 点滅フラグをリセット
    if (_showStartBlinking) {
      setState(() {
        _showStartBlinking = false;
      });
    }

    // ★タイマー画面に行く前に、集中BGMを再生
    // ★ タイマー画面に行く前にFirebaseイベントだけログ
    FirebaseAnalytics.instance.logEvent(name: 'start_child_home_start_promise');
    // ★ チュートリアル中なら追加ログを出す
    final isInTutorial = !(await SharedPrefsHelper.isTutorialStepShown(
      SharedPrefsHelper.tutorialStepPromiseKey,
    ));
    if (isInTutorial) {
      FirebaseAnalytics.instance.logEvent(name: 'tutorial_tap_start_button');
    }
    // 注意：BGM再生は遷移先のTimerScreen.initStateで行われるため、ここでは呼ばない（二重再生防止）

    // タイマー画面に遷移し、結果（獲得ポイント）を待つ
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute<Map<String, dynamic>?>(
        // TimerScreenに、緊急かどうかの情報も渡す
        builder: (context) => TimerScreen(
          promise: _displayPromise!,
          isEmergency: _isDisplayPromiseEmergency,
        ),
      ),
    );

    // 戻り値からポイントと経験値を取得
    final pointsAwarded = result != null ? result['points'] as int? : null;
    final exp = result != null ? result['exp'] as int? : null;

    // ★タイマー画面から戻ってきたら、メインBGMを再生
    _playSavedBgm();
    // ★おためしやくそくをクリアしたら、終了フラグを立てる
    if (pointsAwarded != null && pointsAwarded > 0) {
      await SharedPrefsHelper.setTutorialStepShown(
        SharedPrefsHelper.tutorialStepPromiseKey,
      );
      if (!_isDisplayPromiseEmergency) {
        await SharedPrefsHelper.addCompletionRecord(_displayPromise!['title']);
      }
      // 新しいポイントを計算
      final newTotalPoints = _points + pointsAwarded;

      // SharedPreferencesに新しいポイントを保存
      await SharedPrefsHelper.savePoints(newTotalPoints);

      // ポイント追加の効果音出す
      try {
        SfxManager.instance.playSuccessSound();
      } catch (e) {
        // エラーが発生した場合
        print('再生エラー: $e');
      }

      setState(() {
        _pointsAdded = pointsAwarded;
        _experience += exp ?? 0;
      });
      // 追加されたポイント数を一時的に保存して、アニメーションで表示
      _animationController.forward(from: 0.0);
      _pointsAddedAnimationController.forward(from: 0.0);
      // レベルアップのチェックと表示
      _checkLevelUp();
      // 画面の状態を更新して、再読み込み
      _loadAndDetermineDisplayPromise();

      // チュートリアル: 最初の100ポイントゲット後にお店へ誘導
      bool wasShopStepShown = await SharedPrefsHelper.isTutorialStepShown(
        SharedPrefsHelper.tutorialStepShopKey,
      );
      bool isShown = await SharedPrefsHelper.isGuideShown();
      if (!wasShopStepShown && !isShown && mounted) {
        setState(() {
          _showShopBlinking = true; // おみせボタンを点滅させる
        });
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _showTutorialDialog(
            title: AppLocalizations.of(context)!.tutorialShopTitle,
            content: AppLocalizations.of(context)!.tutorialShopDesc,
            buttonText: AppLocalizations.of(context)!.tutorialBtnShop,
          );
        });
        FirebaseAnalytics.instance.logEvent(name: 'start_tutorial_shop');
      }
    } else {
      // タイマー画面からそのまま戻ってきた場合などで、チュートリアル中なら点滅を再開
      if (isInTutorial && mounted) {
        setState(() {
          _showStartBlinking = true;
        });
      }
    }
  }

  void _checkLevelUp() {
    // 現在のレベルで、次のレベルアップに必要な経験値を超えているか？
    if (_level < requiredExpForLevelUp.length &&
        _experience >= requiredExpForLevelUp[_level]) {
      final newLevel = _level + 1;
      setState(() {
        _level = newLevel;
      });
      SharedPrefsHelper.saveLevel(newLevel);

      // レベルアップの効果音を再生

      final List<String> soundsToPlay = [];
      final String lang = AppLocalizations.of(context)!.localeName;
      if (lang == 'ja') {
        try {
          SfxManager.instance.playTimeYattaSound();
        } catch (e) {
          print('再生エラー: $e');
        }
      } else {
        final String voiceDir = SfxManager.instance.getVoiceDir(lang);
        soundsToPlay.addAll(['se/$voiceDir/level_up.mp3']);
      }
      try {
        SfxManager.instance.playSequentialSounds(soundsToPlay);
      } catch (e) {
        print('再生エラー: $e');
      }

      // ★ レベルアップしたことを伝えるダイアログなどを表示
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
              color: const Color(0xFFFFF3E0), // ピーチクリーム
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF7043).withOpacity(0.5), // オレンジの薄い線
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
                // 左側のキャラクター
                Image.asset('assets/images/clothes_dress_red.gif', height: 60),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    try {
                      SfxManager.instance.playTapSound();
                    } catch (e) {
                      print('再生エラー: $e');
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7043), // オレンジ
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 60), // 横200、縦60。縦幅を出すのがポイント！
                    side: const BorderSide(
                      color: Color(0xFFFFCA28),
                      width: 2,
                    ), // 黄色の輪郭
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
                // 右側のキャラクター
                Image.asset('assets/images/character_kuma.gif', height: 60),
              ],
            ),
          ],
        ),
      ).then((_) async {
        // 1. まず通知許可リクエストをチェックし、ダイアログを出したかどうかの結果(true/false)を受け取る
        bool didRequestNotification = await _requestNotificationPermission(
          context,
          newLevel,
        );

        // 🌟 2. もし通知許可ダイアログが「出なかった」場合だけ、レビューダイアログを聞く
        if (!didRequestNotification) {
          await _requestReviewIfTargetLevel(newLevel);
        }
      });
    }
    // 変更された経験値を保存
    SharedPrefsHelper.saveExperience(_experience);
  }

  Future<void> _requestReviewIfTargetLevel(int level) async {
    // レビューを表示したいレベルの条件をここで指定（例: レベル3以上）
    if (level >= 3) {
      try {
        final InAppReview inAppReview = InAppReview.instance;
        if (await inAppReview.isAvailable()) {
          // システムのレビューダイアログを表示
          await inAppReview.requestReview();
        }
      } catch (e) {
        print('Review request failed: $e');
      }
    }
  }

  // 通知の許可を求める一連の処理（プレ・ダイアログ → OSのダイアログ）
  Future<bool> _requestNotificationPermission(
    BuildContext context,
    int level,
  ) async {
    // 🌟 1. セーブデータを読み込み、「すでに表示したか？」をチェック
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('has_shown_notification_dialog') ?? false;

    if (hasShown) {
      print('通知のお願いダイアログはすでに表示済みのためスキップします');
      return false;
    }

    // レベル2以下なら通知の許可を求めない
    if (level <= 2) return false;
    // 1. 現在の通知許可のステータスを取得
    PermissionStatus status = await Permission.notification.status;

    // すでに「許可」されている、または設定から完全に「拒否」されている場合は何もしない
    if (status.isGranted || status.isPermanentlyDenied) return false;

    // 2. アプリオリジナルの可愛い「お願いダイアログ（プレ・ダイアログ）」を出す
    // ユーザーが「うけとる！」を押したら true、「あとで」を押したら false が返ります
    bool? shouldRequest = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // ダイアログの外側をタップして閉じられないようにする
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.notificationRequestTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0), // ピーチクリーム
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF7043).withOpacity(0.5), // オレンジの薄い線
              width: 2,
            ),
          ),
          // 週1回の通知と、将来の拡張を見据えた安心感のあるメッセージ
          child: Text(
            AppLocalizations.of(context)!.notificationRequestMessage,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          // ❌ 「あとで」ボタン（グレーで目立たせない）
          TextButton(
            onPressed: () => Navigator.pop(context, false), // falseを返す
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: Text(
              AppLocalizations.of(context)!.notificationLater,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // ⭕️ 「うけとる！」ボタン（オレンジで目立たせる）
          ElevatedButton(
            onPressed: () {
              // 必要に応じてタップ音を鳴らす
              try {
                // SfxManager.instance.playTapSound();
              } catch (e) {
                print('再生エラー: $e');
              }
              Navigator.pop(context, true); // trueを返す
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043), // オレンジ
              foregroundColor: Colors.white,
              side: const BorderSide(
                color: Color(0xFFFFCA28), // 黄色の輪郭
                width: 2,
              ),
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

    // 🌟 3. ダイアログを表示し終わったら、「表示したよ！」という記録をセーブする
    // （「うけとる！」でも「あとで」でも、一度見せたという事実は保存します）
    await prefs.setBool('has_shown_notification_dialog', true);

    // 3. ユーザーが「うけとる！」(true) を選んだ時だけ、OS標準のダイアログを出す
    if (shouldRequest == true) {
      await Permission.notification.request();
      FirebaseAnalytics.instance.logEvent(
        name: 'notification_permission_granted',
      );
    } else {
      FirebaseAnalytics.instance.logEvent(
        name: 'notification_permission_denied',
      );
    }
    return true;
  }

  // このメソッドを新しく追加します
  void _skipPromise() async {
    FirebaseAnalytics.instance.logEvent(name: 'start_child_home_skip_promise');
    try {
      SfxManager.instance.playTapSound();
    } catch (e) {
      // エラーが発生した場合
      print('再生エラー: $e');
    }
    if (_displayPromise == null) return;

    // 緊急のやくそくの場合は削除し、定例のやくそくの場合は達成済みとして記録します
    if (_isDisplayPromiseEmergency) {
      await SharedPrefsHelper.saveEmergencyPromise(null);
    } else {
      await SharedPrefsHelper.addCompletionRecord(_displayPromise!['title']);
    }

    // ホーム画面の表示を最新の状態に更新します
    _loadAndDetermineDisplayPromise();
  }

  double _getItemSize(String itemPath) {
    if (itemPath.contains('assets/images/item_kuruma.png')) {
      return 100.0;
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

  @override
  Widget build(BuildContext context) {
    // 画面サイズを取得（位置計算に使用）
    final double screenWidth = MediaQuery.of(context).size.width;
    // 右のノッチ（セーフエリア外）の幅を足す
    final double rightPadding = MediaQuery.of(context).padding.right;
    final double safeAreaWidth = screenWidth - rightPadding;

    // ★ チュートリアル中（いずれかのボタンが点滅中）かどうか
    final bool isAnyTutorialBlinking =
        _showShopBlinking ||
        _showCustomizeBlinking ||
        _showParentSettingsBlinking;

    // Scaffoldが画面全体の基本的な骨組みです
    return Scaffold(
      body: Stack(
        children: [
          // ここに、背景、アバター、家、ボタンなどを重ねていきます

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
            alignment: Alignment.center, // 画面の中央を基準に配置
            child: GestureDetector(
              onTap: () {
                // もしすでにタイマーが動いていたら、一度キャンセルする
                _hintTimer?.cancel();

                // 吹き出しを表示するようにStateを更新
                setState(() {
                  _showHouseHint = true;
                });

                // 3秒後に、吹き出しを非表示にするタイマーをセット
                _hintTimer = Timer(const Duration(seconds: 3), () {
                  setState(() {
                    _showHouseHint = false;
                  });
                });
              },

              onLongPress: () async {
                // 家を長押しした時の処理
                try {
                  SfxManager.instance.playSuccessSound(); // 音を鳴らす
                } catch (e) {
                  // エラーが発生した場合
                  print('再生エラー: $e');
                }

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
                  // ★家の中画面から戻ってきたら、必ずデータを再読み込みする
                  _loadAndDetermineDisplayPromise();
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
                crossAxisAlignment: CrossAxisAlignment.end, // アバターと家の底を揃える
                children: [
                  // 家の画像
                  Image.asset(
                    _equippedHousePath, // あなたが用意した画像ファイル名
                    height: 200, // 高さを指定
                  ),
                ],
              ),
            ),
          ),

          // ★ まだ家に入ったことがなく、かつ移動チュートリアルが完了している場合のみ表示
          if (!_hasEnteredHouse && _isTutorialMoveCompleted)
            Positioned(
              // ★ 家の画像の上あたりに位置を調整
              top: MediaQuery.of(context).size.height * 0.45,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Column(
                  children: [
                    // 吹き出し
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
                        AppLocalizations.of(
                          context,
                        )!.longPressToEnter, // 'おうちを ながおし してみてね！'
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // ポワンポワンする指アイコン
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
              // ★家の位置に合わせて、吹き出しの位置を微調整してください
              top: MediaQuery.of(context).size.height * 0.45,
              left: MediaQuery.of(context).size.width * 0.4,
              child: IgnorePointer(
                // 吹き出し自体はタップできないようにする
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
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),

          // ★ 画面右側に縦に並んだボタン（BGM変更、世界選択）
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 10,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ★ BGM変更ボタンを一番上に追加
                        Material(
                          color: const Color(0xFFFF7043).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              try {
                                SfxManager.instance.playTapSound();
                              } catch (e) {
                                // エラーが発生した場合
                                print('再生エラー: $e');
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BgmSelectionScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 4.0,
                              ),
                              child: SizedBox(
                                width: 55,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.music_note,
                                      size: 24,
                                      color: Color(0xFFFFCA28),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppLocalizations.of(context)!.navMusic,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFFFCA28),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6), // ボタンの間に少し隙間をあける

                        Material(
                          color: const Color(0xFFFF7043).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              try {
                                SfxManager.instance.playTapSound();
                              } catch (e) {
                                // エラーが発生した場合
                                print('再生エラー: $e');
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorldMapScreen(
                                    currentLevel: _level,
                                    currentPoints: _points,
                                    requiredExpForNextLevel:
                                        _requiredExpForNextLevel,
                                    experience: _experience,
                                    experienceFraction: _experienceFraction,
                                  ),
                                ),
                              ).then((_) {
                                // ★世界選択画面から戻ってきたら、必ずデータを再読み込みする
                                _loadAndDetermineDisplayPromise();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 4.0,
                              ),
                              child: SizedBox(
                                width: 55,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.public,
                                      size: 24,
                                      color: Color(0xFFFFCA28),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppLocalizations.of(context)!.navWorldMap,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFFFCA28),
                                        fontWeight: FontWeight.bold,
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
                ),

                // ★ レベル表示（順番をボトムバーの前に移動）
                Positioned(
                  top: 10, // ポイント表示の下あたり
                  left: 0, // 左端を画面の左端に合わせる
                  right: 0, // 右端を画面の右端に合わせる
                  child: Center(
                    // ★ Centerウィジェットで中央に配置
                    child: Container(
                      // ★ ここからが白い枠のデザイン設定
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9), // 少し半透明の白
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          // ポイント表示と同じような影をつける
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
                            width: 220, // ★ 例として横幅を200に設定（画面に合わせて調整してください）
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize:
                                      MainAxisSize.min, // Rowが中身のサイズに合わせる
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
                                    const SizedBox(width: 16),
                                    Text(
                                      // ★ 次のレベルまでの必要経験値を計算して表示
                                      // _requiredExpForNextLevelは次のレベルに必要な「累計」経験値
                                      AppLocalizations.of(
                                        context,
                                      )!.expToNextLevel(
                                        _requiredExpForNextLevel - _experience,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                //経験値バー
                                LinearProgressIndicator(
                                  value: _experienceFraction, // 現在の経験値の割合
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.green,
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

                // 3. 右上の「ポイント表示」
                Positioned(
                  top: 10,
                  right: 10,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              // 少し影をつけて立体感を出す
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$_points', // ポイント数を表示
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // ★「+〇〇」のアニメーション表示
                      if (_pointsAdded != null)
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              '+$_pointsAdded',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                                shadows: [
                                  Shadow(blurRadius: 2, color: Colors.white),
                                ],
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

          // ★アバターの表示と操作
          DraggableCharacter(
            id: 'avatar',
            imagePath: _equippedClothesPath,
            position: _avatarPosition,
            size: 80,
            isBlinking: _showDraggableBlinking,
            onPositionChanged: (delta) {
              setState(() {
                _avatarPosition += delta;
              });
              _onTutorialMove();
            },
          ),

          // ★応援キャラクターの表示と操作
          ..._equippedCharacters.map((charPath) {
            return DraggableCharacter(
              id: charPath,
              imagePath: charPath,
              position:
                  _characterPositionsMap[charPath] ??
                  Offset(safeAreaWidth - 240, 190),
              size: 80,
              isBlinking: _showDraggableBlinking,
              onPositionChanged: (delta) {
                setState(() {
                  _characterPositionsMap[charPath] =
                      (_characterPositionsMap[charPath] ??
                          Offset(safeAreaWidth - 240, 190)) +
                      delta;
                });
                _onTutorialMove();
              },
            );
          }).toList(),

          // ★アイテムの表示と操作
          ..._equippedItems.map((itemPath) {
            return DraggableCharacter(
              id: itemPath,
              imagePath: itemPath,
              position: _itemPositionsMap[itemPath] ?? const Offset(100, 190),
              size: _getItemSize(itemPath),
              isBlinking: _showDraggableBlinking,
              onPositionChanged: (delta) {
                setState(() {
                  _itemPositionsMap[itemPath] =
                      (_itemPositionsMap[itemPath] ?? const Offset(100, 190)) +
                      delta;
                });
                _onTutorialMove();
              },
            );
          }).toList(),

          // ★ チュートリアル点滅中は画面を暗くし、対象以外を触れないようにする
          if (isAnyTutorialBlinking)
            Positioned.fill(child: Container(color: Colors.black38)),

          // 上のバー（ポイントや設定ボタン）とサイドボタン
          SafeArea(
            child: Stack(
              children: [
                // 4. 右側の3つのボタン
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 85,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IgnorePointer(
                          ignoring: isAnyTutorialBlinking,
                          child: Opacity(
                            opacity: isAnyTutorialBlinking ? 0.6 : 1.0,
                            child: Material(
                              color: const Color(0xFFFF7043).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () async {
                                  try {
                                    SfxManager.instance.playTapSound();
                                  } catch (e) {
                                    // エラーが発生した場合
                                    print('再生エラー: $e');
                                  }

                                  // やくそくボード画面から戻ってくるのを「await」で待ち、結果を受け取る
                                  final result =
                                      await Navigator.push<Map<String, int?>>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PromiseBoardScreen(),
                                        ),
                                      );

                                  // 戻り値からポイントと経験値を取得
                                  final pointsFromBoard = result != null
                                      ? result['points']
                                      : null;
                                  final expFromBoard = result != null
                                      ? result['exp']
                                      : null;

                                  // もし、ポイントを持って戻ってきたら
                                  if (pointsFromBoard != null) {
                                    // ポイント追加の効果音出す
                                    try {
                                      SfxManager.instance.playSuccessSound();
                                    } catch (e) {
                                      // エラーが発生した場合
                                      print('再生エラー: $e');
                                    }

                                    // setStateを使って、ポイントを加算し、画面を更新！
                                    setState(() {
                                      _points += pointsFromBoard;
                                      _pointsAdded = pointsFromBoard;
                                      _experience += expFromBoard ?? 0;
                                    });

                                    _animationController.forward(from: 0.0);
                                    _pointsAddedAnimationController.forward(
                                      from: 0.0,
                                    );
                                  }

                                  // レベルアップのチェックと表示
                                  _checkLevelUp();
                                  // SharedPreferencesに新しいポイントを保存
                                  await SharedPrefsHelper.savePoints(_points);

                                  // ★やくそくボード画面から戻ってきたら、必ずデータを再読み込みする！
                                  _loadAndDetermineDisplayPromise();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                    vertical: 4.0,
                                  ),
                                  child: SizedBox(
                                    width: 55,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.article_rounded,
                                          size: 24,
                                          color: Color(0xFFFFCA28),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.navPromiseBoard,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFFFFCA28),
                                            fontWeight: FontWeight.bold,
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

                        const SizedBox(height: 6), // ボタンの間に少し隙間をあける
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
                                  child: Material(
                                    color: const Color(
                                      0xFFFF7043,
                                    ).withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () async {
                                        // チュートリアルで「きせかえ」ボタンを押したかチェック
                                        final isTutorialStepShown =
                                            await SharedPrefsHelper.isTutorialStepShown(
                                              SharedPrefsHelper
                                                  .tutorialStepCustomizeKey,
                                            );
                                        if (!isTutorialStepShown) {
                                          FirebaseAnalytics.instance.logEvent(
                                            name:
                                                'tutorial_tap_customize_button',
                                          );
                                        }
                                        FirebaseAnalytics.instance.logEvent(
                                          name: 'start_child_home_dress_up',
                                        );
                                        try {
                                          SfxManager.instance.playTapSound();
                                        } catch (e) {
                                          print('再生エラー: $e');
                                        }

                                        // キャラクター設定画面へ遷移
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
                                          // チュートリアルで「戻る」ボタンを押したかチェック
                                          final isTutorialStepShown =
                                              await SharedPrefsHelper.isTutorialStepShown(
                                                SharedPrefsHelper
                                                    .tutorialStepCustomizeKey,
                                              );
                                          if (!isTutorialStepShown) {
                                            FirebaseAnalytics.instance.logEvent(
                                              name:
                                                  'tutorial_tap_customize_back',
                                            );
                                          }
                                          // ★設定画面から戻ってきたら、表示を更新するために再読み込み
                                          await _loadAndDetermineDisplayPromise();

                                          // チュートリアル: アイテム移動へ誘導
                                          bool wasMoveShown =
                                              await SharedPrefsHelper.isTutorialStepShown(
                                                SharedPrefsHelper
                                                    .tutorialStepMoveKey,
                                              );
                                          bool isShown =
                                              await SharedPrefsHelper.isGuideShown();
                                          if (!wasMoveShown &&
                                              !isShown &&
                                              mounted) {
                                            // 終了フラグを立てる
                                            await SharedPrefsHelper.setTutorialStepShown(
                                              SharedPrefsHelper
                                                  .tutorialStepCustomizeKey,
                                            );
                                            FirebaseAnalytics.instance.logEvent(
                                              name:
                                                  'start_tutorial_move_interaction',
                                            );
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((
                                                  _,
                                                ) async {
                                                  await _showTutorialDialog(
                                                    title: AppLocalizations.of(
                                                      context,
                                                    )!.tutorialMoveTitle,
                                                    content:
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.tutorialMoveDesc,
                                                    buttonText:
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.tutorialBtnMove,
                                                  );
                                                  // ★ 移動を促す状態にする（紫点滅開始）
                                                  if (!_isWaitingForMove) {
                                                    setState(() {
                                                      _isWaitingForMove = true;
                                                      _showDraggableBlinking =
                                                          true;
                                                    });
                                                  }
                                                });
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                          vertical: 4.0,
                                        ),
                                        child: SizedBox(
                                          width: 55,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.face,
                                                size: 24,
                                                color: Color(0xFFFFCA28),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.navDressUp,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFFFFCA28),
                                                  fontWeight: FontWeight.bold,
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
                            ),
                            if (_showCustomizeBlinking)
                              Positioned(
                                top: -60, // ボタンの上に配置
                                left: -30, // 中央寄せのための調整（吹き出し幅に合わせる）
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
                                        borderRadius: BorderRadius.circular(16),
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
                                        )!.tutorialCustomizeBubble,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    ClipPath(
                                      clipper: _SpeechBubbleTailDownClipper(),
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
                        // BlinkingEffect Customize
                        const SizedBox(height: 6), // ボタンの間に少し隙間をあける
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.centerLeft,
                          children: [
                            IgnorePointer(
                              ignoring:
                                  isAnyTutorialBlinking && !_showShopBlinking,
                              child: Opacity(
                                opacity:
                                    (isAnyTutorialBlinking &&
                                        !_showShopBlinking)
                                    ? 0.6
                                    : 1.0,
                                child: BlinkingEffect(
                                  isBlinking: _showShopBlinking,
                                  child: Material(
                                    color: const Color(
                                      0xFFFF7043,
                                    ).withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () async {
                                        // チュートリアルで「おみせ」ボタンを押したかチェック
                                        final isTutorialStepShown =
                                            await SharedPrefsHelper.isTutorialStepShown(
                                              SharedPrefsHelper
                                                  .tutorialStepShopKey,
                                            );
                                        if (!isTutorialStepShown) {
                                          FirebaseAnalytics.instance.logEvent(
                                            name: 'tutorial_tap_shop_button',
                                          );
                                        }
                                        FirebaseAnalytics.instance.logEvent(
                                          name: 'start_child_home_shop',
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            // ★現在のポイント数を渡してショップ画面を開く
                                            builder: (context) => ShopScreen(
                                              currentPoints: _points,
                                              currentLevel: _level,
                                              mode: ShopMode.forGeneral,
                                            ),
                                          ),
                                        ).then((_) async {
                                          setState(() {
                                            _showShopBlinking = false;
                                          });
                                          // チュートリアルで「戻る」ボタンを押したかチェック
                                          final isTutorialStepShown =
                                              await SharedPrefsHelper.isTutorialStepShown(
                                                SharedPrefsHelper
                                                    .tutorialStepShopKey,
                                              );
                                          if (!isTutorialStepShown) {
                                            FirebaseAnalytics.instance.logEvent(
                                              name: 'tutorial_tap_shop_back',
                                            );
                                          }
                                          // ★ショップ画面から戻ってきたら、必ずデータを再読み込みする
                                          await _loadAndDetermineDisplayPromise();

                                          bool wasCustomizeStepShown =
                                              await SharedPrefsHelper.isTutorialStepShown(
                                                SharedPrefsHelper
                                                    .tutorialStepCustomizeKey,
                                              );
                                          bool isShown =
                                              await SharedPrefsHelper.isGuideShown();
                                          if (!wasCustomizeStepShown &&
                                              !isShown &&
                                              mounted) {
                                            // 終了フラグを立てる
                                            await SharedPrefsHelper.setTutorialStepShown(
                                              SharedPrefsHelper
                                                  .tutorialStepShopKey,
                                            );
                                            FirebaseAnalytics.instance.logEvent(
                                              name: 'start_tutorial_dress_up',
                                            );
                                            // チュートリアル: アイテム購入後にきせかえへ誘導
                                            setState(() {
                                              _showCustomizeBlinking = true;
                                            });
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((
                                                  _,
                                                ) async {
                                                  await _showTutorialDialog(
                                                    title: AppLocalizations.of(
                                                      context,
                                                    )!.tutorialCustomizeTitle,
                                                    content: AppLocalizations.of(
                                                      context,
                                                    )!.tutorialCustomizeDesc,
                                                    buttonText:
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.tutorialBtnCustomize,
                                                  );
                                                });
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                          vertical: 4.0,
                                        ),
                                        child: SizedBox(
                                          width: 55,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.store,
                                                size: 24,
                                                color: Color(0xFFFFCA28),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.navShop,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFFFFCA28),
                                                  fontWeight: FontWeight.bold,
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
                            ),
                            if (_showShopBlinking)
                              Positioned(
                                top: -60, // ボタンの上に配置
                                left: -30, // 中央寄せのための調整
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
                                        borderRadius: BorderRadius.circular(16),
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
                                        )!.tutorialShopBubble,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    ClipPath(
                                      clipper: _SpeechBubbleTailDownClipper(),
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
                        // BlinkingEffect Shop
                      ],
                    ),
                  ),
                ),
                // 2. 左上の「おやが見る画面へ」ボタン
                Positioned(
                  top: 10,
                  left: 10,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            BlinkingEffect(
                              isBlinking: _showParentSettingsBlinking,
                              child: Material(
                                color: const Color(0xFFFF7043).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  onTap:
                                      isAnyTutorialBlinking &&
                                          !_showParentSettingsBlinking
                                      ? null // 他のボタン点滅中は無効
                                      : () async {
                                          FirebaseAnalytics.instance.logEvent(
                                            name:
                                                'start_child_home_parent_settings',
                                          );
                                          try {
                                            SfxManager.instance.playTapSound();
                                          } catch (e) {
                                            print('再生エラー: $e');
                                          }
                                          await _openParentMode();
                                        },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 64,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.settings,
                                            size: 28,
                                            color: Color(0xFFFFCA28),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.parentSettings,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFFFCA28),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // 吹き出し
                            if (_isTutorialParentSettingsFocus)
                              Positioned(
                                top: 10, // ボタンの下に表示
                                left: 90,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF9C4), // 薄い黄色
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
                        const SizedBox(height: 10), // ボタンの間に少し隙間をあける
                        IgnorePointer(
                          ignoring: isAnyTutorialBlinking,
                          child: Opacity(
                            opacity: isAnyTutorialBlinking ? 0.6 : 1.0,
                            child: Material(
                              color: const Color(0xFFFF7043).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () {
                                  FirebaseAnalytics.instance.logEvent(
                                    name: 'start_child_home_help',
                                  );
                                  try {
                                    SfxManager.instance.playTapSound();
                                  } catch (e) {
                                    print('再生エラー: $e');
                                  }
                                  _onHelpButtonPressed();
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 64,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.question_mark,
                                          size: 28,
                                          color: Color(0xFFFFCA28),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          AppLocalizations.of(context)!.help,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFFFCA28),
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ★ 追加: 「はじめる」が点滅中は画面を暗くし、はじめるボタン以外を触れないようにする
          if (_showStartBlinking)
            Positioned.fill(
              child: Container(
                color: Colors.black38, // 薄暗くする
              ),
            ),

          // 下のバー（つぎのやくそく）
          _displayPromise != null
              ? Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      // 点滅中は透明にして背景の暗さに溶け込ませる
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
                                  // 緊急の場合のみ「きんきゅう！」と表示
                                  if (_isDisplayPromiseEmergency)
                                    Text(
                                      AppLocalizations.of(context)!.emergency,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  // 定例の場合は「つぎのやくそく」と表示
                                  if (!_isDisplayPromiseEmergency)
                                    Text(
                                      AppLocalizations.of(context)!.nextPromise,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isAnyTutorialBlinking
                                            ? Colors.white70
                                            : Colors.grey[700],
                                      ),
                                    ),

                                  const SizedBox(height: 2),

                                  // やくそくの名前とポイントを表示
                                  Text(
                                    _isDisplayPromiseEmergency
                                        ? '${_displayPromise!['title']} / ${_displayPromise!['points']}${AppLocalizations.of(context)!.points}'
                                        : '${_displayPromise!['time']}〜 ${_displayPromise!['icon']} ${_displayPromise!['title']} / ${_displayPromise!['points']}${AppLocalizations.of(context)!.points}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      // 緊急やくそくか点滅中なら文字は白
                                      color:
                                          (_isDisplayPromiseEmergency ||
                                              isAnyTutorialBlinking)
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    overflow:
                                        TextOverflow.ellipsis, // 長いテキストは...で省略
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 「やらなかった」ボタン（TextButtonで見え方を少し変える）
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
                              borderRadius: 10,
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
                                      backgroundColor:
                                          _isDisplayPromiseEmergency
                                          ? Colors.white
                                          : Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
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
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_showStartBlinking)
                              Positioned(
                                top: -60, // ボタンの上に配置
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
                                        borderRadius: BorderRadius.circular(16),
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
                                      clipper: _SpeechBubbleTailDownClipper(),
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
                )
              :
                // もしやくそくがない場合は、メッセージを表示
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
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
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _SpeechBubbleTailClipper extends CustomClipper<Path> {
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

class _SpeechBubbleTailDownClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0); // トップ左
    path.lineTo(size.width, 0); // トップ右
    path.lineTo(size.width / 2, size.height); // ボトム中央
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
