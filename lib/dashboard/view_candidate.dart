import 'package:flutter/material.dart';

class ViewCandidate extends StatelessWidget {
  static String id='view_candidate';

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
            Text('Candidates (${candidates.length})' ,style: TextStyle(fontWeight: FontWeight.bold ,fontSize: 20),),
            SizedBox(height: 15,),
            ...(candidates.map((candidate){
              return (
              Candidate(name: candidate['name'],description: candidate['description'],)
              );
            } ).toList())
          ],
        ),
      ),
    );
  }
}

class Candidate extends StatelessWidget {
  Candidate({this.name='' ,this.description=''});
  String name;
  String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Container(
        color: Colors.grey.shade100,
        child: Row(
          // mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Name'),
            Text('Description'),
            TextButton(onPressed: (){}, child: Icon(Icons.delete ,semanticLabel: 'delete',))
          ],
        ),
      ),
        SizedBox(height: 20,)
      ]
    );
  }
}
