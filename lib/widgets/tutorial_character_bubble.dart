// lib/widgets/tutorial_character_bubble.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../helpers/shared_prefs_helper.dart'; // 🌟 パスはプロジェクトに合わせて調整してください

class TutorialCharacterBubble extends StatefulWidget {
  final String text;
  final int? currentStep;
  final int? totalSteps;

  const TutorialCharacterBubble({
    super.key,
    required this.text,
    this.currentStep,
    this.totalSteps,
  });

  @override
  State<TutorialCharacterBubble> createState() =>
      _TutorialCharacterBubbleState();
}

class _TutorialCharacterBubbleState extends State<TutorialCharacterBubble> {
  // 🌟 最初はデフォルトのウサギを設定しておく
  String _charPath = 'assets/images/character_usagi.gif';

  @override
  void initState() {
    super.initState();
    _loadCharacter(); // 🌟 ウィジェットが表示されると同時にキャラを読み込む
  }

  Future<void> _loadCharacter() async {
    final characters = await SharedPrefsHelper.loadEquippedCharacters();
    if (mounted && characters.isNotEmpty) {
      setState(() {
        _charPath = characters.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty) return const SizedBox.shrink();

    final bool showProgress =
        widget.currentStep != null && widget.totalSteps != null;

    // 🌟 修正: DefaultTextStyle を一番外側に置くことで、フォントサイズや行間の計算を正常化します
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌟 読み込んだ応援キャラクター画像
            Image.asset(
              _charPath,
              width: 140,
              height: 140,
              fit: BoxFit.contain, // 画像の比率を保つ
            ),
            // 🌟 吹き出しデザイン
            Padding(
              padding: const EdgeInsets.only(top: 30), // キャラの口元に高さを合わせる
              child: Stack(
                clipBehavior: Clip.none, // はみ出しを許可
                children: [
                  // ① メインの吹き出し枠
                  Container(
                    width: 350, // 🌟 ここで横幅を固定
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4),
                      borderRadius: BorderRadius.circular(16), // 🌟 角は全部丸くする
                      border: Border.all(color: Colors.orange, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 進捗バーとステップ数の表示
                        if (showProgress) ...[
                          Row(
                            children: [
                              Text(
                                'STEP ${widget.currentStep}/${widget.totalSteps}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange, // 枠線に色を合わせる
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value:
                                        widget.currentStep! /
                                        widget.totalSteps!,
                                    minHeight: 8,
                                    backgroundColor: Colors.orange.withOpacity(
                                      0.2,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.orange,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10), // バーとテキストの間の余白
                        ],
                        // 元々のテキスト
                        Text(
                          widget.text,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 18, // バーが入る分、少しだけスッキリしたサイズに調整
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ② 左側の「しっぽ（三角）」
                  Positioned(
                    left: -6, // 左に少しはみ出させる
                    top: 18, // 上からの位置（口元に合わせる）
                    child: Transform.rotate(
                      angle: 45 * math.pi / 180, // 🌟 四角形を45度回転させてひし形（◇）にする
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF9C4), // 背景と同じ色にしてメイン枠と馴染ませる
                          border: Border(
                            // 回転させた時の左下と右下を枠線にする
                            left: BorderSide(color: Colors.orange, width: 2),
                            bottom: BorderSide(color: Colors.orange, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
