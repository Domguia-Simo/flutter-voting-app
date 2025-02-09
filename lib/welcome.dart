import 'package:flutter/material.dart';
import 'principal.dart';

class Welcome extends StatelessWidget {
  static String id = 'welcome';
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset('images/logo.png'),
          Text(
            'Welcome to IAI vote',
            style: TextStyle(
                fontSize: 40,
                color: Colors.green[800],
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          MaterialButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, Principal.id);
              // Navigator.replace(context, oldRoute:MaterialPageRoute(builder: builder) Welcome.id ,newRoute: Principal.id);
            },
            child: Padding(
                padding: EdgeInsets.all(10), child: Text('Get Started')),
            color: Colors.lime[200],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          SizedBox(height: 100),
        ])),
      ),
    );
  }
}
