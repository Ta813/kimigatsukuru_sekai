// lib/helpers/widget_capture_helper.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:home_widget/home_widget.dart';
import 'package:kimigatsukuru_sekai/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import '../managers/sfx_manager.dart';

class WidgetCaptureHelper {
  static Future<void> captureAndSetWidget(
    BuildContext context,
    GlobalKey captureKey,
  ) async {
    try {
      // L10nを取得
      final l10n = AppLocalizations.of(context)!;
      // 1. レンダリング枠を取得して画像化
      RenderRepaintBoundary boundary =
          captureKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image originalImage = await boundary.toImage(pixelRatio: 1.0);

      // ==============================================================
      // 🌟 ウィジェット用のデザインキャンバス（512x512の正方形）を作成
      // ==============================================================
      const double targetSize = 512.0;
      final recorder = ui.PictureRecorder();
      final targetRect = const Rect.fromLTWH(0, 0, targetSize, targetSize);
      final canvas = Canvas(recorder, targetRect);

      // ① 背景を可愛く塗りつぶす＆角を丸くする
      const double borderRadius = 32.0; // ウィジェットの角丸
      final bgPaint = Paint()
        ..color = const Color(0xFFFFF3E0); // 優しいオレンジ背景（お好みで変更！）
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          targetRect,
          const Radius.circular(borderRadius),
        ),
        bgPaint,
      );

      // ② 横長の「元の画面」を真ん中に配置するための計算
      final double aspectRatio = originalImage.height / originalImage.width;
      final double imgWidth = targetSize;
      final double imgHeight = targetSize * aspectRatio;
      final double dy = (targetSize - imgHeight) / 2.0; // 上下の余白の高さ

      // ③ 元の画面を真ん中に描画
      canvas.drawImageRect(
        originalImage,
        Rect.fromLTWH(
          0,
          0,
          originalImage.width.toDouble(),
          originalImage.height.toDouble(),
        ),
        Rect.fromLTWH(0, dy, imgWidth, imgHeight), // 真ん中に配置
        Paint()..filterQuality = ui.FilterQuality.low,
      );

      // ④ 空いた部分（上と下）に文字を描く！
      final textPainter = TextPainter(textDirection: TextDirection.ltr);

      // --- 上の文字 ---
      textPainter.text = TextSpan(
        text: l10n.widgetCreatedWorld,
        style: TextStyle(
          color: Color(0xFFFF7043),
          fontSize: 48,
          fontWeight: FontWeight.w900,
        ),
      );
      textPainter.layout();
      // 真ん中揃えで配置
      textPainter.paint(
        canvas,
        Offset(
          (targetSize - textPainter.width) / 2,
          (dy - textPainter.height) / 2,
        ),
      );

      // --- 下の文字 ---
      textPainter.text = TextSpan(
        text: l10n.widgetTapToPlay,
        style: TextStyle(
          color: Color(0xFFFF7043),
          fontSize: 45,
          fontWeight: FontWeight.w900,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (targetSize - textPainter.width) / 2,
          dy + imgHeight + (dy - textPainter.height) / 2,
        ),
      );

      // 画像を完成させる
      final picture = recorder.endRecording();
      ui.Image finalImage = await picture.toImage(
        targetSize.toInt(),
        targetSize.toInt(),
      );
      final byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final pngBytes = byteData!.buffer.asUint8List();
      // ==============================================================

      // 2. 保存
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/widget_custom_bg.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // 3. ウィジェットへのデータ送信
      HomeWidget.setAppGroupId('group.com.kotoapp.kimigatsukurusekai');
      await HomeWidget.saveWidgetData<String>(
        'widget_background_path',
        imagePath,
      );
      await HomeWidget.saveWidgetData<String>(
        'widget_action',
        'open_action_dialog',
      );

      // 4. ウィジェットを更新
      await HomeWidget.updateWidget(
        name: 'HomeWidgetProvider',
        iOSName: 'KimigatsukuruWidget',
      );

      try {
        SfxManager.instance.playSuccessSound();
      } catch (_) {}

      // ==============================================================
      // 🌟 【ここを修正】
      // 横画面アプリの場合、Androidの requestPinWidget はホーム画面の向きを
      // バグらせてしまうため使用せず、両OS共通で「案内ダイアログ」を表示します。
      // ==============================================================
      Navigator.pop(context); // ロード画面を閉じる
      if (context.mounted) {
        _showGuideDialog(context);
      }
    } catch (e) {
      debugPrint('Widget Capture Error: $e');
    }
  }

  // 🌟 名前を _showGuideDialog に変更し、Android/iOS両方で使える文言にしました
  static void _showGuideDialog(BuildContext context) {
    // L10nを取得
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.widgetReadyTitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.widgetReadyDescription,
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.widgetGotIt,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
