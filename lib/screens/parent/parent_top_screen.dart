// lib/screens/parent_mode/parent_top_screen.dart

import 'package:flutter/material.dart';
import 'regular_promise_settings_screen.dart';
import 'emergency_promise_screen.dart';

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
            const SizedBox(height: 20),
            // 「定例のやくそく設定」ボタン
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegularPromiseSettingsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                // main.dartで設定したテーマカラーが適用されます
                padding: const EdgeInsets.symmetric(vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('定例のやくそく設定'),
            ),
            const SizedBox(height: 20),
            // 「緊急のやくそく設定」ボタン
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyPromiseScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('緊急のやくそく設定'),
            ),
          ],
        ),
      ),
    );
  }
}
