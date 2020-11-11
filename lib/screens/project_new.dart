import 'package:flutter/material.dart';
import 'package:todo_app/models/project.dart';
import 'package:todo_app/repositories/project.dart';
import 'package:todo_app/widgets/project.dart';
import 'package:todo_app/routes.dart';

class ProjectCreationScreen extends StatefulWidget {
  @override
  State<ProjectCreationScreen> createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends State<ProjectCreationScreen> {
  final _key = GlobalKey<FormState>();
  final _prj = Project(name: "");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Project"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Form(
          key: _key,
          child: Column(
            children: [
              ProjectEditForm(
                prj: _prj,
              ),
              RaisedButton(
                child: const Text("Add"),
                onPressed: () {
                  if (_key.currentState.validate()) {
                    _createProjectAndReturnToHome();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createProjectAndReturnToHome() async {
    await RESTProjectRepository().createProject(_prj);
    Navigator.pushNamedAndRemoveUntil(
      context,
      kProjectListRouteName,
      (route) => false,
    );
  }
}
