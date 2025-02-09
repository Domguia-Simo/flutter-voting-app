import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auths/login.dart';

class Principal extends StatelessWidget {
  static String id='principal';

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

  void voteCandidate(BuildContext context,String candidate){
    print(' voted for candidate $candidate');
    try{
      final _user = FirebaseAuth.instance;
      if(_user.currentUser != null){
        //   Code to vote
      }
      else{
        Navigator.pushNamed(context, Login.id);
      }
    }
    catch(e){
      print('an error occured'+e.toString());
      Navigator.pushNamed(context, Login.id);
    }


  }

  List displayCandidates(BuildContext context){
    int i=0;
    var result = candidates.map((candidate){
      i++;
      return Column(
        children: [(
        Container(
          width: double.infinity,
          color: Colors.grey[300],
          child: Padding(
            padding:EdgeInsets.all(10),
            child: Column(
              children: [
                Text(i.toString()+'- '+candidate['name'] ,style: TextStyle(fontWeight: FontWeight.bold ,fontSize: 20),),
                Text(candidate['description'] ,textAlign: TextAlign.justify,),
                MaterialButton(onPressed: (){voteCandidate(context ,candidate['name']);},child: Text('Vote'),color: Colors.lime[200],)
              ],
            ),
          ),
        )
        ), SizedBox(height: 15,)
        ]
      );
    });
    return result.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('IAI president election' ,style: TextStyle(fontWeight: FontWeight.w600),),
        backgroundColor: Colors.lightGreen[300],
        actions: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
              child: TextButton(
                onPressed: (){Navigator.pushNamed(context, Login.id);},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 0,
                    children:[
                      Icon(Icons.login ,color: Colors.black,),
                      Text('sign-in' ,style: TextStyle(color:Colors.black),),

                    ]
                ),
              ))
        ],
      ),
      body:Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [

            SizedBox(height:10),
            Text('Vote your candidate' ,style: TextStyle(fontSize: 25 ,fontWeight: FontWeight.w500),),
            SizedBox(height:15),

            ...displayCandidates(context),
          ],
        ),
      )
    );
  }
}
