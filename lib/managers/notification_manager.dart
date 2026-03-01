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
    // タイムゾーンの初期化（日本時間に設定）
    tz.initializeTimeZones();
    // 🌟 端末のローカルタイムゾーンを自動取得して設定！
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    // Androidの設定（アイコンはアプリのデフォルトアイコンを使用）
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOSの設定（通知の許可を求める）
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
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

    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      // 通知の許可（先ほど追加したもの）
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  // 毎週月曜日の11時に通知をスケジュールするメソッド
  Future<void> scheduleWeeklyMonday11AM() async {
    // 🌟 端末の言語設定が日本語かどうかを判定
    final bool isJapanese = Platform.localeName.startsWith('ja');

    // 言語に合わせてタイトルと本文を切り替え
    final String title = isJapanese
        ? '今週の「やくそく」はいかがですか？🌟'
        : 'How are this week\'s Promises? 🌟';
    final String body = isJapanese
        ? '毎日の育児お疲れ様です☕️ お子様の習慣づくりをアプリでチェックしてみましょう！'
        : 'Taking a quick break? ☕️ Let\'s check your child\'s progress in the app!';

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 0, // 通知ID（固定でOK）
        title: title, // 通知のタイトル
        body: body, // 通知のメッセージ
        scheduledDate: _nextInstanceOfMonday11AM(), // 次の月曜11時の時間を計算
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_reminder_channel', // チャンネルID
            'Weekly Reminder', // チャンネル名
            channelDescription: 'Notification for Monday 11 AM',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode
            .inexactAllowWhileIdle, // Android 12以降で時間に合わせて鳴らす設定
      );
      print("✅ [成功] 1分後の通知スケジュールをOSに登録しました！");
    } catch (e) {
      // 🌟 もしAndroidに弾かれたらここにエラーが出ます！
      print("❌ [失敗] スケジュール登録でエラーが発生しました: $e");
    }
  }

  // 次の「月曜日の11時」を計算するロジック
  tz.TZDateTime _nextInstanceOfMonday11AM() {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    // 今日の11時に設定
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      11,
      0,
    );

    // もし今日が月曜じゃない、または今日が月曜だけどすでに11時を過ぎている場合
    while (scheduledDate.weekday != DateTime.monday ||
        scheduledDate.isBefore(now)) {
      // 1日ずつ足して次の月曜11時を探す
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
