import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:todo_app/models/constants.dart';

const kUsersAPIUrl = kAPIUrl + "/users";

class User {
  final String id;
  final String name;
  final String password;

  User({this.id, this.name, this.password});

  User.fromMap(Map<String, dynamic> map)
      : this(id: map['id'], name: map['name'], password: map['password']);
}

Future<User> signup(User user) async {
  final response = await http.post(kSignupUrl, body: {
    "name": user.name,
    "password": user.password,
  }).catchError((e) {
    return http.Response(e.toString(), 400);
  });
  if (response.statusCode != 201) {
    throw Exception(response.body);
  }
  return User.fromMap(json.decode(response.body));
}

Future<Map<String, dynamic>> login(User user) async {
  final response = await http.post(kLoginUrl, body: {
    "name": user.name,
    "password": user.password,
  }).catchError((e) => http.Response(e.toString(), 400));
  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
  return json.decode(response.body);
}

Future<List<User>> getAllUsers() async {
  final response = await http.get(kUsersAPIUrl, headers: {
    "Authorization": kAuthorizationToken,
  });
  if (response.statusCode != 200) {
    return [];
  }
  List<Map<String, dynamic>> maps = json.decode(response.body);
  return maps.map((e) => User.fromMap(e)).toList();
}
