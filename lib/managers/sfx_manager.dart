// lib/managers/sfx_manager.dart

import 'dart:async';
import 'dart:math';
import 'package:just_audio/just_audio.dart';

class SfxManager {
  static final SfxManager instance = SfxManager._internal();
  final List<AudioPlayer> _players = [];
  int _currentPlayerIndex = 0;
  static const int _poolSize = 5;

  factory SfxManager() {
    return instance;
  }

  SfxManager._internal();

  // 🌟 複数プレイヤーのプールを使用して、同時に効果音がなってもクラッシュ（PlatformException）を防ぎつつ自然に重ねて再生する
  AudioPlayer get _player {
    if (_players.length <= _currentPlayerIndex) {
      _players.add(AudioPlayer());
    }
    final player = _players[_currentPlayerIndex];
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _poolSize;
    return player;
  }

  // 効果音を再生するための共通メソッド
  Future<void> _playSound(String assetPath) async {
    try {
      await _player.setAsset('assets/$assetPath');
      await _player.play();
    } catch (e) {
      print("効果音の再生エラー ($assetPath): $e");
    }
  }

  // 複数の効果音を順番に再生するためのメソッド
  Future<void> playSequentialSounds(
    List<String> assetPaths, {
    double speed = 1.0,
  }) async {
    try {
      // プレイリストを作成
      final playlist = ConcatenatingAudioSource(
        children: assetPaths
            .map((path) => AudioSource.asset('assets/$path'))
            .toList(),
      );

      await _player.setAudioSource(playlist);
      await _player.setSpeed(speed);
      await _player.play();
    } catch (e) {
      print("連続再生エラー: $e");
    }
  }

  String getVoiceDir(String localeName) {
    if (localeName == 'hi') return 'hindi';
    if (localeName == 'ur') return 'urdu';
    if (localeName == 'bn') return 'bengali';
    if (localeName == 'ar') return 'arabic';
    return 'english';
  }

  void playLocalizedSound(String filename, String locale) {
    if (locale == 'ja') {
      return;
    }
    final String dir = getVoiceDir(locale);
    _playSound('se/$dir/$filename');
  }

  // --- 再生用メソッド群（そのまま） ---
  void playTapSound() => _playSound('se/ボタン.mp3');
  void playSuccessSound() => _playSound('se/ポイントが入る音.mp3');
  void playStartSound() => _playSound('se/「スタート」.mp3');

  void playStartSoundLocalized(String locale) {
    if (locale == 'ja') {
      playStartSound();
    } else {
      playLocalizedSound('lets_go.mp3', locale);
    }
  }

  void playRouletteMessageSound() => _playSound('se/「ボタンをタッチしてね」.mp3');
  void playRouletteMessageSoundLocalized(String locale) {
    if (locale == 'ja') {
      playRouletteMessageSound();
    } else {
      playLocalizedSound('please_touch_the_button.mp3', locale);
    }
  }

  void playRouletteWinSound() => _playSound('se/「大当たり～」.mp3');
  void playRouletteWinSoundLocalized(String locale) {
    if (locale == 'ja') {
      playRouletteWinSound();
    } else {
      playLocalizedSound('jackpot.mp3', locale);
    }
  }

  void playRouletteLoseSound() => _playSound('se/「惜っしーい」.mp3');
  void playRouletteLoseSoundLocalized(String locale) {
    if (locale == 'ja') {
      playRouletteLoseSound();
    } else {
      playLocalizedSound('thats_a_shame.mp3', locale);
    }
  }

  void playTimerLoseSound() => _playSound('se/「頑張ったね」.mp3');
  void playTimerLoseSoundLocalized(String locale) {
    if (locale == 'ja') {
      playTimerLoseSound();
    } else {
      playLocalizedSound('you_did_your_best.mp3', locale);
    }
  }

  void playTimerWinSound() => _playSound('se/ラッパのファンファーレ.mp3');
  void playShopInitSound() => _playSound('se/「いらっしゃいませ！」.mp3');
  void playShopInitSoundLocalized(String locale) {
    if (locale == 'ja') {
      playShopInitSound();
    } else {
      playLocalizedSound('welcome.mp3', locale);
    }
  }

  void playShopBuySound() => _playSound('se/「ありがとうございます！」.mp3');
  void playShopBuySoundLocalized(String locale) {
    if (locale == 'ja') {
      playShopBuySound();
    } else {
      playLocalizedSound('thank_you_very_much.mp3', locale);
    }
  }

  void playTimerTimeUpSound() => _playSound('se/「タイムアップ」.mp3');
  void playTimerTimeUpSoundLocalized(String locale) {
    if (locale == 'ja') {
      playTimerTimeUpSound();
    } else {
      playLocalizedSound('times_up.mp3', locale);
    }
  }

  void playTimeAtoSound() => _playSound('se/「あと」.mp3');
  void playTimeYattaSound() => _playSound('se/「やったーー！」.mp3');
  void playRouletteSpinSound() => _playSound('se/ドラムロール.mp3');
  void playTimerWinSound2() => _playSound('se/歓声と拍手.mp3');

  void playStartSoundEnglish() => playLocalizedSound('lets_go.mp3', 'en');
  void playRouletteMessageSoundEnglish() =>
      playLocalizedSound('please_touch_the_button.mp3', 'en');
  void playRouletteWinSoundEnglish() => playLocalizedSound('jackpot.mp3', 'en');
  void playRouletteLoseSoundEnglish() =>
      playLocalizedSound('thats_a_shame.mp3', 'en');
  void playTimerLoseSoundEnglish() =>
      playLocalizedSound('you_did_your_best.mp3', 'en');
  void playShopInitSoundEnglish() => playLocalizedSound('welcome.mp3', 'en');
  void playShopBuySoundEnglish() =>
      playLocalizedSound('thank_you_very_much.mp3', 'en');
  void playTimerTimeUpSoundEnglish() =>
      playLocalizedSound('times_up.mp3', 'en');

  Future<void> playRandomCheerSound() async {
    try {
      final List<String> cheerSounds = [
        'se/「頑張って！」.mp3',
        'se/ganbare--.mp3',
        'se/「その調子その調子！」.mp3',
        'se/「フレーフレー」.mp3',
      ];
      final randomIndex = Random().nextInt(cheerSounds.length);
      await _playSound(cheerSounds[randomIndex]);
    } catch (e) {
      print("再生エラー: $e");
    }
  }

  Future<void> playRandomSadSound() async {
    try {
      final List<String> cheerSounds = [
        'se/「ううっ…」.mp3',
        'se/「ショックー…」.mp3',
        'se/「そんなあー」.mp3',
      ];
      final randomIndex = Random().nextInt(cheerSounds.length);
      await _playSound(cheerSounds[randomIndex]);
    } catch (e) {
      print("再生エラー: $e");
    }
  }

  Future<void> dispose() async {
    try {
      if (_players.isNotEmpty) {
        print("SfxManager: AudioPlayerを停止します（Singletonのため破棄はしません）");
        for (final player in _players) {
          await player.stop();
        }
        // 🌟 重要: こちらも dispose() しない
      }
    } catch (e) {
      print("効果音プレイヤーの停止エラー: $e");
    }
  }
}
