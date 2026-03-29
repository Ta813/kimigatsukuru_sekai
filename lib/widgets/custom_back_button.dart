import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class CustomBackButton extends StatelessWidget {
  final BuildContext? customContext;
  const CustomBackButton({super.key, this.customContext});

  @override
  Widget build(BuildContext context) {
    // If a custom context is not provided, use the inner one.
    // However, for l10n, the inner context provides the standard locale unless restricted.
    return InkWell(
      onTap: () => Navigator.pop(customContext ?? context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back),
            Text(
              AppLocalizations.of(context)!.backButtonLabel,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
