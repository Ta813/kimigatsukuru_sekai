import 'package:flutter/material.dart';
import 'shared_prefs_helper.dart'; // 🌟 パスはプロジェクトに合わせて調整してください
import '../l10n/app_localizations.dart';

// ランクの定義
enum TrophyRank { normal, bronze, silver, gold, diamond }

class TrophyItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final TrophyRank rank;
  final String requiredMissionId;

  const TrophyItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rank,
    required this.requiredMissionId,
  });

  // ランクに応じた色
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

class TrophyHelper {
  // 🌟 アプリ内のすべてのトロフィーリストを自動生成して返すメソッド
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

    // ログイン
    for (int i = 0; i < SharedPrefsHelper.loginTargets.length; i++) {
      int t = SharedPrefsHelper.loginTargets[i];
      double p = i / SharedPrefsHelper.loginTargets.length;
      trophies.add(
        TrophyItem(
          id: 'trophy_login_$t',
          title: loc.trophyLoginTitle(t).replaceAll('\n', ' '),
          description: loc.trophyLoginDesc(t),
          icon: Icons.calendar_month,
          rank: determineRank(p),
          requiredMissionId: 'mission_login_$t',
        ),
      );
    }
    // 買い物
    for (int i = 0; i < SharedPrefsHelper.shopTargets.length; i++) {
      int t = SharedPrefsHelper.shopTargets[i];
      double p = i / SharedPrefsHelper.shopTargets.length;
      trophies.add(
        TrophyItem(
          id: 'trophy_shop_$t',
          title: loc.trophyShopTitle(t).replaceAll('\n', ' '),
          description: loc.trophyShopDesc(t),
          icon: Icons.storefront,
          rank: determineRank(p),
          requiredMissionId: 'mission_shop_$t',
        ),
      );
    }
    // レベル
    for (int i = 0; i < SharedPrefsHelper.levelTargets.length; i++) {
      int t = SharedPrefsHelper.levelTargets[i];
      double p = i / SharedPrefsHelper.levelTargets.length;
      trophies.add(
        TrophyItem(
          id: 'trophy_level_$t',
          title: loc.trophyLevelTitle(t).replaceAll('\n', ' '),
          description: loc.trophyLevelDesc(t),
          icon: Icons.military_tech,
          rank: determineRank(p),
          requiredMissionId: 'mission_level_$t',
        ),
      );
    }
    // ポイント
    for (int i = 0; i < SharedPrefsHelper.pointTargets.length; i++) {
      int t = SharedPrefsHelper.pointTargets[i];
      double p = i / SharedPrefsHelper.pointTargets.length;
      trophies.add(
        TrophyItem(
          id: 'trophy_point_$t',
          title: loc.trophyPointTitle(t).replaceAll('\n', ' '),
          description: loc.trophyPointDesc(t),
          icon: Icons.stars,
          rank: determineRank(p),
          requiredMissionId: 'mission_points_$t',
        ),
      );
    }

    return trophies;
  }
}
