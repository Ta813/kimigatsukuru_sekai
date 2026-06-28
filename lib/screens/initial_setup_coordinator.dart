// lib/screens/initial_setup_coordinator.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/managers/app_update_manager.dart';
import 'package:kimigatsukuru_sekai/managers/bgm_manager.dart';
import 'package:kimigatsukuru_sekai/screens/parent/regular_promise_settings_screen.dart';
import 'package:kimigatsukuru_sekai/widgets/avatar_display.dart';
import 'package:kimigatsukuru_sekai/widgets/breathing_avatar.dart';
import 'package:kimigatsukuru_sekai/widgets/draggable_character.dart';
import '../helpers/shared_prefs_helper.dart';
import '../l10n/app_localizations.dart';
import '../managers/sfx_manager.dart';
import 'child/child_home_screen.dart';
import 'child/character_customize_screen.dart';
import '../widgets/animated_tap_finger.dart';

class InitialSetupCoordinator extends StatefulWidget {
  const InitialSetupCoordinator({super.key});

  @override
  State<InitialSetupCoordinator> createState() =>
      _InitialSetupCoordinatorState();
}

class _InitialSetupCoordinatorState extends State<InitialSetupCoordinator>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  bool _isCheckingResume = true; // 🌟 再開チェック中かどうか

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await AppUpdateManager.instance.checkUpdateAndShowDialog(context);
      }
    });
    _playSavedBgm();
    _checkResumeStatus();
  }

  Future<void> _checkResumeStatus() async {
    final pattern = await SharedPrefsHelper.loadSetupPattern();
    final step = await SharedPrefsHelper.loadSetupStep();

    if (!mounted) return;
    setState(() {
      _isCheckingResume = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (pattern != null && step > 0) {
        // 途中から再開
        _runSetupLoop(pattern, step);
      } else {
        // 🌟 変更: 最初からループを開始する（Step 1からスタート）
        _runSetupLoop('C', 1);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ★アプリの状態が変化した時に呼ばれるメソッド
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        _handleAppResumed();
      }
    }
  }

  Future<void> _handleAppResumed() async {
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
    // 🌟 変更: ロード中以外は背景だけを表示。実際の画面は_runSetupLoopが上に被せて表示します。
    if (_isCheckingResume) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF3E0),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF7043)),
        ),
      );
    }

    return const Scaffold(backgroundColor: Color(0xFFFFF3E0));
  }

  // ==============================================================
  // 🌟 セットアップの管理ループ
  // ==============================================================
  Future<void> _runSetupLoop(
    String pattern,
    int step, {
    bool isBack = false,
  }) async {
    // 🌟 変更: 全パターンのステップ数を 6 に統一
    int totalSteps = 6;

    // 全ステップ完了した場合、ホーム画面へ遷移
    if (step > totalSteps) {
      FirebaseAnalytics.instance.logEvent(name: 'setup_finish');
      await SharedPrefsHelper.setFirstLaunchCompleted();
      await SharedPrefsHelper.clearSetupProgress();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ChildHomeScreen(isInitialSetup: true),
        ),
      );
      return;
    }

    await SharedPrefsHelper.saveSetupProgress(pattern, step);
    Widget? screen;

    FirebaseAnalytics.instance.logEvent(name: 'setup_step_$step');

    // 🌟 変更: ご要望の順番に並び替え
    if (pattern == 'C') {
      switch (step) {
        case 1:
          // ① アバターを設定してね
          screen = AppIntroExplanationScreen(
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 2:
          // ② アバター設定
          screen = CharacterCustomizeScreen(
            isInitialSetup: true,
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 3:
          // ③ キャラクター移動説明
          screen = DraggableInstructionScreen(
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 4:
          // ④ 4つの力（新イントロ画面）
          screen = FourPowersIntroScreen(
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 5:
          // ⑤ やくそく設定
          screen = RegularPromiseSettingsScreen(
            isInitialSetup: true,
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 6:
          // ⑥ 完了
          screen = SetupCompleteScreen(
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
      }
    } else if (pattern == 'A') {
      switch (step) {
        case 1:
          screen = RegularPromiseSettingsScreen(
            isInitialSetup: true,
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 2:
          screen = PassDeviceScreen(
            isToChild: true,
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 3:
          screen = CharacterCustomizeScreen(
            isInitialSetup: true,
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 4:
          screen = DraggableInstructionScreen(
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 5:
          screen = AppRulesInstructionScreen(
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 6:
          screen = SetupCompleteScreen(
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
      }
    } else if (pattern == 'B') {
      switch (step) {
        case 1:
          screen = CharacterCustomizeScreen(
            isInitialSetup: true,
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 2:
          screen = DraggableInstructionScreen(
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 3:
          screen = AppRulesInstructionScreen(
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 4:
          screen = PassDeviceScreen(
            isToChild: false,
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 5:
          screen = RegularPromiseSettingsScreen(
            isInitialSetup: true,
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 6:
          screen = SetupCompleteScreen(
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
      }
    }

    if (screen == null) return;

    dynamic proceed;

    // 通常の画面遷移（戻るか進むかのアニメーションを適用）
    proceed = await Navigator.push<dynamic>(
      context,
      PageRouteBuilder<dynamic>(
        // 🌟 最初の画面を開くときはアニメーションなし（パッと表示）にする
        transitionDuration: step == 1
            ? Duration.zero
            : const Duration(milliseconds: 300),
        pageBuilder: (c, a, sa) => screen!,
        transitionsBuilder: (c, a, sa, child) {
          if (step == 1) return child;
          final offset = isBack
              ? const Offset(-1.0, 0.0)
              : const Offset(1.0, 0.0);
          return SlideTransition(
            position: Tween<Offset>(begin: offset, end: Offset.zero).animate(a),
            child: child,
          );
        },
      ),
    );

    if (!mounted) return;

    // 画面から返ってきた結果によって処理を分岐
    if (proceed == true) {
      _runSetupLoop(pattern, step + 1, isBack: false); // 次のステップへ
    } else if (proceed == 'skip_to_drag') {
      // 🌟 修正: スキップの合図を最優先でキャッチしてStep 3へワープ！
      _runSetupLoop(pattern, 3, isBack: false);
    } else {
      // 戻るボタン（またはAndroidのスワイプ戻る）が押された場合
      if (step == 1) {
        await SharedPrefsHelper.clearSetupProgress();
        // 🌟 修正: 端末のスワイプ操作等で画面を消してしまった場合も、真っ白を防ぐためにStep1を再描画する
        _runSetupLoop(pattern, 1, isBack: true);
      } else {
        _runSetupLoop(pattern, step - 1, isBack: true); // 前のステップへ
      }
    }
  }
}

// ==============================================================
// 🌟 共通のプログレスヘッダー構築メソッド
// ==============================================================
PreferredSizeWidget buildSetupAppBar(
  BuildContext context,
  int? currentStep,
  int? totalSteps,
) {
  final safeStep = currentStep ?? 1;
  final safeTotal = totalSteps ?? 1;
  final progress = safeStep / safeTotal;
  return AppBar(
    backgroundColor: Colors.white,
    toolbarHeight: 48,
    // 🌟 変更: 最初の画面（Step 1）は戻るボタンを隠す安全対策！
    leading: safeStep == 1
        ? const SizedBox()
        : BackButton(
            color: Colors.black54,
            onPressed: () => Navigator.pop(context, false),
          ),
    titleSpacing: 0,
    title: Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(
                  context,
                )!.setupStepProgress(safeStep, safeTotal),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7043),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFFF7043).withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFF7043),
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    ),
  );
}

// ==============================================================
// 🌟 4つの力（旧新イントロ画面） - Step 4用
// ==============================================================
class FourPowersIntroScreen extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const FourPowersIntroScreen({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: buildSetupAppBar(context, currentStep, totalSteps), // 🌟 追加
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.setupNewIntroTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.setupNewIntroSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildPowerItem(
                            icon: '🌟',
                            title: l10n.setupNewIntroPower1Title,
                            desc: l10n.setupNewIntroPower1Desc,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPowerItem(
                            icon: '🚀',
                            title: l10n.setupNewIntroPower2Title,
                            desc: l10n.setupNewIntroPower2Desc,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildPowerItem(
                            icon: '🤝',
                            title: l10n.setupNewIntroPower3Title,
                            desc: l10n.setupNewIntroPower3Desc,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPowerItem(
                            icon: '🌱',
                            title: l10n.setupNewIntroPower4Title,
                            desc: l10n.setupNewIntroPower4Desc,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // ボトムエリア（ボタン）
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  FilledButton(
                    onPressed: () {
                      try {
                        SfxManager.instance.playTapSound();
                      } catch (e) {}
                      Navigator.pop(context, true); // 🌟 trueを返して次のStepへ！
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7043),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      l10n.setupOkButton, // 🌟 「OK」などのテキストに
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 10,
                    bottom: -10,
                    child: AnimatedTapFinger(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerItem({
    required String icon,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================
// 🌟 旧イントロ画面（アバターを設定してね） - Step 1用
// ==============================================================
class AppIntroExplanationScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;

  const AppIntroExplanationScreen({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  State<AppIntroExplanationScreen> createState() =>
      _AppIntroExplanationScreenState();
}

class _AppIntroExplanationScreenState extends State<AppIntroExplanationScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: buildSetupAppBar(context, widget.currentStep, widget.totalSteps),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/character_hime.gif',
                    height: 100,
                    cacheWidth: 200,
                  ),
                  const SizedBox(width: 20),
                  Image.asset(
                    'assets/images/character_kuma.gif',
                    height: 100,
                    cacheWidth: 200,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l10n.setupIntroMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // スキップボタン
                  TextButton(
                    onPressed: () async {
                      try {
                        SfxManager.instance.playTapSound();
                      } catch (_) {}

                      // スキップした場合はデフォルトアバターを保存
                      await SharedPrefsHelper.saveEquippedCharacters([
                        'assets/images/character_usagi.gif',
                      ]);
                      await SharedPrefsHelper.addPurchasedItem('ウサギ');

                      // 🌟 修正: 途中でスキップしてもセットアップ完了扱いにはしない
                      if (!mounted) return;
                      // 合図を返してループ管理側でStep 3へ飛ばす
                      Navigator.pop(context, 'skip_to_drag');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      l10n.setupSkipButton,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 次へボタン
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      FilledButton(
                        onPressed: () {
                          try {
                            SfxManager.instance.playTapSound();
                          } catch (e) {}
                          Navigator.pop(context, true); // 🌟 trueを返して次のステップへ！
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7043),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          l10n.setupIntroNext,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Positioned(
                        right: 0,
                        bottom: 0,
                        child: AnimatedTapFinger(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================
// 🌟 以下、既存の画面ウィジェット（変更なし）
// ==============================================================
class DraggableInstructionScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;

  const DraggableInstructionScreen({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  State<DraggableInstructionScreen> createState() =>
      _DraggableInstructionScreenState();
}

class _DraggableInstructionScreenState extends State<DraggableInstructionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fingerController;
  late Animation<Offset> _fingerAnimation;
  late Animation<double> _fadeAnimation;

  Offset? _avatarPos;
  Offset? _itemPos;
  Offset? _itemPos2;
  List<String> _equippedCharacters = [];
  Map<String, Offset> _characterPositionsMap = {};

  bool _positionsInitialized = false;

  String _equippedFace = 'assets/images/face/face_default.png';
  String _equippedHair = 'assets/images/hair/hair_default.png';
  String _equippedClothes = 'assets/images/clothes/clothes_default.png';
  String? _equippedHeadgear;
  String? _equippedAccessory;

  @override
  void initState() {
    super.initState();

    _fingerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 10),
    ]).animate(_fingerController);

    _loadItems();
  }

  Future<void> _loadItems() async {
    final face = await SharedPrefsHelper.loadEquippedFace();
    final hair = await SharedPrefsHelper.loadEquippedHairstyle();
    final clothes = await SharedPrefsHelper.loadEquippedClothes();
    final headgear = await SharedPrefsHelper.loadEquippedHeadgear();
    final accessory = await SharedPrefsHelper.loadEquippedAccessory();
    final characters = await SharedPrefsHelper.loadEquippedCharacters();

    if (!mounted) return;

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    final Map<String, Offset> loadedPositions = {};
    final charactersToLoad = characters.isEmpty
        ? ['assets/images/character_usagi.gif']
        : characters;

    for (var charPath in charactersToLoad) {
      final loadedPos = await SharedPrefsHelper.loadCharacterPosition(
        'setup_$charPath',
      );
      loadedPositions[charPath] =
          loadedPos ?? Offset(screenWidth * 0.65, screenHeight * 0.45);
    }

    if (!mounted) return;

    setState(() {
      _equippedFace = face ?? 'assets/images/face/face_default.png';
      _equippedHair = hair ?? 'assets/images/hair/hair_default.png';
      _equippedClothes = clothes ?? 'assets/images/clothes/clothes_default.png';
      _equippedHeadgear = headgear;
      _equippedAccessory = accessory;
      _equippedCharacters = characters;

      _characterPositionsMap = {};
      for (var charPath in _equippedCharacters) {
        _characterPositionsMap[charPath] =
            loadedPositions[charPath] ??
            Offset(screenWidth * 0.65, screenHeight * 0.45);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_positionsInitialized) {
      final size = MediaQuery.of(context).size;
      final w = size.width;
      final h = size.height;

      _avatarPos = Offset(w * 0.25, h * 0.45);
      _itemPos = Offset(w * 0.75, h * 0.55);
      _itemPos2 = Offset(w * 0.05, h * 0.5);

      _fingerAnimation =
          Tween<Offset>(
            begin: Offset(w * 0.25, h * 0.50),
            end: Offset(w * 0.55, h * 0.08),
          ).animate(
            CurvedAnimation(
              parent: _fingerController,
              curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
            ),
          );

      _positionsInitialized = true;
    }
  }

  @override
  void dispose() {
    _fingerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: buildSetupAppBar(context, widget.currentStep, widget.totalSteps),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox.expand(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    l10n.setupDraggableTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.setupDraggableDesc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      FilledButton(
                        onPressed: () {
                          try {
                            SfxManager.instance.playTapSound();
                          } catch (e) {}
                          Navigator.pop(context, true);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7043),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          l10n.setupOkButton,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Positioned(
                        right: 0,
                        bottom: 0,
                        child: AnimatedTapFinger(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),

            if (_avatarPos != null)
              DraggableCharacter(
                id: 'avatar_on_setup',
                customWidget: AnimatedAvatar(
                  child: AvatarDisplay(
                    face: _equippedFace,
                    clothes: _equippedClothes,
                    hair: _equippedHair,
                    headgear: _equippedHeadgear,
                    accessory: _equippedAccessory,
                    size: 90,
                  ),
                ),
                position: _avatarPos!,
                size: 90,
                onPositionChanged: (delta) {
                  setState(() => _avatarPos = _avatarPos! + delta);
                },
              ),

            ..._equippedCharacters
                .where(
                  (charPath) => _characterPositionsMap.containsKey(charPath),
                )
                .map((charPath) {
                  return DraggableCharacter(
                    id: 'setup_$charPath',
                    imagePath: charPath,
                    position: _characterPositionsMap[charPath]!,
                    size: 90,
                    onPositionChanged: (delta) {
                      setState(() {
                        final current = _characterPositionsMap[charPath];
                        if (current != null) {
                          _characterPositionsMap[charPath] = current + delta;
                        }
                      });
                    },
                  );
                })
                .toList(),

            if (_itemPos != null)
              DraggableCharacter(
                id: 'item_on_setup',
                imagePath: 'assets/images/item_hana1.png',
                position: _itemPos!,
                size: 50,
                onPositionChanged: (delta) {
                  setState(() {
                    _itemPos = _itemPos! + delta;
                  });
                },
              ),

            if (_itemPos2 != null)
              DraggableCharacter(
                id: 'item_on_setup2',
                imagePath: 'assets/images/item_kuruma.png',
                position: _itemPos2!,
                size: 70,
                onPositionChanged: (delta) {
                  setState(() {
                    _itemPos2 = _itemPos2! + delta;
                  });
                },
              ),

            if (_positionsInitialized)
              AnimatedBuilder(
                animation: _fingerController,
                builder: (context, child) {
                  return Positioned(
                    left: _fingerAnimation.value.dx,
                    top: _fingerAnimation.value.dy,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: const Icon(
                          Icons.touch_app,
                          size: 70,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================
// 🌟 アプリの遊び方（ルール）画面
// ==============================================================
class AppRulesInstructionScreen extends StatefulWidget {
  final int? currentStep;
  final int? totalSteps;

  const AppRulesInstructionScreen({
    super.key,
    this.currentStep = null,
    this.totalSteps = null,
  });

  @override
  State<AppRulesInstructionScreen> createState() =>
      _AppRulesInstructionScreenState();
}

class _AppRulesInstructionScreenState extends State<AppRulesInstructionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: widget.currentStep != null && widget.totalSteps != null
          ? buildSetupAppBar(context, widget.currentStep, widget.totalSteps)
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.setupRulesTitle,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                _buildRuleItem(
                  icon: Icons.play_circle_fill,
                  iconColor: Colors.blueAccent,
                  number: '1',
                  text: l10n.setupRulesStep1,
                ),
                const SizedBox(height: 6),
                _buildRuleItem(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  number: '2',
                  text: l10n.setupRulesStep2,
                ),
                const SizedBox(height: 6),
                _buildRuleItem(
                  icon: Icons.store,
                  iconColor: Colors.pinkAccent,
                  number: '3',
                  text: l10n.setupRulesStep3,
                ),
                const SizedBox(height: 6),
                _buildRuleItem(
                  icon: Icons.public,
                  iconColor: Colors.teal,
                  number: '4',
                  text: l10n.setupRulesStep4,
                ),
                const SizedBox(height: 6),
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    FilledButton(
                      onPressed: () {
                        try {
                          SfxManager.instance.playTapSound();
                        } catch (_) {}
                        Navigator.pop(context, true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7043),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        l10n.setupOkButton,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
      ),
    );
  }

  Widget _buildRuleItem({
    required IconData icon,
    required Color iconColor,
    required String number,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFFF7043),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================
// 🌟 最終のセットアップ100%完了画面 (全画面)
// ==============================================================
class SetupCompleteScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;

  const SetupCompleteScreen({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  State<SetupCompleteScreen> createState() => _SetupCompleteScreenState();
}

class _SetupCompleteScreenState extends State<SetupCompleteScreen> {
  List<String> _equippedCharacters = [];
  String _equippedFace = 'assets/images/face/face_default.png';
  String _equippedHair = 'assets/images/hair/hair_default.png';
  String _equippedClothes = 'assets/images/clothes/clothes_default.png';
  String? _equippedHeadgear;
  String? _equippedAccessory;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final face = await SharedPrefsHelper.loadEquippedFace();
    final hair = await SharedPrefsHelper.loadEquippedHairstyle();
    final clothes = await SharedPrefsHelper.loadEquippedClothes();
    final headgear = await SharedPrefsHelper.loadEquippedHeadgear();
    final accessory = await SharedPrefsHelper.loadEquippedAccessory();
    final characters = await SharedPrefsHelper.loadEquippedCharacters();

    setState(() {
      _equippedFace = face ?? 'assets/images/face/face_default.png';
      _equippedHair = hair ?? 'assets/images/hair/hair_default.png';
      _equippedClothes = clothes ?? 'assets/images/clothes/clothes_default.png';
      _equippedHeadgear = headgear;
      _equippedAccessory = accessory;
      _equippedCharacters = characters;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: buildSetupAppBar(context, widget.currentStep, widget.totalSteps),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedAvatar(
                  child: AvatarDisplay(
                    face: _equippedFace,
                    clothes: _equippedClothes,
                    hair: _equippedHair,
                    headgear: _equippedHeadgear,
                    accessory: _equippedAccessory,
                    size: 100,
                  ),
                ),
                const SizedBox(width: 20),
                if (_equippedCharacters.isNotEmpty)
                  Image.asset(
                    _equippedCharacters.first,
                    height: 100,
                    cacheWidth: 200,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.setupFinishMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                FilledButton(
                  onPressed: () {
                    try {
                      SfxManager.instance.playTapSound();
                    } catch (_) {}
                    Navigator.pop(context, true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7043),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    l10n.setupFinishButton,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
    );
  }
}

// ==============================================================
// 🌟 バトンタッチ（スマホを渡す）画面
// ==============================================================
class PassDeviceScreen extends StatelessWidget {
  final bool isToChild;
  final int? currentStep;
  final int? totalSteps;

  const PassDeviceScreen({
    super.key,
    required this.isToChild,
    this.currentStep = null,
    this.totalSteps = null,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: isToChild
          ? const Color(0xFFFFF3E0)
          : const Color(0xFFE3F2FD),
      appBar: currentStep == null
          ? null
          : buildSetupAppBar(context, currentStep, totalSteps),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isToChild ? Icons.child_care : Icons.face_retouching_natural,
              size: 100,
              color: isToChild ? const Color(0xFFFF7043) : Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            Text(
              isToChild ? l10n.setupPassToChild : l10n.setupPassToAdult,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                FilledButton(
                  onPressed: () {
                    try {
                      SfxManager.instance.playTapSound();
                    } catch (e) {}
                    Navigator.pop(context, true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: isToChild
                        ? const Color(0xFFFF7043)
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
                  child: Text(
                    l10n.setupReceivedButton,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
    );
  }
}
