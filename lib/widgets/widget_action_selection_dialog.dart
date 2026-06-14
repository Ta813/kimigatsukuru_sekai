// lib/widgets/widget_action_selection_dialog.dart

import 'package:flutter/material.dart';
import 'package:kimigatsukuru_sekai/l10n/app_localizations.dart';

class WidgetActionSelectionDialog extends StatelessWidget {
  final VoidCallback onGoHome;
  final VoidCallback onGoSettings;
  final VoidCallback onGoPromise;

  const WidgetActionSelectionDialog({
    super.key,
    required this.onGoHome,
    required this.onGoSettings,
    required this.onGoPromise,
  });

  static void show({
    required BuildContext context,
    required VoidCallback onGoHome,
    required VoidCallback onGoSettings,
    required VoidCallback onGoPromise,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WidgetActionSelectionDialog(
        onGoHome: onGoHome,
        onGoSettings: onGoSettings,
        onGoPromise: onGoPromise,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // L10nを取得
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.widgetActionWhatToDo,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildOptionButton(
              icon: Icons.home,
              color: Colors.green,
              text: l10n.widgetActionGoHome,
              onTap: onGoHome,
            ),
            const SizedBox(height: 12),
            _buildOptionButton(
              icon: Icons.settings,
              color: Colors.blueAccent,
              text: l10n.widgetActionSettings,
              onTap: onGoSettings,
            ),
            const SizedBox(height: 12),
            _buildOptionButton(
              icon: Icons.play_circle_fill,
              color: Colors.orange,
              text: l10n.widgetActionStartPromise,
              onTap: onGoPromise,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
