import 'package:todo_app/routes.dart';
import 'package:flutter/material.dart';

class AnonymousHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RaisedButton(
              child: const Text('Log in'),
              onPressed: () {
                Navigator.pushNamed(context, kLoginRouteName);
              },
            ),
            RaisedButton(
              child: const Text('Sign up'),
              onPressed: () {
                Navigator.pushNamed(context, kSignupRouteName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
