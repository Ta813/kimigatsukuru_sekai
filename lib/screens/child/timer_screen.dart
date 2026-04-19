// lib/screens/timer/timer_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../helpers/shared_prefs_helper.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'roulette_dialog.dart';
import '../../managers/sfx_manager.dart';
import '../../managers/bgm_manager.dart';
import '../../widgets/ad_banner.dart';
import '../../l10n/app_localizations.dart';
import 'package:confetti/confetti.dart';
import '../../widgets/blinking_effect.dart';
import '../parent/child_name_settings_screen.dart'; // 名前設定画面
import 'math_lock_dialog.dart'; // ロック画面
import 'passcode_lock_dialog.dart';
import '../../models/lock_mode.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TimerScreen extends StatefulWidget {
  // StatefulWidgetに変更
  final Map<String, dynamic> promise;
  final bool isEmergency;

  const TimerScreen({
    super.key,
    required this.promise,
    required this.isEmergency,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  Timer? _timer; // タイマーを管理するための変数
  DateTime? _endTime;
  int _remainingSeconds = 0; // 残り時間を秒で管理
  int _totalSeconds = 0; // ★ 合計時間を秒で管理
  bool _isTimeUp = false;
  DateTime? _screenStartTime; // ★ 画面表示からの経過時間を測定

  String? _randomSupportCharacterPath; // ★ランダムで表示するキャラのパス
  String _avatarPath = 'assets/images/avatar.png';

  late ConfettiController _confettiController; // ★ 紙吹雪のコントローラーを宣言

  bool _isFinishedButtonPressed = false;
  bool _isCharacterSad = false;
  bool _isInteractionBusy = false;
  bool _isCompleting = false; // 終了処理中フラグ

  final FlutterTts _flutterTts = FlutterTts();
  String? _childFullName; // 読み上げる名前（敬称付き）を保持
  bool _isTtsInitialized = false; // TTS初期化完了フラグ
  bool _isDisposed = false; // ★ 画面破棄フラグ
  int _namesListCount = 0;
  bool _didInitialize = false;

  late AnimationController _hintAnimationController;

  int _basePoints = 0;
  bool _isTutorial = false;

  // 広告を表示するかどうかのフラグ（最初は絶対にfalseにしておく）
  //bool _showAd = false;

  // 広告表示用の遅延タイマー
  //Timer? _adDelayTimer;

  // この画面が表示された瞬間に、一度だけ呼ばれる初期化処理
  @override
  void initState() {
    super.initState();
    _screenStartTime = DateTime.now(); // ★ 追加：画面起動時刻を記録
    _basePoints = widget.promise['points'] as int? ?? 0;
    _checkTutorial();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 6), // 6秒間だけ紙吹雪を出す
    );

    // ★ アニメーションコントローラーを初期化
    _hintAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // アニメーションの速度
    )..repeat(reverse: true); // ★ 繰り返し再生（reverse: trueで拡大・縮小）

    // ★アプリの状態変化の監視を開始
    WidgetsBinding.instance.addObserver(this);
    // ★画面が表示されたら、スリープを無効にする
    WakelockPlus.enable();

    final durationInMinutes = widget.promise['duration'] as int? ?? 20;
    _totalSeconds = durationInMinutes * 60; // ★ 合計秒数を計算
    _endTime = DateTime.now().add(Duration(minutes: durationInMinutes));

    _startTimer();

    _loadAndSetRandomCharacter();

    // 🌟 画面が開いてから1分後（テスト時は seconds: 5 等）にフラグを true にする
    // _adDelayTimer = Timer(const Duration(minutes: 1), () {
    //   if (mounted) {
    //     setState(() {
    //       _showAd = true;
    //     });
    //     print("1分経過！AdBannerを表示します");
    //   }
    // });
    _playFocusBgm();
  }

  // チュートリアルチェック
  Future<void> _checkTutorial() async {
    final isTutorialShown =
        await SharedPrefsHelper.getChildTutorial() ==
        SharedPrefsHelper.tutorialPhaseStart;

    if (isTutorialShown) {
      if (mounted) {
        setState(() {
          _isTutorial = true;
        });
      }
    }
  }

  bool _hasPlayedInitialSound = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ★サウンドがまだ再生されていなければ
    if (!_hasPlayedInitialSound) {
      final lang = AppLocalizations.of(context)!.localeName;
      if (lang == 'ja') {
        try {
          SfxManager.instance.playStartSound();
        } catch (e) {
          // エラーが発生した場合
          print('再生エラー: $e');
        }
      } else {
        try {
          SfxManager.instance.playStartSoundLocalized(lang);
        } catch (e) {
          // エラーが発生した場合
          print('再生エラー: $e');
        }
      }
      _hasPlayedInitialSound = true; // ★再生済みの旗を立てる
    }
    if (!_didInitialize) {
      _initializeTtsAndLoadNames(); // ★ Move TTS init and name loading here
      _didInitialize = true;
    }
  }

  // この画面が閉じられる時に、一度だけ呼ばれるお片付け処理
  @override
  void dispose() {
    _isDisposed = true; // ★ 破棄フラグを立てる
    _flutterTts.stop();
    _confettiController.dispose();
    _hintAnimationController.dispose();
    // ★アプリの状態変化の監視を終了
    WidgetsBinding.instance.removeObserver(this);
    // ★画面が閉じられたら、スリープを有効に戻す（非常に重要！）
    WakelockPlus.disable();
    _timer?.cancel(); // タイマーが動いていたら、必ず停止する
    //_adDelayTimer?.cancel();
    super.dispose();
  }

  // ★アプリの状態が変化した時に呼ばれる
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // アプリが前面に戻ってきたら、タイマーの表示を更新
      _updateRemainingSeconds();

      // ★ 自分が現在表示されている画面の場合のみ、BGMを再生する
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        print("TimerScreen: アプリ復帰を検知し、集中BGMを再開します");
        _playFocusBgm();
      } else {
        print("TimerScreen: アプリ復帰を検知しましたが、カレント画面ではないためスキップします");
      }

      // もしタイマーが止まっていたら再開
      if (_timer == null || !_timer!.isActive) {
        _startTimer();
      }
    } else if (state == AppLifecycleState.detached) {
      // 🌟 【ここを追加！】アプリが完全にキルされた瞬間の処理
      _timer?.cancel();
      try {
        BgmManager.instance.stopBgm();
      } catch (e) {
        print('再生エラー: $e');
      }
      // Wakelockがオンになったままキルされるのを防ぐ
      try {
        WakelockPlus.disable();
      } catch (e) {
        print('Wakelock解除エラー: $e');
      }
    } else {
      // アプリが裏に回ったら、UI更新用のタイマーは一旦停止
      _timer?.cancel();
      try {
        BgmManager.instance.stopBgm();
      } catch (e) {
        // エラーが発生した場合
        print('再生エラー: $e');
      }
    }
  }

  // ★ 集中BGMを再生するメソッド
  Future<void> _playFocusBgm() async {
    final trackName = await SharedPrefsHelper.loadSelectedFocusBgm();
    final focusTrack = BgmTrack.values.firstWhere(
      (e) => e.name == trackName,
      orElse: () => BgmTrack.focus_original, // 保存されていなければデフォルト
    );

    try {
      await BgmManager.instance.play(focusTrack);
    } catch (e) {
      print('再生エラー: $e');
    }
  }

  // ★ 名前設定画面へ遷移するメソッド（ロック付き）
  void _navigateToChildNameSettings() async {
    FirebaseAnalytics.instance.logEvent(name: 'start_timer_name_settings');
    // 1. ロック画面を表示
    final lockMode = await SharedPrefsHelper.loadLockMode();
    final bool? isCorrect = await showDialog<bool>(
      context: context,
      builder: (context) {
        if (lockMode == LockMode.passcode) {
          return const PasscodeLockDialog();
        }
        return const MathLockDialog();
      },
    );

    // 2. ロック解除成功なら遷移
    if (isCorrect == true && mounted) {
      // ★ 初めて遷移するフラグを立てる
      await SharedPrefsHelper.setHasVisitedChildNameSettings(true);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChildNameSettingsScreen(),
        ),
      );
      // ★ 設定画面から戻ってきたら、名前を再読み込み（任意）
      _initializeTtsAndLoadNames(); // TTS用に読み込む処理があればそれを呼ぶ
    }
  }

  // ★ TTSの初期化と名前読み込みを行うメソッド
  Future<void> _initializeTtsAndLoadNames() async {
    // TTSの初期設定
    final lang = AppLocalizations.of(context)!.localeName;
    try {
      if (lang == 'ja') {
        await _flutterTts.setLanguage("ja-JP");
        await _flutterTts.setSpeechRate(0.4);
        await _flutterTts.setPitch(1.6);
      } else if (lang == 'ur') {
        await _flutterTts.setLanguage("ur-PK");
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setPitch(1.0);
      } else {
        await _flutterTts.setLanguage("en-US");
        await _flutterTts.setSpeechRate(0.6);
        await _flutterTts.setPitch(1.6);
      }
      await _flutterTts.setVolume(1.0);

      _isTtsInitialized = true;
    } catch (e) {
      print("TTS Initialization Error: $e");
      _isTtsInitialized = false; // 初期化失敗
    }

    // 名前リストを読み込む
    final namesList = await SharedPrefsHelper.loadChildNames();
    if (namesList.isNotEmpty && mounted) {
      // ★ 最初の名前を使用する (複数対応の場合は選択ロジックが必要)
      setState(() {
        String tempFullName = "";
        for (Map<String, String> name in namesList) {
          tempFullName += '${name['name']}${name['honorific']}。';
        }
        _childFullName = tempFullName;
        _namesListCount = namesList.length;
      });
    } else {
      _childFullName = '';
      _namesListCount = namesList.length;
    }
  }

  // ★ TTSで読み上げを行う共通メソッド (エラーハンドリング付き)
  Future<void> _speak(String text) async {
    if (!_isTtsInitialized) {
      print("TTS not initialized, cannot speak.");
      return; // TTSが初期化されていなければ何もしない
    }
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print("TTS Speak Error: $e");
      // エラー発生時は通常の効果音にフォールバックするなどの処理も可能
    }
  }

  // ★ 残り時間に合わせてゲージの色を変えるロジック
  Color _getTimerColor(double progress) {
    if (progress > 0.5) {
      return Colors.green; // 半分以上は「緑（余裕）」
    } else if (progress > 0.2) {
      return Colors.orange; // 50%〜20%は「オレンジ（少し急ごう）」
    } else {
      return Colors.redAccent; // 残り20%を切ったら「赤（ピンチ！）」
    }
  }

  Future<void> _loadAndSetRandomCharacter() async {
    final equippedChars = await SharedPrefsHelper.loadEquippedCharacters();
    final clothes = await SharedPrefsHelper.loadEquippedClothes();

    if (equippedChars.isNotEmpty) {
      // ランダムに1体を選ぶ
      final randomIndex = Random().nextInt(equippedChars.length);
      setState(() {
        _randomSupportCharacterPath = equippedChars[randomIndex];
        _avatarPath = clothes ?? 'assets/images/avatar.png';
      });
    } else {
      // 設定されているキャラがいなければ、デフォルトのキャラを設定
      setState(() {
        _randomSupportCharacterPath = 'assets/images/character_usagi.gif';
        _avatarPath = clothes ?? 'assets/images/avatar.png';
      });
    }
  }

  // ★残り時間を計算して更新する処理
  void _updateRemainingSeconds() {
    if (_endTime == null) return;
    final now = DateTime.now();
    // 「終わる時刻」と「今の時刻」の差を計算
    final difference = _endTime!.difference(now);

    // 残り時間が0以下なら0に、そうでなければ残り秒数をセット
    if (mounted) {
      setState(() {
        _remainingSeconds = difference.isNegative ? 0 : difference.inSeconds;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel(); // 念のため既存タイマーをキャンセル
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      // 🌟 追加1: 画面が閉じられていたらタイマーを止めて終わる
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updateRemainingSeconds();

      final localizations = AppLocalizations.of(context);
      if (localizations == null) return;
      final String lang = localizations.localeName;
      final String voiceDir = SfxManager.instance.getVoiceDir(lang);

      // --- 音声再生ロジックをここにまとめる ---
      final List<String> soundsToPlay = [];

      if (_remainingSeconds <= 0) {
        if (!_isTimeUp) {
          if (lang == 'ja') {
            soundsToPlay.add('se/「タイムアップ」.mp3'); // タイムアップ音
          } else {
            soundsToPlay.add('se/$voiceDir/times_up.mp3');
          }
          setState(() => _isTimeUp = true);
        }
        _timer?.cancel();
      } else if (_remainingSeconds == 10) {
        if (lang == 'ja') {
          soundsToPlay.add('se/「10、9、8、7、6、5、4、3、2、1、0」.mp3'); // 10秒カウントダウン
        } else {
          soundsToPlay.addAll([
            'se/$voiceDir/ten.mp3',
            'se/$voiceDir/nine.mp3',
            'se/$voiceDir/eight.mp3',
            'se/$voiceDir/seven.mp3',
            'se/$voiceDir/six.mp3',
            'se/$voiceDir/five.mp3',
            'se/$voiceDir/four.mp3',
            'se/$voiceDir/three.mp3',
            'se/$voiceDir/two.mp3',
            'se/$voiceDir/one.mp3',
          ]);
        }
      } else if (_remainingSeconds == 1 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll(['se/「あと」.mp3', 'se/「1」.mp3', 'se/「分（ふん）」.mp3']);
        } else {
          soundsToPlay.addAll([
            'se/$voiceDir/one.mp3',
            'se/$voiceDir/minute.mp3',
          ]);
        }
      } else if (_remainingSeconds == 2 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll(['se/「あと」.mp3', 'se/「2」.mp3', 'se/「分（ふん）」.mp3']);
        } else {
          soundsToPlay.addAll([
            'se/$voiceDir/two.mp3',
            'se/$voiceDir/minute.mp3',
          ]);
        }
      } else if (_remainingSeconds == 3 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll(['se/「あと」.mp3', 'se/「3」.mp3', 'se/「分（ふん）」.mp3']);
        } else {
          soundsToPlay.addAll([
            'se/$voiceDir/three.mp3',
            'se/$voiceDir/minute.mp3',
          ]);
        }
      } else if (_remainingSeconds == 4 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll([
            'se/「あと」.mp3',
            'se/「4（よん）」.mp3',
            'se/「分（ふん）」.mp3',
          ]);
        } else {
          soundsToPlay.addAll([
            'se/$voiceDir/four.mp3',
            'se/$voiceDir/minute.mp3',
          ]);
        }
      } else if (_remainingSeconds == 5 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll(['se/「あと」.mp3', 'se/「5」.mp3', 'se/「分（ふん）」.mp3']);
        } else {
          soundsToPlay.addAll([
            'se/$voiceDir/five.mp3',
            'se/$voiceDir/minute.mp3',
          ]);
        }
      } else if (_remainingSeconds == 10 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll([
            'se/「あと」.mp3',
            'se/「10（じゅう↑）」.mp3',
            'se/「分（ふん）」.mp3',
          ]);
        } else {
          soundsToPlay.addAll([
            'se/$voiceDir/ten.mp3',
            'se/$voiceDir/minute.mp3',
          ]);
        }
      } else if (_remainingSeconds == 15 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll([
            'se/「あと」.mp3',
            'se/「10（じゅう↓）」.mp3',
            'se/「5」.mp3',
            'se/「分（ふん）」.mp3',
          ]);
        } else {
          soundsToPlay.addAll([
            'se/$voiceDir/fifteen.mp3',
            'se/$voiceDir/minute.mp3',
          ]);
        }
      } else if (_remainingSeconds == 20 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll(['se/「あと」.mp3', 'se/「20」.mp3', 'se/「分（ふん）」.mp3']);
        } else {
          soundsToPlay.addAll([
            'se/$voiceDir/twenty.mp3',
            'se/$voiceDir/minute.mp3',
          ]);
        }
      } else if (_remainingSeconds == 25 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll([
            'se/「あと」.mp3',
            'se/「20（に↑じゅう↓）」.mp3',
            'se/「5」.mp3',
            'se/「分（ふん）」.mp3',
          ]);
        } else {
          soundsToPlay.addAll([
            'se/$voiceDir/twenty_five.mp3',
            'se/$voiceDir/minute.mp3',
          ]);
        }
      } else if (_remainingSeconds == 30 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll(['se/「あと」.mp3', 'se/「30」.mp3', 'se/「分（ふん）」.mp3']);
        } else {
          soundsToPlay.addAll([
            'se/$voiceDir/thirty.mp3',
            'se/$voiceDir/minute.mp3',
          ]);
        }
      }

      // もし再生すべき音があれば、SfxManagerの新しいメソッドを呼び出す
      if (soundsToPlay.isNotEmpty) {
        if (_isDisposed) return; // ★ 破棄されていたら中断

        // 1. BGMを一時停止
        try {
          BgmManager.instance.pause();
        } catch (e) {
          // エラーが発生した場合
          print('再生エラー: $e');
        }
        // 2. 効果音の再生が「終わるのを待つ」
        if (soundsToPlay.length == 10) {
          try {
            await SfxManager.instance.playSequentialSounds(
              soundsToPlay,
              speed: 1.2,
            );
          } catch (e) {
            // エラーが発生した場合
            print('再生エラー: $e');
          }
        } else {
          try {
            await SfxManager.instance.playSequentialSounds(soundsToPlay);
          } catch (e) {
            // エラーが発生した場合
            print('再生エラー: $e');
          }
        }

        if (_isDisposed) return; // ★ 待機中に破棄されたかチェック
        await Future.delayed(const Duration(seconds: 3));

        if (_isDisposed) return; // ★ 再びチェック
        // 3. BGMを再開
        try {
          BgmManager.instance.resume();
        } catch (e) {
          // エラーが発生した場合
          print('再生エラー: $e');
        }
      }
    });
  }

  // 秒を「分:秒」の形式（例: 19:59）に変換するヘルパー関数
  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _showApprovalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.confirmation,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0), // ピーチクリーム
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF7043).withOpacity(0.5), // オレンジの薄い線
                width: 2,
              ),
            ),
            child: Text(
              AppLocalizations.of(
                context,
              )!.askIfFinished(widget.promise['title']),
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // チュートリアルで「まだだよ」ボタンを押したかチェック
                final isTutorialStepShown =
                    await SharedPrefsHelper.isTutorialStepShown(
                      SharedPrefsHelper.tutorialStepPromiseKey,
                    );
                if (!isTutorialStepShown) {
                  FirebaseAnalytics.instance.logEvent(
                    name: 'tutorial_tap_not_yet_finish_button',
                  );
                }
                try {
                  SfxManager.instance.playTapSound();
                } catch (e) {
                  print('再生エラー: $e');
                }
                Navigator.of(dialogContext).pop();
                _startTimer();
                setState(() {
                  _isFinishedButtonPressed = false;
                });
              },
              child: Text(
                AppLocalizations.of(context)!.notYet,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            BlinkingEffect(
              isBlinking: _isTutorial,
              child: ElevatedButton(
                onPressed: _isCompleting
                    ? null
                    : () async {
                        if (!mounted) return;
                        setState(() => _isCompleting = true);
                        final localizations = AppLocalizations.of(context);
                        final lang = localizations?.localeName ?? 'en';
                        final voiceDir = SfxManager.instance.getVoiceDir(lang);
                        // まず承認ダイアログを閉じる
                        Navigator.of(dialogContext).pop();

                        // チュートリアルで「おわった！」ボタンを押したかチェック
                        final isTutorialStepShown =
                            await SharedPrefsHelper.isTutorialStepShown(
                              SharedPrefsHelper.tutorialStepPromiseKey,
                            );
                        if (!isTutorialStepShown) {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'tutorial_tap_yes_finished_button',
                          );
                        }
                        // 次に、時間切れかどうかで処理を分岐
                        if (!_isTimeUp) {
                          _confettiController.play();
                          try {
                            SfxManager.instance.playTimerWinSound();
                          } catch (e) {
                            print('再生エラー: $e');
                          }
                          await Future.delayed(const Duration(seconds: 2));

                          // ◯◯がんばったね。
                          if (_childFullName != null &&
                              _childFullName!.isNotEmpty) {
                            await _speak('$_childFullName');
                            await Future.delayed(
                              Duration(milliseconds: 1300 * _namesListCount),
                            );
                          }

                          if (lang == 'ja') {
                            try {
                              SfxManager.instance.playTimerLoseSound();
                            } catch (e) {
                              print('再生エラー: $e');
                            }
                          } else {
                            final List<String> soundsToPlay = [];
                            soundsToPlay.addAll([
                              'se/$voiceDir/you_did_your_best.mp3',
                            ]);
                            try {
                              SfxManager.instance.playSequentialSounds(
                                soundsToPlay,
                              );
                            } catch (e) {
                              print('再生エラー: $e');
                            }
                          }
                          await Future.delayed(const Duration(seconds: 1));

                          try {
                            SfxManager.instance.playTimerWinSound2();
                          } catch (e) {
                            print('再生エラー: $e');
                          }
                          await Future.delayed(const Duration(seconds: 4));
                          // 時間内なら -> ルーレットへ
                          if (mounted) {
                            _showRouletteAndFinish();
                          }
                        } else {
                          if (_childFullName != null &&
                              _childFullName!.isNotEmpty) {
                            await _speak('$_childFullName');
                            await Future.delayed(
                              Duration(milliseconds: 1300 * _namesListCount),
                            );
                          }

                          if (lang == 'ja') {
                            try {
                              SfxManager.instance.playTimerLoseSound();
                            } catch (e) {
                              print('再生エラー: $e');
                            }
                          } else {
                            final String lang = AppLocalizations.of(
                              context,
                            )!.localeName;
                            final String voiceDir = SfxManager.instance
                                .getVoiceDir(lang);
                            final List<String> soundsToPlay = [];
                            soundsToPlay.addAll([
                              'se/$voiceDir/you_did_your_best.mp3',
                            ]);
                            try {
                              SfxManager.instance.playSequentialSounds(
                                soundsToPlay,
                              );
                            } catch (e) {
                              print('再生エラー: $e');
                            }
                          }
                          await Future.delayed(const Duration(seconds: 2));

                          // 時間切れなら -> ポイント半分で終了
                          if (mounted) {
                            _finishPromise(pointMultiplier: 0.5, exp: 1);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7043), // オレンジ
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: Color(0xFFFFCA28),
                    width: 2,
                  ), // 黄色の輪郭
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  AppLocalizations.of(context)!.yesFinished,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ★ルーレットを表示して、その結果で終了処理を呼ぶメソッド
  void _showRouletteAndFinish() async {
    final basePoints = _basePoints;

    final multiplier = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          RouletteDialog(basePoints: basePoints, isTutorial: _isTutorial),
    );
    if (!mounted) return;
    // ルーレットの結果（1倍か2倍か）で終了処理を呼ぶ
    _finishPromise(pointMultiplier: multiplier ?? 1, exp: 3);
  }

  // ★ポイントを計算して、画面を閉じる最終処理メソッド
  void _finishPromise({required num pointMultiplier, required int exp}) async {
    final basePoints = _basePoints;
    int pointsAwarded = (basePoints * pointMultiplier).toInt();

    // ポイントが0の場合は経験値も0にする（ガイド用など）
    final int finalExp = basePoints == 0 ? 0 : exp;

    if (widget.isEmergency) {
      await SharedPrefsHelper.saveEmergencyPromise(null);
    }

    // やくそく回数を加算
    await SharedPrefsHelper.incrementPromiseCount();
    // 累計ポイントを加算
    await SharedPrefsHelper.addCumulativePoints(pointsAwarded);

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop<Map<String, dynamic>>({
        'points': pointsAwarded,
        'exp': finalExp,
        'isFirstTimeBonus': _isTutorial,
      });
    }
  }

  // 応援フレーズのリスト
  final List<String> _encouragementsEn = [
    'Keep up the good work!',
    'Try your best!',
    'Go for it!',
    'You got this!',
    'Keep it up!',
  ];

  final List<String> _encouragementsHi = [
    'अपना काम जारी रखें!',
    'अपना सर्वश्रेष्ठ प्रयास करें!',
    'इसके लिए जाओ!',
    'आप यह कर सकते हैं!',
    'इसे जारी रखें!',
  ];
  final List<String> _encouragementsUr = [
    'اپنا کام جاری رکھیں!',
    'اپنا بہترین کام کریں!',
    'کوشش کریں!',
    'آپ یہ کر سکتے ہیں!',
    'اسی طرح لگے رہیں!',
  ];
  final List<String> _encouragementsBn = [
    'শুভকামনা রইল!',
    'অব্যাহত রাখুন!',
    'এগিয়ে চলুন!',
    'আপনি এটি পারবেন!',
    'চেষ্টা চালিয়ে যান!',
  ];

  final List<String> _encouragementsAr = [
    'بالتوفيق!',
    'استمر هكذا!',
    'افعلها!',
    'يمكنك فعل ذلك!',
    'استمر في المحاولة!',
  ];

  final List<String> _encouragementsJa = [
    'そのまま頑張って！',
    'ベストを尽くして！',
    'ファイト！',
    '君ならできる！',
    'その調子！',
  ];

  // ランダムな応援フレーズを返すメソッド
  String getRandomEncouragement() {
    final lang = AppLocalizations.of(context)!.localeName;
    List<String> list;
    if (lang == 'ja') {
      list = _encouragementsJa;
    } else if (lang == 'hi') {
      list = _encouragementsHi;
    } else if (lang == 'ur') {
      list = _encouragementsUr;
    } else if (lang == 'bn') {
      list = _encouragementsBn;
    } else if (lang == 'ar') {
      list = _encouragementsAr;
    } else {
      list = _encouragementsEn;
    }
    return list[Random().nextInt(list.length)];
  }

  // 悲しいフレーズリスト
  final List<String> _sadPhrasesEn = [
    "Oh... that's too bad...",
    "Aww... I was hoping you'd finish...",
    "We'll get it next time!",
    "Oh no...",
    "That's okay, maybe next time.",
  ];

  final List<String> _sadPhrasesHi = [
    "ओह... यह बहुत बुरा हुआ...",
    "ओह... मुझे उम्मीद थी कि आप इसे पूरा कर लेंगे...",
    "अगली बार हम इसे कर लेंगे!",
    "ओह नहीं...",
    "कोई बात नहीं, शायद अगली बार।",
  ];

  final List<String> _sadPhrasesJa = [
    "あらら…残念…",
    "次はきっとできるよ！",
    "どんまいどんまい！",
    "ショック…次は頑張ろう！",
    "次は成功させようね！",
  ];
  final List<String> _sadPhrasesUr = [
    "اوہ... یہ تو بہت برا ہوا...",
    "اف... مجھے امید تھی کہ آپ اسے مکمل کر لیں گے...",
    "اگلی بار ہم اسے کر لیں گے!",
    "اوہ نہیں...",
    "کوئی بات نہیں، شاید اگلی بار۔",
  ];
  final List<String> _sadPhrasesBn = [
    "ওহ... এটি বেশ দুঃখজনক...",
    "আহ... আমি আশা করেছিলাম আপনি শেষ করবেন...",
    "পরের বার আমরা এটি করব!",
    "ওহ না...",
    "ঠিক আছে, হয়তো পরের বার হবে।",
  ];

  final List<String> _sadPhrasesAr = [
    "أوه... هذا سيء للغاية...",
    "أوه... كنت آمل أن تنتهي...",
    "سنفعلها في المرة القادمة!",
    "أوه لا...",
    "لا بأس، ربما في المرة القادمة.",
  ];

  // 悲しいフレーズを返却
  String getRandomSadPhraseLocalized() {
    final lang = AppLocalizations.of(context)!.localeName;
    List<String> list;
    if (lang == 'ja') {
      list = _sadPhrasesJa;
    } else if (lang == 'hi') {
      list = _sadPhrasesHi;
    } else if (lang == 'ur') {
      list = _sadPhrasesUr;
    } else if (lang == 'bn') {
      list = _sadPhrasesBn;
    } else if (lang == 'ar') {
      list = _sadPhrasesAr;
    } else {
      list = _sadPhrasesEn;
    }
    return list[Random().nextInt(list.length)];
  }

  @override
  Widget build(BuildContext context) {
    String? currentCharacterPath = _randomSupportCharacterPath;
    if (_isCharacterSad) {
      //悲しい状態なら、ファイル名を "_sad.png" に置き換える
      currentCharacterPath = currentCharacterPath?.replaceAll(
        '.gif',
        '_sad.png',
      );
    }

    return WillPopScope(
      // ★ _isFinishedButtonPressedがtrue（処理中）の間は、戻る操作を無効化する
      onWillPop: () async => !_isFinishedButtonPressed,
      child: Scaffold(
        appBar: AppBar(
          // もらった情報を使って、タイトルを表示します
          backgroundColor: widget.isEmergency ? Colors.red[400] : null,
          title: Text(
            AppLocalizations.of(
              context,
            )!.challengingPromise(widget.promise['title']),
          ),
          actions: [
            if (!_isFinishedButtonPressed)
              Stack(
                // ★ Stackでアイコンと吹き出しを重ねる準備
                alignment: Alignment.topRight, // 吹き出しをアイコンの右上に配置
                children: [
                  // 名前設定画面へのアイコンボタン
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: _navigateToChildNameSettings,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.face_retouching_natural),
                            Text(
                              AppLocalizations.of(context)!.nameSetting,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: Stack(
          children: [
            Positioned(
              left: 50,
              bottom: 50,
              child: Image.asset(_avatarPath, height: 180),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🌟 ゲージとタイマーを横並びで表示
                  Builder(
                    builder: (context) {
                      // 残り時間の割合（0.0 〜 1.0）を計算する
                      double progress = _totalSeconds > 0
                          ? (_remainingSeconds / _totalSeconds).clamp(0.0, 1.0)
                          : 0.0;

                      return Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // 中央で横並びにする
                        children: [
                          // 🌟 左側：コンパクトな円形ゲージ
                          SizedBox(
                            width: 80, // サイズをグッと小さく！
                            height: 80,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 14, // サイズに合わせて少し細くします
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getTimerColor(progress),
                              ),
                              strokeCap: StrokeCap.round,
                            ),
                          ),

                          const SizedBox(width: 20), // ゲージと文字の間の隙間
                          // 🌟 右側：時間とテキスト
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // 文字を左揃えにすると綺麗です
                            children: [
                              Text(
                                _formatDuration(_remainingSeconds), // タイマー表示
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: _isTimeUp
                                      ? Colors.red
                                      : Colors.black87,
                                  height: 1.0, // 縦の隙間を詰めめる
                                ),
                              ),
                              if (_basePoints > 0) ...[
                                const SizedBox(height: 4),
                                _isTimeUp
                                    ? Text(
                                        AppLocalizations.of(
                                              context,
                                            )!.pointsHalf(
                                              (_basePoints / 2)
                                                  .floor()
                                                  .toString(),
                                            ) +
                                            '\n' +
                                            AppLocalizations.of(
                                              context,
                                            )!.timerExpFailure,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red[700],
                                        ),
                                      )
                                    : Text(
                                        AppLocalizations.of(
                                              context,
                                            )!.pointsChance(_basePoints) +
                                            '\n' +
                                            AppLocalizations.of(
                                              context,
                                            )!.timerExpChance,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                              ],
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  BlinkingEffect(
                    isBlinking: _isTutorial && !_isFinishedButtonPressed,
                    child: ElevatedButton(
                      // ★「おわった！」ボタンは、常に承認ダイアログを呼び出すだけ
                      onPressed: _isFinishedButtonPressed
                          ? null
                          : () async {
                              int elapsedSeconds = 0;
                              if (_screenStartTime != null) {
                                elapsedSeconds = DateTime.now()
                                    .difference(_screenStartTime!)
                                    .inSeconds;
                              }
                              //チュートリアルで「おわった！」ボタンを押したか
                              final isTutorialStepShown =
                                  await SharedPrefsHelper.isTutorialStepShown(
                                    SharedPrefsHelper.tutorialStepPromiseKey,
                                  );
                              if (isTutorialStepShown) {
                                FirebaseAnalytics.instance.logEvent(
                                  name: 'tutorial_tap_finished_button',
                                );
                              } else {
                                FirebaseAnalytics.instance.logEvent(
                                  name: 'start_timer_finished',
                                  parameters: {
                                    'elapsed_seconds': elapsedSeconds,
                                  },
                                );
                              }
                              setState(() {
                                _isFinishedButtonPressed = true;
                              });
                              _timer?.cancel();
                              _showApprovalDialog();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // 「はじめる」ボタンと同じ青色
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.blue.shade100, // 薄い青色の輪郭
                          width: 3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 8,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.finished),
                    ),
                  ),
                ],
              ),
            ),
            //応援キャラの表示
            if (currentCharacterPath != null)
              Positioned(
                right: 50,
                bottom: 0,
                child: Column(
                  children: [
                    Image.asset(currentCharacterPath, height: 165),
                    Row(
                      children: [
                        // 応援マークボタン
                        InkWell(
                          onTap: _isInteractionBusy
                              ? null
                              : () async {
                                  FirebaseAnalytics.instance.logEvent(
                                    name: 'start_timer_cheer',
                                  );
                                  setState(() {
                                    _isInteractionBusy = true;
                                  });
                                  try {
                                    BgmManager.instance.pause();
                                  } catch (e) {
                                    print('再生エラー: $e');
                                  }
                                  if (_childFullName != null &&
                                      _childFullName!.isNotEmpty) {
                                    await _speak('$_childFullName');
                                    await Future.delayed(
                                      Duration(
                                        milliseconds: 1300 * _namesListCount,
                                      ),
                                    );
                                  }

                                  if (AppLocalizations.of(
                                        context,
                                      )!.localeName ==
                                      'ja') {
                                    await SfxManager.instance
                                        .playRandomCheerSound();
                                  } else {
                                    await _speak(getRandomEncouragement());
                                  }

                                  // 2秒後に元の状態に戻す
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      try {
                                        BgmManager.instance.resume();
                                      } catch (e) {
                                        print('再生エラー: $e');
                                      }
                                      if (mounted) {
                                        setState(() {
                                          _isInteractionBusy = false;
                                        });
                                      }
                                    },
                                  );
                                },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.celebration,
                                  color: Colors.pinkAccent,
                                  size: 40,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.cheerLabel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pinkAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 悲しい顔マークボタン
                        InkWell(
                          onTap: _isInteractionBusy
                              ? null
                              : () async {
                                  FirebaseAnalytics.instance.logEvent(
                                    name: 'start_timer_sad',
                                  );
                                  setState(() {
                                    _isInteractionBusy = true;
                                    _isCharacterSad = true;
                                  });
                                  try {
                                    BgmManager.instance.pause();
                                  } catch (e) {
                                    print('再生エラー: $e');
                                  }

                                  final lang = AppLocalizations.of(
                                    context,
                                  )!.localeName;
                                  if (lang == 'ja') {
                                    await SfxManager.instance
                                        .playRandomSadSound();
                                  } else {
                                    await _speak(getRandomSadPhraseLocalized());
                                  }

                                  // 3秒後に元の状態に戻す
                                  Future.delayed(
                                    const Duration(seconds: 3),
                                    () {
                                      try {
                                        BgmManager.instance.resume();
                                      } catch (e) {
                                        print('再生エラー: $e');
                                      }
                                      if (mounted) {
                                        setState(() {
                                          _isCharacterSad = false;
                                          _isInteractionBusy = false;
                                        });
                                      }
                                    },
                                  );
                                },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.sentiment_very_dissatisfied,
                                  color: Colors.blueAccent,
                                  size: 40,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.sadLabel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.topCenter, // 画面の上部中央から紙吹雪を出す
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive, // 全方向に爆発
                shouldLoop: false, // 繰り返しはしない
                numberOfParticles: 30, // パーティクルの数
                gravity: 0.3, // 重力（ゆっくり落ちるように）
                emissionFrequency: 0.05, // 発生頻度
                colors: const [
                  // 紙吹雪の色
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.red,
                  Colors.yellow,
                  Colors.white,
                  Colors.black,
                ],
              ),
            ),
          ],
        ),
        // 画面下部にバナーを設置（初回起動時は広告を表示しない）
        bottomNavigationBar: const AdBanner(),
      ),
    );
  }
}
