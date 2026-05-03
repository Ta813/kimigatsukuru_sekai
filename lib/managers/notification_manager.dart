// lib/managers/notification_manager.dart

import 'dart:io';
import 'dart:ui'; // ★追加: Localeを使用するため
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart'; // ★追加: 多言語の文字列を取得するため
import '../../helpers/shared_prefs_helper.dart'; // ★追加: 保存された言語設定を取得するため

import 'package:permission_handler/permission_handler.dart';

class NotificationManager {
  static final NotificationManager instance = NotificationManager._internal();
  factory NotificationManager() => instance;
  NotificationManager._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false; // ★追加: 初期化完了フラグ
  bool get isInitialized => _isInitialized;

  // 初期化処理
  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      // タイムゾーンの取得に失敗した場合でも、通知の初期化自体は継続できるようにする
      print("⚠️ NotificationManager: Failed to initialize timezones: $e");
      // デフォルトとして UTC を設定 (必要に応じて修正)
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin
        .initialize(
          settings: initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {},
        )
        .then((_) {
          _isInitialized = true;
          print("✅ NotificationManager: Initialized successfully.");
        })
        .catchError((e) {
          print("❌ NotificationManager: Failed to initialize plugin: $e");
        });
  }

  /// 通知許可をリクエストするメソッド
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      // iOSの場合: flutter_local_notificationsのネイティブ機能を使ってリクエスト
      // これにより、DarwinInitializationSettings で false にしていた権限を明示的に要求します
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    } else if (Platform.isAndroid) {
      // Androidの場合: permission_handler または local_notifications の機能を使用
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return false;
  }

  // ★追加: 現在の言語設定に基づいて AppLocalizations を取得するヘルパーメソッド
  Future<AppLocalizations> _getL10n() async {
    String langCode = 'en'; // デフォルトは英語

    try {
      // 1. まずアプリ内の手動設定（歯車マークで設定した言語）を探す
      final savedLocale = await SharedPrefsHelper.loadLocale();
      if (savedLocale != null && savedLocale.isNotEmpty) {
        langCode = savedLocale;
      } else {
        // 2. なければスマホ本体の言語設定を取得する
        // ハイフンとアンダースコアの両方に対応 ('en-US' or 'en_US')
        langCode = Platform.localeName.replaceAll('-', '_').split('_')[0];
      }
    } catch (e) {
      print('言語設定の取得エラー: $e');
    }

    // サポートしている言語以外だったら英語にフォールバック
    if (!['ja', 'en', 'hi', 'ur', 'bn', 'ar'].contains(langCode)) {
      langCode = 'en';
    }

    // ContextなしでAppLocalizationsを読み込む
    return await AppLocalizations.delegate.load(Locale(langCode));
  }

  // --- やくそくリストに基づいて通知をすべて再設定する ---
  Future<void> scheduleAllRegularPromises(
    List<Map<String, dynamic>> promises,
  ) async {
    // 1. やくそく関連の通知（ID 100以降とする）を一度すべてキャンセル
    for (int i = 100; i < 200; i++) {
      await _flutterLocalNotificationsPlugin.cancel(id: i);
    }

    // ★翻訳データの読み込み
    final l10n = await _getL10n();

    // 2. リストをループして各時間を予約
    for (int i = 0; i < promises.length; i++) {
      final promise = promises[i];
      final String title = promise['title'] ?? '';
      final String timeStr = promise['time'] ?? ''; // "07:30" 形式
      final String icon = promise['icon'] ?? '⭐';

      if (timeStr.isEmpty) continue;

      // ★ ローカライズされた文字列を適用
      final notificationTitle = l10n.promiseNotificationTitle(title);
      final notificationBody = l10n.promiseNotificationBody(icon);

      try {
        // ★追加: 初期化されていない場合はスキップ（または待機）
        if (!_isInitialized) {
          print(
            "⚠️ NotificationManager not initialized yet. Skipping schedule for $title.",
          );
          continue;
        }

        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id: 100 + i, // IDを100, 101...とする
          title: notificationTitle,
          body: notificationBody,
          scheduledDate: _nextInstanceOfTime(timeStr),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'promise_reminder_channel',
              l10n.notificationChannelPromiseName,
              channelDescription: l10n.notificationChannelPromiseDesc,
              importance: Importance.high,
              priority: Priority.high,
              color: Color(0xFFFF7043),
              // icon: 'ic_notification', // 削除: AndroidInitializationSettings のデフォルトを使用する
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time, // 毎日その時間に鳴らす
        );
      } catch (e) {
        print("❌ 通知の予約に失敗しました ($title): $e");
      }
    }
    print("✅ ${promises.length}件のやくそく通知を再設定しました");
  }

  // 指定された時刻（HH:mm）の「次の発生タイミング」を計算する
  tz.TZDateTime _nextInstanceOfTime(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // すでにその時間を過ぎている場合は翌日に設定
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // 毎週月曜日の11時に通知をスケジュールするメソッド（既存）
  Future<void> scheduleWeeklyMonday11AM() async {
    // ★翻訳データの読み込み
    final l10n = await _getL10n();

    // ★ ローカライズされた文字列を適用
    final String title = l10n.weeklyNotificationTitle;
    final String body = l10n.weeklyNotificationBody;

    try {
      // ★追加: 初期化されていない場合はスキップ
      if (!_isInitialized) {
        print(
          "⚠️ NotificationManager not initialized yet. Skipping weekly schedule.",
        );
        return;
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 0, // ID 0 は月曜通知用
        title: title,
        body: body,
        scheduledDate: _nextInstanceOfMonday11AM(),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_reminder_channel',
            l10n.notificationChannelWeeklyName,
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFFFF7043),
            // icon: 'ic_notification', // 削除: AndroidInitializationSettings のデフォルトを使用する
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      print("❌ 月曜通知の登録エラー: $e");
    }
  }

  tz.TZDateTime _nextInstanceOfMonday11AM() {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      11,
      0,
    );
    while (scheduledDate.weekday != DateTime.monday ||
        scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
