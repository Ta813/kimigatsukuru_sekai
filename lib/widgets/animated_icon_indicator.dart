import 'package:flutter/material.dart';

class AnimatedIconIndicator extends StatefulWidget {
  final IconData iconData;
  final Color iconColor;
  final double iconSize;
  final double offsetY; // アニメーションのオフセット量
  final Duration duration; // アニメーションの速度
  final double rotationAngle; // アイコンの回転角度 (ラジアン)

  const AnimatedIconIndicator({
    super.key,
    required this.iconData,
    this.iconColor = Colors.white,
    this.iconSize = 30,
    this.offsetY = 10, // デフォルトで10ピクセル上下する
    this.duration = const Duration(seconds: 1), // デフォルトで1秒間
    this.rotationAngle = 0, // デフォルトで回転なし
  });

  @override
  State<AnimatedIconIndicator> createState() => _AnimatedIconIndicatorState();
}

class _AnimatedIconIndicatorState extends State<AnimatedIconIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true); // 無限リピート（往復）

    _animation = Tween<double>(begin: -widget.offsetY, end: widget.offsetY)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOutSine, // 滑らかな上下動のカーブ
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value), // _animation.valueがオフセットになる
          child: Transform.rotate(
            angle: widget.rotationAngle,
            child: Icon(
              widget.iconData,
              color: widget.iconColor,
              size: widget.iconSize,
            ),
          ),
        );
      },
    );
  }
}
