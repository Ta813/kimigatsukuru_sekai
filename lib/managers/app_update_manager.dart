// lib/managers/app_update_manager.dart

import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/shared_prefs_helper.dart';
import '../managers/sfx_manager.dart';
import '../l10n/app_localizations.dart';

class AppUpdateManager {
  // シングルトン化
  static final AppUpdateManager instance = AppUpdateManager._internal();
  AppUpdateManager._internal();

  /// 🌟 1. Firebase Remote Config から最新バージョンを取得（機内モード対応）
  Future<String> _fetchLatestVersionFromRemote() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // 【安全策】オフラインで一度も通信できていない時のための初期値を「現在のバージョン」にする
      await remoteConfig.setDefaults({'latest_app_version': currentVersion});

      // 通信のタイムアウトと、キャッシュの有効期限を設定
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5), // 機内モード時に長く待たせないよう5秒で諦める
          minimumFetchInterval: const Duration(hours: 12), // 12時間に1回だけ通信して更新する
        ),
      );

      // ネットワーク通信を試みる（機内モードや圏外の時はここでエラーがスローされる）
      await remoteConfig.fetchAndActivate();

      // キャッシュ（または通信で得た最新値、またはデフォルト値）を取得
      return remoteConfig.getString('latest_app_version');
    } catch (e) {
      // 🌟 機内モードや電波が悪い時はここに来る
      debugPrint('Remote Configの取得に失敗（オフライン等）: $e');

      // オフラインで通信できない場合は「現在のバージョン」を返して、アップデート画面を出さないようにする
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    }
  }

  /// 🌟 2. アップデートがあるかチェックしてダイアログを出す
  Future<void> checkUpdateAndShowDialog(BuildContext context) async {
    try {
      // 端末にインストールされている現在のバージョンを取得
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // リモート（ストア）の最新バージョンを取得
      final latestVersion = await _fetchLatestVersionFromRemote();

      // 現在のバージョンより新しいバージョンが存在するか？
      if (_isUpdateAvailable(currentVersion, latestVersion)) {
        // 過去に「しない」を選んだバージョンかどうかチェック
        final ignoredVersion =
            await SharedPrefsHelper.loadIgnoredUpdateVersion();

        // 最新バージョンと「しない」に設定されたバージョンが【違う】場合のみ表示
        if (ignoredVersion != latestVersion) {
          if (!context.mounted) return;
          _showUpdateDialog(context, latestVersion);
        }
      }
    } catch (e) {
      debugPrint('アップデート確認エラー: $e');
    }
  }

  /// 🌟 3. バージョンの文字列を比較する（1.0.1 < 1.0.2 なら true）
  bool _isUpdateAvailable(String current, String latest) {
    try {
      List<int> currentParts = current.split('.').map(int.parse).toList();
      List<int> latestParts = latest.split('.').map(int.parse).toList();

      for (int i = 0; i < latestParts.length; i++) {
        int c = i < currentParts.length ? currentParts[i] : 0;
        int l = latestParts[i];
        if (l > c) return true; // 最新版の数字のほうが大きい
        if (l < c) return false; // 現在の版の数字のほうが大きい
      }
    } catch (e) {
      return false; // パースに失敗した場合は安全のためfalse
    }
    return false; // 全く同じバージョン
  }

  /// 🌟 4. かわいいアップデートダイアログを表示
  void _showUpdateDialog(BuildContext context, String latestVersion) {
    showDialog(
      context: context,
      barrierDismissible: false, // 外側タップで閉じられないようにする
      builder: (BuildContext dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(
            l10n.updateDialogTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF7043),
            ),
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0), // アプリに合わせたピーチクリーム色
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF7043).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Text(
              l10n.updateDialogMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            // 「しない」ボタン
            TextButton(
              onPressed: () async {
                try {
                  SfxManager.instance.playTapSound();
                } catch (_) {}
                // このバージョンを「スキップ済み」として保存
                await SharedPrefsHelper.saveIgnoredUpdateVersion(latestVersion);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: Text(
                l10n.updateDialogSkip,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 「アップデート！」ボタン
            ElevatedButton(
              onPressed: () {
                try {
                  SfxManager.instance.playSuccessSound();
                } catch (_) {}
                Navigator.pop(dialogContext);
                _openStore();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043), // オレンジ
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
              child: Text(
                l10n.updateDialogUpdate,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 🌟 5. ストアを開く
  Future<void> _openStore() async {
    // 【TODO】ご自身のアプリのIDに変更してください
    const String appleId = '6761637868';
    const String androidPackageName = 'com.kotoapp.kimigatsukuru_sekai';

    final String url = Platform.isIOS
        ? 'itms-apps://itunes.apple.com/app/id$appleId'
        : 'market://details?id=$androidPackageName';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('ストアを開けませんでした: $e');
    }
  }
}
