// lib/screens/timer/timer_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../helpers/shared_prefs_helper.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'roulette_dialog.dart';
import '../../managers/sfx_manager.dart';
import '../../managers/bgm_manager.dart';
import '../../widgets/ad_banner.dart';

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

class _TimerScreenState extends State<TimerScreen> with WidgetsBindingObserver {
  Timer? _timer; // タイマーを管理するための変数
  DateTime? _endTime;
  int _remainingSeconds = 0; // 残り時間を秒で管理
  bool _isTimeUp = false;

  // この画面が表示された瞬間に、一度だけ呼ばれる初期化処理
  @override
  void initState() {
    super.initState();
    // ★アプリの状態変化の監視を開始
    WidgetsBinding.instance.addObserver(this);
    // ★画面が表示されたら、スリープを無効にする
    WakelockPlus.enable();

    final durationInMinutes = widget.promise['duration'] as int? ?? 20;
    _endTime = DateTime.now().add(Duration(minutes: durationInMinutes));

    _startTimer();
  }

  // この画面が閉じられる時に、一度だけ呼ばれるお片付け処理
  @override
  void dispose() {
    // ★アプリの状態変化の監視を終了
    WidgetsBinding.instance.removeObserver(this);
    // ★画面が閉じられたら、スリープを有効に戻す（非常に重要！）
    WakelockPlus.disable();
    _timer?.cancel(); // タイマーが動いていたら、必ず停止する
    super.dispose();
  }

  // ★アプリの状態が変化した時に呼ばれる
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // アプリが前面に戻ってきたら、タイマーの表示を更新
      _updateRemainingSeconds();
      // もしタイマーが止まっていたら再開
      if (_timer == null || !_timer!.isActive) {
        _startTimer();
      }
    } else {
      // アプリが裏に回ったら、UI更新用のタイマーは一旦停止
      _timer?.cancel();
    }
  }

  // ★残り時間を計算して更新する処理
  void _updateRemainingSeconds() {
    if (_endTime == null) return;
    final now = DateTime.now();
    // 「終わる時刻」と「今の時刻」の差を計算
    final difference = _endTime!.difference(now);

    // 残り時間が0以下なら0に、そうでなければ残り秒数をセット
    setState(() {
      _remainingSeconds = difference.isNegative ? 0 : difference.inSeconds;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _updateRemainingSeconds();

      // --- 音声再生ロジックをここにまとめる ---
      final List<String> soundsToPlay = [];

      if (_remainingSeconds <= 0) {
        if (!_isTimeUp) {
          soundsToPlay.add('se/「タイムアップ」.mp3'); // タイムアップ音
          setState(() => _isTimeUp = true);
        }
        _timer?.cancel();
      } else if (_remainingSeconds == 10) {
        soundsToPlay.add('se/「10、9、8、7、6、5、4、3、2、1、0」.mp3'); // 10秒カウントダウン
      } else if (_remainingSeconds == 1 * 60) {
        soundsToPlay.addAll(['se/「あと」.mp3', 'se/「1」.mp3', 'se/「分（ふん）」.mp3']);
      } else if (_remainingSeconds == 2 * 60) {
        soundsToPlay.addAll(['se/「あと」.mp3', 'se/「2」.mp3', 'se/「分（ふん）」.mp3']);
      } else if (_remainingSeconds == 3 * 60) {
        soundsToPlay.addAll(['se/「あと」.mp3', 'se/「3」.mp3', 'se/「分（ふん）」.mp3']);
      } else if (_remainingSeconds == 4 * 60) {
        soundsToPlay.addAll([
          'se/「あと」.mp3',
          'se/「4（よん）」.mp3',
          'se/「分（ふん）」.mp3',
        ]);
      } else if (_remainingSeconds == 5 * 60) {
        soundsToPlay.addAll(['se/「あと」.mp3', 'se/「5」.mp3', 'se/「分（ふん）」.mp3']);
      } else if (_remainingSeconds == 10 * 60) {
        soundsToPlay.addAll([
          'se/「あと」.mp3',
          'se/「10（じゅう↑）」.mp3',
          'se/「分（ふん）」.mp3',
        ]);
      } else if (_remainingSeconds == 15 * 60) {
        soundsToPlay.addAll([
          'se/「あと」.mp3',
          'se/「10（じゅう↓）」.mp3',
          'se/「5」.mp3',
          'se/「分（ふん）」.mp3',
        ]);
      } else if (_remainingSeconds == 20 * 60) {
        soundsToPlay.addAll(['se/「あと」.mp3', 'se/「20」.mp3', 'se/「分（ふん）」.mp3']);
      } else if (_remainingSeconds == 25 * 60) {
        soundsToPlay.addAll([
          'se/「あと」.mp3',
          'se/「20（に↑じゅう↓）」.mp3',
          'se/「5」.mp3',
          'se/「分（ふん）」.mp3',
        ]);
      } else if (_remainingSeconds == 30 * 60) {
        soundsToPlay.addAll(['se/「あと」.mp3', 'se/「30」.mp3', 'se/「分（ふん）」.mp3']);
      }

      // もし再生すべき音があれば、SfxManagerの新しいメソッドを呼び出す
      if (soundsToPlay.isNotEmpty) {
        // 1. BGMを一時停止
        BgmManager.instance.pause();
        // 2. 効果音の再生が「終わるのを待つ」
        await SfxManager.instance.playSequentialSounds(soundsToPlay);
        await Future.delayed(const Duration(seconds: 3));
        // 3. BGMを再開
        BgmManager.instance.resume();
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
          title: const Text('かくにん'),
          content: Text('${widget.promise['title']} は、ちゃんとおわったかな？'),
          actions: <Widget>[
            TextButton(
              child: const Text('まだだよ'),
              onPressed: () {
                SfxManager.instance.playTapSound();
                Navigator.of(dialogContext).pop();
                _startTimer();
              },
            ),
            ElevatedButton(
              child: const Text('おわったよ！'),
              // ★「おわったよ！」ボタンが押されたら、ここから処理が始まる
              onPressed: () {
                // まず承認ダイアログを閉じる
                Navigator.of(dialogContext).pop();
                // 次に、時間切れかどうかで処理を分岐
                if (!_isTimeUp) {
                  SfxManager.instance.playTimerWinSound();
                  // 時間内なら -> ルーレットへ
                  _showRouletteAndFinish();
                } else {
                  SfxManager.instance.playTimerLoseSound();
                  // 時間切れなら -> ポイント半分で終了
                  _finishPromise(pointMultiplier: 0.5);
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
    final multiplier = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const RouletteDialog(),
    );
    // ルーレットの結果（1倍か2倍か）で終了処理を呼ぶ
    _finishPromise(pointMultiplier: multiplier ?? 1);
  }

  // ★ポイントを計算して、画面を閉じる最終処理メソッド
  void _finishPromise({required num pointMultiplier}) async {
    final basePoints = widget.promise['points'] as int? ?? 0;
    final pointsAwarded = (basePoints * pointMultiplier).toInt();

    if (widget.isEmergency) {
      await SharedPrefsHelper.saveEmergencyPromise(null);
    }
    if (!mounted) return;
    Navigator.of(context).pop(pointsAwarded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // もらった情報を使って、タイトルを表示します
        backgroundColor: widget.isEmergency ? Colors.red[400] : null,
        title: Text('${widget.promise['title']} に挑戦中！'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatDuration(_remainingSeconds), // タイマー表示
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: _isTimeUp ? Colors.red : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            _isTimeUp
                ? Text(
                    'おしい！ポイントは${widget.promise['points'] / 2}になるよ！',
                    style: TextStyle(fontSize: 20, color: Colors.red[700]),
                  )
                : Text(
                    '${widget.promise['points']}ポイント ゲットのチャンス！',
                    style: const TextStyle(fontSize: 20),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              // ★「おわった！」ボタンは、常に承認ダイアログを呼び出すだけ
              onPressed: () {
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
              child: const Text('おわった！'),
            ),
          ],
        ),
      ),
      // 画面下部にバナーを設置
      bottomNavigationBar: const AdBanner(),
    );
  }
}
