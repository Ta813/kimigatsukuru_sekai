// lib/screens/child_home/draggable_character.dart

import 'package:flutter/material.dart';
import '../../helpers/shared_prefs_helper.dart';

class DraggableCharacter extends StatefulWidget {
  final String id;
  final String imagePath;
  final Offset position;
  final double size;
  final Function(Offset) onPositionChanged;

  const DraggableCharacter({
    super.key,
    required this.id,
    required this.imagePath,
    required this.position,
    required this.size,
    required this.onPositionChanged,
  });

  @override
  State<DraggableCharacter> createState() => _DraggableCharacterState();
}

class _DraggableCharacterState extends State<DraggableCharacter> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          setState(() {
            widget.onPositionChanged(details.delta);
          });
        },
        onPanEnd: (_) {
          SharedPrefsHelper.saveCharacterPosition(widget.id, widget.position);
        },
        child: Image.asset(widget.imagePath, height: widget.size),
      ),
    );
  }
}
