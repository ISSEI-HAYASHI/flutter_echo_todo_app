import 'package:flutter/material.dart';
import 'package:todo_app/screens/todo_detail.dart';
import 'package:todo_app/screens/todo_edit.dart';
import 'package:todo_app/screens/todo_home.dart';
import 'package:todo_app/screens/todo_new.dart';
import 'package:todo_app/routes.dart';
import 'package:todo_app/screens/login.dart';
import 'package:todo_app/screens/signup.dart';
import 'package:todo_app/screens/anonymous_home.dart';

import 'routes.dart';

//追加
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo_app/notification/notificationHelper.dart';
import 'package:todo_app/store/store.dart';
import 'package:todo_app/store/appState.dart';
import 'package:redux/redux.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;
Store<AppState> store;
//ここまで

// asyncに変更
void main() async{
  // 追加
  WidgetsFlutterBinding.ensureInitialized();
  await initStore();
  store = getStore();
  notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  await initNotifications(flutterLocalNotificationsPlugin);
  // ここまで
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: kAnonymousHomeRouteName,
      routes: {
        kTodoHomeRouteName: (context) => TodoHomeScreen(),
        kTodoDetailRouteName: (context) =>
            TodoDetailScreen(todo: ModalRoute.of(context).settings.arguments),
        kTodoCreationRouteName: (context) => TodoCreationScreen(),
        kTodoEditRouteName: (context) =>
            TodoEditScreen(original: ModalRoute.of(context).settings.arguments),
        kLoginRouteName: (context) => LoginScreen(),
        kSignupRouteName: (context) => SignupScreen(),
        kAnonymousHomeRouteName: (context) => AnonymousHomeScreen(),
      },
    );
  }
}
