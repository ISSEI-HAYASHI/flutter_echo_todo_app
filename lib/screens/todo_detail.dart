import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/repositories/constants.dart';
import 'package:todo_app/routes.dart';
import 'package:todo_app/repositories/project.dart';
import 'package:todo_app/models/project.dart';

class TodoDetailScreen extends StatelessWidget {
  final Todo todo;
  // final List<File> _fileList = [
  //   File(''),
  // ];
  TodoDetailScreen({Key key, this.todo}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final Future<Project> prj =
        RESTProjectRepository().retrieveProject(id: todo.projectID);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      todo.title,
                      style: TextStyle(fontSize: 40),
                    ),
                    FutureBuilder<Project>(
                      future: prj,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text("no projet.");
                        } else {
                          return Text(snapshot.data.name);
                          // final _prj = snapshot.data;
                          // return Text()
                        }
                      },
                    )
                  ],
                )),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('time duration.'),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                todo.memo,
                style: TextStyle(fontSize: 16),
              ),
            ),
            todo.imageUrl.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Image.network("$kHostUrl/" + todo.imageUrl),
                  )
                : Container(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          Navigator.pushNamed(context, kTodoEditRouteName, arguments: todo);
        },
      ),
    );
  }
}
