import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// 全アプリ共通でパーミッションリクエストの競合を防ぐためのマネージャー
class PermissionManager {
  static final PermissionManager instance = PermissionManager._internal();
  factory PermissionManager() => instance;
  PermissionManager._internal();

  bool _isRequesting = false;

  /// 指定されたパーミッションをリクエストする。
  /// すでに別のリクエストが進行中の場合は、リクエストを行わずに現在のステータスを返す。
  Future<PermissionStatus> request(Permission permission) async {
    if (_isRequesting) {
      debugPrint(
        'PermissionManager: A request is already in progress. Ignoring request for $permission',
      );
      return await permission.status;
    }

    _isRequesting = true;
    try {
      debugPrint('PermissionManager: Requesting $permission');
      return await permission.request();
    } catch (e) {
      debugPrint('PermissionManager: Error requesting $permission: $e');
      return await permission.status;
    } finally {
      _isRequesting = false;
    }
  }

  /// 現在リクエスト中かどうか
  bool get isRequesting => _isRequesting;
}
