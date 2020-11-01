import 'dart:io';

import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/routes.dart';
import 'package:todo_app/widgets/todo.dart';
import 'package:todo_app/repositories/todo.dart';
import 'package:todo_app/repositories/image.dart';

class TodoCreationScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TodoCreationScreenState();
}

class _TodoCreationScreenState extends State<TodoCreationScreen> {
  final _key = GlobalKey<FormState>();
  final _todo = Todo(title: '', memo: '', start: DateTime.now());
  final List<File> _fileList = [
    File(''),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Todo'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Form(
          key: _key,
          // autovalidate: true,
          child: Column(
            children: [
              TodoEditForm(
                todo: _todo,
                fileList: _fileList,
              ),
              RaisedButton(
                child: const Text('Add'),
                onPressed: () {
                  if (_key.currentState.validate()) {
                    _createTodoAndReturnToHome();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createTodoAndReturnToHome() async {
    if (_fileList[0] != null) {
      String imageurl = await ImageToAPI().upload(_fileList[0]);
      _todo.imageUrl = imageurl;
    }
    await RESTTodoRepository().createTodo(_todo);
    Navigator.pushNamedAndRemoveUntil(
      context,
      kTodoHomeRouteName,
      (route) => false,
    );
  }
}
