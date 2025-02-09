import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'principal.dart';
import 'auths/login.dart';
import 'auths/register.dart';
import 'welcome.dart';
import 'dashboard/index.dart';
import 'dashboard/create_candidate.dart';
import 'dashboard/view_candidate.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Future<bool> hasInternet() async{
    try{
      var result = await InternetAddress.lookup('google.com');
      if(result.isNotEmpty){
        return true;
      }else{return false;}
    }catch(e){return false;}

  }
  if(kIsWeb){
    // if(await hasInternet()){
      Firebase.initializeApp(options: const FirebaseOptions(apiKey: "AIzaSyCGUMUye2WB1vTVl4mzMiGm0L9U1Q_ARxI",
          authDomain: "flutter-voting-app-443f5.firebaseapp.com",
          projectId: "flutter-voting-app-443f5",
          storageBucket: "flutter-voting-app-443f5.firebasestorage.app",
          messagingSenderId: "774722658159",
          appId: "1:774722658159:web:0d672808c78d295764929a",
          measurementId: "G-9XX9HX6LDY"));
    // }
  }else{
    // if(await hasInternet()) {
      await Firebase.initializeApp();
    // }
  }

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title:'IAI voting app',
      theme:ThemeData(fontFamily:'DejaVuSans' ),
      initialRoute: Welcome.id,
      routes:{
        Welcome.id:(context)=>Welcome(),
        Principal.id:(context)=>Principal(),
        // Authentication routes
        Login.id:(context)=>Login(),
        Register.id:(context)=>Register(),
        // Dashboard routes
        Index.id:(context)=>Index(),
        ViewCandidate.id:(context)=>ViewCandidate(),
        CreateCandidate.id:(context)=>CreateCandidate(),

      }
    )
  );
}


