// lib/bgm_manager.dart

import 'package:flutter/services.dart';
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

  // just_audioのプレイヤーを管理します
  AudioPlayer? _bgmPlayer;
  Future<AudioPlayer>? _initFuture;

  // 外部からのアクセス用ゲッターは修正
  // プレイヤーが必要な場合は await _ensurePlayer() を使うように統一します
  Future<AudioPlayer> _ensurePlayer() async {
    return _initFuture ??= _init();
  }

  Future<AudioPlayer> _init() async {
    try {
      print("BgmManager: AudioPlayerを新規作成します");
      final player = AudioPlayer();
      _bgmPlayer = player;
      return player;
    } on PlatformException catch (e) {
      print("BgmManager: AudioPlayer作成中にプラットフォーム例外が発生しました: $e");
      _initFuture = null; // 失敗時は次回復帰できるようにリセット
      rethrow;
    } catch (e) {
      print("BgmManager: AudioPlayer作成中に予期せぬエラーが発生しました: $e");
      _initFuture = null;
      rethrow;
    }
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

  BgmTrack? _currentTrack;

  Future<void> play(BgmTrack track) async {
    try {
      print("BgmManager.play: $track (現在のトラック: $_currentTrack)");

      // すでに同じトラックを再生中の場合は何もしない（二重再生・カクつき・エラー防止）
      if (_currentTrack == track && (_bgmPlayer?.playing ?? false)) {
        print("BgmManager.play: 同一トラック再生中のためスキップします");
        return;
      }

      final trackPath = _getTrackPath(track);

      if (trackPath == null) {
        await stopBgm();
        _currentTrack = track;
        return;
      }

      // 再生前にプレイヤーを確保
      final player = await _ensurePlayer();

      // 一旦停止
      await player.stop();

      print("BgmManager.play: アセットをロード中... $trackPath");
      try {
        await player.setAsset(trackPath);
      } on PlatformException catch (e) {
        if (e.code == 'abort') {
          print("BgmManager.play: ロードが中断されました（次のロードが優先されました）: $e");
          return; // 中断された場合は後続の処理を行わない
        }
        rethrow;
      }

      await player.setLoopMode(LoopMode.one);
      await player.play();

      _currentTrack = track;
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
      final player = await _ensurePlayer();
      await player.play();
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
        print("BgmManager: AudioPlayerを破棄します");
        final playerToDispose = _bgmPlayer!;
        _bgmPlayer = null; // 先に参照を切る
        await playerToDispose.stop();
        await playerToDispose.dispose();
      }
    } catch (e) {
      print("BGMの破棄エラー: $e");
    }
  }
}
