// lib/screens/parent_mode/parent_top_screen.dart

import 'package:flutter/material.dart';
import 'regular_promise_settings_screen.dart';
import 'emergency_promise_screen.dart';
import '../../managers/sfx_manager.dart';
import '../../widgets/ad_banner.dart';
import 'advice_screen.dart';

class ParentTopScreen extends StatelessWidget {
  const ParentTopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('おやが見る画面')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // 画面いっぱいに広げる
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('最初にお読みください'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdviceScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                textStyle: const TextStyle(fontSize: 16),
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 10),
            // 「定例のやくそく設定」ボタン
            ElevatedButton(
              onPressed: () {
                SfxManager.instance.playTapSound();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegularPromiseSettingsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                // main.dartで設定したテーマカラーが適用されます
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('定例のやくそく設定'),
            ),
            const SizedBox(height: 10),
            // 「緊急のやくそく設定」ボタン
            ElevatedButton(
              onPressed: () {
                SfxManager.instance.playTapSound();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyPromiseScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('緊急のやくそく設定'),
            ),
          ],
        ),
      ),
      // 画面下部にバナーを設置
      bottomNavigationBar: const AdBanner(),
    );
  }
}
