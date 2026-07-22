import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../managers/purchase_manager.dart';
import '../../widgets/ad_banner.dart';
import '../../widgets/avatar_display.dart';
import 'mini_game_screen.dart'; // GameCourse を読み込むため

// 🌟 ジャンプゲーム専用の障害物データ
class JumpObstacleData {
  double x;
  double y;
  double size;
  String imagePath;
  bool passed;

  JumpObstacleData({
    required this.x,
    required this.y,
    required this.size,
    required this.imagePath,
    this.passed = false,
  });
}

class JumpGamePlayScreen extends StatefulWidget {
  final GameCourse course;
  const JumpGamePlayScreen({super.key, required this.course});

  @override
  State<JumpGamePlayScreen> createState() => _JumpGamePlayScreenState();
}

class _JumpGamePlayScreenState extends State<JumpGamePlayScreen> {
  // 物理演算（重力とジャンプ力）
  final double _playerSize = 70.0;
  double _playerX = 60.0; // 左の方に固定して、背景（障害物）を動かします
  double _playerY = 0.0;
  double _groundY = 0.0;

  double _velocityY = 0.0;
  final double _gravity = 2.5; // 重力
  final double _jumpStrength = 28.0; // ジャンプ力
  bool _isJumping = false;

  List<JumpObstacleData> _obstacles = [];
  Timer? _gameTimer;
  int _score = 0;
  bool _isPlaying = false;
  bool _hasStarted = false;
  int _currentTickets = 0;
  int _highScore = 0;

  final Random _random = Random();
  bool _isSizeInitialized = false;
  double _screenWidth = 0.0;
  double _screenHeight = 0.0;

  String _activeCharPath = 'MY_AVATAR';

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logEvent(
      name: 'jumpgame_start',
      parameters: {'course': widget.course.name},
    );
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final tickets = await SharedPrefsHelper.getGameTickets();
    // 🌟 よけろ！とは別の「ジャンプ用ランキング」にするためキーに _jump を付けます
    final h = await SharedPrefsHelper.getHighScore(
      '${widget.course.name}_jump',
    );
    final charPath = await SharedPrefsHelper.getMiniGameCharacter();
    if (mounted) {
      setState(() {
        _currentTickets = tickets;
        _highScore = h;
        _activeCharPath = charPath;
      });
    }
  }

  void _initGameDimensions(double width, double height) {
    _screenWidth = width;
    _screenHeight = height;

    final adOffset = PurchaseManager.instance.isPremium.value ? 0.0 : 60.0;
    _groundY = _screenHeight - _playerSize - 60 - adOffset;
    _playerY = _groundY;

    _isSizeInitialized = true;
  }

  void _startGame() {
    setState(() {
      _hasStarted = true;
      _isPlaying = true;
    });
    _gameTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_isPlaying) _updateGame();
    });
  }

  // 🌟 タップした時のジャンプ処理
  void _jump() {
    if (!_isPlaying || _isJumping) return;
    setState(() {
      _velocityY = -_jumpStrength; // 上に向かって力を加える
      _isJumping = true;
    });
    try {
      SfxManager.instance.playTapSound();
    } catch (_) {}
  }

  void _updateGame() {
    setState(() {
      // 1. 重力の処理（プレイヤーの落下）
      _velocityY += _gravity;
      _playerY += _velocityY;

      // 着地判定（地面より下に行かないようにする）
      if (_playerY >= _groundY) {
        _playerY = _groundY;
        _velocityY = 0;
        _isJumping = false;
      }

      // 2. 障害物の生成
      // 右端から一定間隔でランダムに障害物を出す
      bool canSpawn =
          _obstacles.isEmpty || (_obstacles.last.x < _screenWidth - 300);
      if (canSpawn && _random.nextDouble() < 0.03) {
        final randomImage =
            widget.course.obstacleImages[_random.nextInt(
              widget.course.obstacleImages.length,
            )];
        final obsSize = 50.0 + _random.nextDouble() * 30.0; // 50〜80のランダムなサイズ
        _obstacles.add(
          JumpObstacleData(
            x: _screenWidth,
            y: _groundY + _playerSize - obsSize, // 大きさに関わらず地面にくっつける
            size: obsSize,
            imagePath: randomImage,
          ),
        );
      }

      // 3. 障害物の移動と衝突判定
      List<JumpObstacleData> nextObstacles = [];
      double speed = 12.0 + (_score / 50); // スコアが上がるほどスクロールが速くなる！

      for (var obs in _obstacles) {
        obs.x -= speed; // 左へ流れる

        // 当たり判定（ストレスにならないよう、少し小さめに判定をとる）
        Rect playerRect = Rect.fromLTWH(
          _playerX + 20,
          _playerY + 20,
          _playerSize - 40,
          _playerSize - 20,
        );
        Rect obsRect = Rect.fromLTWH(
          obs.x + 15,
          obs.y + 15,
          obs.size - 30,
          obs.size - 20,
        );

        if (playerRect.overlaps(obsRect)) {
          _endGame();
          return;
        }

        // 飛び越えたらスコア加算
        if (!obs.passed && obs.x + obs.size < _playerX) {
          obs.passed = true;
          _score += 10;
        }

        // 画面の左端から消えたらリストから外す
        if (obs.x + obs.size > 0) {
          nextObstacles.add(obs);
        }
      }
      _obstacles = nextObstacles;
    });
  }

  Future<void> _endGame() async {
    setState(() => _isPlaying = false);
    _gameTimer?.cancel();

    final courseKey = '${widget.course.name}_jump';
    final oldHighScore = await SharedPrefsHelper.getHighScore(courseKey);
    await SharedPrefsHelper.saveGameScore(courseKey, _score);

    // 🌟 世界ランキングへの送信処理
    if (_score > oldHighScore && _score > 0) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('world_rankings')
            .where('course', isEqualTo: courseKey)
            .orderBy('score', descending: true)
            .limit(30)
            .get();

        bool isTop30 = false;
        final docs = snapshot.docs;

        if (docs.length < 30) {
          isTop30 = true;
        } else {
          final rank30Score = docs.last.data()['score'] as int? ?? 0;
          if (_score > rank30Score) isTop30 = true;
        }

        if (isTop30) {
          await FirebaseFirestore.instance.collection('world_rankings').add({
            'course': courseKey,
            'score': _score,
            'character': _activeCharPath,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        print('スコア送信エラー: $e');
      }
    }

    await _loadInitialData();
    FirebaseAnalytics.instance.logEvent(
      name: 'jumpgame_gameover',
      parameters: {'score': _score},
    );
    try {
      SfxManager.instance.playGameOverSound();
    } catch (_) {}
  }

  Future<void> _restartGame() async {
    if (!kDebugMode) {
      final currentTickets = await SharedPrefsHelper.getGameTickets();
      if (currentTickets <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🛑 チケットがなくなっちゃった！'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      await SharedPrefsHelper.updateGameTickets(-1);
    }

    setState(() {
      _obstacles.clear();
      _score = 0;
      _playerY = _groundY;
      _velocityY = 0;
      _isJumping = false;
      _isPlaying = true;
    });
    await _loadInitialData();
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
              onTap: _jump, // 🌟 画面のどこをタップしてもジャンプする！
              child: Stack(
                children: [
                  // 背景
                  SizedBox.expand(
                    child: Image.asset(
                      widget.course.backgroundPath,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    color: Colors.white.withOpacity(0.2),
                  ), // 少し明るくして見やすく
                  // 🌟 地面のライン（視覚的な目安）
                  Positioned(
                    top: _groundY + _playerSize,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 5,
                      color: widget.course.themeColor.withOpacity(0.5),
                    ),
                  ),

                  // スコア表示
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'スコア: $_score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '🥇 じこベスト: $_highScore',
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // プレイヤー（アバター or 応援キャラクター）
                  Positioned(
                    left: _playerX,
                    top: _playerY,
                    child: _activeCharPath == 'MY_AVATAR'
                        ? const AvatarDisplay(size: 70)
                        : Image.asset(
                            _activeCharPath,
                            width: _playerSize,
                            height: _playerSize,
                            cacheWidth: 140,
                          ),
                  ),

                  // 流れてくる障害物
                  ..._obstacles.map(
                    (obs) => Positioned(
                      left: obs.x,
                      top: obs.y,
                      child: Image.asset(
                        obs.imagePath,
                        width: obs.size,
                        height: obs.size,
                        cacheWidth: 120,
                      ),
                    ),
                  ),

                  // 🌟 スタート前オーバーレイ
                  if (!_hasStarted)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.course.name}\n(ジャンプ！)',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '画面をタップして\nジャンプでよけよう！',
                              textAlign: TextAlign.center,
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
                              child: const Text(
                                'スタート！',
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

                  // 🌟 ゲームオーバー画面のオーバーレイ
                  if (_hasStarted && !_isPlaying)
                    Container(
                      color: Colors.black87,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'スコア: $_score',
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                '🎫 のこりチケット: ${kDebugMode ? "∞" : _currentTickets} 枚',
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
                                  label: const Text('もう一回やる'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF7043),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                OutlinedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.exit_to_app),
                                  label: const Text('おわる'),
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

                  // 広告
                  if (!PurchaseManager.instance.isPremium.value)
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: AdBanner(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
