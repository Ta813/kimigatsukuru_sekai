// lib/widgets/avatar_display.dart

import 'package:flutter/material.dart';

class AvatarDisplay extends StatelessWidget {
  final String? face;
  final String? clothes;
  final String? hair;
  final String? headgear;
  final String? accessory;
  final double size;

  const AvatarDisplay({
    super.key,
    this.face,
    this.clothes,
    this.hair,
    this.headgear,
    this.accessory,
    this.size = 80, // デフォルトのサイズ
  });

  @override
  Widget build(BuildContext context) {
    // 重ね合わせの順番をここで一元管理！
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hair != null && hair!.isNotEmpty)
            Image.asset(hair!, height: size),
          if (face != null && face!.isNotEmpty)
            Image.asset(face!, height: size),
          if (clothes != null && clothes!.isNotEmpty)
            Image.asset(clothes!, height: size),
          if (headgear != null && headgear!.isNotEmpty)
            Image.asset(headgear!, height: size),
          if (accessory != null && accessory!.isNotEmpty)
            Image.asset(accessory!, height: size),
        ],
      ),
    );
  }
}
