// lib/sfx_manager.dart

import 'package:just_audio/just_audio.dart';

class SfxManager {
  // Singleton（このクラスの唯一のインスタンス）を生成
  static final SfxManager instance = SfxManager._internal();

  // 効果音専用のプレイヤー (just_audio)
  final AudioPlayer _sfxPlayer = AudioPlayer();

  factory SfxManager() {
    return instance;
  }
  SfxManager._internal();

  // 効果音を再生するための共通メソッド
  Future<void> _playSound(String assetPath) async {
    try {
      // just_audioでは、アセットパスの先頭に'assets/'をつけます
      await _sfxPlayer.setAsset('assets/$assetPath');
      _sfxPlayer.play();
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
      await _sfxPlayer.setAudioSource(playlist);
      await _sfxPlayer.setSpeed(speed);
      await _sfxPlayer.play();
    } catch (e) {
      print("連続再生エラー: $e");
    }
  }

  // --- ここから再生用のメソッド ---
  // 各メソッドが、ファイルパスを指定して共通メソッドを呼び出します

  void playTapSound() => _playSound('se/ボタン.mp3');
  void playSuccessSound() => _playSound('se/ポイントが入る音.mp3');
  void playStartSound() => _playSound('se/「スタート」.mp3');
  void playStartSoundEnglish() => _playSound('se/english/lets_go.mp3');
  void playRouletteMessageSound() => _playSound('se/「ボタンをタッチしてね」.mp3');
  void playRouletteMessageSoundEnglish() =>
      _playSound('se/english/please_touch_the_button.mp3');
  void playRouletteWinSound() => _playSound('se/「大当たり～」.mp3');
  void playRouletteWinSoundEnglish() => _playSound('se/english/jackpot.mp3');
  void playRouletteLoseSound() => _playSound('se/「惜っしーい」.mp3');
  void playRouletteLoseSoundEnglish() =>
      _playSound('se/english/thats_a_shame.mp3');
  void playTimerLoseSound() => _playSound('se/「頑張ったね」.mp3');
  void playTimerLoseSoundEnglish() =>
      _playSound('se/english/you_did_your_best.mp3');
  void playTimerWinSound() => _playSound('se/ラッパのファンファーレ.mp3');
  void playShopInitSound() => _playSound('se/「いらっしゃいませ！」.mp3');
  void playShopInitSoundEnglish() => _playSound('se/english/welcome.mp3');
  void playShopBuySound() => _playSound('se/「ありがとうございます！」.mp3');
  void playShopBuySoundEnglish() =>
      _playSound('se/english/thank_you_very_much.mp3');
  void playTimerTimeUpSound() => _playSound('se/「タイムアップ」.mp3');
  void playTimerTimeUpSoundEnglish() => _playSound('se/english/times_up.mp3');
  void playTimeAtoSound() => _playSound('se/「あと」.mp3');

  // アプリ終了時にリソースを解放する
  void dispose() {
    _sfxPlayer.dispose();
  }
}
