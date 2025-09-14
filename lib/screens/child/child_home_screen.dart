import 'dart:async';

import 'package:flutter/material.dart';
import '../../widgets/draggable_character.dart';
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

  bool _hasEnteredHouse = false; // 家に入ったことがあるかのローカルな旗
  late AnimationController _hintAnimationController; // 吹き出しアニメーション用

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

    _loadAndDetermineDisplayPromise(); // 定例のやくそくを読み込む（既存の処理）
    // ★アプリの状態変化の監視を開始
    WidgetsBinding.instance.addObserver(this);
    // ★BGMの再生を開始
    BgmManager.instance.play(BgmTrack.main);

    _showGuideIfNeeded(); // 必要ならガイドを表示
  }

  @override
  void dispose() {
    _hintAnimationController.dispose();
    _animationController.dispose();
    _pointsAddedAnimationController.dispose();
    // ★アプリの状態変化の監視を終了
    WidgetsBinding.instance.removeObserver(this);
    // ★BGMマネージャーのリソースを解放
    BgmManager.instance.dispose();
    super.dispose();
  }

  // ★アプリの状態が変化した時に呼ばれるメソッド
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // アプリが前面に戻ってきたら、BGMを再生
      BgmManager.instance.play(BgmTrack.main);
    } else {
      // アプリがバックグラウンドに回ったら、BGMを停止
      BgmManager.instance.stopBgm();
    }
  }

  void _showTutorial() async {
    await _showGuideDialog(
      title: AppLocalizations.of(context)!.guideWelcomeTitle,
      content: AppLocalizations.of(context)!.guideWelcomeDesc,
    );
    // 親モード設定のガイド
    await _showGuideDialog(
      title: AppLocalizations.of(context)!.guideSettingsTitle,
      content: AppLocalizations.of(context)!.guideSettingsDesc,
    );
    // つぎのやくそくのガイド
    await _showGuideDialog(
      title: AppLocalizations.of(context)!.guideNextPromiseTitle,
      content: AppLocalizations.of(context)!.guideNextPromiseDesc,
    );
    // やくそくボードのガイド
    await _showGuideDialog(
      title: AppLocalizations.of(context)!.guidePromiseBoardTitle,
      content: AppLocalizations.of(context)!.guidePromiseBoardDesc,
    );
    // ポイントのガイド
    await _showGuideDialog(
      title: AppLocalizations.of(context)!.guidePointsTitle,
      content: AppLocalizations.of(context)!.guidePointsDesc,
    );
    // ショップのガイド
    await _showGuideDialog(
      title: AppLocalizations.of(context)!.guideShopTitle,
      content: AppLocalizations.of(context)!.guideShopDesc,
    );
    // キャラクター選択のガイド
    await _showGuideDialog(
      title: AppLocalizations.of(context)!.guideCustomizeTitle,
      content: AppLocalizations.of(context)!.guideCustomizeDesc,
    );
    // ヘルプボタンのガイド
    await _showGuideDialog(
      title: AppLocalizations.of(context)!.guideHelpTitle,
      content: AppLocalizations.of(context)!.guideHelpDesc,
    );
  }

  void _showGuideIfNeeded() async {
    bool isShown = await SharedPrefsHelper.isGuideShown();
    if (!isShown && mounted) {
      // 画面の描画が終わってから、最初のダイアログを表示
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        //ガイド表示
        _showTutorial();
        // 全ての説明が終わったら、表示済みフラグを立てる
        await SharedPrefsHelper.setGuideShown();
      });
    }
  }

  // 説明ダイアログを表示するための共通メソッド
  Future<void> _showGuideDialog({
    required String title,
    required String content,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              SfxManager.instance.playTapSound();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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

    final orientation = MediaQuery.of(context).orientation;

    late double screenWidth;
    late double screenHeight;

    // 画面の向きに応じて幅と高さを設定
    if (orientation == Orientation.landscape) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
    } else {
      screenWidth = MediaQuery.of(context).size.height;
      screenHeight = MediaQuery.of(context).size.width;
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
      loadedPositions[charPath] = loadedPos ?? Offset(490, 190);
    }

    final itemsToLoad = items.isEmpty ? [] : items;

    for (var itemPath in itemsToLoad) {
      final loadedPos = await SharedPrefsHelper.loadCharacterPosition(itemPath);
      loadedPositions[itemPath] = loadedPos ?? Offset(100, 190);
    }
    // 最後に、画面の状態を更新
    setState(() {
      _hasEnteredHouse = entered;
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
            loadedPositions[charPath] ?? Offset(490, 190); // 読み込んだ位置を保存
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
    });
  }

  // 「はじめる」ボタンを押した時の処理を修正
  void _startPromise() async {
    if (_displayPromise == null) return;

    // ★タイマー画面に行く前に、集中BGMを再生
    BgmManager.instance.play(BgmTrack.focus);

    // タイマー画面に遷移し、結果（獲得ポイント）を待つ
    final pointsAwarded = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        // TimerScreenに、緊急かどうかの情報も渡す
        builder: (context) => TimerScreen(
          promise: _displayPromise!,
          isEmergency: _isDisplayPromiseEmergency,
        ),
      ),
    );

    // ★タイマー画面から戻ってきたら、メインBGMを再生
    BgmManager.instance.play(BgmTrack.main);

    if (pointsAwarded != null && pointsAwarded > 0) {
      if (!_isDisplayPromiseEmergency) {
        await SharedPrefsHelper.addCompletionRecord(_displayPromise!['title']);
      }
      // 新しいポイントを計算
      final newTotalPoints = _points + pointsAwarded;

      // SharedPreferencesに新しいポイントを保存
      await SharedPrefsHelper.savePoints(newTotalPoints);

      // ポイント追加の効果音出す
      SfxManager.instance.playSuccessSound();

      setState(() {
        _pointsAdded = pointsAwarded;
      });
      // 追加されたポイント数を一時的に保存して、アニメーションで表示
      _animationController.forward(from: 0.0);
      _pointsAddedAnimationController.forward(from: 0.0);
      // 画面の状態を更新して、再読み込み
      _loadAndDetermineDisplayPromise();
    }
  }

  // このメソッドを新しく追加します
  void _skipPromise() async {
    SfxManager.instance.playTapSound();
    if (_displayPromise == null) return;

    // 「やらなかった」やくそくも、達成済みとして記録します
    await SharedPrefsHelper.addCompletionRecord(_displayPromise!['title']);

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
    // Scaffoldが画面全体の基本的な骨組みです
    return Scaffold(
      body: Stack(
        children: [
          // ここに、背景、アバター、家、ボタンなどを重ねていきます

          // 背景
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                // 背景画像のファイル名を指定
                image: AssetImage('assets/images/world.png'),

                // 画像を画面全体に綺麗に引き伸ばします
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 上のバー（ポイントや設定ボタン）
          // SafeAreaで、スマホの上のステータスバー（時間や電波表示）に
          // ボタンが隠れないようにします
          SafeArea(
            child: Stack(
              children: [
                // 2. 左上の「おやが見る画面へ」ボタン
                Positioned(
                  top: 10,
                  left: 10,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color(
                              0xFFFF7043,
                            ).withOpacity(0.9), // 半透明の黒い背景
                            shape: BoxShape.circle, // 形を円にする
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.settings,
                              size: 40,
                              color: Color(0xFFFFCA28),
                            ),
                            onPressed: () async {
                              SfxManager.instance.playTapSound();
                              final bool? isCorrect = await showDialog<bool>(
                                context: context,
                                builder: (context) => const MathLockDialog(),
                              );

                              // ★もし、結果がtrue（正解）だったら、親モード画面へ
                              if (isCorrect == true) {
                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ParentTopScreen(),
                                  ),
                                ).then((_) {
                                  _loadAndDetermineDisplayPromise();
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 10), // ボタンの間に少し隙間をあける
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFFF7043).withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.question_mark,
                              size: 40,
                              color: Color(0xFFFFCA28),
                            ),
                            onPressed: () {
                              SfxManager.instance.playTapSound();
                              _showTutorial();
                            },
                          ),
                        ),
                      ],
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

                // 4. 右側の3つのボタン
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 10,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // やくそくボードボタン
                        Container(
                          decoration: BoxDecoration(
                            color: Color(
                              0xFFFF7043,
                            ).withOpacity(0.9), // 半透明の黒い背景
                            shape: BoxShape.circle, // 形を円にする
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.article_rounded,
                              size: 40,
                              color: Color(0xFFFFCA28),
                            ),
                            onPressed: () async {
                              SfxManager.instance.playTapSound();
                              // やくそくボード画面から戻ってくるのを「await」で待ち、結果を受け取る
                              final pointsFromBoard = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PromiseBoardScreen(),
                                ),
                              );

                              // もし、ポイントを持って戻ってきたら
                              if (pointsFromBoard != null) {
                                // ポイント追加の効果音出す
                                SfxManager.instance.playSuccessSound();

                                // setStateを使って、ポイントを加算し、画面を更新！
                                setState(() {
                                  _points += (pointsFromBoard as int);
                                  _pointsAdded = pointsFromBoard;
                                });

                                _animationController.forward(from: 0.0);
                                _pointsAddedAnimationController.forward(
                                  from: 0.0,
                                );
                              }
                              // SharedPreferencesに新しいポイントを保存
                              await SharedPrefsHelper.savePoints(_points);

                              // ★やくそくボード画面から戻ってきたら、必ずデータを再読み込みする！
                              _loadAndDetermineDisplayPromise();
                            },
                          ),
                        ),
                        const SizedBox(height: 10), // ボタンの間に少し隙間をあける
                        // キャラクター選択ボタン
                        Container(
                          decoration: BoxDecoration(
                            color: Color(
                              0xFFFF7043,
                            ).withOpacity(0.9), // 半透明の黒い背景
                            shape: BoxShape.circle, // 形を円にする
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.face,
                              size: 40,
                              color: Color(0xFFFFCA28),
                            ),
                            onPressed: () {
                              SfxManager.instance.playTapSound();
                              // キャラクター設定画面へ遷移
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CharacterCustomizeScreen(),
                                ),
                              ).then((_) {
                                // ★設定画面から戻ってきたら、表示を更新するために再読み込み
                                _loadAndDetermineDisplayPromise();
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 10), // ボタンの間に少し隙間をあける
                        // ごほうびショップボタン
                        Container(
                          decoration: BoxDecoration(
                            color: Color(
                              0xFFFF7043,
                            ).withOpacity(0.9), // 半透明の黒い背景
                            shape: BoxShape.circle, // 形を円にする
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.store,
                              size: 40,
                              color: Color(0xFFFFCA28),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // ★現在のポイント数を渡してショップ画面を開く
                                  builder: (context) => ShopScreen(
                                    currentPoints: _points,
                                    mode: ShopMode.forGeneral,
                                  ),
                                ),
                              ).then((_) {
                                // ★ショップ画面から戻ってきたら、必ずデータを再読み込みする
                                _loadAndDetermineDisplayPromise();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 真ん中のエリア（アバターと家）
          Align(
            alignment: Alignment.bottomCenter, // 画面下の中央を基準に配置
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
                SfxManager.instance.playSuccessSound(); // 音を鳴らす

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
                      currentPoints: _points, // ★この行を追加
                    ),
                  ),
                ).then((_) {
                  // ★家の中画面から戻ってきたら、必ずデータを再読み込みする
                  _loadAndDetermineDisplayPromise();
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100.0), // 下から少し浮かせる
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
          ),

          // ★ まだ家に入ったことがない場合のみ表示
          if (!_hasEnteredHouse)
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
                      // 緊急やくそくなら赤色、そうでなければ半透明の白
                      color: _isDisplayPromiseEmergency
                          ? Colors.red[400]
                          : Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
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
                                    color: Colors.grey[700],
                                  ),
                                ),

                              const SizedBox(height: 2),

                              // やくそくの名前とポイントを表示
                              Text(
                                _isDisplayPromiseEmergency
                                    ? '${_displayPromise!['title']} / ${_displayPromise!['points']}${AppLocalizations.of(context)!.points}'
                                    : '${_displayPromise!['time']}〜 ${_displayPromise!['title']} / ${_displayPromise!['points']}${AppLocalizations.of(context)!.points}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  // 緊急やくそくなら文字は白
                                  color: _isDisplayPromiseEmergency
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                overflow:
                                    TextOverflow.ellipsis, // 長いテキストは...で省略
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 「やらなかった」ボタン（TextButtonで見え方を少し変える）
                        TextButton(
                          onPressed: _skipPromise,
                          child: Text(
                            AppLocalizations.of(context)!.didNotDo,
                            style: TextStyle(
                              color: _isDisplayPromiseEmergency
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                        ),

                        ElevatedButton(
                          onPressed: _startPromise,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isDisplayPromiseEmergency
                                ? Colors.white
                                : Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _isDisplayPromiseEmergency
                                ? AppLocalizations.of(context)!.startNow
                                : AppLocalizations.of(context)!.startPromise,
                            style: TextStyle(
                              color: _isDisplayPromiseEmergency
                                  ? Colors.red[400]
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

          // ★アバターの表示と操作
          DraggableCharacter(
            id: 'avatar',
            imagePath: _equippedClothesPath,
            position: _avatarPosition,
            size: 80,
            onPositionChanged: (delta) {
              setState(() {
                _avatarPosition += delta; // ★位置の更新
              });
            },
          ),

          // ★応援キャラクターの表示と操作
          ..._equippedCharacters.map((charPath) {
            return DraggableCharacter(
              id: charPath, // IDとして画像パスを使う
              imagePath: charPath,
              position: _characterPositionsMap[charPath] ?? Offset(490, 190),
              size: 80,
              onPositionChanged: (delta) {
                setState(() {
                  // ★位置の更新
                  _characterPositionsMap[charPath] =
                      (_characterPositionsMap[charPath] ??
                          const Offset(490, 190)) +
                      delta;
                });
              },
            );
          }).toList(),

          // ★アイテムの表示と操作
          ..._equippedItems.map((itemPath) {
            return DraggableCharacter(
              id: itemPath,
              imagePath: itemPath,
              position: _itemPositionsMap[itemPath] ?? const Offset(100, 190),
              size: _getItemSize(itemPath), // アイテムは少し小さめに
              onPositionChanged: (delta) {
                setState(() {
                  _itemPositionsMap[itemPath] =
                      (_itemPositionsMap[itemPath] ?? const Offset(100, 190)) +
                      delta;
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
