// lib/screens/initial_setup_coordinator.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/managers/bgm_manager.dart';
import 'package:kimigatsukuru_sekai/screens/parent/regular_promise_settings_screen.dart'; // 本物の画面
import 'package:kimigatsukuru_sekai/screens/premium_paywall_screen.dart'; // 🌟 プレミアム画面をインポート
import 'package:kimigatsukuru_sekai/widgets/avatar_display.dart';
import 'package:kimigatsukuru_sekai/widgets/draggable_character.dart';
import '../helpers/shared_prefs_helper.dart';
import '../l10n/app_localizations.dart';
import '../managers/sfx_manager.dart';
import '../managers/purchase_manager.dart';
import 'child/child_home_screen.dart';
import 'child/character_customize_screen.dart';

class InitialSetupCoordinator extends StatefulWidget {
  const InitialSetupCoordinator({super.key});

  @override
  State<InitialSetupCoordinator> createState() =>
      _InitialSetupCoordinatorState();
}

class _InitialSetupCoordinatorState extends State<InitialSetupCoordinator>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // 最初のイントロ画面を表示するかどうかのフラグ
  bool _showIntro = true;
  bool _isCheckingResume = true; // 🌟 追加: 再開チェック中かどうか

  @override
  void initState() {
    super.initState();
    _playSavedBgm();
    _checkResumeStatus();
  }

  Future<void> _checkResumeStatus() async {
    final pattern = await SharedPrefsHelper.loadSetupPattern();
    final step = await SharedPrefsHelper.loadSetupStep();

    if (pattern != null && step > 0) {
      if (!mounted) return;
      setState(() {
        _showIntro = false;
        _isCheckingResume = false;
      });

      // 画面構築後に自動で再開
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (pattern == 'A') _startPatternA(context, resumeStep: step);
        if (pattern == 'B') _startPatternB(context, resumeStep: step);
        if (pattern == 'C') _startPatternC(context, resumeStep: step);
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

    if (_showIntro) {
      return _buildIntroScreen();
    }

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.setupAgeQuestion,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              // 年齢選択のリスト
              _buildAgeButton(
                context,
                label: l10n.setupAgeUnder7,
                onTap: () {
                  _startPatternB(context); // パターンB: こども ➔ おとな
                },
              ),
              _buildAgeButton(
                context,
                label: l10n.setupAge8to12,
                onTap: () {
                  _startPatternC(context); // パターンC: こども ➔ おとな（バトンなし）
                },
              ),
              _buildAgeButton(
                context,
                label: l10n.setupAge13to18,
                onTap: () {
                  _startPatternC(context); // パターンC: こども ➔ おとな（バトンなし）
                },
              ),
              _buildAgeButton(
                context,
                label: l10n.setupAgeAdult,
                isAdult: true,
                onTap: () {
                  _startPatternA(context); // パターンA: おとな ➔ こども
                },
              ),
            ],
          ),
        ),
      ),
    );
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
              ElevatedButton(
                onPressed: () {
                  try {
                    FirebaseAnalytics.instance.logEvent(name: 'setup_start');
                    SfxManager.instance.playTapSound();
                  } catch (e) {}
                  setState(() {
                    _showIntro = false;
                  });
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgeButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    bool isAdult = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 40),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isAdult ? Colors.blueAccent : Colors.white,
          foregroundColor: isAdult ? Colors.white : Colors.black87,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(
            color: isAdult ? Colors.blue : Colors.orangeAccent,
            width: 2,
          ),
          elevation: 2,
        ),
        onPressed: () {
          try {
            SfxManager.instance.playTapSound();
          } catch (e) {}

          final l10n = AppLocalizations.of(context)!;
          if (isAdult) {
            FirebaseAnalytics.instance.logEvent(name: 'setup_age_18');
          } else if (label == l10n.setupAgeUnder7) {
            FirebaseAnalytics.instance.logEvent(name: 'setup_age_7');
          } else if (label == l10n.setupAge8to12) {
            FirebaseAnalytics.instance.logEvent(name: 'setup_age_8_12');
          } else if (label == l10n.setupAge13to18) {
            FirebaseAnalytics.instance.logEvent(name: 'setup_age_13_17');
          }
          onTap();
        },
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ==============================================================
  // 🌟 パターンA: おとな ➔ 子供（バトンタッチあり）
  // ==============================================================
  Future<void> _startPatternA(
    BuildContext context, {
    int resumeStep = 0,
  }) async {
    // 1. おとな（親）向け設定
    if (resumeStep <= 1) {
      await SharedPrefsHelper.saveSetupProgress('A', 1);
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const RegularPromiseSettingsScreen(isInitialSetup: true),
        ),
      );
    }
    if (!context.mounted) return;

    // 2. スマホを子供に渡す画面
    if (resumeStep <= 2) {
      await SharedPrefsHelper.saveSetupProgress('A', 2);
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const PassDeviceScreen(isToChild: true, progress: 0.5),
        ),
      );
    }
    if (!context.mounted) return;

    // 3. 子供向け設定（アバターなど）
    if (resumeStep <= 3) {
      await SharedPrefsHelper.saveSetupProgress('A', 3);
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CharacterCustomizeScreen(isInitialSetup: true),
        ),
      );
    }
    if (!context.mounted) return;

    // 🌟 4. ドラッグ操作の説明画面（新規追加）
    if (resumeStep <= 4) {
      await SharedPrefsHelper.saveSetupProgress('A', 4);
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DraggableInstructionScreen()),
      );
    }
    if (!context.mounted) return;

    await _finishSetup(context, pattern: 'A', resumeStep: resumeStep);
  }

  // ==============================================================
  // 🌟 パターンB: 子供 ➔ おとな（バトンタッチあり）
  // ==============================================================
  Future<void> _startPatternB(
    BuildContext context, {
    int resumeStep = 0,
  }) async {
    // 1. 子供向け設定
    if (resumeStep <= 1) {
      await SharedPrefsHelper.saveSetupProgress('B', 1);
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CharacterCustomizeScreen(isInitialSetup: true),
        ),
      );
    }
    if (!context.mounted) return;

    // 🌟 2. ドラッグ操作の説明画面（新規追加）
    if (resumeStep <= 2) {
      await SharedPrefsHelper.saveSetupProgress('B', 2);
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DraggableInstructionScreen()),
      );
    }
    if (!context.mounted) return;

    // 3. スマホを親に渡す画面
    if (resumeStep <= 3) {
      await SharedPrefsHelper.saveSetupProgress('B', 3);
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const PassDeviceScreen(isToChild: false, progress: 0.5),
        ),
      );
    }
    if (!context.mounted) return;

    // 4. おとな（親）向け設定
    if (resumeStep <= 4) {
      await SharedPrefsHelper.saveSetupProgress('B', 4);
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const RegularPromiseSettingsScreen(isInitialSetup: true),
        ),
      );
    }
    if (!context.mounted) return;

    await _finishSetup(context, pattern: 'B', resumeStep: resumeStep);
  }

  // ==============================================================
  // 🌟 パターンC: 子供 ➔ おとな（バトンタッチなし）
  // ==============================================================
  Future<void> _startPatternC(
    BuildContext context, {
    int resumeStep = 0,
  }) async {
    // 1. 子供向け設定
    if (resumeStep <= 1) {
      await SharedPrefsHelper.saveSetupProgress('C', 1);
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CharacterCustomizeScreen(isInitialSetup: true),
        ),
      );
    }
    if (!context.mounted) return;

    // 🌟 2. ドラッグ操作の説明画面（新規追加）
    if (resumeStep <= 2) {
      await SharedPrefsHelper.saveSetupProgress('C', 2);
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DraggableInstructionScreen()),
      );
    }
    if (!context.mounted) return;

    // 3. おとな（親）向け設定（そのまま連続して表示）
    if (resumeStep <= 3) {
      await SharedPrefsHelper.saveSetupProgress('C', 3);
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const RegularPromiseSettingsScreen(isInitialSetup: true),
        ),
      );
    }
    if (!context.mounted) return;

    await _finishSetup(context, pattern: 'C', resumeStep: resumeStep);
  }

  // ==============================================================
  // 🌟 すべての設定が終わったあとの処理（Paywall ➔ 100%完了画面 ➔ ホーム）
  // ==============================================================
  Future<void> _finishSetup(
    BuildContext context, {
    required String pattern,
    int resumeStep = 0,
  }) async {
    // 🌟 間に画面が増えたのでステップ番号を調整
    int paywallStep = (pattern == 'C') ? 4 : 5;
    int completeStep = (pattern == 'C') ? 5 : 6;

    // 1. プレミアムプランへの誘導
    if (resumeStep <= paywallStep) {
      await SharedPrefsHelper.recordFirstLaunchTime();
      await SharedPrefsHelper.saveSetupProgress(pattern, paywallStep);
      if (!context.mounted) return;
      if (!PurchaseManager.instance.isPremium.value) {
        FirebaseAnalytics.instance.logEvent(name: 'setup_paywall_screen_show');
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
        );
      }
    }

    if (!context.mounted) return;

    // 2. ダイアログではなく、「100%完了画面（全画面）」へ遷移
    if (resumeStep <= completeStep) {
      await SharedPrefsHelper.saveSetupProgress(pattern, completeStep);
      if (!context.mounted) return;
      FirebaseAnalytics.instance.logEvent(name: 'setup_complete_screen_show');
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SetupCompleteScreen()),
      );
    }

    if (!context.mounted) return;

    // 3. 全て完了したのでフラグを保存してホームへ
    FirebaseAnalytics.instance.logEvent(name: 'setup_finish');
    await SharedPrefsHelper.setFirstLaunchCompleted();
    await SharedPrefsHelper.clearSetupProgress(); // 進行状況をクリア
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
    );
  }
}

// ==============================================================
// 🌟 ドラッグ操作の説明画面（実際に触って遊べるインタラクティブ版）
// ==============================================================
class DraggableInstructionScreen extends StatefulWidget {
  const DraggableInstructionScreen({super.key});

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

    late double screenWidth;
    late double screenHeight;

    // 画面サイズを取得
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    final loadedPositions = {};
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: Stack(
          children: [
            // 背景のテキストと完了ボタン
            SizedBox.expand(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'アバターと キャラクターは\nゆびで 自由に うごかせるよ！',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ためしに さわって うごかしてみてね！',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      try {
                        SfxManager.instance.playTapSound();
                      } catch (e) {}
                      Navigator.pop(context); // 画面を閉じて次へ進む
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
                    child: const Text(
                      'わかった！',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),

            // 🌟 実際に動かせるキャラクター（うさぎ）
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

            // ★応援キャラクターの表示と操作
            ..._equippedCharacters.map((charPath) {
              return DraggableCharacter(
                id: 'setup_$charPath', // IDとして画像パスを使う
                imagePath: charPath,
                position: _characterPositionsMap[charPath]!,
                size: 90,
                onPositionChanged: (delta) {
                  setState(() {
                    // ★位置の更新
                    _characterPositionsMap[charPath] =
                        _characterPositionsMap[charPath]! + delta;
                  });
                },
              );
            }).toList(),

            if (_itemPos != null)
              DraggableCharacter(
                id: 'item_on_setup', // IDとして画像パスを使う
                imagePath: 'assets/images/item_hana1.png',
                position: _itemPos!,
                size: 50,
                onPositionChanged: (delta) {
                  setState(() {
                    // ★位置の更新
                    _itemPos = _itemPos! + delta;
                  });
                },
              ),

            if (_itemPos2 != null)
              DraggableCharacter(
                id: 'item_on_setup2', // IDとして画像パスを使う
                imagePath: 'assets/images/item_kuruma.png',
                position: _itemPos2!,
                size: 70,
                onPositionChanged: (delta) {
                  setState(() {
                    // ★位置の更新
                    _itemPos2 = _itemPos2! + delta;
                  });
                },
              ),

            // 🌟 「こうやって動かすんだよ」と教える動く指のアニメーション
            if (_positionsInitialized)
              AnimatedBuilder(
                animation: _fingerController,
                builder: (context, child) {
                  return Positioned(
                    left: _fingerAnimation.value.dx,
                    top: _fingerAnimation.value.dy,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: const Icon(
                        Icons.touch_app,
                        size: 70,
                        color: Colors.orangeAccent,
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
// 🌟 最終のセットアップ100%完了画面 (全画面)
// ==============================================================
class SetupCompleteScreen extends StatelessWidget {
  const SetupCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🌟 100%の進捗バー
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  Text(
                    l10n.setupFinishTitle100,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                      value: 1.0, // 100%完了
                      backgroundColor: Colors.white54,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.orangeAccent,
                      ),
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset('assets/images/character_panda.gif', height: 100),
                const SizedBox(width: 20),
                Image.asset('assets/images/character_kuma.gif', height: 100),
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
            ElevatedButton(
              onPressed: () {
                try {
                  SfxManager.instance.playTapSound();
                } catch (_) {}
                Navigator.pop(context); // 画面を閉じて、呼び出し元(_finishSetup)へ返す
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
  final double progress;

  const PassDeviceScreen({
    super.key,
    required this.isToChild,
    this.progress = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: isToChild
          ? const Color(0xFFFFF3E0)
          : const Color(0xFFE3F2FD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  Text(
                    l10n.setupProgressComplete((progress * 100).toInt()),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white54,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isToChild ? Colors.orangeAccent : Colors.blueAccent,
                      ),
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Icon(
              isToChild ? Icons.child_care : Icons.face_retouching_natural,
              size: 100,
              color: isToChild ? Colors.orangeAccent : Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            Text(
              isToChild ? l10n.setupPassToChild : l10n.setupPassToAdult,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                try {
                  SfxManager.instance.playTapSound();
                } catch (e) {}
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isToChild
                    ? Colors.orangeAccent
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
          ],
        ),
      ),
    );
  }
}
