import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:todo_app/models/project.dart';
import 'package:todo_app/repositories/constants.dart';

abstract class ProjectRepository {
  Future<List<Project>> retrieveProjects();
  Future<Project> retrieveProject({String id});
  Future<void> createProject(Project prj);
  Future<void> deleteTodo(Project prj);
}

class RESTProjectRepository implements ProjectRepository {
  @override
  Future<List<Project>> retrieveProjects() async {
    final response = await http.get("$kProjectAPIUrl", headers: {
      'Authorization': kAuthorizationToken,
    });
    // print(response.statusCode);
    final prjList = jsonDecode(response.body).cast<Map<String, dynamic>>()
        as List<Map<String, dynamic>>;
    return prjList.map((e) => Project.fromMap(e)).toList();
  }

  @override
  Future<Project> retrieveProject({String id}) async {
    final response = await http.get("$kProjectAPIUrl/$id", headers: {
      'Authorization': kAuthorizationToken,
    });
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    return Project.fromMap(json.decode(response.body));
  }

  @override
  Future<void> createProject(Project prj) async {
    final response = await http.post(
      kProjectAPIUrl,
      headers: {
        'Authorization': kAuthorizationToken,
        'Content-Type': kJSONMime,
      },
      body: json.encode(prj.toMap()),
    );
    if (response.statusCode != 201) {
      print('error');
      throw Exception(response.body);
    }
  }

  @override
  Future<void> deleteTodo(Project prj) async {
    final response = await http.delete('$kProjectAPIUrl/${prj.id}', headers: {
      'Authorization': kAuthorizationToken,
    });
    if (response.statusCode != 204) {
      throw Exception(response.body);
    }
  }
}
