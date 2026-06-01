// lib/screens/initial_setup_coordinator.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/managers/app_update_manager.dart';
import 'package:kimigatsukuru_sekai/managers/bgm_manager.dart';
import 'package:kimigatsukuru_sekai/screens/parent/regular_promise_settings_screen.dart';
import 'package:kimigatsukuru_sekai/widgets/avatar_display.dart';
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
  bool _isCheckingResume = true; // 🌟 追加: 再開チェック中かどうか

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

    if (pattern != null && step > 0) {
      if (!mounted) return;
      setState(() {
        _isCheckingResume = false;
      });

      // 画面構築後に自動で再開
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _runSetupLoop(pattern, step);
      });
    } else {
      if (!mounted) return;
      setState(() {
        _isCheckingResume = false;
      });
    }
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
      // ★ 自分が現在表示されている画面の場合のみ、BGM再生を行う
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        _handleAppResumed();
      }
    }
    // BGMの停止・再開はBgmManager自身が担当するため、ここでは行わない
  }

  // アプリが前面に戻ってきた時の処理
  Future<void> _handleAppResumed() async {
    // 保存されたBGMを再生
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
    if (_isCheckingResume) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF3E0),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF7043)),
        ),
      );
    }

    return _buildIntroScreen();
  }

  // 年齢を聞く前のイントロ画面
  Widget _buildIntroScreen() {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset('assets/images/character_panda.gif', height: 100),
                  const SizedBox(width: 20),
                  Image.asset('assets/images/character_kuma.gif', height: 100),
                ],
              ),
              const SizedBox(height: 32),
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
              const SizedBox(height: 40),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      try {
                        FirebaseAnalytics.instance.logEvent(
                          name: 'setup_start',
                        );
                        SfxManager.instance.playTapSound();
                      } catch (e) {}
                      _runSetupLoop('C', 1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7043),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
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
        ),
      ),
    );
  }

  // ==============================================================
  // 🌟 自由な「戻る/進む」を可能にする、新しいセットアップの管理ループ
  // ==============================================================
  Future<void> _runSetupLoop(
    String pattern,
    int step, {
    bool isBack = false,
  }) async {
    // パターンごとに全ステップ数を決定（Paywallを除外した数）
    int totalSteps = (pattern == 'C') ? 5 : 6;

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

    // 進行状況を保存
    await SharedPrefsHelper.saveSetupProgress(pattern, step);
    Widget? screen;

    // ステップ番号に応じた画面を取得
    if (pattern == 'A') {
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
    } else if (pattern == 'C') {
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
          screen = RegularPromiseSettingsScreen(
            isInitialSetup: true,
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
        case 5:
          screen = SetupCompleteScreen(
            currentStep: step,
            totalSteps: totalSteps,
          );
          break;
      }
    }

    if (screen == null) return;

    bool? proceed;

    // 通常の画面遷移（戻るか進むかのアニメーションを適用）
    proceed = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a, sa) => screen!,
        transitionsBuilder: (c, a, sa, child) {
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

    // 画面から返ってきた結果（戻るボタン=null、次へ=true）によって処理を分岐
    if (proceed == true) {
      _runSetupLoop(pattern, step + 1, isBack: false); // 次のステップへ
    } else {
      // 戻るボタンが押された場合
      if (step == 1) {
        // ステップ1で戻った場合は、年齢選択画面（Intro）に戻る
        await SharedPrefsHelper.clearSetupProgress();
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
    elevation: 0,
    toolbarHeight: 48,
    leading: BackButton(
      color: Colors.black54,
      onPressed: () => Navigator.pop(context, false), // 戻る時は false(null扱い) を返す
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
// 🌟 ドラッグ操作の説明画面
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

  // 画面内で動かせるキャラクターの初期位置（画面サイズ確定後に設定）
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
    FirebaseAnalytics.instance.logEvent(name: 'setup_drag_instruction_show');

    // 指を動かすアニメーション（2.5秒かけて繰り返す）
    _fingerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    // 指がスッと現れて、ドラッグし終わったらスッと消えるアニメーション
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

    // 画面サイズを取得
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

      _characterPositionsMap = {}; // 一旦クリア
      for (var charPath in _equippedCharacters) {
        _characterPositionsMap[charPath] =
            loadedPositions[charPath] ??
            Offset(screenWidth * 0.65, screenHeight * 0.45); // 読み込んだ位置を保存
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

      // キャラクターを画面中央付近に配置
      _avatarPos = Offset(w * 0.25, h * 0.45);
      _itemPos = Offset(w * 0.75, h * 0.55);
      _itemPos2 = Offset(w * 0.05, h * 0.5);

      // 指アニメーションを画面サイズに合わせて動的に設定
      _fingerAnimation =
          Tween<Offset>(
            begin: Offset(w * 0.25, h * 0.50),
            end: Offset(w * 0.55, h * 0.38),
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
      appBar: buildSetupAppBar(
        context,
        widget.currentStep,
        widget.totalSteps,
      ), // 🌟 追加
      body: SafeArea(
        child: Stack(
          children: [
            // 背景のテキストと完了ボタン
            SizedBox.expand(
              child: Column(
                children: [
                  const SizedBox(height: 40), // アプリバーが追加されたので余白を少し調整
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
                      ElevatedButton(
                        onPressed: () {
                          try {
                            SfxManager.instance.playTapSound();
                          } catch (e) {}
                          Navigator.pop(context, true); // 🌟 true を返すことで「次へ」進む
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7043),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
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

            // 実際に動かせるキャラクター（うさぎ等）
            if (_avatarPos != null)
              DraggableCharacter(
                id: 'avatar_on_setup',
                customWidget: AvatarDisplay(
                  face: _equippedFace,
                  clothes: _equippedClothes,
                  hair: _equippedHair,
                  headgear: _equippedHeadgear,
                  accessory: _equippedAccessory,
                  size: 90,
                ),
                position: _avatarPos!,
                size: 90,
                onPositionChanged: (delta) {
                  setState(() => _avatarPos = _avatarPos! + delta);
                },
              ),

            // 応援キャラクターの表示と操作
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

            // 「こうやって動かすんだよ」と教える動く指のアニメーション
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
    FirebaseAnalytics.instance.logEvent(name: 'setup_rule_instruction_show');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: widget.currentStep != null && widget.totalSteps != null
          ? buildSetupAppBar(context, widget.currentStep, widget.totalSteps)
          : null, // 🌟 追加
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

                // ルール1
                _buildRuleItem(
                  icon: Icons.play_circle_fill,
                  iconColor: Colors.blueAccent,
                  number: '1',
                  text: l10n.setupRulesStep1,
                ),
                const SizedBox(height: 6),

                // ルール2
                _buildRuleItem(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  number: '2',
                  text: l10n.setupRulesStep2,
                ),
                const SizedBox(height: 6),

                // ルール3
                _buildRuleItem(
                  icon: Icons.store,
                  iconColor: Colors.pinkAccent,
                  number: '3',
                  text: l10n.setupRulesStep3,
                ),
                const SizedBox(height: 6),

                // ルール4
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
                    ElevatedButton(
                      onPressed: () {
                        try {
                          SfxManager.instance.playTapSound();
                        } catch (_) {}
                        Navigator.pop(context, true); // 🌟 true を返すことで「次へ」進む
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7043),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
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
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // 数字のバッジ
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
          // アイコン
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(width: 16),
          // テキスト
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
    FirebaseAnalytics.instance.logEvent(name: 'setup_drag_instruction_show');
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
      appBar: buildSetupAppBar(
        context,
        widget.currentStep,
        widget.totalSteps,
      ), // 🌟 追加
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ※既存のプログレスバーはAppBarに移動したため削除しました
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AvatarDisplay(
                  face: _equippedFace,
                  clothes: _equippedClothes,
                  hair: _equippedHair,
                  headgear: _equippedHeadgear,
                  accessory: _equippedAccessory,
                  size: 100,
                ),
                const SizedBox(width: 20),
                if (_equippedCharacters.isNotEmpty)
                  Image.asset(_equippedCharacters.first, height: 100),
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
                ElevatedButton(
                  onPressed: () {
                    try {
                      SfxManager.instance.playTapSound();
                    } catch (_) {}
                    Navigator.pop(context, true); // 🌟 true を返すことで「完了」へ進む
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7043),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
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
          : buildSetupAppBar(context, currentStep, totalSteps), // 🌟 追加
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ※既存のプログレスバーはAppBarに移動したため削除しました
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
                ElevatedButton(
                  onPressed: () {
                    try {
                      SfxManager.instance.playTapSound();
                    } catch (e) {}
                    Navigator.pop(context, true); // 🌟 true を返すことで「次へ」進む
                  },
                  style: ElevatedButton.styleFrom(
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
