import 'package:flutter/material.dart';

/// 子ウィジェットを「ぽよん、ぽよん」と継続的にアニメーションさせるウィジェット
class PoyonAnimation extends StatefulWidget {
  final Widget child;

  const PoyonAnimation({super.key, required this.child});

  @override
  State<PoyonAnimation> createState() => _PoyonAnimationState();
}

class _PoyonAnimationState extends State<PoyonAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // 2秒サイクルでアニメーションを繰り返す
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(); // 無限ループ

    _scaleAnimation = TweenSequence<double>([
      // 前半：1.0 から 1.2 へ「ぽよん」とはじける
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70, // 時間の70%を使う
      ),
      // 後半：ゆっくり 1.0 に戻る
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30, // 残りの30%で戻る
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}
