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
  Future<void> playSequentialSounds(List<String> assetPaths) async {
    try {
      // プレイリストを作成
      final playlist = ConcatenatingAudioSource(
        children: assetPaths
            .map((path) => AudioSource.asset('assets/$path'))
            .toList(),
      );

      // プレイリストをプレイヤーにセットして再生
      await _sfxPlayer.setAudioSource(playlist);
      _sfxPlayer.play();
    } catch (e) {
      print("連続再生エラー: $e");
    }
  }

  // --- ここから再生用のメソッド ---
  // 各メソッドが、ファイルパスを指定して共通メソッドを呼び出します

  void playTapSound() => _playSound('se/ボタン.mp3');
  void playSuccessSound() => _playSound('se/ポイントが入る音.mp3');
  void playStartSound() => _playSound('se/「スタート」.mp3');
  void playRouletteMessageSound() => _playSound('se/「ボタンをタッチしてね」.mp3');
  void playRouletteWinSound() => _playSound('se/「大当たり～」.mp3');
  void playRouletteLoseSound() => _playSound('se/「惜っしーい」.mp3');
  void playTimerLoseSound() => _playSound('se/「頑張ったね」.mp3');
  void playTimerWinSound() => _playSound('se/ラッパのファンファーレ.mp3');
  void playShopInitSound() => _playSound('se/「いらっしゃいませ！」.mp3');
  void playShopBuySound() => _playSound('se/「ありがとうございます！」.mp3');
  void playTimer1Sound() => _playSound('se/「1」.mp3');
  void playTimer2Sound() => _playSound('se/「2」.mp3');
  void playTimer3Sound() => _playSound('se/「3」.mp3');
  void playTimer4Sound() => _playSound('se/「4（よん）」.mp3');
  void playTimer5Sound() => _playSound('se/「5」.mp3');
  void playTimer10Sound() => _playSound('se/「10（じゅう↓）」.mp3');
  void playTimer1XSound() => _playSound('se/「10（じゅう↑）」.mp3');
  void playTimer20Sound() => _playSound('se/「20」.mp3');
  void playTimer2XSound() => _playSound('se/「20（に↑じゅう↓）」.mp3');
  void playTimer30Sound() => _playSound('se/「30」.mp3');
  void playTimerCountDownSound() =>
      _playSound('se/「10、9、8、7、6、5、4、3、2、1、0」.mp3');
  void playTimerTimeUpSound() => _playSound('se/「タイムアップ」.mp3');
  void playTimeAtoSound() => _playSound('se/「あと」.mp3');
  void playTimeMinuteSound() => _playSound('se/「分（ふん）」.mp3');

  // アプリ終了時にリソースを解放する
  void dispose() {
    _sfxPlayer.dispose();
  }
}
