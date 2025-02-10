import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateCandidate extends StatefulWidget {
  static String id = 'create_candidate';

  @override
  State<CreateCandidate> createState() => _CreateCandidateState();
}

class _CreateCandidateState extends State<CreateCandidate> {
  String name = '';

  String description = '';

  String image = '';
  String msg = '';
  String error ='';

  void addCandidate() async{
    if(name.isEmpty || description.isEmpty){
      setState(() {
        error ='Fill all the fieds';
      });
      return;
    }
    try{
      setState(() {
        error = '';
      });
        final fireStore =  FirebaseFirestore.instance;
        final response = await fireStore.collection('candidates').add({
          'name':name,
          'description':description
        });
        print(response);
        setState(() {
          msg = 'Candidate added successfully';
        });

    }catch(e){
      setState(() {
        error = 'Verify your internet connection';
      });
    }
  }

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
            Text(error.isEmpty ? msg : error ,style: TextStyle(color: error.isEmpty ? Colors.green:Colors.red),),
            MaterialButton(
              onPressed: () {
                addCandidate();
              },
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
