import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'register.dart';
import '../dashboard/index.dart';
import '../principal.dart';

class Login extends StatelessWidget {
  static String id = 'login';

  String email = '';
  String password = '';

  void login(BuildContext context) async {
    print('the email :' + email + ' the password:' + password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
          padding: EdgeInsets.all(10),
          child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Icon(Icons.close))),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(image: AssetImage('images/logo.png'))
                ),
                width: 100,
                height: 100,
              ),
              Text('Sign-in to IAI vote' ,style: TextStyle(fontWeight: FontWeight.bold ,fontSize: 20),),
              SizedBox(height:20),
              TextField(
                style: TextStyle(color: Colors.black),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    hintText: 'Enter your email', icon: Icon(Icons.email)),
                onChanged: (e) => email = e,
              ),
              TextField(
                // style: TextStyle(fontSize: 12),
                obscureText: true,
                decoration: InputDecoration(
                    hintText: 'Enter your password', icon: Icon(Icons.lock)),
                onChanged: (e) => password = e,
              ),
              SizedBox(
                height: 10,
              ),
              MaterialButton(
                onPressed: () {
                  login(context);
                },
                color: Colors.blue,
                child: Text('Login'),
              ),
              SizedBox(
                height: 5,
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, Register.id),
                child: Text('No account?'),
              ),
              SizedBox(
                height: 100,
              )
            ],
          ),
        ),
      ),
    );
  }
}
