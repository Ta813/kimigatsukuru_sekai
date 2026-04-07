import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class HelpMenuDialog extends StatelessWidget {
  const HelpMenuDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0), // まるみを持たせて優しい印象に
      ),
      backgroundColor: const Color(0xFFFFF4E6), // 背景は温かみのある薄いベージュ
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // タイトル
            Text(
              l10n.helpMenuTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8D6E63), // ブラウン系の優しい文字色
              ),
            ),
            const SizedBox(height: 6),

            // 選択肢1・2（1段目）
            Row(
              children: [
                Expanded(
                  child: _buildMenuButton(
                    context: context,
                    title: l10n.helpMenuYakusoku,
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFFFF8A65), // オレンジ系
                    resultKey: 'yakusoku',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMenuButton(
                    context: context,
                    title: l10n.helpMenuShop,
                    icon: Icons.storefront,
                    color: const Color(0xFF4FC3F7), // 水色系
                    resultKey: 'shop',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // 選択肢3・4（2段目）
            Row(
              children: [
                Expanded(
                  child: _buildMenuButton(
                    context: context,
                    title: l10n.helpMenuCustomize,
                    icon: Icons.checkroom,
                    color: const Color(0xFFFFB74D), // イエロー系
                    resultKey: 'dressup',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMenuButton(
                    context: context,
                    title: l10n.helpMenuOthers,
                    icon: Icons.more_horiz,
                    color: const Color(0xFF81C784), // グリーン系
                    resultKey: 'others',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // 閉じるボタン
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.helpMenuClose,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ボタンを生成する共通メソッド
  Widget _buildMenuButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required String resultKey,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        minimumSize: const Size(0, 80), // 縦に少し高さを出す
      ),
      onPressed: () {
        Navigator.of(context).pop(resultKey);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
