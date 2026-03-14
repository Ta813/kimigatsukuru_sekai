// lib/widgets/blinking_effect.dart

import 'package:flutter/material.dart';

/// 子ウィジェットを赤く点滅させる共通ラッパー。
/// [isBlinking] が false の場合はアニメーションせず、そのまま child を返す。
class BlinkingEffect extends StatefulWidget {
  final Widget child;

  /// true の時だけ点滅する
  final bool isBlinking;

  /// ボタンの丸みに合わせて調整（デフォルト 8.0）
  final double borderRadius;

  const BlinkingEffect({
    super.key,
    required this.child,
    this.isBlinking = true,
    this.borderRadius = 8.0,
  });

  @override
  State<BlinkingEffect> createState() => _BlinkingEffectState();
}

class _BlinkingEffectState extends State<BlinkingEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 0.8秒かけて赤くなり、また元に戻るループアニメーション
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.isBlinking) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BlinkingEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBlinking) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 点滅しない場合はそのまま返す（パフォーマンス最適化）
    if (!widget.isBlinking) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                // アニメーション値(0.0〜1.0)に合わせて赤い影を変化させる
                color: Colors.redAccent.withValues(
                  alpha: _controller.value * 0.8,
                ),
                spreadRadius: 6 * _controller.value,
                blurRadius: 10,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
