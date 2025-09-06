// lib/screens/timer/roulette_dialog.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../managers/sfx_manager.dart';
import '../../l10n/app_localizations.dart';

class RouletteDialog extends StatefulWidget {
  final int basePoints;

  const RouletteDialog({super.key, required this.basePoints});

  @override
  State<RouletteDialog> createState() => _RouletteDialogState();
}

class _RouletteDialogState extends State<RouletteDialog> {
  @override
  void initState() {
    super.initState();
  }

  bool _hasPlayedInitialSound = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ★サウンドがまだ再生されていなければ
    if (!_hasPlayedInitialSound) {
      final lang = AppLocalizations.of(context)!.localeName;
      if (lang == 'ja') {
        SfxManager.instance.playRouletteMessageSound();
      } else {
        final List<String> soundsToPlay = [];
        soundsToPlay.addAll(['se/english/please_touch_the_button.mp3']);
        SfxManager.instance.playSequentialSounds(soundsToPlay);
      }
      _hasPlayedInitialSound = true; // ★再生済みの旗を立てる
    }
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
          final lang = AppLocalizations.of(context)!.localeName;
          if (lang == 'ja') {
            SfxManager.instance.playRouletteWinSound();
          } else {
            final List<String> soundsToPlay = [];
            soundsToPlay.addAll(['se/english/jackpot.mp3']);
            SfxManager.instance.playSequentialSounds(soundsToPlay);
          }
          _resultText = AppLocalizations.of(context)!.rouletteCongrats;
          _pointMultiplier = 2; // あたりなら2倍
        } else {
          final lang = AppLocalizations.of(context)!.localeName;
          if (lang == 'ja') {
            SfxManager.instance.playRouletteLoseSound();
          } else {
            final List<String> soundsToPlay = [];
            soundsToPlay.addAll(['se/english/thats_a_shame.mp3']);
            SfxManager.instance.playSequentialSounds(soundsToPlay);
          }
          _resultText = AppLocalizations.of(context)!.rouletteTryAgain;
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
      title: Text(AppLocalizations.of(context)!.rouletteTitle),
      content: SizedBox(
        height: 150,
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
                    Text(AppLocalizations.of(context)!.rouletteQuestion),
                    const SizedBox(height: 20),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(color: Colors.grey[600]),
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(context)!.rouletteWin,
                          ),
                          TextSpan(
                            text:
                                '${widget.basePoints * 2} ${AppLocalizations.of(context)!.points}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          TextSpan(
                            text: AppLocalizations.of(context)!.rouletteLose,
                          ),
                          TextSpan(
                            text:
                                '${widget.basePoints} ${AppLocalizations.of(context)!.points}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _spin,
                      child: Text(AppLocalizations.of(context)!.rouletteSpin),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
