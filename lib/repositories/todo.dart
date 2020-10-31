import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/repositories/constants.dart';

// import '../screens/todo_new.dart';

abstract class TodoRepository {
  Future<List<Todo>> retrieveTodos({String userID, bool done});
  Future<Todo> retrieveTodo(String id);
  Future<void> createTodo(Todo todo);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(Todo todo);
}

class RESTTodoRepository implements TodoRepository {
  @override
  Future<List<Todo>> retrieveTodos({String userID, bool done}) async {
    final response = await http.get('$kTodoAPIUrl/$userID/$done', headers: {
      'Authorization': kAuthorizationToken,
    });
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    final todoList = jsonDecode(response.body).cast<Map<String, dynamic>>()
        as List<Map<String, dynamic>>;
    return todoList.map((e) => Todo.fromMap(e)).toList();
  }

  @override
  Future<Todo> retrieveTodo(String id) async {
    final response = await http.get('$kTodoAPIUrl/$id', headers: {
      'Authorization': kAuthorizationToken,
    });
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    return Todo.fromMap(json.decode(response.body));
  }

  @override
  Future<void> createTodo(Todo todo) async {
    todo.personID = kUserID;
    final response = await http.post(
      kTodoAPIUrl,
      headers: {
        'Authorization': kAuthorizationToken,
        'Content-Type': kJSONMime,
      },
      body: json.encode(todo.toMap()),
    );
    if (response.statusCode != 201) {
      print('error');
      throw Exception(response.body);
    }
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final response = await http.put(
      '$kTodoAPIUrl/${todo.id}',
      headers: {
        'Authorization': kAuthorizationToken,
        'Content-Type': kJSONMime,
      },
      body: json.encode(todo.toMap()),
    );
    if (response.statusCode != 204) {
      throw Exception(response.body);
    }
  }

  @override
  Future<void> deleteTodo(Todo todo) async {
    final response = await http.delete('$kTodoAPIUrl/${todo.id}', headers: {
      'Authorization': kAuthorizationToken,
    });
    if (response.statusCode != 204) {
      throw Exception(response.body);
    }
  }
}
