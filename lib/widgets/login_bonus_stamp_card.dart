import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'poyon_animation.dart';

class LoginBonusStampCard extends StatelessWidget {
  final int currentLoginCount; // 現在の連続ログイン日数 (1〜7)

  const LoginBonusStampCard({super.key, required this.currentLoginCount});

  // 💡 日数に応じて付与するポイントを返す関数
  int _getPointsForDay(int day) {
    if (day == 7) return 200;
    if (day == 3) return 80;
    return 20; // 基本ポイント
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.orange[50], // 優しい背景色
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.loginBonusWeeklyTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          Text(
            l10n.loginBonusResetNote,
            style: TextStyle(fontSize: 12, color: Colors.orange[700]),
          ),
          const SizedBox(height: 16),
          // 💡 FittedBoxで包むことで、横幅が狭い時に「自動的に縮小」して1列に収める
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                int day = index + 1;
                bool isCleared = day <= currentLoginCount;
                int points = _getPointsForDay(day);
                bool isDay3 = day == 3;
                bool isDay7 = day == 7;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildStampItem(
                    context,
                    day,
                    isCleared,
                    points,
                    isDay3,
                    isDay7,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // 1個のスタンプを作るウィジェット
  Widget _buildStampItem(
    BuildContext context,
    int day,
    bool isCleared,
    int points,
    bool isDay3,
    bool isDay7,
  ) {
    final l10n = AppLocalizations.of(context)!;

    // 🎨 見た目の出し分け設定（縦方向の見切れを防ぐため、全体的に高さを抑える）
    double size = isDay7 ? 54.0 : (isDay3 ? 46.0 : 40.0);
    double itemWidth = isDay7 ? 60.0 : 48.0;

    // 🌟 今日のスタンプかどうかを判定
    bool isToday = day == currentLoginCount;

    Color baseColor = isDay7
        ? Colors.amber
        : (isDay3
              ? Colors.pinkAccent
              : isToday
              ? Colors.green
              : Colors.orange);

    // 7日目専用のド派手なグラデーション
    Gradient? bgGradient = (isDay7 && isCleared)
        ? const LinearGradient(
            colors: [Colors.yellow, Colors.green, Colors.redAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;

    // 中に入るアイコン（チェック、星、王冠）
    Widget iconWidget = Icon(
      isDay7 ? Icons.workspace_premium : (isDay3 ? Icons.star : Icons.check),
      color: Colors.white,
      size: isDay7 ? 32 : 24,
    );

    return SizedBox(
      width: itemWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 獲得ポイント数
          Text(
            '+${points}P',
            style: TextStyle(
              fontSize: isDay7 ? 12 : 10,
              fontWeight: FontWeight.bold,
              color: isDay7 ? Colors.redAccent : Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          // スタンプ本体
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: isDay7 ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: isDay7 ? BorderRadius.circular(10) : null,
              color: isCleared
                  ? (bgGradient == null ? baseColor : null)
                  : Colors.grey[300],
              gradient: isCleared ? bgGradient : null,
              boxShadow: isCleared
                  ? [
                      BoxShadow(
                        color: baseColor.withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              // 🌟 ここからがアニメーションの魔法です！
              child: isCleared
                  ? (isToday
                        // 今日の分だけ「ぽよんっ！」と継続的にアニメーションさせる
                        ? PoyonAnimation(child: iconWidget)
                        // 過去の分は普通に表示するだけ
                        : iconWidget)
                  // まだクリアしていない日
                  : Text(
                      '$day',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          // 「〇日目」
          Text(
            l10n.loginBonusDay(day),
            style: TextStyle(
              fontSize: 10,
              color: isCleared ? Colors.green[800] : Colors.grey[600],
              fontWeight: isCleared ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
