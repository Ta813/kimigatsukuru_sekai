// lib/screens/mini_game_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:kimigatsukuru_sekai/helpers/shared_prefs_helper.dart';
import 'package:kimigatsukuru_sekai/l10n/app_localizations.dart';
import 'package:kimigatsukuru_sekai/managers/purchase_manager.dart';
import 'package:kimigatsukuru_sekai/models/mini_game_name.dart';
import 'package:kimigatsukuru_sekai/screens/child/mini_game_ranking_screen.dart';
import 'package:kimigatsukuru_sekai/screens/premium_paywall_screen.dart';
import 'package:kimigatsukuru_sekai/widgets/avatar_display.dart';
import 'package:kimigatsukuru_sekai/widgets/breathing_avatar.dart';
import '../../managers/sfx_manager.dart';
import '../../widgets/ad_banner.dart';

// 🌟 コース（せかい）のデータ構造
class GameCourse {
  final String name;
  final String backgroundPath;
  final List<String> obstacleImages;
  final int requiredLevel;
  final Color themeColor;

  GameCourse({
    required this.name,
    required this.backgroundPath,
    required this.obstacleImages,
    required this.requiredLevel,
    required this.themeColor,
  });
}

// ==============================================================
// 🌟 1. コース（せかい）選択画面（レベル制限付き）
// ==============================================================
class MiniGameCoordinator extends StatefulWidget {
  final int userLevel;

  const MiniGameCoordinator({super.key, required this.userLevel});

  @override
  State<MiniGameCoordinator> createState() => _MiniGameCoordinatorState();
}

class _MiniGameCoordinatorState extends State<MiniGameCoordinator> {
  int _tickets = 0;
  bool _isLoading = true;
  Map<String, int> _highscore = {};

  // コースデータ定義
  final List<GameCourse> courses = [
    GameCourse(
      name: 'いつものせかい',
      backgroundPath: 'assets/images/world.png',
      obstacleImages: [
        'assets/images/item_hana1.png',
        'assets/images/item_bo-ru.png',
        'assets/images/item_kuruma.png',
      ],
      requiredLevel: 1,
      themeColor: const Color(0xFFFF7043),
    ),
    GameCourse(
      name: 'おおきなしま',
      backgroundPath: 'assets/images/island.png',
      obstacleImages: [
        'assets/images/island/vehicle_bus.png',
        'assets/images/island/vehicle_hikousen1.png',
        'assets/images/island/vehicle_herikoputa-.png',
      ],
      requiredLevel: 5,
      themeColor: const Color(0xFFFF7043),
    ),
    GameCourse(
      name: 'うみ',
      backgroundPath: 'assets/images/sea_background.png',
      obstacleImages: [
        'assets/images/sea/item_bin.png',
        'assets/images/sea/item_ikari.png',
        'assets/images/sea/item_kaigara.png',
      ],
      requiredLevel: 10,
      themeColor: Colors.blueAccent,
    ),
    GameCourse(
      name: 'そら',
      backgroundPath: 'assets/images/sky_background.png',
      obstacleImages: [
        'assets/images/sky/item_huusen1.png',
        'assets/images/sky/item_kumo.png',
        'assets/images/sky/item_kikyuu.png',
      ],
      requiredLevel: 15,
      themeColor: Colors.lightBlue,
    ),
    GameCourse(
      name: 'うちゅう',
      backgroundPath: 'assets/images/space_background.png',
      obstacleImages: [
        'assets/images/space/item_inseki1.png',
        'assets/images/space/item_ufo.png',
        'assets/images/space/item_jinkoueisei1.png',
      ],
      requiredLevel: 20,
      themeColor: Colors.indigo,
    ),
    GameCourse(
      name: 'ジャングル',
      backgroundPath: 'assets/images/jungle_background.png',
      obstacleImages: [
        'assets/images/jungle/living_kaeru.png',
        'assets/images/jungle/item_conpasu.png',
        'assets/images/jungle/item_gps.png',
      ],
      requiredLevel: 30,
      themeColor: Colors.green,
    ),
    GameCourse(
      name: 'さばく',
      backgroundPath: 'assets/images/desert_background.png',
      obstacleImages: [
        'assets/images/desert/item_kapunosu.png',
        'assets/images/desert/living_sasori.png',
        'assets/images/desert/item_tutanka-men.png',
      ],
      requiredLevel: 40,
      themeColor: Colors.yellow,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  // 🎫 保存されているゲームチケットの枚数を読み込む
  Future<void> _loadTickets() async {
    final tickets = await SharedPrefsHelper.getGameTickets();
    Map<String, int> highscore = {};
    for (var course in courses) {
      final score = await SharedPrefsHelper.getHighScore(course.name);
      highscore[course.name] = score;
    }
    if (mounted) {
      setState(() {
        _tickets = tickets;
        _isLoading = false;
        _highscore = highscore;
      });
    }
  }

  void _showPremiumUpgradeDialog() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.upgradeToPremium,
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
                l10n.premiumShopUnlockMessage,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel, style: TextStyle(color: Colors.grey[600])),
          ),
          FilledButton(
            onPressed: () async {
              FirebaseAnalytics.instance.logEvent(
                name: 'premium_open_mini_game',
              );
              Navigator.pop(dialogContext);
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
              side: const BorderSide(color: Color(0xFFFFCA28), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              l10n.seeDetails,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF3E0),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF7043)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.miniGameChooseCourse),
        backgroundColor: const Color(0xFFFF7043),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🌟 🎫 現在の残りプレイ回数を子どものモチベーション用に大きく表示！
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFF7043), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.miniGamePlayCountRemaining,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.miniGamePlayCountValue(_tickets),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF7043),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  final isPremium = PurchaseManager.instance.isPremium.value;
                  final isLevelLocked = widget.userLevel < course.requiredLevel;

                  // 🌟 チケットを持っていて、かつレベルが足りている場合のみプレイ可能
                  final isLevelOk = !isLevelLocked || isPremium;
                  final hasTicket = _tickets > 0;

                  return GestureDetector(
                    onTap: () async {
                      if (!hasTicket) {
                        // ❌ チケットがない場合はトーストで親切に案内
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.miniGameNoTicketMsg,
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      if (!isLevelOk) {
                        _showPremiumUpgradeDialog();
                        return;
                      }

                      // ⭕ 両方クリアしていればゲーム開始！
                      try {
                        SfxManager.instance.playTapSound();
                      } catch (_) {}

                      // 🌟 【超重要】ゲーム画面に進む「直前」にチケットを1枚消費する
                      await SharedPrefsHelper.updateGameTickets(-1);

                      if (!context.mounted) return;

                      // ゲーム画面へ遷移し、終わって戻ってくるのを待つ（await）
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GamePlayScreen(course: course),
                        ),
                      );

                      // 🌟 ゲームから戻ってきたら、減った後のチケット枚数を再読み込みして画面を更新！
                      _loadTickets();
                    },
                    child: Opacity(
                      // チケットがない、またはレベルロックなら見た目を半透明にする
                      opacity: (hasTicket && isLevelOk) ? 1.0 : 0.5,
                      child: Card(
                        elevation: (hasTicket && isLevelOk) ? 4 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        // 🌟 修正: 背景色ではなく画像を敷くための設定
                        clipBehavior: Clip.antiAlias, // 画像が角丸をはみ出さないようにする
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: (hasTicket && isLevelOk)
                                  ? course.themeColor
                                  : Colors.transparent,
                              width: 3, // 少し枠を太くして選択可能感を出す
                            ),
                            borderRadius: BorderRadius.circular(16),
                            // 🌟 追加: 世界の背景画像を設定！
                            image: DecorationImage(
                              image: AssetImage(course.backgroundPath),
                              fit: BoxFit.cover, // カードいっぱいに画像を広げる
                              // 文字を読みやすくするため、画像に薄い黒のベールをかける
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.4),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  MiniGameName.getMiniGameName(
                                    course.name,
                                    context,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // 🌟 背景が暗くなるので白文字に
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 4,
                                      ), // 影をつけて読みやすく
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (!isLevelOk)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLevelLocked
                                          ? Colors.redAccent.withOpacity(0.8)
                                          : Colors.black45,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.miniGameLevelRequired(
                                        course.requiredLevel,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    children: [
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.miniGameHighScore(
                                          _highscore[course.name] ?? 0,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => GameRankingScreen(
                                                courseName: course.name,
                                                themeColor: course.themeColor,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.bar_chart,
                                              color: Colors.white70,
                                              size: 16,
                                            ),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.miniGameViewRanking,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
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
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================
// 🌟 2. ミニゲームプレイ画面（左右よけゲーム本体）
// ==============================================================
class GamePlayScreen extends StatefulWidget {
  final GameCourse course;

  const GamePlayScreen({super.key, required this.course});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

// 障害物オブジェクトの定義
class ObstacleData {
  double x;
  double y;
  final String imagePath;
  final double size;

  ObstacleData({
    required this.x,
    required this.y,
    required this.imagePath,
    this.size = 50,
  });
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  // ゲームの基本設定
  final double _playerSize = 70.0;
  double _playerX = 0.0;
  double _playerY = 0.0;

  List<ObstacleData> _obstacles = [];
  Timer? _gameTimer;
  int _score = 0;
  bool _isPlaying = false; // 🌟 最初は false
  bool _hasStarted = false; // 🌟 スタートボタンを押したかどうかの判定用
  int _currentTickets = 0; // 🌟 チケット表示用

  final Random _random = Random();

  bool _isSizeInitialized = false;
  double _screenWidth = 0.0;
  double _screenHeight = 0.0;

  String _activeCharPath = 'MY_AVATAR';

  String _equippedFace = 'assets/images/face/face_default.png';
  String _equippedHair = 'assets/images/hair/hair_default.png';
  String _equippedClothes = 'assets/images/clothes/clothes_default.png';
  String? _equippedHeadgear;
  String? _equippedAccessory;

  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logEvent(
      name: 'minigame_start',
      parameters: {'course': widget.course.name},
    );
    _loadTicketCount(); // 最初と終了時に枚数を読み込む
    _loadHighScore();
  }

  // 🌟 チケット枚数を読み込むメソッド
  Future<void> _loadTicketCount() async {
    final tickets = await SharedPrefsHelper.getGameTickets();
    final charPath = await SharedPrefsHelper.getMiniGameCharacter();

    final face = await SharedPrefsHelper.loadEquippedFace();
    final hair = await SharedPrefsHelper.loadEquippedHairstyle();
    final clothes = await SharedPrefsHelper.loadEquippedClothes();
    final headgear = await SharedPrefsHelper.loadEquippedHeadgear();
    final accessory = await SharedPrefsHelper.loadEquippedAccessory();

    if (mounted) {
      setState(() {
        _currentTickets = tickets;

        _activeCharPath = charPath;

        _equippedFace = face ?? 'assets/images/face/face_default.png';
        _equippedHair = hair ?? 'assets/images/hair/hair_default.png';
        _equippedClothes =
            clothes ?? 'assets/images/clothes/clothes_default.png';
        _equippedHeadgear = headgear;
        _equippedAccessory = accessory;
      });
    }
  }

  Future<void> _loadHighScore() async {
    final h = await SharedPrefsHelper.getHighScore(widget.course.name);
    setState(() => _highScore = h);
  }

  void _initGameDimensions(double width, double height) {
    _screenWidth = width;
    _screenHeight = height;
    _playerX = (_screenWidth - _playerSize) / 2;
    _playerY = _screenHeight - _playerSize - 40;

    _isSizeInitialized = true;
    // ❌ ここでのタイマースタートは削除します（スタートボタンで開始するため）
  }

  // 🌟 ゲームを実際に開始するメソッド
  void _startGame() {
    setState(() {
      _hasStarted = true;
      _isPlaying = true;
    });
    _gameTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_isPlaying) _updateGame();
    });
  }

  void _updateGame() {
    setState(() {
      _score++;

      if (_random.nextDouble() < 0.05 && _obstacles.length < 5) {
        final randomImage =
            widget.course.obstacleImages[_random.nextInt(
              widget.course.obstacleImages.length,
            )];
        _obstacles.add(
          ObstacleData(
            x: _random.nextDouble() * (_screenWidth - 50),
            y: -50,
            imagePath: randomImage,
          ),
        );
      }

      List<ObstacleData> nextObstacles = [];
      for (var obs in _obstacles) {
        obs.y += 6.0 + (_score / 500);

        if ((obs.x - _playerX).abs() < (_playerSize * 0.7) &&
            (obs.y - _playerY).abs() < (_playerSize * 0.7)) {
          _endGame();
          return;
        }

        if (obs.y < _screenHeight) {
          nextObstacles.add(obs);
        }
      }
      _obstacles = nextObstacles;
    });
  }

  Future<void> _endGame() async {
    setState(() {
      _isPlaying = false;
    });
    _gameTimer?.cancel();

    final oldHighScore = await SharedPrefsHelper.getHighScore(
      widget.course.name,
    );
    await SharedPrefsHelper.saveGameScore(widget.course.name, _score);

    // 🌟 【超重要】自己ベストを更新した時だけ、世界（Firestore）にスコアを送信する！
    // 🌟 【超重要】まずは「自分の自己ベストを更新したか」をチェック
    if (_score > oldHighScore && _score > 0) {
      try {
        final courseName = widget.course.name;

        // 🌟 1. クラウド上の「現在のトップ30」を取得する
        final snapshot = await FirebaseFirestore.instance
            .collection('world_rankings')
            .where('course', isEqualTo: courseName)
            .orderBy('score', descending: true)
            .limit(30)
            .get();

        bool isTop30 = false;
        final docs = snapshot.docs;

        if (docs.length < 30) {
          // まだ世界に30人の記録がない場合は、無条件でランクイン！
          isTop30 = true;
        } else {
          // 30人いる場合は、「30位（一番最後の人）のスコア」を取得して比較する
          final rank30Score = docs.last.data()['score'] as int? ?? 0;
          if (_score > rank30Score) {
            isTop30 = true; // 30位のスコアを上回っていたらランクイン！
          }
        }

        // 🌟 2. 30位以内に入る場合のみ、Firestoreへ書き込みを行う！
        if (isTop30) {
          final charPath = await SharedPrefsHelper.getMiniGameCharacter();
          await FirebaseFirestore.instance.collection('world_rankings').add({
            'course': courseName,
            'score': _score,
            'character': charPath,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        print('スコア送信エラー: $e'); // オフライン等の場合は無視する
      }
    }

    await _loadTicketCount(); // 🌟 ゲーム終了時に最新のチケット枚数を表示に反映
    await _loadHighScore();
    FirebaseAnalytics.instance.logEvent(
      name: 'minigame_gameover',
      parameters: {'score': _score},
    );
    try {
      SfxManager.instance.playGameOverSound();
    } catch (_) {}
  }

  Future<void> _restartGame() async {
    final currentTickets = await SharedPrefsHelper.getGameTickets();
    if (currentTickets <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.miniGameNoTicketMsg),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    await SharedPrefsHelper.updateGameTickets(-1);

    setState(() {
      _obstacles.clear();
      _score = 0;
      _playerX = (_screenWidth - _playerSize) / 2;
      _isPlaying = true;
    });
    await _loadTicketCount(); // リスタート後の枚数を更新
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_isPlaying) _updateGame();
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (!_isSizeInitialized) {
              _initGameDimensions(constraints.maxWidth, constraints.maxHeight);
            }

            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (!_isPlaying) return;
                setState(() {
                  _playerX += details.delta.dx;
                  if (_playerX < 0) _playerX = 0;
                  if (_playerX > _screenWidth - _playerSize) {
                    _playerX = _screenWidth - _playerSize;
                  }
                });
              },
              child: Stack(
                children: [
                  // 背景・スコア・プレイヤー・障害物の描画（既存のまま）
                  SizedBox.expand(
                    child: Image.asset(
                      widget.course.backgroundPath,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(color: Colors.black.withOpacity(0.1)),

                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.miniGameScoreLabel(_score),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 80,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.miniGameHighScore(_highScore),
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: _playerX,
                    top: _playerY,
                    child: _activeCharPath == 'MY_AVATAR'
                        ? AnimatedAvatar(
                            child: AvatarDisplay(
                              face: _equippedFace,
                              clothes: _equippedClothes,
                              hair: _equippedHair,
                              headgear: _equippedHeadgear,
                              accessory: _equippedAccessory,
                              size: 80,
                            ),
                          ) // 🌟 選択キャラがアバターなら、今のアバターを描画！
                        : Image.asset(
                            _activeCharPath,
                            width: _playerSize,
                            height: _playerSize,
                            cacheWidth: 140,
                          ),
                  ),

                  ..._obstacles.map(
                    (obs) => Positioned(
                      left: obs.x,
                      top: obs.y,
                      child: Image.asset(
                        obs.imagePath,
                        width: obs.size,
                        height: obs.size,
                        cacheWidth: 100,
                      ),
                    ),
                  ),

                  // 🌟 【新規】スタート前オーバーレイ
                  if (!_hasStarted)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'よけろ！',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.miniGameInstructions,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: _startGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF7043),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.miniGameStartButton,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 🌟 【修正】ゲームオーバー画面のオーバーレイ
                  if (_hasStarted && !_isPlaying)
                    Container(
                      color: Colors.black87,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.miniGameScoreLabel(_score),
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // 🌟 チケット枚数の表示
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                '🎫 のこりチケット: $_currentTickets 枚',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FilledButton.icon(
                                  onPressed: _restartGame,
                                  icon: const Icon(Icons.refresh),
                                  label: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.miniGamePlayAgain,
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF7043),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                OutlinedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.exit_to_app),
                                  label: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.miniGameEndButton,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white),
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
            );
          },
        ),
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }
}
