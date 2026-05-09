// lib/screens/help_menu_dialog.dart

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
        padding: const EdgeInsets.all(12.0),
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
            const SizedBox(height: 14),

            // 🌟 追加：「あそびかた」ボタン（一番上に横長で配置）
            SizedBox(
              width: double.infinity,
              child: _buildMenuButton(
                context: context,
                title: l10n.helpMenuRules,
                icon: Icons.menu_book,
                color: const Color(0xFF4DD0E1), // 爽やかなシアン系
                resultKey: 'rules',
              ),
            ),
            const SizedBox(height: 12),

            // 選択肢1・2（2段目）
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
                    title: l10n.helpMenuCustomize,
                    icon: Icons.checkroom,
                    color: const Color(0xFFFFB74D), // イエロー系
                    resultKey: 'dressup',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 選択肢3・4（3段目）
            Row(
              children: [
                Expanded(
                  child: _buildMenuButton(
                    context: context,
                    title: l10n.helpMenuPromiseSettings,
                    icon: Icons.settings,
                    color: const Color(0xFFBA68C8), // パープル系
                    resultKey: 'promise_settings',
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
        minimumSize: const Size(0, 45), // 少し高さを確保
      ),
      onPressed: () {
        Navigator.of(context).pop(resultKey);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24), // アイコンサイズを少し調整
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
