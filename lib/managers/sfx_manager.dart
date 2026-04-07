// lib/managers/sfx_manager.dart

import 'dart:math';

import 'package:just_audio/just_audio.dart';

class SfxManager {
  // Singleton（このクラスの唯一のインスタンス）を生成
  static final SfxManager instance = SfxManager._internal();

  // 効果音専用のプレイヤーを遅延初期化します
  AudioPlayer? _sfxPlayer;

  AudioPlayer get _player {
    if (_sfxPlayer == null) {
      print("SfxManager: AudioPlayerを新規作成します");
      _sfxPlayer = AudioPlayer();
    }
    return _sfxPlayer!;
  }

  factory SfxManager() {
    return instance;
  }
  SfxManager._internal();

  // 効果音を再生するための共通メソッド
  Future<void> _playSound(String assetPath) async {
    try {
      await _player.stop();
      await _player.setAsset('assets/$assetPath');
      await _player.play();
    } catch (e) {
      // もしエラーが出た場合、コンソールに表示
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

      // プレイリストをプレイヤーにセットして再生
      await _player.stop();
      await _player.setAudioSource(playlist);
      await _player.setSpeed(speed);
      await _player.play();
    } catch (e) {
      print("連続再生エラー: $e");
    }
  }

  // ロケールに基づいて、ボイス（音声）が入っているディレクトリ名を返します
  String getVoiceDir(String localeName) {
    if (localeName == 'hi') return 'hindi';
    if (localeName == 'ur') return 'urdu';
    if (localeName == 'bn') return 'bengali';
    if (localeName == 'ar') return 'arabic';
    return 'english'; // デフォルトはenglish
  }

  // 言語に応じた効果音を再生するための汎用メソッド
  void playLocalizedSound(String filename, String locale) {
    if (locale == 'ja') {
      // 日本語の場合は各メソッドで個別に定義（日本語特有のファイル名のため）
      return;
    }
    final String dir = getVoiceDir(locale);
    _playSound('se/$dir/$filename');
  }

  // --- ここから再生用のメソッド ---

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

  // 互換性のための既存メソッド（内部でLocalized版を呼ぶように修正）
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

  // アプリ終了時にリソースを解放する
  void dispose() async {
    try {
      if (_sfxPlayer != null) {
        print("SfxManager: AudioPlayerを破棄します");
        await _sfxPlayer!.stop();
        await _sfxPlayer!.dispose();
        _sfxPlayer = null;
      }
    } catch (e) {
      print("効果音プレイヤーの停止エラー: $e");
    }
  }
}
