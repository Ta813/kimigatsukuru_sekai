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

  /// 点滅の色（デフォルトは purpleAccent）
  final Color color;

  const BlinkingEffect({
    super.key,
    required this.child,
    this.isBlinking = true,
    this.borderRadius = 8.0,
    this.color = Colors.purpleAccent,
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
        // 🌟 修正: 影を完全にやめて、ウィジェット自体を少しだけ拡大縮小させる
        // 1.0（元のサイズ） 〜 1.05（5%拡大） の間をループする
        final scale = 1.0 + (_controller.value * 0.2);
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}
