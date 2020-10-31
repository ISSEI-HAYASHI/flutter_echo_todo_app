import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:todo_app/models/user.dart';
import 'package:todo_app/repositories/constants.dart';

abstract class SignupRepository {
  Future<User> signup(User user);
}

class RESTSignupRepository implements SignupRepository {
  @override
  Future<User> signup(User user) async {
    final response = await http.post(kSignupUrl, body: {
      "name": user.name,
      "password": user.password,
    }).catchError((e) => http.Response(e.toString(), 400));
    if (response.statusCode != 201) {
      throw Exception(response.body);
    }
    return User.fromMap(json.decode(response.body));
  }
}

abstract class LoginRepository {
  Future<String> login(User user);
}

class RESTLoginRepository implements LoginRepository {
  @override
  Future<String> login(User user) async {
    final response = await http.post(kLoginUrl, body: {
      "name": user.name,
      "password": user.password,
    }).catchError((e) => http.Response(e.toString(), 400));
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    return json.decode(response.body)['token'];
  }
}
