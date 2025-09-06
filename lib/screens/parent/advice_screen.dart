// lib/screens/parent_mode/advice_screen.dart

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class AdviceScreen extends StatelessWidget {
  const AdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ★ローカライズされた文字列を使いやすくするために、変数に入れておく
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adviceScreenTitle), // ★翻訳キーを使用
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adviceMainTitle, // ★翻訳キーを使用
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AdvicePoint(
              icon: Icons.people_outline,
              title: l10n.advice1Title, // ★翻訳キーを使用
              description: l10n.advice1Desc, // ★翻訳キーを使用
            ),
            AdvicePoint(
              icon: Icons.child_care,
              title: l10n.advice2Title, // ★翻訳キーを使用
              description: l10n.advice2Desc, // ★翻訳キーを使用
            ),
            AdvicePoint(
              icon: Icons.timer,
              title: l10n.advice3Title, // ★翻訳キーを使用
              description: l10n.advice3Desc, // ★翻訳キーを使用
            ),
            AdvicePoint(
              icon: Icons.star,
              title: l10n.advice4Title, // ★翻訳キーを使用
              description: l10n.advice4Desc, // ★翻訳キーを使用
            ),
            AdvicePoint(
              icon: Icons.comment,
              title: l10n.advice5Title, // ★翻訳キーを使用
              description: l10n.advice5Desc, // ★翻訳キーを使用
            ),
          ],
        ),
      ),
    );
  }
}

// アドバイスの各項目をきれいに表示するための共通ウィジェット
class AdvicePoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const AdvicePoint({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
