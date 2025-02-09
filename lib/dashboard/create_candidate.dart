import 'package:flutter/material.dart';

class CreateCandidate extends StatelessWidget {
  static String id = 'create_candidate';

  String name = '';
  String description = '';
  String image = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add candidate',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.lightGreen[300],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text('Candidate creation form',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(
              height: 15,
            ),
            TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(hintText: 'Candidate name'),
              onChanged: (e) => name = e,
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(hintText: "Candidate's description"),
              minLines: 5,
              maxLines: 10,
              onChanged: (e) => description = e,
            ),
            SizedBox(
              height: 20,
            ),
            MaterialButton(
              onPressed: () {},
              child: Padding( padding:EdgeInsets.all(10),child: Text('Add Candidate')),
              color: Colors.lime[200],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
          ],
        ),
      ),
    );
  }
}
