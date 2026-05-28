// lib/bgm_manager.dart

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

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

  factory BgmManager() {
    return instance;
  }

  BgmManager._internal() {
    // アプリ全体のライフサイクルをBgmManager自身で監視
    WidgetsBinding.instance.addObserver(this);
  }

  // 🌟 複雑なCompleterを廃止し、シンプルで安全な遅延初期化に変更
  AudioPlayer get _player {
    if (_bgmPlayer == null) {
      _bgmPlayer = AudioPlayer(
        handleAudioSessionActivation: false, // 🌟 自動アクティベーションを無効化（クラッシュ対策）
      );
      _bgmPlayer!.playbackEventStream.listen(
        (event) {},
        onError: (Object e, StackTrace stackTrace) {
          print('BgmManager playback stream error: $e');
        },
      );
    }
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
    try {
      // 🌟 手動でセッションをアクティブ化し、iPad特有のバックグラウンドエラーをキャッチ
      try {
        final session = await AudioSession.instance;
        await session.setActive(true);
      } catch (e) {
        print(
          "BgmManager: AudioSession activation failed (safe to ignore): $e",
        );
      }

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
    } on PlayerInterruptedException catch (e) {
      print("BGM loading interrupted ($track): ${e.message}");
    } on PlayerException catch (e) {
      print("BGM PlayerException ($track): ${e.message}");
    } catch (e) {
      print("BGMの再生エラー ($track): $e");
    }
  }

  Future<void> pause() async {
    try {
      if (_bgmPlayer != null) {
        await _bgmPlayer!.pause();
        try {
          final session = await AudioSession.instance;
          await session.setActive(false);
        } catch (e) {
          print("BgmManager: AudioSession deactivation failed: $e");
        }
      }
    } catch (e) {
      print("BGMの一時停止エラー: $e");
    }
  }

  Future<void> resume() async {
    try {
      if (_bgmPlayer != null) {
        try {
          final session = await AudioSession.instance;
          await session.setActive(true);
        } catch (e) {
          print("BgmManager: AudioSession activation failed on resume: $e");
        }
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
        try {
          final session = await AudioSession.instance;
          await session.setActive(false);
        } catch (e) {
          print("BgmManager: AudioSession deactivation failed on stop: $e");
        }
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
