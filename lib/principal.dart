import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auths/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Principal extends StatefulWidget {
  static String id='principal';

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {

  List candidates = [];
  String error = '';
  String msg ='';

  bool isLogin = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    void getCandidates() async{
      try{
        setState(() {
          error='';
        });
        final fireStore = FirebaseFirestore.instance;
        final response = await fireStore.collection('candidates').get();
        setState(() {
          candidates = response.docs;
        });
      }
      catch(e){
        setState(() {
          error='Verify your internet connection';
        });
      }
    }
    void verifyUser(){
      try{
        final auth = FirebaseAuth.instance;
        final user = auth.currentUser;
        setState(() {
          isLogin = user != null;
        });
      }
      catch(e){
        print(e);
      }
    }
    getCandidates();
    verifyUser();
  }

  // final List<Map> candidates = [
  //   {
  //     'name':'Domguia',
  //     'description':'Hey am Domguia i want to be president of the student committee'
  //   },
  //   {
  //     'name':'Simo',
  //     'description':'Hey am Simo i want to be president of the student committee'
  //   },
  //   {
  //     'name':'Ulrich',
  //     'description':'Hey am Ulrich i want to be president of the student committee'
  //   }
  // ];

  void voteCandidate(BuildContext context,String id ,List votes) async{
    print(' voted for candidate $id');
    try{
      List newVotes = votes;
      final auth = FirebaseAuth.instance;

      final user = auth.currentUser;
      if(!votes.contains(user?.email)){
        newVotes.add(user?.email);
      }else{
        setState(() {
          msg = "You already voted!";
        });
        return;
      }

      // final _user = FirebaseAuth.instance;
      if(user != null){
        //   Code to vote
        final fireStore = FirebaseFirestore.instance;
        final response = await fireStore.collection('candidates').doc(id).update(
            {
              'votes':newVotes
            });
        setState(() {
          msg = "Your vote was registered correctly";
        });
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
                Text(i.toString()+'- '+candidate.data()['name'] ,style: TextStyle(fontWeight: FontWeight.bold ,fontSize: 20),),
                Text(candidate.data()['description'] ,textAlign: TextAlign.justify,),
                MaterialButton(onPressed: (){voteCandidate(context ,candidate.id ,candidate.data()['votes']);},child: Text('Vote'),color: Colors.lime[200],)
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

  void logOut() async{
    final auth = FirebaseAuth.instance;
    await auth.signOut();
    setState(() {
      isLogin = false;
    });
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
                onPressed: ()async{!isLogin ? Navigator.pushNamed(context, Login.id):logOut();},
                child:  !isLogin  ?  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 0,
                    children:[
                      Icon(Icons.login ,color: Colors.black,),
                      Text('sign-in' ,style: TextStyle(color:Colors.black),),
                    ]
                ):
                  Container(
                    child: Text('log-out here'),
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
            Text(msg ,style: TextStyle(color:Colors.green),),
            SizedBox(height: 10,),

            ...displayCandidates(context),
          ],
        ),
      )
    );
  }
}
