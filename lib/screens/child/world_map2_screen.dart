import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/world_map_background2.png'),
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
            child: const AnimatedPlaceholderThumbnail(
              text: '実装中',
              offsetY: 8,
              duration: Duration(seconds: 2),
            ),
          ),

          // 実装中のサムネイル (左下)
          Align(
            alignment: const Alignment(-0.8, 0.8), // 左下
            child: const AnimatedPlaceholderThumbnail(
              text: '実装中',
              offsetY: 8,
              duration: Duration(seconds: 2),
            ),
          ),

          // 実装中のサムネイル (右下)
          Align(
            alignment: const Alignment(0.8, 0.8), // 右下
            child: const AnimatedPlaceholderThumbnail(
              text: '実装中',
              offsetY: 8,
              duration: Duration(seconds: 2),
            ),
          ),
        ],
      ),
    );
  }
}
