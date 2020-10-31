import 'package:flutter/material.dart';
import 'package:todo_app/models/user.dart';
import 'package:todo_app/routes.dart';

import '../routes.dart';

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16),
        child: SignupForm(),
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _key = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: '');
  final _password1Controller = TextEditingController(text: '');
  final _password2Controller = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            validator: _nameValidator,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextFormField(
            controller: _password1Controller,
            validator: _password1Validator,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
          ),
          TextFormField(
            controller: _password2Controller,
            validator: _password2Validator,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm password',
            ),
          ),
          RaisedButton(
            child: const Text('Sign up'),
            onPressed: () {
              if (_key.currentState.validate()) {
                _signup(context);
              }
            },
          ),
        ],
      ),
    );
  }

  String _nameValidator(String value) {
    if (value.isEmpty) {
      return 'Enter your name';
    }
    return null;
  }

  String _password1Validator(String value) {
    if (value.isEmpty) {
      return 'Enter a password';
    }
    return null;
  }

  String _password2Validator(String value) {
    if (value.isEmpty) {
      return 'Confirm your password';
    }
    if (value != _password1Controller.text) {
      return "Passwords didn't match";
    }
    return null;
  }

  Future<void> _signup(BuildContext context) async {
    var user =
        User(name: _nameController.text, password: _password1Controller.text);
    user = await signup(user).catchError((e) {
      Scaffold.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      return null;
    });
    if (user != null) {
      Navigator.pushNamedAndRemoveUntil(
          context, kLoginRouteName, (route) => false);
    }
  }
}
