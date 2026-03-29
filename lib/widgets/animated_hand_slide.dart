import 'package:flutter/material.dart';

class AnimatedHandSlide extends StatefulWidget {
  const AnimatedHandSlide({super.key});

  @override
  State<AnimatedHandSlide> createState() => _AnimatedHandSlideState();
}

class _AnimatedHandSlideState extends State<AnimatedHandSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Moves horizontally from left to right
    _animation = Tween<Offset>(
      begin: const Offset(-0.8, 0),
      end: const Offset(0.8, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: const Icon(
        Icons.touch_app, // A finger icon
        color: Colors.white,
        size: 40,
        shadows: [
          Shadow(
            color: Colors.black54,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
