import 'package:flutter/material.dart';
import '../../helpers/shared_prefs_helper.dart';
import '../../l10n/app_localizations.dart';

class PasscodeLockDialog extends StatefulWidget {
  const PasscodeLockDialog({super.key});

  @override
  State<PasscodeLockDialog> createState() => _PasscodeLockDialogState();
}

class _PasscodeLockDialogState extends State<PasscodeLockDialog> {
  String _enteredPasscode = '';
  String? _errorMessage;

  void _onNumberPressed(String number) {
    if (_enteredPasscode.length < 4) {
      setState(() {
        _enteredPasscode += number;
      });
    }

    // 4桁に達したら確認
    if (_enteredPasscode.length == 4) {
      _verifyPasscode();
    }
  }

  void _onDeletePressed() {
    if (_enteredPasscode.isNotEmpty) {
      setState(() {
        _enteredPasscode = _enteredPasscode.substring(
          0,
          _enteredPasscode.length - 1,
        );
      });
    }
  }

  Future<void> _verifyPasscode() async {
    final savedPasscode = await SharedPrefsHelper.loadPasscode();
    if (_enteredPasscode == savedPasscode) {
      if (mounted) Navigator.pop(context, true); // 正解ならtrueを返す
    } else {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.passcodeIncorrect;
        _enteredPasscode = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.passcodeEnter4Digit),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // パスワード入力表示
          Text(
            _enteredPasscode.padRight(4, '◦'),
            style: const TextStyle(fontSize: 20, letterSpacing: 8),
          ),

          Container(
            height: 20, // 高さを固定してレイアウトが崩れないようにする
            alignment: Alignment.center,
            child: _errorMessage != null
                ? Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  )
                : null, // メッセージがなければ何も表示しない
          ),
          // ★ 作成したキーパッドウィジェットをここに配置
          Container(
            width: 240, // 横幅も指定するとレイアウトが安定します
            height: 160, // 高さを適切な値に固定します
            child: NumericKeypad(
              onNumberPressed: _onNumberPressed,
              onDeletePressed: _onDeletePressed,
            ),
          ),
        ],
      ),
    );
  }
}

class NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onNumberPressed;
  final VoidCallback onDeletePressed;

  const NumericKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    // ボタンに表示するラベルのリスト
    final List<String> buttons = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '', '0', '⌫', // ⌫ は削除ボタン
    ];

    return GridView.builder(
      // GridView自体のスクロールを無効化
      physics: const NeverScrollableScrollPhysics(),
      // ColumnやAlertDialogの中で高さを自動調整
      shrinkWrap: true,
      // 3列のグリッド
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 3,
        crossAxisSpacing: 2,
        childAspectRatio: 2.2, // ボタンの縦横比を調整
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        final item = buttons[index];

        // 空のラベルの場合は何も表示しない
        if (item.isEmpty) {
          return Container();
        }

        // 削除ボタンの場合
        if (item == '⌫') {
          return TextButton(
            child: const Icon(Icons.backspace_outlined, size: 14),
            onPressed: onDeletePressed,
          );
        }

        // 数字ボタンの場合
        return TextButton(
          child: Text(
            item,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          onPressed: () => onNumberPressed(item),
        );
      },
    );
  }
}
