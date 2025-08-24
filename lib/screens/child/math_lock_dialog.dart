// lib/screens/child/math_lock_dialog.dart

import 'dart:math';
import 'package:flutter/material.dart';

class MathLockDialog extends StatefulWidget {
  const MathLockDialog({super.key});

  @override
  State<MathLockDialog> createState() => _MathLockDialogState();
}

class _MathLockDialogState extends State<MathLockDialog> {
  late int _num1;
  late int _num2;
  late int _correctAnswer;
  String? _errorMessage;

  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = Random();
    _num1 = random.nextInt(9) + 1; // 1から9までの数
    _num2 = random.nextInt(9) + 1; // 1から9までの数
    _correctAnswer = _num1 * _num2; // ★掛け算に変更
  }

  void _checkAnswer() {
    final int? userAnswer = int.tryParse(_answerController.text);
    if (userAnswer == _correctAnswer) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = 'ざんねん、ちがうみたい';
        _answerController.clear();
        _generateQuestion();
      });
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _errorMessage = null);
      });
    }
  }

  void _onNumpadTapped(String value) {
    if (value == 'C') {
      _answerController.clear();
    } else {
      _answerController.text += value;
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> buttons = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'C',
      '0',
      '',
    ];

    return AlertDialog(
      content: SizedBox(
        // ★高さを少し柔軟性のある範囲で指定
        height: MediaQuery.of(context).size.height * 0.65,
        width: 250,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 横方向の中央揃え
              crossAxisAlignment: CrossAxisAlignment.center, // 縦方向の中央揃え
              children: [
                // 問題テキスト
                Text(
                  '$_num1 × $_num2 =', // 「?」を「=」に変更
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16), // 問題と答えの間のスペース
                // 答えの入力ボックス
                SizedBox(
                  width: 80, // ★テキストボックスの横幅を80に固定
                  child: TextFormField(
                    controller: _answerController,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      errorText: _errorMessage,
                      // エラーメッセージが表示されてもレイアウトが崩れないように調整
                      errorStyle: const TextStyle(height: 2.5, fontSize: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            // ★残りのスペースを全てGridViewに与える
            Expanded(
              child: GridView.builder(
                itemCount: buttons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                  childAspectRatio: 2.2, // ボタンの縦横比を調整
                ),
                itemBuilder: (context, index) {
                  final buttonValue = buttons[index];
                  if (buttonValue.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return ElevatedButton(
                    onPressed: () => _onNumpadTapped(buttonValue),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(0),
                    ),
                    child: Text(
                      buttonValue,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('やめる'),
        ),
        ElevatedButton(onPressed: _checkAnswer, child: const Text('OK')),
      ],
    );
  }
}
