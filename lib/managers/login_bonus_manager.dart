import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/shared_prefs_helper.dart';
import '../l10n/app_localizations.dart';
import '../widgets/login_bonus_stamp_card.dart';

class LoginBonusManager {
  // 💡 日数に応じて付与するポイントを返す関数
  int _getPointsForDay(int day) {
    if (day == 7) return 200;
    if (day == 3) return 80;
    return 20; // 基本ポイント
  }

  // 💡 便利関数：その日付が含まれる週の「月曜日」の0時0分を返す
  DateTime _getMonday(DateTime date) {
    // weekday: 1 (Mon) to 7 (Sun)
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: date.weekday - 1));
  }

  // 💡 便利関数：同じ日かどうかを判定
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // アプリ起動時（ホーム画面表示時など）に呼ぶメソッド
  Future<int> checkLoginBonus(BuildContext context) async {
    int pointsEarned = 0;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // 前回ログインした日時を取得
    final lastLoginStr = prefs.getString('last_login_date');
    int loginCount = prefs.getInt('weekly_login_count') ?? 0;

    if (lastLoginStr == null) {
      // 🌟 完全な初回ログイン
      loginCount = 1;
      pointsEarned = await _showBonusDialog(
        context,
        loginCount,
      ); // ボーナス付与＆ダイアログ表示
    } else {
      final lastLogin = DateTime.parse(lastLoginStr);

      if (!_isSameDay(now, lastLogin)) {
        // 🌟 違う日（今日初めてのログイン）の場合

        DateTime thisMonday = _getMonday(now);
        DateTime lastMonday = _getMonday(lastLogin);

        if (_isSameDay(thisMonday, lastMonday)) {
          // 同じ週の中でのログイン（カウントアップ）
          loginCount += 1;
          // 7日を超えたら7に固定（またはリセットも検討可能だが、ここではカウントアップを継続するか7で止める）
          if (loginCount > 7) loginCount = 7;
        } else {
          // 違う週になった（月曜を跨いだ）のでリセット！
          loginCount = 1;
        }

        pointsEarned = await _showBonusDialog(
          context,
          loginCount,
        ); // ボーナス付与＆ダイアログ表示
      } else {
        // 🌟 今日すでにログイン済み（何もしない）
        print("今日はすでにログインボーナスを受け取っています");
      }
    }

    // 最後に「今日」を保存
    await prefs.setString('last_login_date', now.toIso8601String());
    await prefs.setInt('weekly_login_count', loginCount);

    return pointsEarned;
  }

  Future<int> _showBonusDialog(BuildContext context, int count) async {
    // ポイント付与
    int pointsToAdd = _getPointsForDay(count);
    int currentPoints = await SharedPrefsHelper.loadPoints();
    await SharedPrefsHelper.savePoints(currentPoints + pointsToAdd);

    if (!context.mounted) return 0;

    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        // 画面幅に応じて最大480pxまでの広い幅を確保する
        final dialogWidth = screenWidth > 520 ? 480.0 : screenWidth * 0.9;

        return AlertDialog(
          // ダイアログ自体の外側余白を適切に設定
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          // 縦方向にはみ出さないようにスクロール可能にする
          content: SingleChildScrollView(
            clipBehavior: Clip.none,
            child: SizedBox(
              width: dialogWidth,
              child: LoginBonusStampCard(currentLoginCount: count),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 左側の衣装画像
                Image.asset('assets/images/clothes_dress_red.gif', height: 60),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    FirebaseAnalytics.instance.logEvent(
                      name: 'login_bonus_received',
                      parameters: {'day': count, 'points_added': pointsToAdd},
                    );
                    Navigator.pop(context); // ダイアログを閉じる
                    // 受け取り処理などをここに書く
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7043),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFFFF7043).withOpacity(0.5),
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    l10n.loginBonusReceive,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 右側のキャラクター画像
                Image.asset('assets/images/character_kuma.gif', height: 60),
              ],
            ),
          ],
        );
      },
    );

    return pointsToAdd;
  }
}
