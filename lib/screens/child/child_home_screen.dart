import 'package:flutter/material.dart';
import 'promise_board_screen.dart';
import 'timer_screen.dart';
import 'shop_screen.dart';
import '../parent/parent_top_screen.dart';
import '../../helpers/shared_prefs_helper.dart';
import 'character_customize_screen.dart';
import '../../managers/bgm_manager.dart';
import '../../managers/sfx_manager.dart';
import 'math_lock_dialog.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String _equippedClothesPath = 'assets/images/avatar.png'; // デフォルト画像
  String _equippedHousePath = 'assets/images/house.png'; // デフォルト画像
  // ポイント数の状態を管理するための変数
  int _points = 0;

  Map<String, dynamic>? _displayPromise; // 実際に下のバーに表示するやくそく
  bool _isDisplayPromiseEmergency = false; // 表示しているのが緊急かどうか

  @override
  void initState() {
    super.initState();

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

    _loadAndDetermineDisplayPromise(); // 定例のやくそくを読み込む（既存の処理）
    // ★アプリの状態変化の監視を開始
    WidgetsBinding.instance.addObserver(this);
    // ★BGMの再生を開始
    BgmManager.instance.play(BgmTrack.main);
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  // データを読み込み、表示するやくそくを決定する
  Future<void> _loadAndDetermineDisplayPromise() async {
    // まず、SharedPreferencesから両方のデータを読み込む
    final loadedPoints = await SharedPrefsHelper.loadPoints();
    final regular = await SharedPrefsHelper.loadRegularPromises();
    final emergency = await SharedPrefsHelper.loadEmergencyPromise();
    final todaysCompletedTitles =
        await SharedPrefsHelper.loadTodaysCompletedPromiseTitles();

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

    // 最後に、画面の状態を更新
    setState(() {
      _points = loadedPoints;
      _displayPromise = nextPromise;
      _isDisplayPromiseEmergency = isEmergency;
      _equippedClothesPath = clothes ?? 'assets/images/avatar.png';
      _equippedHousePath = house ?? 'assets/images/house.png';
    });
  }

  // 「はじめる」ボタンを押した時の処理を修正
  void _startPromise() async {
    if (_displayPromise == null) return;

    // ★タイマー画面に行く前に、集中BGMを再生
    BgmManager.instance.play(BgmTrack.focus);
    SfxManager.instance.playStartSound();

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
      _animationController.forward(from: 0.0);
      if (!_isDisplayPromiseEmergency) {
        await SharedPrefsHelper.addCompletionRecord(_displayPromise!['title']);
      }
      // 新しいポイントを計算
      final newTotalPoints = _points + pointsAwarded;

      // SharedPreferencesに新しいポイントを保存
      await SharedPrefsHelper.savePoints(newTotalPoints);

      // ポイント追加の効果音出す
      SfxManager.instance.playSuccessSound();

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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFF7043).withOpacity(0.9), // 半透明の黒い背景
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
                              builder: (context) => const ParentTopScreen(),
                            ),
                          ).then((_) {
                            _loadAndDetermineDisplayPromise();
                          });
                        }
                      },
                    ),
                  ),
                ),

                // 3. 右上の「ポイント表示」
                Positioned(
                  top: 10,
                  right: 10,
                  child: ScaleTransition(
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
                          const Icon(Icons.star, color: Colors.amber, size: 24),
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
                                });
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
                              SfxManager.instance.playTapSound();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // ★現在のポイント数を渡してショップ画面を開く
                                  builder: (context) =>
                                      ShopScreen(currentPoints: _points),
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
            child: Padding(
              padding: const EdgeInsets.only(bottom: 90.0), // 下から少し浮かせる
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
                crossAxisAlignment: CrossAxisAlignment.end, // アバターと家の底を揃える
                children: [
                  // アバター画像
                  Image.asset(
                    _equippedClothesPath, // あなたが用意した画像ファイル名
                    height: 80, // 高さを指定
                  ),
                  const SizedBox(width: 30), // アバターと家の間に隙間をあける
                  // 家の画像
                  Image.asset(
                    _equippedHousePath, // あなたが用意した画像ファイル名
                    height: 200, // 高さを指定
                  ),
                ],
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
                                const Text(
                                  'きんきゅう！',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              // 定例の場合は「つぎのやくそく」と表示
                              if (!_isDisplayPromiseEmergency)
                                Text(
                                  'つぎのやくそく',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),

                              const SizedBox(height: 2),

                              // やくそくの名前とポイントを表示
                              Text(
                                _isDisplayPromiseEmergency
                                    ? '${_displayPromise!['title']} / ${_displayPromise!['points']}ポイント'
                                    : '${_displayPromise!['time']}〜 ${_displayPromise!['title']} / ${_displayPromise!['points']}ポイント',
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
                            'やらなかった',
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
                            _isDisplayPromiseEmergency ? 'すぐにはじめる' : 'はじめる',
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
                    child: const Center(
                      child: Text(
                        '今日のやくそくは、すべておわりました！✨',
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
