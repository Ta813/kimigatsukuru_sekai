import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedAvatar extends StatefulWidget {
  final Widget child;

  const AnimatedAvatar({super.key, required this.child});

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar>
    with TickerProviderStateMixin {
  // 🌟 コントローラーが複数になるので変更

  // --- 呼吸アニメーション用 ---
  late AnimationController _breatheController;
  late Animation<double> _scaleYAnimation;
  late Animation<double> _scaleXAnimation;
  late Animation<double> _rotateAnimation;

  // --- 🌟 ランダムアクション用 ---
  late AnimationController _actionController;
  Timer? _actionTimer;
  int _currentAction = 0; // 0:大ジャンプ, 1:一回転, 2:ブルブル

  @override
  void initState() {
    super.initState();

    // ==========================================
    // 1. 呼吸アニメーション（ずっと繰り返す）
    // ==========================================
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    final breatheCurve = CurvedAnimation(
      parent: _breatheController,
      curve: Curves.easeInOutSine,
    );

    _scaleYAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(breatheCurve);
    _scaleXAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(breatheCurve);
    _rotateAnimation = Tween<double>(
      begin: -math.pi / 90,
      end: math.pi / 90,
    ).animate(breatheCurve);

    // ==========================================
    // 2. アクション用アニメーション（1回1秒）
    // ==========================================
    _actionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // ==========================================
    // 3. 4秒ごとにランダムな動きをさせるタイマー
    // ==========================================
    _actionTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted) {
        setState(() {
          // 0, 1, 2, 3, 4, 5のどれかをランダムで選ぶ
          _currentAction = math.Random().nextInt(6);
        });
        _actionController.forward(from: 0.0); // アクション開始！
      }
    });
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _actionController.dispose();
    _actionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 Listenable.merge で、呼吸とアクションの「両方」の変化を監視する
    return AnimatedBuilder(
      animation: Listenable.merge([_breatheController, _actionController]),
      builder: (context, child) {
        // ベースは「呼吸」の動き
        double finalTranslateY = 0.0;
        double finalScaleX = _scaleXAnimation.value;
        double finalScaleY = _scaleYAnimation.value;
        double finalRotateZ = _rotateAnimation.value;

        // 🌟 アクション中（1秒間）は、動きをダイナミックに追加・上書きする
        if (_actionController.isAnimating) {
          double t = _actionController.value; // 0.0 〜 1.0 に向かって増える時間

          if (_currentAction == 0) {
            // 🎬 アクション1：控えめな「ぷにっと小ジャンプ」
            if (t < 0.15) {
              // ① 飛ぶ前の「しゃがみこみ」
              double p = t / 0.15;
              finalScaleY *= 1.0 - (0.3 * p);
              finalScaleX *= 1.0 + (0.3 * p);
            } else if (t < 0.5) {
              // ② 上昇（🌟 高さを 60.0 から 20.0 に変更）
              double p = (t - 0.15) / 0.35;
              finalTranslateY = -20.0 * math.sin(p * math.pi / 2);
              finalScaleY *= 0.7 + (0.5 * p);
              finalScaleX *= 1.3 - (0.5 * p);
            } else if (t < 0.85) {
              // ③ 下降（🌟 高さを 60.0 から 20.0 に変更）
              double p = (t - 0.5) / 0.35;
              finalTranslateY = -20.0 * math.cos(p * math.pi / 2);
              finalScaleY *= 1.2 - (0.2 * p);
              finalScaleX *= 0.8 + (0.2 * p);
            } else if (t < 0.92) {
              // ④ 着地の衝撃で「ぐしゃっ」と潰れる
              double p = (t - 0.85) / 0.07;
              finalScaleY *= 1.0 - (0.4 * p);
              finalScaleX *= 1.0 + (0.4 * p);
            } else {
              // ⑤ ボヨーンと元の形に復帰
              double p = (t - 0.92) / 0.08;
              finalScaleY *= 0.6 + (0.4 * p);
              finalScaleX *= 1.4 - (0.4 * p);
            }
          } else if (_currentAction == 1) {
            // 🎬 アクション2：ルンルン！ごきげんジャンプ（大回転から変更）
            finalTranslateY = -20.0 * math.sin(t * math.pi); // 20pxだけ跳ねる
            // 🌟 空中で右→左→右と軽く揺れる（足をバタバタ・ごきげんな感じ）
            // 0.2 は傾きの強さです。数値を小さくする(0.1など)とさらに控えめになります。
            finalRotateZ += math.sin(t * math.pi * 2) * 0.2;
          } else if (_currentAction == 2) {
            // 🎬 アクション3：ブルブルッ！とよろこぶ（変更なし）
            finalTranslateY = -15.0 * math.sin(t * math.pi); // 軽く跳ねる
            finalRotateZ += math.sin(t * math.pi * 8) * 0.15; // 左右に激しく揺れる
          } else if (_currentAction == 3) {
            // 🌟 追加：アクション4：のび〜っ！と背伸びしてリラックス
            // ジャンプはせずに、上にグーッと伸びてゆっくり戻る
            finalScaleY *= 1.0 + (0.2 * math.sin(t * math.pi)); // 縦に最大20%伸びる
            finalScaleX *= 1.0 - (0.1 * math.sin(t * math.pi)); // 伸びた分、横は少し細くなる
            finalTranslateY =
                -5.0 * math.sin(t * math.pi); // 背伸びに合わせて少しだけ重心が上がる
          } else if (_currentAction == 4) {
            // 🌟 追加：アクション5：ぴょんぴょん！（2回連続の小ジャンプ）
            // 1秒間に2回（波を2つ）作るために math.pi * 2 を使い、abs() で常に上方向に跳ねさせます
            double bounce = math.sin(t * math.pi * 2).abs();
            finalTranslateY = -15.0 * bounce; // 15px上に2回跳ねる

            // 跳ねるタイミングに合わせて、少しだけ縦にシュッと伸びる
            finalScaleY *= 1.0 + (0.1 * bounce);
            finalScaleX *= 1.0 - (0.05 * bounce);
          } else if (_currentAction == 5) {
            // 🌟 追加：アクション6：フレー！フレー！（全身で応援）
            // 1秒間に2回ジャンプします
            double bounce = math.sin(t * math.pi * 2).abs();
            finalTranslateY = -20.0 * bounce; // ぴょんぴょんより少し高めにジャンプ！

            // 🌟 応援のキモ：1回目のジャンプで右に、2回目のジャンプで左に大きく傾く！
            // math.sin(t * math.pi * 2) は、前半でプラス（右）、後半でマイナス（左）になります
            finalRotateZ += math.sin(t * math.pi * 2) * 0.3; // 0.3 は約17度の大きな傾き

            // 元気いっぱいに見せるため、ジャンプ時にシュッと伸びる
            finalScaleY *= 1.0 + (0.15 * bounce);
            finalScaleX *= 1.0 - (0.1 * bounce);
          }
        }

        return Transform.translate(
          offset: Offset(0, finalTranslateY),
          child: Transform(
            alignment: Alignment.bottomCenter, // 常に足元を固定！
            transform: Matrix4.diagonal3Values(finalScaleX, finalScaleY, 1.0)
              ..rotateZ(finalRotateZ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
