import 'package:todo_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/repositories/constants.dart';
import 'dart:convert';

abstract class UserRepository {
  Future<List<User>> retrieveUsers();
  Future<User> retrieveUser(String id);
}

class RESTUserRepository implements UserRepository {
  @override
  Future<List<User>> retrieveUsers() async {
    final response = await http.get("$kUserAPIUrl", headers: {
      'Authorization': kAuthorizationToken,
    });

    final userList = jsonDecode(response.body).cast<Map<String, dynamic>>()
        as List<Map<String, dynamic>>;
    return userList.map((e) => User.fromMap(e)).toList();
  }

  @override
  Future<User> retrieveUser(String id) async {
    final response = await http.get("$kUserAPIUrl/$id", headers: {
      'Authorization': kAuthorizationToken,
    });
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    return User.fromMap(json.decode(response.body));
  }
}
