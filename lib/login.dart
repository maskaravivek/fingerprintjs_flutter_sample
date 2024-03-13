import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'logged_in.dart';
import 'dart:convert';

class LoginCard extends StatefulWidget {
  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  String _username = '';
  String _password = '';

  Future<void> handleLogin() async {
    try {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      var request = MultipartRequest(
          'POST',
          Uri.parse(
              'https://fingerprint-flask-server-fbf335614101.herokuapp.com/login'));
      request.fields.addAll({'username': _username, 'password': _password});

      StreamedResponse response = await request.send();

      var responseStr = await response.stream.bytesToString();
      final responseJson = json.decode(responseStr);
      if (responseJson['status'] == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoggedIn()),
        );
      } else {
        print("responseJson ${responseJson}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Log in failed - ${responseJson['message']}'),
        ));
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'Username'),
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Password'),
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await handleLogin();
                },
                child: Text('Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
