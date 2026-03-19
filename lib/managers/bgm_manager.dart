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

  // just_audioのプレイヤーを遅延初期化します
  AudioPlayer? _bgmPlayer;
  BgmTrack? _currentTrack;

  AudioPlayer get _player {
    if (_bgmPlayer == null) {
      print("BgmManager: AudioPlayerを新規作成します");
      _bgmPlayer = AudioPlayer();
    }
    return _bgmPlayer!;
  }

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
      if (_bgmPlayer != null && _bgmPlayer!.playing && _currentTrack == track)
        return;

      final trackPath = _getTrackPath(track);

      if (trackPath == null) {
        await stopBgm();
        _currentTrack = track;
        return;
      }
      // just_audioでは、assetsからの読み込みにsetAssetを使います
      await _player.setAsset(trackPath);
      // ループ再生を設定
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
      _currentTrack = track;
    } catch (e) {
      print("BGMの再生エラー: $e");
    }
  }

  Future<void> pause() async {
    try {
      if (_bgmPlayer != null) {
        await _bgmPlayer!.pause();
      }
    } catch (e) {
      print("BGMの一時停止エラー: $e");
    }
  }

  Future<void> resume() async {
    try {
      await _player.play();
    } catch (e) {
      print("BGMの再生エラー: $e");
    }
  }

  Future<void> stopBgm() async {
    try {
      if (_bgmPlayer != null) {
        await _bgmPlayer!.stop();
      }
      _currentTrack = null;
    } catch (e) {
      print("BGMの停止エラー: $e");
    }
  }

  Future<void> dispose() async {
    try {
      if (_bgmPlayer != null) {
        print("BgmManager: AudioPlayerを破棄します");
        await _bgmPlayer!.stop();
        await _bgmPlayer!.dispose();
        _bgmPlayer = null;
      }
    } catch (e) {
      print("BGMの停止エラー: $e");
    }
  }
}
