// lib/screens/timer/timer_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../helpers/shared_prefs_helper.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'roulette_dialog.dart';
import '../../managers/sfx_manager.dart';
import '../../managers/bgm_manager.dart';
import '../../widgets/ad_banner.dart';
import '../../l10n/app_localizations.dart';
import 'package:confetti/confetti.dart';
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
  bool _isTimeUp = false;

  String? _randomSupportCharacterPath; // ★ランダムで表示するキャラのパス
  String _avatarPath = 'assets/images/avatar.png';

  late ConfettiController _confettiController; // ★ 紙吹雪のコントローラーを宣言

  bool _isFinishedButtonPressed = false;
  bool _isCharacterSad = false;
  bool _isInteractionBusy = false;
  bool _showNameSettingHint = false;

  final FlutterTts _flutterTts = FlutterTts();
  String? _childFullName; // 読み上げる名前（敬称付き）を保持
  bool _isTtsInitialized = false; // TTS初期化完了フラグ
  int _namesListCount = 0;
  bool _didInitialize = false;

  late AnimationController _hintAnimationController;
  late Animation<double> _hintScaleAnimation;

  // この画面が表示された瞬間に、一度だけ呼ばれる初期化処理
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 6), // 6秒間だけ紙吹雪を出す
    );

    // ★ アニメーションコントローラーを初期化
    _hintAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // アニメーションの速度
    )..repeat(reverse: true); // ★ 繰り返し再生（reverse: trueで拡大・縮小）

    // ★ スケールアニメーションを定義 (1.0倍から1.1倍に変化)
    _hintScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _hintAnimationController,
        curve: Curves.easeInOut, // ゆっくり変化
      ),
    );
    // ★アプリの状態変化の監視を開始
    WidgetsBinding.instance.addObserver(this);
    // ★画面が表示されたら、スリープを無効にする
    WakelockPlus.enable();

    final durationInMinutes = widget.promise['duration'] as int? ?? 20;
    _endTime = DateTime.now().add(Duration(minutes: durationInMinutes));

    _startTimer();

    _loadAndSetRandomCharacter();

    _checkToShowNameHint();
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
        final List<String> soundsToPlay = [];
        soundsToPlay.addAll(['se/english/lets_go.mp3']);
        try {
          SfxManager.instance.playSequentialSounds(soundsToPlay);
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
    _flutterTts.stop();
    _confettiController.dispose();
    _hintAnimationController.dispose();
    // ★アプリの状態変化の監視を終了
    WidgetsBinding.instance.removeObserver(this);
    // ★画面が閉じられたら、スリープを有効に戻す（非常に重要！）
    WakelockPlus.disable();
    _timer?.cancel(); // タイマーが動いていたら、必ず停止する
    super.dispose();
  }

  // ★アプリの状態が変化した時に呼ばれる
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // アプリが前面に戻ってきたら、タイマーの表示を更新
      _updateRemainingSeconds();

      final trackName = await SharedPrefsHelper.loadSelectedFocusBgm();
      final focusTrack = BgmTrack.values.firstWhere(
        (e) => e.name == trackName,
        orElse: () => BgmTrack.focus_original, // 保存されていなければデフォルト
      );

      // ★ タイマー画面に行く前に、"選択された"集中BGMを再生
      try {
        BgmManager.instance.play(focusTrack);
      } catch (e) {
        // エラーが発生した場合
        print('再生エラー: $e');
      }

      // もしタイマーが止まっていたら再開
      if (_timer == null || !_timer!.isActive) {
        _startTimer();
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

  // ★ 名前設定を促すメッセージを表示するかチェックするメソッド
  Future<void> _checkToShowNameHint() async {
    final hasVisited = await SharedPrefsHelper.hasVisitedChildNameSettings();
    final names = await SharedPrefsHelper.loadChildNames(); // 現在の名前リストも確認
    if (!hasVisited && names.isEmpty && mounted) {
      // 未訪問かつ名前未登録の場合
      setState(() {
        _showNameSettingHint = true;
      });
    }
  }

  // ★ 名前設定画面へ遷移するメソッド（ロック付き）
  void _navigateToChildNameSettings() async {
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
      // メッセージを非表示にする
      setState(() {
        _showNameSettingHint = false;
      });

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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _updateRemainingSeconds();

      final lang = AppLocalizations.of(context)!.localeName;

      // --- 音声再生ロジックをここにまとめる ---
      final List<String> soundsToPlay = [];

      if (_remainingSeconds <= 0) {
        if (!_isTimeUp) {
          if (lang == 'ja') {
            soundsToPlay.add('se/「タイムアップ」.mp3'); // タイムアップ音
          } else {
            soundsToPlay.add('se/english/times_up.mp3');
          }
          setState(() => _isTimeUp = true);
        }
        _timer?.cancel();
      } else if (_remainingSeconds == 10) {
        if (lang == 'ja') {
          soundsToPlay.add('se/「10、9、8、7、6、5、4、3、2、1、0」.mp3'); // 10秒カウントダウン
        } else {
          soundsToPlay.addAll([
            'se/english/ten.mp3',
            'se/english/nine.mp3',
            'se/english/eight.mp3',
            'se/english/seven.mp3',
            'se/english/six.mp3',
            'se/english/five.mp3',
            'se/english/four.mp3',
            'se/english/three.mp3',
            'se/english/two.mp3',
            'se/english/one.mp3',
          ]);
        }
      } else if (_remainingSeconds == 1 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll(['se/「あと」.mp3', 'se/「1」.mp3', 'se/「分（ふん）」.mp3']);
        } else {
          soundsToPlay.addAll(['se/english/one.mp3', 'se/english/minute.mp3']);
        }
      } else if (_remainingSeconds == 2 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll(['se/「あと」.mp3', 'se/「2」.mp3', 'se/「分（ふん）」.mp3']);
        } else {
          soundsToPlay.addAll(['se/english/two.mp3', 'se/english/minute.mp3']);
        }
      } else if (_remainingSeconds == 3 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll(['se/「あと」.mp3', 'se/「3」.mp3', 'se/「分（ふん）」.mp3']);
        } else {
          soundsToPlay.addAll([
            'se/english/three.mp3',
            'se/english/minute.mp3',
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
          soundsToPlay.addAll(['se/english/four.mp3', 'se/english/minute.mp3']);
        }
      } else if (_remainingSeconds == 5 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll(['se/「あと」.mp3', 'se/「5」.mp3', 'se/「分（ふん）」.mp3']);
        } else {
          soundsToPlay.addAll(['se/english/five.mp3', 'se/english/minute.mp3']);
        }
      } else if (_remainingSeconds == 10 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll([
            'se/「あと」.mp3',
            'se/「10（じゅう↑）」.mp3',
            'se/「分（ふん）」.mp3',
          ]);
        } else {
          soundsToPlay.addAll(['se/english/ten.mp3', 'se/english/minute.mp3']);
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
            'se/english/fifteen.mp3',
            'se/english/minute.mp3',
          ]);
        }
      } else if (_remainingSeconds == 20 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll(['se/「あと」.mp3', 'se/「20」.mp3', 'se/「分（ふん）」.mp3']);
        } else {
          soundsToPlay.addAll([
            'se/english/twenty.mp3',
            'se/english/minute.mp3',
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
            'se/english/twenty_five.mp3',
            'se/english/minute.mp3',
          ]);
        }
      } else if (_remainingSeconds == 30 * 60) {
        if (lang == 'ja') {
          soundsToPlay.addAll(['se/「あと」.mp3', 'se/「30」.mp3', 'se/「分（ふん）」.mp3']);
        } else {
          soundsToPlay.addAll([
            'se/english/thirty.mp3',
            'se/english/minute.mp3',
          ]);
        }
      }

      // もし再生すべき音があれば、SfxManagerの新しいメソッドを呼び出す
      if (soundsToPlay.isNotEmpty) {
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
        await Future.delayed(const Duration(seconds: 3));
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

  // ★承認ダイアログを表示するメソッド
  void _showApprovalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmation),
          content: Text(
            AppLocalizations.of(
              context,
            )!.askIfFinished(widget.promise['title']),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.notYet),
              onPressed: () {
                try {
                  SfxManager.instance.playTapSound();
                } catch (e) {
                  // エラーが発生した場合
                  print('再生エラー: $e');
                }
                Navigator.of(dialogContext).pop();
                _startTimer();
                setState(() {
                  _isFinishedButtonPressed = false;
                });
              },
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.yesFinished),
              // ★「おわったよ！」ボタンが押されたら、ここから処理が始まる
              onPressed: () async {
                // まず承認ダイアログを閉じる
                Navigator.of(dialogContext).pop();
                // 次に、時間切れかどうかで処理を分岐
                if (!_isTimeUp) {
                  _confettiController.play();
                  try {
                    SfxManager.instance.playTimerWinSound();
                  } catch (e) {
                    // エラーが発生した場合
                    print('再生エラー: $e');
                  }
                  await Future.delayed(const Duration(seconds: 2));

                  // ◯◯がんばったね。
                  final lang = AppLocalizations.of(context)!.localeName;
                  if (_childFullName != null && _childFullName!.isNotEmpty) {
                    await _speak('$_childFullName');
                    await Future.delayed(
                      Duration(milliseconds: 1300 * _namesListCount),
                    );
                  }

                  if (lang == 'ja') {
                    try {
                      SfxManager.instance.playTimerLoseSound();
                    } catch (e) {
                      // エラーが発生した場合
                      print('再生エラー: $e');
                    }
                  } else {
                    final List<String> soundsToPlay = [];
                    soundsToPlay.addAll(['se/english/you_did_your_best.mp3']);
                    try {
                      SfxManager.instance.playSequentialSounds(soundsToPlay);
                    } catch (e) {
                      // エラーが発生した場合
                      print('再生エラー: $e');
                    }
                  }
                  await Future.delayed(const Duration(seconds: 1));

                  try {
                    SfxManager.instance.playTimerWinSound2();
                  } catch (e) {
                    // エラーが発生した場合
                    print('再生エラー: $e');
                  }
                  await Future.delayed(const Duration(seconds: 4));
                  // 時間内なら -> ルーレットへ
                  if (mounted) {
                    _showRouletteAndFinish();
                  }
                } else {
                  final lang = AppLocalizations.of(context)!.localeName;
                  if (_childFullName != null && _childFullName!.isNotEmpty) {
                    await _speak('$_childFullName');
                    await Future.delayed(
                      Duration(milliseconds: 1300 * _namesListCount),
                    );
                  }

                  if (lang == 'ja') {
                    try {
                      SfxManager.instance.playTimerLoseSound();
                    } catch (e) {
                      // エラーが発生した場合
                      print('再生エラー: $e');
                    }
                  } else {
                    final List<String> soundsToPlay = [];
                    soundsToPlay.addAll(['se/english/you_did_your_best.mp3']);
                    try {
                      SfxManager.instance.playSequentialSounds(soundsToPlay);
                    } catch (e) {
                      // エラーが発生した場合
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
            ),
          ],
        );
      },
    );
  }

  // ★ルーレットを表示して、その結果で終了処理を呼ぶメソッド
  void _showRouletteAndFinish() async {
    final basePoints = widget.promise['points'] as int? ?? 0;

    final multiplier = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RouletteDialog(basePoints: basePoints),
    );
    // ルーレットの結果（1倍か2倍か）で終了処理を呼ぶ
    _finishPromise(pointMultiplier: multiplier ?? 1, exp: 3);
  }

  // ★ポイントを計算して、画面を閉じる最終処理メソッド
  void _finishPromise({required num pointMultiplier, required int exp}) async {
    final basePoints = widget.promise['points'] as int? ?? 0;
    int pointsAwarded = (basePoints * pointMultiplier).toInt();

    if (widget.isEmergency) {
      await SharedPrefsHelper.saveEmergencyPromise(null);
    }
    if (!mounted) return;
    Navigator.of(context).pop({'points': pointsAwarded, 'exp': exp});
  }

  // 応援フレーズのリスト
  final List<String> _encouragements = [
    'Keep up the good work!',
    'Try your best!',
    'Go for it!',
    'You got this!',
    'Keep it up!',
  ];

  // ランダムな応援フレーズを返すメソッド
  String getRandomEncouragement() {
    final random = Random();
    final index = random.nextInt(
      _encouragements.length,
    ); // 0からリストの長さ-1までのランダムな整数を生成
    return _encouragements[index]; // ランダムに選ばれたフレーズを返す
  }

  // 悲しいフレーズリスト
  final List<String> _sadPhrasesEnglish = [
    "Oh... that's too bad...",
    "Aww... I was hoping you'd finish...",
    "We'll get it next time!",
    "Oh no...",
    "That's okay, maybe next time.",
  ];

  // 悲しいフレーズを返却
  String getRandomSadPhraseEnglish() {
    final random = Random();
    final index = random.nextInt(_sadPhrasesEnglish.length);
    return _sadPhrasesEnglish[index];
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
            Stack(
              // ★ Stackでアイコンと吹き出しを重ねる準備
              alignment: Alignment.topRight, // 吹き出しをアイコンの右上に配置
              children: [
                // 名前設定画面へのアイコンボタン
                IconButton(
                  icon: const Icon(Icons.face_retouching_natural),
                  onPressed: _navigateToChildNameSettings,
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
                  Text(
                    _formatDuration(_remainingSeconds), // タイマー表示
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: _isTimeUp ? Colors.red : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _isTimeUp
                      ? Text(
                          AppLocalizations.of(context)!.pointsHalf(
                                (widget.promise['points'] / 2)
                                    .floor()
                                    .toString(),
                              ) +
                              '\n' +
                              AppLocalizations.of(context)!.timerExpFailure,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.red[700],
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          AppLocalizations.of(
                                context,
                              )!.pointsChance(widget.promise['points']) +
                              '\n' +
                              AppLocalizations.of(context)!.timerExpChance,
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    // ★「おわった！」ボタンは、常に承認ダイアログを呼び出すだけ
                    onPressed: _isFinishedButtonPressed
                        ? null
                        : () {
                            setState(() {
                              _isFinishedButtonPressed = true;
                            });
                            _timer?.cancel();
                            _showApprovalDialog();
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.finished),
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
                    Image.asset(currentCharacterPath, height: 180),
                    Row(
                      children: [
                        // 応援マークボタン
                        IconButton(
                          icon: const Icon(
                            Icons.celebration,
                            color: Colors.pinkAccent,
                          ),
                          iconSize: 40,
                          onPressed: _isInteractionBusy
                              ? null
                              : () async {
                                  setState(() {
                                    _isInteractionBusy = true;
                                  });
                                  try {
                                    BgmManager.instance.pause();
                                  } catch (e) {
                                    // エラーが発生した場合
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
                                  final lang = AppLocalizations.of(
                                    context,
                                  )!.localeName;
                                  if (lang == 'ja') {
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
                                        // エラーが発生した場合
                                        print('再生エラー: $e');
                                      }
                                      if (mounted) {
                                        // ★ 安全チェック
                                        setState(() {
                                          _isInteractionBusy = false;
                                        });
                                      }
                                    },
                                  );
                                },
                        ),
                        const SizedBox(width: 16),
                        // 悲しい顔マークボタン
                        IconButton(
                          icon: const Icon(
                            Icons.sentiment_very_dissatisfied,
                            color: Colors.blueAccent,
                          ),
                          iconSize: 40,
                          onPressed: _isInteractionBusy
                              ? null
                              : () async {
                                  setState(() {
                                    _isInteractionBusy = true;
                                    _isCharacterSad = true;
                                  });
                                  try {
                                    BgmManager.instance.pause();
                                  } catch (e) {
                                    // エラーが発生した場合
                                    print('再生エラー: $e');
                                  }
                                  final lang = AppLocalizations.of(
                                    context,
                                  )!.localeName;
                                  if (lang == 'ja') {
                                    await SfxManager.instance
                                        .playRandomSadSound();
                                  } else {
                                    await _speak(getRandomSadPhraseEnglish());
                                  }
                                  // 3秒後に元の状態に戻す
                                  Future.delayed(
                                    const Duration(seconds: 3),
                                    () {
                                      try {
                                        BgmManager.instance.resume();
                                      } catch (e) {
                                        // エラーが発生した場合
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // ★ 初回のみ表示される吹き出し
            if (_showNameSettingHint)
              Positioned(
                top: 0, // アイコンの上端に合わせる
                right: 20, // アイコンの少し左に配置 (調整が必要)
                child: IgnorePointer(
                  // 吹き出し自体はタップできないように
                  child: ScaleTransition(
                    scale: _hintScaleAnimation, // ★ 作成したアニメーションを適用
                    child: Container(
                      // ★ 吹き出し本体（Stackや三角形は削除）
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[100]?.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.nameSettingHint,
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                    ),
                  ),
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
        // 画面下部にバナーを設置
        bottomNavigationBar: const AdBanner(),
      ),
    );
  }
}
