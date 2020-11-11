import 'package:flutter/material.dart';
import 'package:todo_app/models/project.dart';
import 'package:todo_app/repositories/project.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_app/routes.dart';

class ProjectListScreen extends StatefulWidget {
  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final _key = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final _prjs = RESTProjectRepository().retrieveProjects();
    return Scaffold(
      key: _key,
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // int _currentIndex = 2;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  kTodoHomeRouteName,
                  (route) => false,
                );
              }),
          title: const Text("Project List")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, kProjectCreationRouteName);
        },
      ),
      body: FutureBuilder<List<Project>>(
        future: _prjs,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              final prj = snapshot.data[index];
              return Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: .25,
                child: Container(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(prj.name),
                    // leading: Text(item.id.toString()),
                  ),
                ),
                actions: [
                  IconSlideAction(
                    caption: '削除',
                    icon: Icons.delete,
                    color: Colors.red,
                    onTap: () {
                      RESTProjectRepository().deleteProject(prj);
                      setState(() {});
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
