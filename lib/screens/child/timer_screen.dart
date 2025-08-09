// lib/screens/timer/timer_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  // StatefulWidgetに変更
  final Map<String, String> promise;

  const TimerScreen({super.key, required this.promise});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer; // タイマーを管理するための変数
  int _remainingSeconds = 0; // 残り時間を秒で管理

  // この画面が表示された瞬間に、一度だけ呼ばれる初期化処理
  @override
  void initState() {
    super.initState();
    _remainingSeconds = 20 * 60;
    _startTimer();
  }

  // この画面が閉じられる時に、一度だけ呼ばれるお片付け処理
  @override
  void dispose() {
    _timer?.cancel(); // タイマーが動いていたら、必ず停止する
    super.dispose();
  }

  void _startTimer() {
    // 1秒ごとに、中の処理を繰り返すタイマーを開始
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return; // 画面が閉じた後に実行されるのを防ぐおまじない
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel(); // 0になったらタイマーを停止
        }
      });
    });
  }

  // 秒を「分:秒」の形式（例: 19:59）に変換するヘルパー関数
  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // もらった情報を使って、タイトルを表示します
        title: Text('${widget.promise['title']} に挑戦中！'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatDuration(_remainingSeconds), // タイマー表示
              style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              '${widget.promise['points']}ポイント ゲットのチャンス！', // もらった情報を使う
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // まず、動いているタイマーを停止します
                _timer?.cancel();

                // 次に、承認ダイアログを表示します
                showDialog(
                  context: context,
                  barrierDismissible: false, // ダイアログの外をタップしても閉じないようにする
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text('かくにん'),
                      content: Text('${widget.promise['title']} は、ちゃんとおわったかな？'),
                      actions: <Widget>[
                        // 「まだ」ボタン
                        TextButton(
                          child: const Text('まだだよ'),
                          onPressed: () {
                            // ダイアログを閉じる
                            Navigator.of(dialogContext).pop();
                            // タイマーを再開する！
                            _startTimer();
                          },
                        ),
                        // 「OK」ボタン
                        ElevatedButton(
                          child: const Text('おわったよ！'),
                          onPressed: () {
                            // 獲得するポイント数を準備（Stringをintに変換）
                            final pointsAwarded =
                                int.tryParse(widget.promise['points'] ?? '0') ??
                                0;
                            // ダイアログを閉じる
                            Navigator.of(dialogContext).pop();
                            // さらに、タイマー画面を閉じつつ、"結果"としてポイント数を渡す
                            Navigator.of(context).pop(pointsAwarded);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              // styleプロパティを追加します
              style: ElevatedButton.styleFrom(
                // ボタンの縦横の余白（パディング）を指定
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                // テキストのスタイルを指定
                textStyle: const TextStyle(
                  fontSize: 30, // 文字の大きさを30
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('おわり！'),
            ),
          ],
        ),
      ),
    );
  }
}
