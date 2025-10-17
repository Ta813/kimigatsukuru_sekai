// lib/screens/timer/roulette_dialog.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../managers/sfx_manager.dart';
import '../../l10n/app_localizations.dart';

class RouletteDialog extends StatefulWidget {
  final int basePoints;

  const RouletteDialog({super.key, required this.basePoints});

  @override
  State<RouletteDialog> createState() => _RouletteDialogState();
}

class _RouletteDialogState extends State<RouletteDialog> {
  int _playerLevel = 1;
  double _winPointMultiplier = 2.0;

  @override
  void initState() {
    super.initState();
    _loadDisplay();
  }

  bool _hasPlayedInitialSound = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ★サウンドがまだ再生されていなければ
    if (!_hasPlayedInitialSound) {
      final lang = AppLocalizations.of(context)!.localeName;
      if (lang == 'ja') {
        try {
          SfxManager.instance.playRouletteMessageSound();
        } catch (e) {
          // エラーが発生した場合
          print('再生エラー: $e');
        }
      } else {
        final List<String> soundsToPlay = [];
        soundsToPlay.addAll(['se/english/please_touch_the_button.mp3']);
        try {
          SfxManager.instance.playSequentialSounds(soundsToPlay);
        } catch (e) {
          // エラーが発生した場合
          print('再生エラー: $e');
        }
      }
      _hasPlayedInitialSound = true; // ★再生済みの旗を立てる
    }
  }

  bool _isSpinning = false;
  String? _resultText;
  double _pointMultiplier = 1;

  Future<void> _loadDisplay() async {
    // 現在のプレイヤーレベルを取得
    _playerLevel = await SharedPrefsHelper.loadLevel();
    // レベルに応じて倍率を決定
    setState(() {
      _winPointMultiplier = 2.0 + (_playerLevel - 1) * 0.1;
    });
  }

  void _spin() async {
    SfxManager.instance.playRouletteSpinSound();

    setState(() {
      _isSpinning = true;
    });

    // 2秒間、回転アニメーションを見せる
    Timer(const Duration(seconds: 4), () {
      // 50%の確率で「あたり」を決定
      final bool isWin = Random().nextBool();

      setState(() {
        _isSpinning = false;
        if (isWin) {
          final lang = AppLocalizations.of(context)!.localeName;
          if (lang == 'ja') {
            try {
              SfxManager.instance.playRouletteWinSound();
            } catch (e) {
              // エラーが発生した場合
              print('再生エラー: $e');
            }
          } else {
            final List<String> soundsToPlay = [];
            soundsToPlay.addAll(['se/english/jackpot.mp3']);
            try {
              SfxManager.instance.playSequentialSounds(soundsToPlay);
            } catch (e) {
              // エラーが発生した場合
              print('再生エラー: $e');
            }
          }
          _resultText = AppLocalizations.of(context)!.rouletteCongrats;

          // レベルに応じて倍率を決定
          _pointMultiplier = _winPointMultiplier;
        } else {
          final lang = AppLocalizations.of(context)!.localeName;
          if (lang == 'ja') {
            try {
              SfxManager.instance.playRouletteLoseSound();
            } catch (e) {
              // エラーが発生した場合
              print('再生エラー: $e');
            }
          } else {
            final List<String> soundsToPlay = [];
            soundsToPlay.addAll(['se/english/thats_a_shame.mp3']);
            try {
              SfxManager.instance.playSequentialSounds(soundsToPlay);
            } catch (e) {
              // エラーが発生した場合
              print('再生エラー: $e');
            }
          }
          _resultText = AppLocalizations.of(context)!.rouletteTryAgain;
          _pointMultiplier = 1; // はずれなら1倍
        }
      });

      // 結果を2.5秒表示したら、自動でダイアログを閉じる
      Timer(const Duration(milliseconds: 3000), () {
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
        height: 200,
        child: Center(
          child: _isSpinning
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/slot_spinning.gif', height: 150),
                    const SizedBox(height: 43),
                  ],
                )
              : _resultText != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      _pointMultiplier > 1
                          ? 'assets/images/slot_win.png'
                          : 'assets/images/slot_lose.png',
                      height: 150,
                    ),
                    Text(
                      // 結果表示
                      _resultText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                                '${(widget.basePoints * _winPointMultiplier).floor().toString()} ${AppLocalizations.of(context)!.points}',
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
