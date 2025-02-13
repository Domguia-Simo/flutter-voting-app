import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'register.dart';
import '../dashboard/index.dart';
import '../principal.dart';

class Login extends StatefulWidget {
  static String id = 'login';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = '';

  String password = '';

  String error='';

  bool _loading =false;

  void login(BuildContext context) async {
    print('the email :' + email + ' the password:' + password);
    if(email.isEmpty || password.isEmpty){
      setState(() {
        error='Please fill all the fields';
      });
      return;
    }
    setState(() {
      _loading = true;
    });
    try{
      setState(() {
        error = '';
      });
      final auth = FirebaseAuth.instance;
      final user = await auth.signInWithEmailAndPassword(email: email, password: password);
      if(user.user != null){
        if(user.user?.email == 'admin@gmail.com'){
          Navigator.pushNamed(context, Index.id);
        }else{
          Navigator.pushReplacementNamed(context,Principal.id);
        }
      }else{
        setState(() {
        });
        print('an error occured');
      }
      // print(user.user);
    }
    catch(e){
      print('an error occures');
      setState(() {
        error = e.toString();

        // error = 'Verify your internet connection';
      });
      print(e.toString());
    }finally{
      setState(() {
        _loading = false;
      });
    }

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
              Text(error ,style: TextStyle(color:Colors.red),),
              SizedBox(
                height: 10,
              ),
              MaterialButton(
                onPressed: () {
                  _loading ? null:login(context);
                },

                color: Colors.blue,
                child: _loading ? Container(height: 20 ,width:20, child: CircularProgressIndicator( strokeWidth: 3 ,color: Colors.white,)):Text('Login'),
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
