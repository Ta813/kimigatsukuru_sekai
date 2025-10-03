// lib/bgm_manager.dart

import 'package:just_audio/just_audio.dart';

enum BgmTrack {
  main,
  fun,
  cute,
  relaxing,
  energetic,
  sparkly,
  none,
  focus_original,
  focus_cute,
  focus_cool,
  focus_hurry,
  focus_nature,
  focus_relaxing,
  focus_none,
}

class BgmManager {
  static final BgmManager instance = BgmManager._internal();

  // just_audioのプレイヤーを使います
  final AudioPlayer _bgmPlayer = AudioPlayer();
  BgmTrack? _currentTrack;

  factory BgmManager() {
    return instance;
  }

  BgmManager._internal();

  String? _getTrackPath(BgmTrack track) {
    switch (track) {
      case BgmTrack.main:
        return 'assets/audio/bgm_home.mp3';
      case BgmTrack.fun:
        return 'assets/audio/bgm_home_tanoshii.mp3';
      case BgmTrack.cute:
        return 'assets/audio/bgm_home_kawaii.mp3';
      case BgmTrack.relaxing:
        return 'assets/audio/bgm_home_yuttari.mp3';
      case BgmTrack.energetic:
        return 'assets/audio/bgm_home_genki.mp3';
      case BgmTrack.sparkly:
        return 'assets/audio/bgm_home_kirakira.mp3';
      case BgmTrack.focus_original:
        return 'assets/audio/bgm_task.mp3';
      case BgmTrack.focus_cute:
        return 'assets/audio/bgm_task_kawaii.mp3';
      case BgmTrack.focus_cool:
        return 'assets/audio/bgm_task_kakkoii.mp3';
      case BgmTrack.focus_hurry:
        return 'assets/audio/bgm_task_isogu.mp3';
      case BgmTrack.focus_nature:
        return 'assets/audio/bgm_task_sizen.mp3';
      case BgmTrack.focus_relaxing:
        return 'assets/audio/bgm_task_kokotiyoi.mp3';
      default:
        return null; // ★ BGMなしの場合はnullを返す
    }
  }

  Future<void> play(BgmTrack track) async {
    try {
      if (_bgmPlayer.playing && _currentTrack == track) return;

      final trackPath = _getTrackPath(track);

      if (trackPath == null) {
        await stopBgm();
        _currentTrack = track;
        return;
      }
      // just_audioでは、assetsからの読み込みにsetAssetを使います
      await _bgmPlayer.setAsset(trackPath);
      // ループ再生を設定
      await _bgmPlayer.setLoopMode(LoopMode.one);
      _bgmPlayer.play();
      _currentTrack = track;
    } catch (e) {
      print("BGMの再生エラー: $e");
    }
  }

  Future<void> pause() async {
    try {
      await _bgmPlayer.pause();
    } catch (e) {
      print("BGMの一時停止エラー: $e");
    }
  }

  Future<void> resume() async {
    try {
      _bgmPlayer.play();
    } catch (e) {
      print("BGMの再生エラー: $e");
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
      _currentTrack = null;
    } catch (e) {
      print("BGMの停止エラー: $e");
    }
  }

  void dispose() {
    _bgmPlayer.dispose();
  }
}
