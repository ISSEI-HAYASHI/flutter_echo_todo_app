import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:todo_app/models/user.dart';
import 'package:todo_app/routes.dart';
import 'package:todo_app/repositories/constants.dart';
// import 'package:todo_app/models/todo.dart';
// import 'package:todo_app/repositories/todo.dart';

// import '../models/todo.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In'),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16),
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _key = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            validator: _nameValidator,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextFormField(
            controller: _passwordController,
            validator: _passwordValidator,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
          ),
          RaisedButton(
            child: const Text('Log in'),
            onPressed: () {
              if (_key.currentState.validate()) {
                _login(context);
              }
            },
          ),
        ],
      ),
    );
  }

  String _nameValidator(String value) {
    if (value.isEmpty) {
      return 'Enter your name';
    }
    return null;
  }

  String _passwordValidator(String value) {
    if (value.isEmpty) {
      return 'Enter a password';
    }
    return null;
  }

  Future<void> _login(BuildContext context) async {
    debugPrint("_login func run.");
    final user = User(
      name: _nameController.text,
      password: _passwordController.text,
    );
    final res = await login(user).catchError((e) {
      Scaffold.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      return {'token': null};
    });
    //print(res);
    final String token = res['token'];
    final String userNmae = res['userID'];
    final String userID = res['userID'];

    final docDir = await getApplicationDocumentsDirectory();
    final configFile = File(p.join(docDir.path, 'config.json'));
    print(configFile);
    if (configFile == null) {
      configFile.createSync(recursive: true);
    }
    var config = Map<String, dynamic>();
    if (configFile.existsSync()) {
      config = json.decode(configFile.readAsStringSync());
    }
    config['token'] = token;
    config['userNmae'] = userNmae;
    config['userID'] = userID;
    configFile.writeAsStringSync(json.encode(config));
    if (user != null) {
      kAuthorizationToken = 'Bearer ' + token;
      kUserName = userNmae;
      kUserID = userID;
      // for (int i = 1; i <= 4; i++) {
      //   print(i);
      //   Todo testTodo;
      //   testTodo = Todo(
      //     //id: '$i$i$i$i',
      //     title: 'title$i',
      //     memo: 'memo$i',
      //     // imageUrl: 'imageUrl$i',
      //     done: false,
      //     start: DateTime.now(),
      //     end: DateTime.now().add(new Duration(days: 5)),
      //     personID: userID,
      //   );
      //   await RESTTodoRepository().createTodo(testTodo);
      // }
      Navigator.pushNamedAndRemoveUntil(
          context, kTodoHomeRouteName, (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, kSignupRouteName, (route) => false);
    }
  }
}
