import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImageShareHelper {
  /// 指定したGlobalKeyを持つウィジェットを画像化してシェアする
  static Future<void> shareWidget({
    required GlobalKey globalKey,
    required String shareText,
  }) async {
    try {
      // 1. GlobalKeyから描画オブジェクトを取得
      final boundary =
          globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      // 2. ウィジェットを画像（ui.Image）に変換 (pixelRatioで画質を高く設定)
      final image = await boundary.toImage(pixelRatio: 3.0);

      // 3. 画像をPNG形式のバイトデータに変換
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // 4. スマホの一時フォルダに画像を保存
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/kimiseka_share.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // 5. OSのシェア機能を呼び出して、画像とテキストを一緒にシェア
      await Share.shareXFiles([XFile(imagePath)], text: shareText);
    } catch (e) {
      debugPrint('画像シェアエラー: $e');
    }
  }
}
