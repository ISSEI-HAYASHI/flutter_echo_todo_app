import 'package:flutter/material.dart';
import 'package:todo_app/screens/todo_detail.dart';
import 'package:todo_app/screens/todo_edit.dart';
import 'package:todo_app/screens/todo_home.dart';
import 'package:todo_app/screens/todo_new.dart';
import 'package:todo_app/routes.dart';
import 'package:todo_app/screens/login.dart';
import 'package:todo_app/screens/signup.dart';
import 'package:todo_app/screens/anonymous_home.dart';
import 'package:todo_app/screens/project_list.dart';
import 'package:todo_app/screens/project_new.dart';

import 'routes.dart';

void main() {
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
        kProjectListRouteName: (context) => ProjectListScreen(),
        kProjectCreationRouteName: (context) => ProjectCreationScreen(),
      },
    );
  }
}
