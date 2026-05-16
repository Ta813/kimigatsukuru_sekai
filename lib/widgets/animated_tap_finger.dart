import 'package:flutter/material.dart';

/// タップを促すポワンポワン動く指のアニメーションウィジェット
class AnimatedTapFinger extends StatefulWidget {
  const AnimatedTapFinger({super.key});

  @override
  State<AnimatedTapFinger> createState() => _AnimatedTapFingerState();
}

class _AnimatedTapFingerState extends State<AnimatedTapFinger>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ScaleTransition(
        scale: _animation,
        child: const Icon(
          Icons.touch_app,
          size: 50,
          color: Colors.orangeAccent,
          shadows: [
            Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
      ),
    );
  }
}
