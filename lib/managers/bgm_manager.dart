// lib/bgm_manager.dart

import 'package:just_audio/just_audio.dart';

enum BgmTrack { main, focus }

class BgmManager {
  static final BgmManager instance = BgmManager._internal();

  // just_audioのプレイヤーを使います
  final AudioPlayer _bgmPlayer = AudioPlayer();
  BgmTrack? _currentTrack;

  factory BgmManager() {
    return instance;
  }

  BgmManager._internal();

  Future<void> play(BgmTrack track) async {
    if (_bgmPlayer.playing && _currentTrack == track) return;

    String filePath;
    switch (track) {
      case BgmTrack.main:
        filePath = 'assets/audio/bgm_home.mp3';
        break;
      case BgmTrack.focus:
        filePath = 'assets/audio/bgm_task.mp3';
        break;
    }

    try {
      // just_audioでは、assetsからの読み込みにsetAssetを使います
      await _bgmPlayer.setAsset(filePath);
      // ループ再生を設定
      await _bgmPlayer.setLoopMode(LoopMode.one);
      _bgmPlayer.play();
      _currentTrack = track;
    } catch (e) {
      print("BGMの再生エラー: $e");
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
    _currentTrack = null;
  }

  void dispose() {
    _bgmPlayer.dispose();
  }
}
