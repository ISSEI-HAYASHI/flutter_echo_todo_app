import 'dart:io';

import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/routes.dart';
import 'package:todo_app/widgets/todo.dart';
import 'package:todo_app/repositories/todo.dart';
import 'package:todo_app/repositories/image.dart';

class TodoEditScreen extends StatefulWidget {
  final Todo original;

  TodoEditScreen({Key key, this.original}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TodoEditScreenState();
}

class _TodoEditScreenState extends State<TodoEditScreen> {
  final _key = GlobalKey<FormState>();
  Todo _todo;
  final List<File> _fileList = [
    File(""),
  ];
  final String _tempUrl = "";

  @override
  void initState() {
    super.initState();
    _todo = Todo.fromMap(widget.original.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Todo'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Form(
          key: _key,
          autovalidate: true,
          child: Column(
            children: [
              TodoEditForm(
                todo: _todo,
                fileList: _fileList,
                tempUrl: _tempUrl,
              ),
              RaisedButton(
                child: const Text('Save'),
                onPressed: () {
                  if (_key.currentState.validate()) {
                    _updateTodoAndPop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateTodoAndPop() async {
    print(_tempUrl);
    if (_fileList[0].path != "") {
      if (_todo.imageUrl.isNotEmpty) {
        RESTImageRepository().delete(_todo.imageUrl);
      }
      _todo.imageUrl = await RESTImageRepository().upload(_fileList[0]);
    } else {
      if (_todo.imageUrl.isNotEmpty && _tempUrl.isEmpty) {
        RESTImageRepository().delete(_todo.imageUrl);
        _todo.imageUrl = "";
      }
    }

    await RESTTodoRepository().updateTodo(_todo);
    Navigator.pushNamedAndRemoveUntil(
      context,
      kTodoHomeRouteName,
      (route) => false,
    );
  }
}
