// lib/bgm_manager.dart

import 'dart:async';
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
  AudioPlayer? _bgmPlayer;

  factory BgmManager() {
    return instance;
  }

  BgmManager._internal();

  // 🌟 複雑なCompleterを廃止し、シンプルで安全な遅延初期化に変更
  AudioPlayer get _player {
    _bgmPlayer ??= AudioPlayer();
    return _bgmPlayer!;
  }

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
        return null;
    }
  }

  Future<void> play(BgmTrack track) async {
    try {
      print("BgmManager.play: $track");
      final trackPath = _getTrackPath(track);

      if (trackPath == null) {
        await stopBgm();
        return;
      }

      print("BgmManager.play: アセットをロード中... $trackPath");
      await _player.setAsset(trackPath);
      await _player.setLoopMode(LoopMode.one);
      await _player.play();

      print("BgmManager.play: 再生開始しました: $track");
    } catch (e) {
      print("BGMの再生エラー ($track): $e");
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
      if (_bgmPlayer != null) {
        await _bgmPlayer!.play();
      }
    } catch (e) {
      print("BGMの再開エラー: $e");
    }
  }

  Future<void> stopBgm() async {
    try {
      if (_bgmPlayer != null) {
        await _bgmPlayer!.stop();
      }
    } catch (e) {
      print("BGMの停止エラー: $e");
    }
  }

  Future<void> dispose() async {
    try {
      if (_bgmPlayer != null) {
        print("BgmManager: AudioPlayerを停止します（Singletonのため破棄はしません）");
        await _bgmPlayer!.stop();
        // 🌟 重要: 参照を切ったり dispose() しないことで、
        // アプリ起動中に発生する「重複初期化クラッシュ」を完全に防ぎます。
      }
    } catch (e) {
      print("BGMの破棄エラー: $e");
    }
  }
}
