import 'package:flutter/material.dart';

class AnimatedPlaceholderThumbnail extends StatefulWidget {
  final String text;
  final String? imagePath;
  final double width;
  final double height;
  final double offsetY;
  final Duration duration;
  final IconData? iconData;

  const AnimatedPlaceholderThumbnail({
    super.key,
    required this.text,
    this.imagePath,
    this.width = 120,
    this.height = 80,
    this.offsetY = 5,
    this.duration = const Duration(seconds: 2),
    this.iconData,
  });

  @override
  State<AnimatedPlaceholderThumbnail> createState() =>
      _AnimatedPlaceholderThumbnailState();
}

class _AnimatedPlaceholderThumbnailState
    extends State<AnimatedPlaceholderThumbnail>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _animation = Tween<double>(begin: -widget.offsetY, end: widget.offsetY)
        .animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
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
          offset: Offset(0, _animation.value),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.imagePath == null ? Colors.grey[400] : null,
              border: Border.all(color: Colors.white, width: 4),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
              image: widget.imagePath != null
                  ? DecorationImage(
                      image: AssetImage(widget.imagePath!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.4),
                        BlendMode.darken,
                      ),
                    )
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  widget.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (widget.iconData != null)
                  Positioned(
                    right: 4,
                    child: Icon(
                      widget.iconData,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
