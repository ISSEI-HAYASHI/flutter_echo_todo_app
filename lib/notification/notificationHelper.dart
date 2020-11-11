import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:todo_app/models/reminder.dart';
import 'package:todo_app/models/reminderNotification.dart';
import 'package:rxdart/subjects.dart';

final BehaviorSubject<ReminderNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReminderNotification>();
final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();

Future<void> initNotifications(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  var initializationSettingsAndroid = AndroidInitializationSettings('demia_logo_clear');
  var initializationSettingsIOS = IOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
      onDidReceiveLocalNotification: (int id, String title, String body, String payload) async {
      didReceiveLocalNotificationSubject.add(ReminderNotification(
          id: id,
          title: title,
          body: body,
          payload: payload
      ));
    });
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification:
        (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      selectNotificationSubject.add(payload);
    },
  );
}

//すべての通知を削除
Future<void> turnOffNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

//一致するidの通知を削除
Future<void> turnOffNotificationById(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, num id) async {
  await flutterLocalNotificationsPlugin.cancel(id);
}

// 通知の設定と保存を行う
Future<void> scheduleNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    int id,
    String title,
    String body,
    DateTime scheduledNotificationDateTime
  ) async {

  // 通知の詳細を設定
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    id.toString(),
    'Reminder notifications',
    'Remember about it',
    icon: 'demia_logo_clear',
    // color: Colors.lightGreen,
    enableLights: true,
    enableVibration: true,
    fullScreenIntent: true,
    // visibility: true,

  );
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics
  );
  await flutterLocalNotificationsPlugin.schedule(
    // ここのidが通知のひとつひとつを管理している
    // ＞現状はひとつの予定につき1個しか設定できない状態
    id,
    title,
    body,
    scheduledNotificationDateTime,
    platformChannelSpecifics,
  );
}

void requestIOSPermissions(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );
}
