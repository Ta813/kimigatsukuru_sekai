import 'package:flutter/material.dart';
import 'island_screen.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../l10n/app_localizations.dart';
import 'sea_screen.dart';
import 'sky_screen.dart';

class WorldMapScreen extends StatefulWidget {
  // ★ StatefulWidgetに変更
  final int currentLevel;
  final int currentPoints;
  final int requiredExpForNextLevel;
  final int experience;
  final double experienceFraction;

  const WorldMapScreen({
    super.key,
    required this.currentLevel,
    required this.currentPoints,
    required this.requiredExpForNextLevel,
    required this.experience,
    required this.experienceFraction,
  });

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  @override
  void initState() {
    super.initState();
    // ★ 最初のフレーム描画後にガイドをチェックする
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowGuide();
    });
  }

  Future<void> _checkAndShowGuide() async {
    final bool hasShown = await SharedPrefsHelper.getWorldMapGuideShown();
    if (!hasShown && mounted) {
      await _showGuideSequence(); // ガイドを順番に表示
      await SharedPrefsHelper.setWorldMapGuideShown(); // 表示済みフラグを立てる
    }
  }

  // ★ ガイドを順番に表示するメソッド
  Future<void> _showGuideSequence() async {
    bool shouldContinue;
    shouldContinue = await _showGuideDialog(
      title: AppLocalizations.of(context)!.worldMapGuideTitle1,
      content: AppLocalizations.of(context)!.worldMapGuideContent1,
    );
    if (!shouldContinue) return;
    shouldContinue = await _showGuideDialog(
      title: AppLocalizations.of(context)!.worldMapGuideTitle2,
      content: AppLocalizations.of(context)!.worldMapGuideContent2,
    );
    if (!shouldContinue) return;
    shouldContinue = await _showGuideDialog(
      title: AppLocalizations.of(context)!.worldMapGuideTitle3,
      content: AppLocalizations.of(context)!.worldMapGuideContent3,
    );
  }

  // ★ ダイアログを表示するための共通メソッド
  Future<bool> _showGuideDialog({
    required String title,
    required String content,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              // ★ falseを返してダイアログを閉じる
              Navigator.of(context).pop(false);
            },
            child: Text(AppLocalizations.of(context)!.skip), // TODO: l10n対応
          ),
          TextButton(
            onPressed: () {
              try {
                SfxManager.instance.playTapSound();
              } catch (e) {
                // エラーが発生した場合
                print('再生エラー: $e');
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                //「世界の全貌」の背景画像を指定
                image: AssetImage('assets/images/world_map_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 左上の「ホームに戻る」ボタン
          Positioned(
            top: 20.0, // 上からの距離
            left: 20.0, // 左からの距離
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFF7043).withOpacity(0.9), // 半透明の黒い背景
                    shape: BoxShape.circle, // 形を円にする
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.keyboard_return,
                      size: 40,
                      color: Color(0xFFFFCA28),
                    ),
                    onPressed: () {
                      try {
                        SfxManager.instance.playTapSound();
                      } catch (e) {
                        // エラーが発生した場合
                        print('再生エラー: $e');
                      }
                      Navigator.pop(context);
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
                      try {
                        SfxManager.instance.playTapSound();
                      } catch (e) {
                        // エラーが発生した場合
                        print('再生エラー: $e');
                      }
                      _showGuideSequence();
                    },
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 20.0, // 上からの距離
            left: 20.0, // 左からの距離
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFF7043).withOpacity(0.9), // 半透明の黒い背景
                    shape: BoxShape.circle, // 形を円にする
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.keyboard_return,
                      size: 40,
                      color: Color(0xFFFFCA28),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),

          // ★ --- 下の海エリアのタップ領域 --- ★
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {
                // ★ レベル10以上かチェック
                if (widget.currentLevel >= 10) {
                  try {
                    SfxManager.instance.playSuccessSound();
                  } catch (e) {
                    // エラーが発生した場合
                    print('再生エラー: $e');
                  }
                  // ★ レベル10以上なら、SeaScreenに遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeaScreen(
                        currentLevel: widget.currentLevel,
                        currentPoints: widget.currentPoints,
                        requiredExpForNextLevel: widget.requiredExpForNextLevel,
                        experience: widget.experience,
                        experienceFraction: widget.experienceFraction,
                      ),
                    ),
                  );
                } else {
                  // ★ レベルが足りない場合はメッセージを表示
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.seaAreaLocked,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                width: 300,
                height: 150,
                color: Colors.transparent,
                child: Align(
                  // ★ アイコンを下中央に配置
                  alignment: Alignment.bottomCenter,
                  child: _AnimatedIconIndicator(
                    iconData: Icons.arrow_downward, // 下矢印
                    iconColor: Colors.blue, // 海っぽい色
                    iconSize: 40,
                    offsetY: 10,
                    duration: const Duration(seconds: 1),
                  ),
                ),
              ),
            ),
          ),

          // ★ --- 上の空エリアのタップ領域 --- ★
          Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () {
                // ★ レベル15以上かチェック
                if (widget.currentLevel >= 15) {
                  try {
                    SfxManager.instance.playSuccessSound();
                  } catch (e) {
                    // エラーが発生した場合
                    print('再生エラー: $e');
                  }
                  // ★ レベル15以上なら、SkyScreenに遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SkyScreen(
                        currentLevel: widget.currentLevel,
                        currentPoints: widget.currentPoints,
                        requiredExpForNextLevel: widget.requiredExpForNextLevel,
                        experience: widget.experience,
                        experienceFraction: widget.experienceFraction,
                      ),
                    ),
                  );
                } else {
                  // レベルが足りない場合
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.skyAreaLocked,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                width: 300,
                height: 150,
                color: Colors.transparent,
                child: Align(
                  // ★ アイコンを上中央に配置
                  alignment: Alignment.topCenter,
                  child: _AnimatedIconIndicator(
                    iconData: Icons.arrow_upward, // 上矢印
                    iconColor: Colors.purpleAccent, // 宇宙っぽい色
                    iconSize: 40,
                    offsetY: 10,
                    duration: const Duration(seconds: 1),
                  ),
                ),
              ),
            ),
          ),

          // ★ --- 真ん中の島のタップ領域 --- ★
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                if (widget.currentLevel >= 5) {
                  try {
                    SfxManager.instance.playSuccessSound();
                  } catch (e) {
                    // エラーが発生した場合
                    print('再生エラー: $e');
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IslandScreen(
                        currentLevel: widget.currentLevel,
                        currentPoints: widget.currentPoints,
                        requiredExpForNextLevel: widget.requiredExpForNextLevel,
                        experience: widget.experience,
                        experienceFraction: widget.experienceFraction,
                      ),
                    ),
                  );
                } else {
                  // レベルが足りない場合はメッセージを表示
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.islandLocked),
                    ),
                  );
                }
              },
              child: Container(
                width: 200, // タップ領域の横幅
                height: 200, // タップ領域の縦幅
                color: Colors.transparent, // 透明なので見えない
                child: Center(
                  // ★ アイコンを中央に配置
                  child: _AnimatedIconIndicator(
                    iconData: Icons.circle_outlined, // ◎マーク
                    iconColor: Colors.amber, // 色を強調
                    iconSize: 100,
                    offsetY: 8, // 上下動の幅
                    duration: const Duration(seconds: 2), // 2秒で1往復
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

class _AnimatedIconIndicator extends StatefulWidget {
  final IconData iconData;
  final Color iconColor;
  final double iconSize;
  final double offsetY; // アニメーションのオフセット量
  final Duration duration; // アニメーションの速度
  final double rotationAngle; // アイコンの回転角度 (ラジアン)

  const _AnimatedIconIndicator({
    required this.iconData,
    this.iconColor = Colors.white,
    this.iconSize = 30,
    this.offsetY = 10, // デフォルトで10ピクセル上下する
    this.duration = const Duration(seconds: 1), // デフォルトで1秒間
    // ignore: unused_element_parameter
    this.rotationAngle = 0, // デフォルトで回転なし
  });

  @override
  State<_AnimatedIconIndicator> createState() => _AnimatedIconIndicatorState();
}

class _AnimatedIconIndicatorState extends State<_AnimatedIconIndicator>
    with SingleTickerProviderStateMixin {
  // ★ SingleTickerProviderStateMixinを追加
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true); // ★ ここで無限リピート（往復）を設定

    _animation = Tween<double>(begin: -widget.offsetY, end: widget.offsetY)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOutSine, // ★ 滑らかな上下動のカーブ
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // ★ AnimatedBuilderでアニメーションを適用
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value), // _animation.valueが直接オフセットになる
          child: Transform.rotate(
            angle: widget.rotationAngle,
            child: Icon(
              widget.iconData,
              color: widget.iconColor,
              size: widget.iconSize,
            ),
          ),
        );
      },
    );
  }
}
