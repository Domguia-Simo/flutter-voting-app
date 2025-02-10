import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewCandidate extends StatefulWidget {
  static String id='view_candidate';

  @override
  State<ViewCandidate> createState() => _ViewCandidateState();
}

class _ViewCandidateState extends State<ViewCandidate> {
  String error = '';
  List potentials = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    void getCandidates() async{
      try{
        setState(() {
          error ='';
        });
        final fireStore = FirebaseFirestore.instance;
        final res = await fireStore.collection('candidates').get();
        // print(res.docs[0]);
        setState(() {
          potentials = res.docs;
        });
      }catch(e){
        setState(() {
          error ='Verify your internet connection';
        });
        print('an error occured');
        // print(e.toString());

      }
    }
    getCandidates();

  }

  void deleteCandidate(String id) async{
    try{
      final fireStore = FirebaseFirestore.instance;
      await fireStore.collection('candidates').doc(id).delete();

    }
    catch(e){
      setState(() {
        error = 'Verify your internet connection';
      });
      print(e.toString());
    }
  }

  final List<Map> candidates = [
    {
      'name':'Domguia',
      'description':'Hey am Domguia i want to be president of the student committee'
    },
    {
      'name':'Simo',
      'description':'Hey am Simo i want to be president of the student committee'
    },
    {
      'name':'Ulrich',
      'description':'Hey am Ulrich i want to be president of the student committee'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Candidate list' ,style: TextStyle(fontWeight: FontWeight.w600),),
        backgroundColor: Colors.lightGreen[300],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20,),
            Text('Candidates (${potentials.length})' ,style: TextStyle(fontWeight: FontWeight.bold ,fontSize: 20),),
            SizedBox(height: 15,),
            ...(potentials.map((candidate){
              print(candidate.data());
              return (
              Candidate(name: candidate.data()['name'],description: candidate.data()['description'],id: candidate.id, removeCandidate: deleteCandidate,)
              );
            } ).toList())
          ],
        ),
      ),
    );
  }
}

class Candidate extends StatelessWidget {
  Candidate({this.name='' ,this.description='' ,this.id='', required this.removeCandidate });
  String name;
  String description;
  String id='';
  Function removeCandidate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Container(
        color: Colors.grey.shade100,
        child: Row(
          // mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name ,style:TextStyle(fontWeight: FontWeight.bold)),
                Text(description ,overflow: TextOverflow.fade,),
              ],
            ),

            TextButton(onPressed: (){removeCandidate(id);}, child: Icon(Icons.delete ,semanticLabel: 'delete',))
          ],
        ),
      ),
        SizedBox(height: 20,)
      ]
    );
  }
}
