import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/screens/child/trophy_screen.dart';
import '../helpers/shared_prefs_helper.dart';
import 'sfx_manager.dart';
import '../l10n/app_localizations.dart';
// import '../screens/trophy_screen.dart'; // 🌟 TrophyScreenのパスを正しく合わせてください

enum TrophyRank { normal, bronze, silver, gold, diamond }

class TrophyItem {
  final String id;
  final String title;
  final IconData icon;
  final TrophyRank rank;

  const TrophyItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.rank,
  });

  Color get color {
    switch (rank) {
      case TrophyRank.normal:
        return Colors.brown;
      case TrophyRank.bronze:
        return const Color(0xFFCD7F32);
      case TrophyRank.silver:
        return const Color(0xFFC0C0C0);
      case TrophyRank.gold:
        return const Color(0xFFFFD700);
      case TrophyRank.diamond:
        return const Color(0xFFb9f2ff);
    }
  }
}

class TrophyManager {
  // 全トロフィーの定義
  static List<TrophyItem> getAllTrophies(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final List<TrophyItem> trophies = [];
    TrophyRank determineRank(double progress) {
      if (progress < 0.3) return TrophyRank.normal;
      if (progress < 0.5) return TrophyRank.bronze;
      if (progress < 0.75) return TrophyRank.silver;
      if (progress < 0.9) return TrophyRank.gold;
      return TrophyRank.diamond;
    }

    for (int i = 0; i < SharedPrefsHelper.loginTargets.length; i++) {
      int t = SharedPrefsHelper.loginTargets[i];
      trophies.add(
        TrophyItem(
          id: 'trophy_login_$t',
          title: loc.trophyLoginTitle(t),
          icon: Icons.calendar_month,
          rank: determineRank(i / SharedPrefsHelper.loginTargets.length),
        ),
      );
    }
    for (int i = 0; i < SharedPrefsHelper.shopTargets.length; i++) {
      int t = SharedPrefsHelper.shopTargets[i];
      trophies.add(
        TrophyItem(
          id: 'trophy_shop_$t',
          title: loc.trophyShopTitle(t),
          icon: Icons.storefront,
          rank: determineRank(i / SharedPrefsHelper.shopTargets.length),
        ),
      );
    }
    for (int i = 0; i < SharedPrefsHelper.levelTargets.length; i++) {
      int t = SharedPrefsHelper.levelTargets[i];
      trophies.add(
        TrophyItem(
          id: 'trophy_level_$t',
          title: loc.trophyLevelTitle(t),
          icon: Icons.military_tech,
          rank: determineRank(i / SharedPrefsHelper.levelTargets.length),
        ),
      );
    }
    for (int i = 0; i < SharedPrefsHelper.pointTargets.length; i++) {
      int t = SharedPrefsHelper.pointTargets[i];
      trophies.add(
        TrophyItem(
          id: 'trophy_point_$t',
          title: loc.trophyPointTitle(t),
          icon: Icons.stars,
          rank: determineRank(i / SharedPrefsHelper.pointTargets.length),
        ),
      );
    }
    return trophies;
  }

  // 🌟 各画面から呼び出す「チェック＆表示」メソッド
  static Future<void> checkAndShowTrophies(BuildContext context) async {
    final cumulativeLoginDays =
        await SharedPrefsHelper.loadCumulativeLoginDays();
    final cumulativeShop = await SharedPrefsHelper.loadCumulativeShopCount();
    final currentLevel = await SharedPrefsHelper.loadLevel();
    final cumulativePoints = await SharedPrefsHelper.loadCumulativePoints();

    final unlockedTrophies = await SharedPrefsHelper.loadUnlockedTrophies();
    if (!context.mounted) return;
    final allTrophies = getAllTrophies(context);

    List<TrophyItem> newlyUnlocked = [];

    for (var trophy in allTrophies) {
      if (unlockedTrophies.contains(trophy.id)) continue; // すでに獲得済みならスキップ

      bool isConditionMet = false;
      if (trophy.id.startsWith('trophy_login_')) {
        if (cumulativeLoginDays >= int.parse(trophy.id.split('_').last))
          isConditionMet = true;
      } else if (trophy.id.startsWith('trophy_shop_')) {
        if (cumulativeShop >= int.parse(trophy.id.split('_').last))
          isConditionMet = true;
      } else if (trophy.id.startsWith('trophy_level_')) {
        if (currentLevel >= int.parse(trophy.id.split('_').last))
          isConditionMet = true;
      } else if (trophy.id.startsWith('trophy_point_')) {
        if (cumulativePoints >= int.parse(trophy.id.split('_').last))
          isConditionMet = true;
      }

      if (isConditionMet) {
        newlyUnlocked.add(trophy);
        // 裏側では条件を満たしたすべてのトロフィーを「獲得済み」としてセーブする
        await SharedPrefsHelper.addUnlockedTrophy(trophy.id);
      }
    }

    if (newlyUnlocked.isNotEmpty && context.mounted) {
      // =========================================================
      // 🌟 変更：今回獲得したすべてのトロフィーの中から、たった1つだけを選ぶ
      // =========================================================

      // 優先順位（ランクの高さ）を定義するヘルパー関数
      int getRankScore(TrophyRank rank) {
        switch (rank) {
          case TrophyRank.normal:
            return 1;
          case TrophyRank.bronze:
            return 2;
          case TrophyRank.silver:
            return 3;
          case TrophyRank.gold:
            return 4;
          case TrophyRank.diamond:
            return 5;
        }
      }

      // newlyUnlocked の中から、一番ランクが高いものを探し出す
      TrophyItem bestTrophyToShow = newlyUnlocked.first;
      for (var trophy in newlyUnlocked) {
        if (getRankScore(trophy.rank) > getRankScore(bestTrophyToShow.rank)) {
          bestTrophyToShow = trophy;
        }
      }

      // 絞り込んだ「一番すごいトロフィー」を1つだけダイアログ表示する
      await _showSingleTrophyDialog(context, bestTrophyToShow);
    }
  }

  static Future<void> _showSingleTrophyDialog(
    BuildContext context,
    TrophyItem trophy,
  ) async {
    try {
      SfxManager.instance.playSuccessSound();
    } catch (_) {}

    IconData displayIcon = trophy.icon;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.trophyNewTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: trophy.rank == TrophyRank.diamond
                      ? const Color(0xFFb9f2ff)
                      : trophy.color,
                  width: 4,
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Icon(displayIcon, size: 40, color: trophy.color),
            ),
            const SizedBox(height: 6),
            Text(
              trophy.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.trophyGotMessage,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () {
              try {
                SfxManager.instance.playTapSound();
              } catch (_) {}
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.trophyLater,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                SfxManager.instance.playTapSound();
              } catch (_) {}
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrophyScreen()),
              );
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.trophyGoSee,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
