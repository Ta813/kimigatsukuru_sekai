import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:kimigatsukuru_sekai/screens/premium_paywall_screen.dart';
import 'island_screen.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../managers/purchase_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/round_menu_button.dart';
import '../../widgets/animated_placeholder_thumbnail.dart';
import 'sea_screen.dart';
import 'sky_screen.dart';
import 'space_screen.dart';
import 'world_map2_screen.dart';

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
    SharedPrefsHelper.setHasOpenedWorldMap(true);
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
        title: Text(
          title,
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
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(false);
              }
            },
            child: Text(
              AppLocalizations.of(context)!.skip,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _showPremiumUpgradeDialog(int requiredLevel) async {
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
                AppLocalizations.of(
                  context,
                )!.mapLevelLockMessage(requiredLevel),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.premiumMapUnlockMessage,
                style: const TextStyle(fontSize: 16, height: 1.5),
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
                name: 'premium_open_world_map',
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
              backgroundColor: const Color(0xFFFF7043), // オレンジ
              foregroundColor: Colors.white,
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
              AppLocalizations.of(context)!.seeDetails,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PurchaseManager.instance.isPremium,
      builder: (context, isPremium, child) {
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

              Positioned(
                top: 20.0, // 上からの距離
                left: 20.0, // 左からの距離
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RoundMenuButton(
                        icon: Icons.keyboard_return,
                        label: AppLocalizations.of(context)!.navBack,
                        iconColor: const Color(0xFF5D4037),
                        backgroundColor: const Color(0xFFCFD8DC), // ブルーグレー
                        onTap: () {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'start_world_map_back',
                          );
                          try {
                            SfxManager.instance.playTapSound();
                          } catch (e) {
                            print('再生エラー: $e');
                          }
                          Navigator.pop(context);
                        },
                      ),

                      const SizedBox(height: 0), // ボタンの間に少し隙間をあける

                      RoundMenuButton(
                        icon: Icons.question_mark,
                        label: AppLocalizations.of(context)!.help,
                        iconColor: const Color(0xFF5D4037),
                        backgroundColor: const Color(0xFFFFF9C4), // ライトイエロー
                        onTap: () {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'start_world_map_help',
                          );
                          try {
                            SfxManager.instance.playTapSound();
                          } catch (e) {
                            print('再生エラー: $e');
                          }
                          _showGuideSequence();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ★ --- 下の海エリアのタップ領域 --- ★
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    FirebaseAnalytics.instance.logEvent(
                      name: 'start_world_map_sea',
                    );
                    // ★ レベル10以上かチェック
                    if (widget.currentLevel >= 10 || isPremium) {
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
                            requiredExpForNextLevel:
                                widget.requiredExpForNextLevel,
                            experience: widget.experience,
                            experienceFraction: widget.experienceFraction,
                          ),
                        ),
                      );
                    } else {
                      // ★ レベルが足りない場合はメッセージを表示
                      _showPremiumUpgradeDialog(10);
                    }
                  },
                  child: Container(
                    width: 300,
                    height: 150,
                    color: Colors.transparent,
                    child: Align(
                      // ★ サムネイル画像に変更
                      child: const _AnimatedMapThumbnail(
                        imagePath: 'assets/images/sea_background.png',
                        offsetY: 8,
                        duration: Duration(seconds: 2),
                      ),
                    ),
                  ),
                ),
              ),

              // ★ --- 上の空エリアのタップ領域 --- ★
              Align(
                alignment: const Alignment(-0.7, -0.3), // 左のほうにずらす
                child: GestureDetector(
                  onTap: () {
                    FirebaseAnalytics.instance.logEvent(
                      name: 'start_world_map_sky',
                    );
                    // ★ レベル15以上かチェック
                    if (widget.currentLevel >= 15 || isPremium) {
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
                            requiredExpForNextLevel:
                                widget.requiredExpForNextLevel,
                            experience: widget.experience,
                            experienceFraction: widget.experienceFraction,
                          ),
                        ),
                      );
                    } else {
                      // レベルが足りない場合
                      _showPremiumUpgradeDialog(15);
                    }
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    color: Colors.transparent,
                    child: Center(
                      // ★ サムネイル画像に変更
                      child: const _AnimatedMapThumbnail(
                        imagePath: 'assets/images/sky_background.png',
                        offsetY: 8,
                        duration: Duration(seconds: 2),
                      ),
                    ),
                  ),
                ),
              ),

              // ★ --- さらに上の宇宙エリアのタップ領域 --- ★
              Align(
                alignment: const Alignment(-0.7, -1.1), // 空のさらに上に配置
                child: GestureDetector(
                  onTap: () {
                    FirebaseAnalytics.instance.logEvent(
                      name: 'start_world_map_space',
                    );
                    // ★ レベル20以上かチェック
                    if (widget.currentLevel >= 20 || isPremium) {
                      try {
                        SfxManager.instance.playSuccessSound();
                      } catch (e) {
                        print('再生エラー: $e');
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpaceScreen(
                            currentLevel: widget.currentLevel,
                            currentPoints: widget.currentPoints,
                            requiredExpForNextLevel:
                                widget.requiredExpForNextLevel,
                            experience: widget.experience,
                            experienceFraction: widget.experienceFraction,
                          ),
                        ),
                      );
                    } else {
                      // レベルが足りない場合
                      _showPremiumUpgradeDialog(20);
                    }
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    color: Colors.transparent,
                    child: Center(
                      child: const _AnimatedMapThumbnail(
                        imagePath: 'assets/images/space_background.png',
                        offsetY: 8,
                        duration: Duration(seconds: 2),
                      ),
                    ),
                  ),
                ),
              ),

              // ★ --- 真ん中の島のタップ領域 --- ★
              Align(
                alignment: const Alignment(0.0, -0.6),
                child: GestureDetector(
                  onTap: () {
                    FirebaseAnalytics.instance.logEvent(
                      name: 'start_world_map_island',
                    );
                    if (widget.currentLevel >= 5 || isPremium) {
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
                            requiredExpForNextLevel:
                                widget.requiredExpForNextLevel,
                            experience: widget.experience,
                            experienceFraction: widget.experienceFraction,
                          ),
                        ),
                      );
                    } else {
                      // レベルが足りない場合はメッセージを表示
                      _showPremiumUpgradeDialog(5);
                    }
                  },
                  child: Container(
                    width: 200, // タップ領域の横幅
                    height: 200, // タップ領域の縦幅
                    color: Colors.transparent, // 透明なので見えない
                    child: Center(
                      // ★ サムネイル画像に変更
                      child: const _AnimatedMapThumbnail(
                        imagePath: 'assets/images/island.png',
                        offsetY: 8,
                        duration: Duration(seconds: 2),
                      ),
                    ),
                  ),
                ),
              ),

              // ★ --- 右端のマップ（世界地図2）のタップ領域 --- ★
              Align(
                alignment: const Alignment(0.9, 0.0), // 右端中央
                child: GestureDetector(
                  onTap: () {
                    FirebaseAnalytics.instance.logEvent(
                      name: 'start_world_map2',
                    );
                    try {
                      SfxManager.instance.playSuccessSound();
                    } catch (e) {
                      print('再生エラー: $e');
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorldMap2Screen(
                          currentLevel: widget.currentLevel,
                          currentPoints: widget.currentPoints,
                          requiredExpForNextLevel:
                              widget.requiredExpForNextLevel,
                          experience: widget.experience,
                          experienceFraction: widget.experienceFraction,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    color: Colors.transparent,
                    child: Center(
                      child: const AnimatedPlaceholderThumbnail(
                        text: '次の世界へ',
                        imagePath: 'assets/images/world_map_background2.png',
                        offsetY: 8,
                        duration: Duration(seconds: 2),
                        iconData: Icons.arrow_forward_ios,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedMapThumbnail extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;
  final double offsetY;
  final Duration duration;

  const _AnimatedMapThumbnail({
    required this.imagePath,
    // ignore: unused_element_parameter
    this.width = 120,
    // ignore: unused_element_parameter
    this.height = 80,
    this.offsetY = 5,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<_AnimatedMapThumbnail> createState() => _AnimatedMapThumbnailState();
}

class _AnimatedMapThumbnailState extends State<_AnimatedMapThumbnail>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _animation = Tween<double>(begin: -widget.offsetY, end: widget.offsetY)
        .animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
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
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 4),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
              image: DecorationImage(
                image: AssetImage(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
