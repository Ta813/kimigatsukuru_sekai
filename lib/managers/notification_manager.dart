// lib/managers/notification_manager.dart

import 'dart:io';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  static final NotificationManager instance = NotificationManager._internal();
  factory NotificationManager() => instance;
  NotificationManager._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 初期化処理
  Future<void> init() async {
    tz.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

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

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );
  }

  // --- 追加: やくそくリストに基づいて通知をすべて再設定する ---
  Future<void> scheduleAllRegularPromises(
    List<Map<String, dynamic>> promises,
  ) async {
    // 1. やくそく関連の通知（ID 100以降とする）を一度すべてキャンセル
    // IDが重複しないように管理するため、まずはリセットします
    for (int i = 100; i < 200; i++) {
      await _flutterLocalNotificationsPlugin.cancel(id: i);
    }

    final bool isJapanese = Platform.localeName.startsWith('ja');

    // 2. リストをループして各時間を予約
    for (int i = 0; i < promises.length; i++) {
      final promise = promises[i];
      final String title = promise['title'] ?? '';
      final String timeStr = promise['time'] ?? ''; // "07:30" 形式
      final String icon = promise['icon'] ?? '⭐';

      if (timeStr.isEmpty) continue;

      final notificationTitle = isJapanese
          ? '「$title」のじかんだよ！'
          : 'Time for "$title"!';
      final notificationBody = isJapanese
          ? '$icon やくそくを はじめよう！'
          : '$icon Let\'s start your promise!';

      try {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id: 100 + i, // IDを100, 101...とする
          title: notificationTitle,
          body: notificationBody,
          scheduledDate: _nextInstanceOfTime(timeStr),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'promise_reminder_channel',
              'Promise Reminders',
              channelDescription: 'Notifications for each promise time',
              importance: Importance.high,
              priority: Priority.high,
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
    final bool isJapanese = Platform.localeName.startsWith('ja');
    final String title = isJapanese
        ? '今週の「やくそく」はいかがですか？🌟'
        : 'How are this week\'s Promises? 🌟';
    final String body = isJapanese
        ? '毎日の育児お疲れ様です☕️ お子様の習慣づくりをアプリでチェックしてみましょう！'
        : 'Taking a quick break? ☕️ Let\'s check your child\'s progress in the app!';

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 0, // ID 0 は月曜通知用
        title: title,
        body: body,
        scheduledDate: _nextInstanceOfMonday11AM(),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_reminder_channel',
            'Weekly Reminder',
            importance: Importance.high,
            priority: Priority.high,
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
