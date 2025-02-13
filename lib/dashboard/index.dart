import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'view_candidate.dart';
import 'create_candidate.dart';

class Index extends StatefulWidget {
  static String id = 'dashboard';
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {

  Map<String ,dynamic> session ={};
  /*
  * session:{status:[active ,ended ,published]}
  * */
  bool _loading = false;
  bool _endVoteLoading = false;
  bool _publishVoteLoading = false;
  bool _sessionloading = false;

  String msg ='';
  String error ='';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    void getCurrentSession() async{
      setState(() {
        _loading = true;
        error = '';
        msg = '';
      });
      try{
        final fireStore = FirebaseFirestore.instance;
        final sessions = await fireStore.collection('sessions').get();
        setState(() {
          session = sessions.docs[0].data();
          session['id'] = sessions.docs[0].id;
        });
      }
      catch(e){
        setState(() {
          error = 'An error occured';
        });
        print(e);
      }
      finally{
        setState(() {
          _loading = false;
        });
      }
    }
    getCurrentSession();
  }

  // Function to end a vote by changing the session status
  void endVotes() async{


    if(session['status'] == 'ended' || session['status'] == 'published'){
      setState(() {
        msg = '';
        error='Votes already ended';
      });
      return;
    }
    setState(() {
      _endVoteLoading = true;
      error='';
      msg='';
    });

    try{
      final fireStore =  FirebaseFirestore.instance;
      final response = await fireStore.collection('sessions').doc(session['id']).update({
        'status':'ended'
      });
      setState(() {
        msg = 'Votes ended successfully';
        session['status'] = 'ended';
      });
    }
    catch(e){
      setState(() {
        error = 'An error occured';
      });
      print(e);
    }
    finally{
      setState(() {
        _endVoteLoading = false;
      });
    }
  }

  // Function to publish the vote results
  void publishResults() async{
    if(session['status'] == 'published' ){
      setState(() {
        msg = '';
        error='Votes already published';
      });
      return;
    }
    setState(() {
      _publishVoteLoading = true;
      error ='';
      msg ='';
    });
    try{
      final fireStore = FirebaseFirestore.instance;
      final response = await fireStore.collection('sessions').doc(session['id']).update({
        'status':'published'
      });
      setState(() {
        msg = 'Votes results published successfully! \n note: this operation is not reversible';
        session['status'] = 'published';
      });
    }
    catch(e){
      setState(() {
        error ='an error occured';
      });
      print(e);
    }finally{
      setState(() {
        _publishVoteLoading = false;

      });
    }
  }


  // Function to start a new session
  void startSession() async{
    setState(() {
      _sessionloading = true;
      error = '';
      msg ='';
    });
    try{
      final fireStore = FirebaseFirestore.instance;
      final sessions = await fireStore.collection('sessions').doc(session['id']).update({
        'status':'active'
      });
      final candidates = await fireStore.collection('candidates').get();
       candidates.docs.clear();

      CollectionReference users = FirebaseFirestore.instance.collection('users');

      // Step 1: Fetch all users
      QuerySnapshot querySnapshot = await users.get();

      if (querySnapshot.docs.isNotEmpty) {
        // Step 2: Create a batch for multiple updates
        WriteBatch batch = FirebaseFirestore.instance.batch();

        for (var doc in querySnapshot.docs) {
          batch.update(doc.reference, {"hasVoted": false});
        }

        // Step 3: Commit the batch update
        await batch.commit();

        print("Voting status reset successfully for all users.");
      }

      setState(() {
        session['status'] = 'active';
        msg = 'New Session created correctly \n all the previous candidates will be automatically deleted \n this operation is not reverisble';
      });
    }
    catch(e){
      setState(() {
        error = 'an error occured';
      });
      print(e);
    }finally{
      setState(() {
        _sessionloading = false;
      });
    }
  }

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
        child: _loading ? Center(child: CircularProgressIndicator()):Column(
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
            Center(child: Text(error ,style: TextStyle(color:Colors.red),)),
            Center(child: Text(msg ,style: TextStyle(color:Colors.green),)),

            SizedBox(height: 15,),
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
                  if(session['status'] == 'ended' || session['status'] == 'published'){
                    setState(() {
                      error ='Votes have been ended \n You need to start a new session';
                      msg = '';
                    });
                  }else{
                    Navigator.pushNamed(context, CreateCandidate.id);
                  }
                },
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Add Candidates'))),
            SizedBox(
              height: 20,
            ),
            // MaterialButton(
            //     color: Colors.lime[50],
            //     hoverColor: Colors.lime[200],
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            //     onPressed: () { _endVoteLoading ? null:endVotes(); },
            //     child: Padding(
            //         padding: EdgeInsets.all(10), child:_endVoteLoading ?CircularProgressIndicator(): Text('End votes'))),
            // SizedBox(
            //   height: 20,
            // ),
            MaterialButton(
                color: Colors.lime[50],
                hoverColor: Colors.lime[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                onPressed: () { _publishVoteLoading ? null:publishResults(); },
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: _publishVoteLoading ? CircularProgressIndicator():Text('End votes and Publish results'))),
            SizedBox(
              height: 20,
            ),
             session['status'] == 'active' ? Text(''):
            MaterialButton(
                color: Colors.lime[100],
                hoverColor: Colors.lime[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                onPressed: () { _sessionloading ? null:startSession(); },
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: _sessionloading ? CircularProgressIndicator():Text('Start a new session')))
          ],
        ),
      ),
    );
  }
}
