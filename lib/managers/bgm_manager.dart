// lib/bgm_manager.dart

import 'dart:async';
import 'package:flutter/widgets.dart';
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

class BgmManager with WidgetsBindingObserver {
  static final BgmManager instance = BgmManager._internal();
  AudioPlayer? _bgmPlayer;

  // バックグラウンドに移行する前に再生中だったかどうかを記録
  bool _wasPlayingBeforeBackground = false;

  // 🌟 ロード中の競合を防ぐフラグ
  bool _isLoading = false;
  BgmTrack? _currentTrack;
  BgmTrack? _pendingTrack;

  factory BgmManager() {
    return instance;
  }

  BgmManager._internal() {
    // アプリ全体のライフサイクルをBgmManager自身で監視
    WidgetsBinding.instance.addObserver(this);
  }

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

  // 🌟 アプリのライフサイクル変化をBgmManager自身で受け取る
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // バックグラウンド移行 or アプリ終了時: BGMを停止
      final isPlaying = _bgmPlayer?.playing ?? false;
      _wasPlayingBeforeBackground = isPlaying;
      if (isPlaying) {
        _bgmPlayer?.pause();
        print('BgmManager: バックグラウンド移行 → BGM一時停止');
      }
    } else if (state == AppLifecycleState.resumed) {
      // フォアグラウンド復帰時: バックグラウンド前に再生中だった場合のみ再開
      if (_wasPlayingBeforeBackground) {
        _bgmPlayer?.play();
        print('BgmManager: フォアグラウンド復帰 → BGM再開');
      }
      _wasPlayingBeforeBackground = false;
    }
  }

  Future<void> play(BgmTrack track) async {
    // 🌟 同じトラックが既に再生中なら何もしない
    if (_currentTrack == track && (_bgmPlayer?.playing ?? false)) {
      return;
    }

    // 🌟 ロード中なら「次に再生するトラック」を予約してリターン
    //    ロード完了後に _pendingTrack があれば改めて play() を呼ぶ
    if (_isLoading) {
      _pendingTrack = track;
      print("BgmManager.play: ロード中のため予約: $track");
      return;
    }

    _isLoading = true;
    _pendingTrack = null;

    try {
      print("BgmManager.play: $track");
      final trackPath = _getTrackPath(track);

      if (trackPath == null) {
        await stopBgm();
        _currentTrack = track;
        return;
      }

      // 🌟 ロード前に一度停止して "Loading interrupted" を防ぐ
      await _player.stop();

      print("BgmManager.play: アセットをロード中... $trackPath");
      await _player.setAsset(trackPath);
      await _player.setLoopMode(LoopMode.one);
      await _player.play();

      _currentTrack = track;
      print("BgmManager.play: 再生開始しました: $track");
    } catch (e) {
      // "Loading interrupted" はレース条件由来の一過性エラー。ログのみ。
      print("BGMの再生エラー ($track): $e");
    } finally {
      _isLoading = false;

      // 🌟 ロード中に別の play() が来ていた場合、改めて再生
      final pending = _pendingTrack;
      if (pending != null && pending != _currentTrack) {
        _pendingTrack = null;
        await play(pending);
      }
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
        _currentTrack = null;
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
