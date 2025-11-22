import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:icloud_storage/icloud_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../helpers/shared_prefs_helper.dart';
import 'package:http/http.dart' as http;

const String _backupFileName = 'kimigatsukurusekai_backup.json';
const String _iCloudContainerId = 'iCloud.com.kotoapp.kimigatsukurusekai';

class BackupService {
  // =============================================
  // ★ Google Drive 関連 (Android / iOS)
  // =============================================

  // Googleサインインの初期化と認証クライアントの取得
  static Future<auth.AuthClient?> _getGoogleAuthClient() async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: [drive.DriveApi.driveAppdataScope], // アプリ固有のファイルへのアクセス権限
      );
      final account = await googleSignIn.signIn();
      if (account == null) {
        print("Google Sign-In failed or was cancelled.");
        return null; // ユーザーがキャンセル
      }
      final authentication = await account.authentication;
      final accessToken = authentication.accessToken;

      if (accessToken == null) {
        print("Failed to get access token from Google.");
        return null;
      }

      final credentials = auth.AccessCredentials(
        auth.AccessToken(
          'Bearer', // 1番目の引数 (Type)
          accessToken, // 2番目の引数 (Data)
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
        null, // Refresh token (今回はnull)
        googleSignIn.scopes,
      );

      return auth.authenticatedClient(http.Client(), credentials);
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // Google Driveにバックアップ
  static Future<bool> backupToGoogleDrive() async {
    final client = await _getGoogleAuthClient();
    if (client == null) return false;

    try {
      final driveApi = drive.DriveApi(client);
      final dataString = await SharedPrefsHelper.exportDataAsJson();

      // 1. まず文字列をUTF-8のバイト列に変換
      final dataBytes = utf8.encode(dataString);
      // 2. 正しいバイト長を取得
      final byteLength = dataBytes.length;

      // ファイルIDを検索（すでにあれば上書き、なければ新規作成）
      final fileList = await driveApi.files.list(
        q: "name='$_backupFileName' and 'appDataFolder' in parents",
        spaces: 'appDataFolder',
      );

      final media = drive.Media(
        Stream.value(dataBytes),
        byteLength,
        contentType: 'application/json',
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // 既存ファイルを更新
        final fileId = fileList.files!.first.id!;
        await driveApi.files.update(drive.File(), fileId, uploadMedia: media);
        print("Google Drive: Backup updated.");
      } else {
        // 新規ファイルを作成
        await driveApi.files.create(
          drive.File(
            name: _backupFileName,
            parents: ['appDataFolder'], // アプリ専用フォルダに保存
          ),
          uploadMedia: media,
        );
        print("Google Drive: Backup created.");
      }
      return true;
    } catch (e) {
      print("Google Drive Backup Error: $e");
      return false;
    } finally {
      client.close();
    }
  }

  // Google Driveから復元
  static Future<bool> restoreFromGoogleDrive() async {
    final client = await _getGoogleAuthClient();
    if (client == null) return false;

    try {
      final driveApi = drive.DriveApi(client);
      final fileList = await driveApi.files.list(
        q: "name='$_backupFileName' and 'appDataFolder' in parents",
        spaces: 'appDataFolder',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        print("Google Drive: No backup file found.");
        return false; // バックアップファイルがない
      }

      final fileId = fileList.files!.first.id!;
      final media =
          await driveApi.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final jsonString = await utf8.decodeStream(media.stream);
      await SharedPrefsHelper.importDataFromJson(jsonString);
      print("Google Drive: Restore successful.");
      return true;
    } catch (e) {
      print("Google Drive Restore Error: $e");
      return false;
    } finally {
      client.close();
    }
  }

  // =============================================
  // ★ iCloud 関連 (iOSのみ)
  // =============================================
  static Future<bool> backupToiCloud() async {
    if (!Platform.isIOS) return false;

    try {
      final data = await SharedPrefsHelper.exportDataAsJson();

      // 一時ファイルに書き出す
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$_backupFileName');
      await tempFile.writeAsString(data);

      await ICloudStorage.upload(
        containerId: _iCloudContainerId,
        filePath: tempFile.path,
        destinationRelativePath: _backupFileName,
        onProgress: (stream) {
          stream.listen(
            (progress) => print('Upload File Progress: $progress'),
            onDone: () => print('Upload File Done'),
            onError: (err) => print('Upload File Error: $err'),
            cancelOnError: true,
          );
        },
      );
      print("iCloud: Backup successful.");
      await tempFile.delete(); // 一時ファイルを削除
      return true;
    } catch (e) {
      print("iCloud Backup Error: $e");
      return false;
    }
  }

  static Future<bool> restoreFromiCloud() async {
    if (!Platform.isIOS) return false;

    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$_backupFileName');

      await ICloudStorage.download(
        containerId: _iCloudContainerId,
        relativePath: _backupFileName,
        destinationFilePath: tempFile.path,
        onProgress: (stream) {
          stream.listen((progress) {
            print('iCloud Download Progress: $progress');
          });
        },
      );

      final jsonString = await tempFile.readAsString();
      await SharedPrefsHelper.importDataFromJson(jsonString);
      print("iCloud: Restore successful.");
      await tempFile.delete(); // 一時ファイルを削除
      return true;
    } catch (e) {
      print("iCloud Restore Error: $e");
      return false;
    }
  }
}
