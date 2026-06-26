import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:kimigatsukuru_sekai/managers/purchase_manager.dart';
import 'package:kimigatsukuru_sekai/screens/child/jungle_screen.dart';
import 'package:kimigatsukuru_sekai/screens/premium_paywall_screen.dart';
import '../../managers/sfx_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/round_menu_button.dart';
import '../../widgets/animated_placeholder_thumbnail.dart';

class WorldMap2Screen extends StatefulWidget {
  final int currentLevel;
  final int currentPoints;
  final int requiredExpForNextLevel;
  final int experience;
  final double experienceFraction;

  const WorldMap2Screen({
    super.key,
    required this.currentLevel,
    required this.currentPoints,
    required this.requiredExpForNextLevel,
    required this.experience,
    required this.experienceFraction,
  });

  @override
  State<WorldMap2Screen> createState() => _WorldMap2ScreenState();
}

class _WorldMap2ScreenState extends State<WorldMap2Screen> {
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
          FilledButton(
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
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043), // オレンジ
              foregroundColor: Colors.white,
              side: const BorderSide(
                color: Color(0xFFFFCA28),
                width: 2,
              ), // 黄色の輪郭
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
                    image: AssetImage(
                      'assets/images/world_map_background2.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 20.0,
                left: 20.0,
                child: SafeArea(
                  child: RoundMenuButton(
                    icon: Icons.keyboard_return,
                    label: AppLocalizations.of(context)!.navBack,
                    iconColor: const Color(0xFF5D4037),
                    backgroundColor: const Color(0xFFCFD8DC), // ブルーグレー
                    onTap: () {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'start_world_map2_back',
                      );
                      try {
                        SfxManager.instance.playTapSound();
                      } catch (e) {
                        print('再生エラー: $e');
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),

              // 実装中のサムネイル (中央)
              Align(
                alignment: Alignment.center,
                child: AnimatedPlaceholderThumbnail(
                  text: AppLocalizations.of(context)!.underConstruction,
                  offsetY: 8,
                  duration: const Duration(seconds: 2),
                ),
              ),

              // 実装中のサムネイル (左下)
              Align(
                alignment: const Alignment(-1.0, 0.8), // 左下
                child: GestureDetector(
                  onTap: () {
                    FirebaseAnalytics.instance.logEvent(
                      name: 'start_world_map_jungle',
                    );
                    // ★ レベル30以上かチェック
                    if (widget.currentLevel >= 30 || isPremium) {
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
                          builder: (context) => JungleScreen(
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
                      _showPremiumUpgradeDialog(30);
                    }
                  },
                  child: Container(
                    width: 300,
                    height: 150,
                    color: Colors.transparent,
                    child: Align(
                      // ★ サムネイル画像に変更
                      child: _AnimatedMapThumbnail(
                        imagePath: 'assets/images/jungle_background.png',
                        offsetY: 8,
                        duration: const Duration(seconds: 2),
                        isLocked: widget.currentLevel < 30 && !isPremium,
                        requiredLevel: 30,
                      ),
                    ),
                  ),
                ),
              ),

              // 実装中のサムネイル (右下)
              Align(
                alignment: const Alignment(0.8, 0.8), // 右下
                child: AnimatedPlaceholderThumbnail(
                  text: AppLocalizations.of(context)!.underConstruction,
                  offsetY: 8,
                  duration: const Duration(seconds: 2),
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
  final bool isLocked;
  final int requiredLevel;

  const _AnimatedMapThumbnail({
    required this.imagePath,
    // ignore: unused_element_parameter
    this.width = 120,
    // ignore: unused_element_parameter
    this.height = 80,
    this.offsetY = 5,
    this.duration = const Duration(seconds: 2),
    this.isLocked = false,
    this.requiredLevel = 0,
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
          child: Stack(
            children: [
              Opacity(
                opacity: widget.isLocked ? 0.8 : 1.0,
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 4),
                    borderRadius: BorderRadius.circular(12),

                    image: DecorationImage(
                      image: AssetImage(widget.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              if (widget.isLocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Lv.${widget.requiredLevel}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
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
