import 'package:flutter/material.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatelessWidget {
  static String id='register';

  String email='';
  String password='';
  String confirm='';

  void register(BuildContext context) async{
    if(password != confirm){
      print('error! passwords not identical');
    }else{
      print(' the email:'+email+' the password:'+password);

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
              Text('Sign-up to IAI vote' ,style: TextStyle(fontWeight: FontWeight.bold ,fontSize: 20),),
              SizedBox(height:20),

              TextField(
                style: TextStyle(color: Colors.black ),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'Enter your email', icon: Icon(Icons.email)),
                onChanged: (e)=>email=e ,
              ),
              TextField(
                // style: TextStyle(fontSize: 12),
                obscureText: true,
                decoration: InputDecoration(hintText: 'Enter your password', icon: Icon(Icons.lock_outline)),
                onChanged: (e)=>password=e,
              ),
              TextField(
                // style: TextStyle(fontSize: 12),
                obscureText: true,
                decoration: InputDecoration(hintText: 'Confirm your password', icon: Icon(Icons.lock)),
                onChanged: (e)=>confirm=e,
              ),
              SizedBox(height: 10,),
              MaterialButton(onPressed: (){register(context);}, color: Colors.blue, child: Text('Register'),),
              SizedBox(height: 5,),

              TextButton(onPressed: ()=>Navigator.pushNamed(context, Login.id), child: Text('Already have an account?'),),
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
