// lib/screens/timer/roulette_dialog.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../managers/sfx_manager.dart';

class RouletteDialog extends StatefulWidget {
  const RouletteDialog({super.key});

  @override
  State<RouletteDialog> createState() => _RouletteDialogState();
}

class _RouletteDialogState extends State<RouletteDialog> {
  @override
  void initState() {
    super.initState();
    SfxManager.instance.playRouletteMessageSound();
  }

  bool _isSpinning = false;
  String? _resultText;
  int _pointMultiplier = 1;

  void _spin() {
    setState(() {
      _isSpinning = true;
    });

    // 2秒間、回転アニメーションを見せる
    Timer(const Duration(seconds: 2), () {
      // 50%の確率で「あたり」を決定
      final bool isWin = Random().nextBool();

      setState(() {
        _isSpinning = false;
        if (isWin) {
          SfxManager.instance.playRouletteWinSound();
          _resultText = 'おめでとう！\nポイント2ばい！';
          _pointMultiplier = 2; // あたりなら2倍
        } else {
          SfxManager.instance.playRouletteLoseSound();
          _resultText = 'またチャレンジしてね';
          _pointMultiplier = 1; // はずれなら1倍
        }
      });

      // 結果を2.5秒表示したら、自動でダイアログを閉じる
      Timer(const Duration(milliseconds: 2500), () {
        if (mounted) {
          // 閉じる時に、結果（1倍か2倍か）を返す
          Navigator.of(context).pop(_pointMultiplier);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ポイントアップチャンス！'),
      content: SizedBox(
        height: 120,
        child: Center(
          child: _isSpinning
              ? const CircularProgressIndicator() // 回転中のアニメーション
              : _resultText != null
              ? Text(
                  // 結果表示
                  _resultText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Column(
                  // 最初の表示
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('ルーレットをまわす？'),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _spin, child: const Text('まわす！')),
                  ],
                ),
        ),
      ),
    );
  }
}
