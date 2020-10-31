import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/routes.dart';
import 'package:todo_app/widgets/todo.dart';
import 'package:todo_app/repositories/todo.dart';

class TodoEditScreen extends StatefulWidget {
  final Todo original;

  TodoEditScreen({Key key, this.original}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TodoEditScreenState();
}

class _TodoEditScreenState extends State<TodoEditScreen> {
  final _key = GlobalKey<FormState>();
  Todo _todo;

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
              TodoEditForm(todo: _todo),
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
    final docDir = await getApplicationDocumentsDirectory();
    final imgDir = Directory(p.join(docDir.path, 'images'));
    if (!imgDir.existsSync()) {
      imgDir.createSync();
    }
    // if (_todo.imageUrl.isNotEmpty && !_todo.image.startsWith(imgDir.path)) {
    //   final image = _todo.imageFile
    //       .copySync(p.join(imgDir.path, p.basename(_todo.image)));
    //   _todo.image = image.path;
    // }
    await RESTTodoRepository().updateTodo(_todo);
    Navigator.pushNamedAndRemoveUntil(
      context,
      kTodoHomeRouteName,
      (route) => false,
    );
  }
}
