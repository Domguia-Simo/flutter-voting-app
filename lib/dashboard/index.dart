import 'package:flutter/material.dart';
import 'view_candidate.dart';
import 'create_candidate.dart';

class Index extends StatelessWidget {
  static String id = 'dashboard';
  const Index({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.lightGreen[300],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(
                  'Welcome administrator',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                )),
            SizedBox(
              height: 15,
            ),
            MaterialButton(
                color: Colors.lime[50],
                hoverColor: Colors.lime[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                onPressed: () {
                  Navigator.pushNamed(context, ViewCandidate.id);
                },
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'View Candidates',
                    ))),
            SizedBox(
              height: 20,
            ),
            MaterialButton(
                color: Colors.lime[50],
                hoverColor: Colors.lime[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                onPressed: () {
                  Navigator.pushNamed(context, CreateCandidate.id);
                },
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Add Candidates'))),
            SizedBox(
              height: 20,
            ),
            MaterialButton(
                color: Colors.lime[50],
                hoverColor: Colors.lime[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                onPressed: () {},
                child: Padding(
                    padding: EdgeInsets.all(10), child: Text('End votes'))),
            SizedBox(
              height: 20,
            ),
            MaterialButton(
                color: Colors.lime[50],
                hoverColor: Colors.lime[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                onPressed: () {},
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Publish results')))
          ],
        ),
      ),
    );
  }
}
