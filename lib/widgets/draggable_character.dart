// lib/screens/child_home/draggable_character.dart

import 'package:flutter/material.dart';
import '../../helpers/shared_prefs_helper.dart';
import 'blinking_effect.dart';
import 'animated_hand_slide.dart';

class DraggableCharacter extends StatefulWidget {
  final String id;
  final String? imagePath;
  final Widget? customWidget;
  final Offset position;
  final double size;
  final Function(Offset) onPositionChanged;
  final bool isBlinking;
  final bool isInteractive;

  const DraggableCharacter({
    super.key,
    required this.id,
    this.imagePath,
    this.customWidget,
    required this.position,
    required this.size,
    required this.onPositionChanged,
    this.isBlinking = false,
    this.isInteractive = true,
  });

  @override
  State<DraggableCharacter> createState() => _DraggableCharacterState();
}

class _DraggableCharacterState extends State<DraggableCharacter> {
  @override
  Widget build(BuildContext context) {
    final Widget displayWidget =
        widget.customWidget ??
        Image.asset(widget.imagePath!, height: widget.size);

    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: IgnorePointer(
        ignoring: !widget.isInteractive,
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
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              BlinkingEffect(
                isBlinking: widget.isBlinking,
                color: Colors.purpleAccent,
                child: widget.isInteractive
                    ? displayWidget
                    : ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.black45,
                          BlendMode.srcATop,
                        ), // 触れないことを示すために薄暗くする
                        child: displayWidget,
                      ),
              ),
              if (widget.isBlinking)
                const Positioned(
                  bottom: -20, // Display slightly below the center
                  child: AnimatedHandSlide(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
