import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewCandidate extends StatefulWidget {
  static String id='view_candidate';

  @override
  State<ViewCandidate> createState() => _ViewCandidateState();
}

class _ViewCandidateState extends State<ViewCandidate> {
  Map<String ,dynamic> session = {};
  String error = '';
  List potentials = [];

  bool _loading = false;
  bool _deleteLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future<void> getCurrentSession() async{

      try{
        final fireStore = FirebaseFirestore.instance;
        final sessions = await fireStore.collection('sessions').get();
        setState(() {
          session = sessions.docs[0].data();
          session['id'] = sessions.docs[0].id;
        });
      }
      catch(e){
        print(e);
      }

    }

    void getCandidates() async{
      setState(() {
        error ='';
        _loading = true;
      });

      await getCurrentSession();

      try{

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
      finally{
        setState(() {
          _loading = false;
        });
      }
    }
    getCandidates();

  }

  void deleteCandidate(String id) async{
    setState(() {
      _deleteLoading = true;
      error = '';
    });
    try{
      final fireStore = FirebaseFirestore.instance;
      await fireStore.collection('candidates').doc(id).delete();
      final newItems = await fireStore.collection('candidates').get();
      setState(() {
        potentials = newItems.docs;
      });

    }
    catch(e){
      setState(() {
        error = 'Verify your internet connection';
      });
      print(e.toString());
    }
    finally{
      setState(() {
        _deleteLoading = false;
      });
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
            _loading ? Center(child: CircularProgressIndicator()):Text('Candidates (${potentials.length})' ,style: TextStyle(fontWeight: FontWeight.bold ,fontSize: 20),),
            SizedBox(height: 15,),
            _deleteLoading ? Center(child: Row(children: [Text('deleting the candidate..') ,Container(height:10 ,width:10,child: CircularProgressIndicator())],),):Text(''),
            Text(error ,style: TextStyle(color:Colors.red),),
            SizedBox(height: 15,),
            ...(potentials.map((candidate){
              print(candidate.data());
              return (
              Candidate(name: candidate.data()['name'],description: candidate.data()['description'],id: candidate.id, removeCandidate: deleteCandidate,status: session['status'],)
              );
            } ).toList())
          ],
        ),
      ),
    );
  }
}

class Candidate extends StatelessWidget {
  Candidate({this.name='' ,this.description='' ,this.id='', required this.removeCandidate , this.status=''});
  String name;
  String description;
  String id='';
  String status='';
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

            status != 'active' ? Text(''):TextButton(onPressed: (){removeCandidate(id);}, child: Icon(Icons.delete ,semanticLabel: 'delete',))
          ],
        ),
      ),
        SizedBox(height: 20,)
      ]
    );
  }
}
