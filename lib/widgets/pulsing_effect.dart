import 'package:flutter/material.dart';

/// 中身のウィジェットを鼓動のように拡大・縮小させるエフェクト
class PulsingEffect extends StatefulWidget {
  final Widget child;
  final bool isPulsing; // アニメーションを動かすかどうかのフラグ
  final double minScale; // 最小の大きさ（1.0 が標準）
  final double maxScale; // 最大の大きさ

  const PulsingEffect({
    super.key,
    required this.child,
    required this.isPulsing,
    this.minScale = 1.0, // デフォルトは標準サイズ
    this.maxScale = 1.3, // デフォルトは1.3倍
  });

  @override
  State<PulsingEffect> createState() => _PulsingEffectState();
}

class _PulsingEffectState extends State<PulsingEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // アニメーションの速度を設定（800ミリ秒かけて往復）
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Curves.easeInOut を使って、滑らかに動きを加速・減速させる
    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // フラグがONなら最初からアニメーションを開始
    if (widget.isPulsing) {
      _controller.repeat(reverse: true); // 往復（大きく -> 小さく）を繰り返す
    }
  }

  @override
  void didUpdateWidget(covariant PulsingEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部からフラグが切り替えられた時の処理
    if (widget.isPulsing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPulsing && _controller.isAnimating) {
      _controller.stop();
      _controller.reset(); // 停止時は元の大きさに戻す
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // メモリリーク防止
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // アニメーションしない時は、そのまま表示
    if (!widget.isPulsing) {
      return widget.child;
    }

    // ScaleTransition を使って、子ウィジェットを拡大・縮小
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}
