import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fpjs_pro_plugin/fpjs_pro_plugin.dart';
import 'package:http/http.dart';
import 'logged_in.dart';
import 'dart:convert';

class SignupCard extends StatefulWidget {
  @override
  State<SignupCard> createState() => _SignupCardState();
}

class _SignupCardState extends State<SignupCard> {
  String _fullName = '';
  String _username = '';
  String _password = '';

  @override
  void initState() {
    super.initState();
    _initFingerprint();
  }

  Future<void> handleSignup() async {
    try {
      var deviceData = await FpjsProPlugin.getVisitorData();

      var visitorId = deviceData.visitorId;
      var requestId = deviceData.requestId;

      if (visitorId == null) {
        print('Visitor ID is null');
        return;
      }

      // call the signup API endpoint
      var request = MultipartRequest(
          'POST',
          Uri.parse(
              'https://fingerprint-flask-server-fbf335614101.herokuapp.com/register'));
      request.fields.addAll({
        'username': _username,
        'password': _password,
        'full_name': _fullName,
        'visitor_id': visitorId,
        'request_id': requestId
      });

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
          content: Text('Signup failed - ${responseJson['message']}'),
        ));
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void _initFingerprint() async {
    await FpjsProPlugin.initFpjs('bWE4lFPnSw0agkH9wL2X');
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
                decoration: InputDecoration(labelText: 'Full Name'),
                onChanged: (value) => _fullName = value,
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Username'),
                onChanged: (value) => _username = value,
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Password'),
                onChanged: (value) => _password = value,
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await handleSignup();
                },
                child: Text('Signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
