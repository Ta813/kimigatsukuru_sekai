import 'package:flutter/material.dart';

enum TailDirection { top, bottom, left, right, bottomRight }

class SpeechBubble extends StatelessWidget {
  final String text;
  final TailDirection tailDirection;
  final Duration? duration;

  const SpeechBubble({
    super.key,
    required this.text,
    this.tailDirection = TailDirection.bottom,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tailDirection == TailDirection.top) _buildTail(context),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tailDirection == TailDirection.left) _buildTail(context),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (tailDirection == TailDirection.right) _buildTail(context),
          ],
        ),
        if (tailDirection == TailDirection.bottom) _buildTail(context),
        if (tailDirection == TailDirection.bottomRight)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(left: 170.0),
              child: _buildTail(context),
            ),
          ),
      ],
    );
  }

  Widget _buildTail(BuildContext context) {
    Widget tail;
    switch (tailDirection) {
      case TailDirection.top:
        tail = ClipPath(
          clipper: SpeechBubbleTailClipper(),
          child: Container(width: 16, height: 8, color: Colors.white),
        );
        break;
      case TailDirection.bottom:
      case TailDirection.bottomRight:
        tail = ClipPath(
          clipper: SpeechBubbleTailDownClipper(),
          child: Container(width: 16, height: 8, color: Colors.white),
        );
        break;
      case TailDirection.left:
        tail = RotatedBox(
          quarterTurns: 3,
          child: ClipPath(
            clipper: SpeechBubbleTailClipper(),
            child: Container(width: 16, height: 8, color: Colors.white),
          ),
        );
        break;
      case TailDirection.right:
        tail = RotatedBox(
          quarterTurns: 1,
          child: ClipPath(
            clipper: SpeechBubbleTailClipper(),
            child: Container(width: 16, height: 8, color: Colors.white),
          ),
        );
        break;
    }
    return tail;
  }
}

class SpeechBubbleTailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SpeechBubbleTailDownClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
