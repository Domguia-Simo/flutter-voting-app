import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auths/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Principal extends StatefulWidget {
  static String id = 'principal';

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  Map<String ,dynamic> session = {};
  List candidates = [];
  String error = '';
  String msg = '';

  bool _loading = false;
  bool isLogin = false;
  bool _voting = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Function to get the active session to verify if it has ended or not
    Future<void> getSession() async{
      try{
        final fireStore = FirebaseFirestore.instance;
        final sessions = await fireStore.collection('sessions').get();
        setState(() {
          session = sessions.docs[0].data();
          session['id'] = sessions.docs[0].id;
        });
        print(session);
      }
      catch(e){
        print(e);
      }
    }

    // Function to get the list of candidates
    void getCandidates() async {
      setState(() {
        error = '';
        _loading = true;
      });
      await getSession();
      try {
        final fireStore = FirebaseFirestore.instance;
        final response = await fireStore.collection('candidates').get();
        setState(() {
          candidates = response.docs;
        });
      } catch (e) {
        setState(() {
          error = e.toString();
        });
      } finally {
        _loading = false;
      }
    }

    // Function to verify if the user is login or not
    void verifyUser() {
      try {
        final auth = FirebaseAuth.instance;
        final user = auth.currentUser;
        setState(() {
          isLogin = user != null;
        });
      } catch (e) {
        print(e);
      }
    }

    // getSession();
    getCandidates();
    verifyUser();
  }


  void voteCandidate(BuildContext context, String id, List votes) async {
    print(' voted for candidate $id');
    // return;
    setState(() {
      _voting = true;
    });
    try {
      List newVotes = votes;
      final auth = FirebaseAuth.instance;
      final fireStore = FirebaseFirestore.instance;

      final user = auth.currentUser;
      // print(user);
      if (user != null) {

      final votingUser = await fireStore.collection('users').where('email' ,isEqualTo: user.email).get();
      print('getting the voting user');
      print(votingUser.docs.first.data());
      if(votingUser.docs.first.data()['hasVoted']){
        setState(() {
          msg = 'You cannot vote twice';
          _voting = false;
        });
        return;
      }
      newVotes.add(user.email);

        final response = await fireStore
            .collection('candidates')
            .doc(id)
            .update({'votes': newVotes});

        String voterId = votingUser.docs.first.id;
        await fireStore.collection('users').doc(voterId).update({
          'email':user.email,
          'hasVoted':true
        });
        setState(() {
          msg = "Your vote was registered correctly";
        });
      }
      else {
        Navigator.pushNamed(context, Login.id);
      }
    } catch (e) {
      setState(() {
        msg = e.toString();
      });
      print('an error occured' + e.toString());
      // Navigator.pushNamed(context, Login.id);
    }
    finally{
      _voting = false;
    }
  }
  // Function to display the candidates to be voted
  List<Widget> displayCandidates(BuildContext context) {
    int i = 0;
    var result = candidates.map((candidate) {
      i++;
      return Column(children: [
        (Container(
          width: double.infinity,
          color: Colors.grey[300],
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  i.toString() + '- ' + candidate.data()['name'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  candidate.data()['description'],
                  textAlign: TextAlign.justify,
                ),
                MaterialButton(
                  onPressed: () {
                    voteCandidate(
                        context, candidate.id, candidate.data()['votes']);
                  },
                  child: Text('Vote'),
                  color: Colors.lime[200],
                )
              ],
            ),
          ),
        )),
        SizedBox(
          height: 15,
        )
      ]);
    });
    return result.toList();
  }

  // Function to display candidates results
  Widget displayResult() {
    print(candidates.length);
    int max =0;
    var winner;
    if(candidates.length != 0){
      for(int i=0;i<candidates.length;i++){
        if(candidates[i].data()['votes'].length >= max){
          max = candidates[i].data()['votes'].length;
          winner = candidates[i].data();
        }
      }
      print("the max: "+max.toString());
      print(winner);
      return Container(child: Column(
        children: [
          Text('The winner is '+ winner['name'] ,style: TextStyle(fontSize: 25 ,fontWeight: FontWeight.bold),)
        ],
      ),);

    }else{
      return Container();
    }
  }

  void logOut() async {
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
          title: Text(
            'IAI president election',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.lightGreen[300],
          actions: [
            Container(
                padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
                child: TextButton(
                  onPressed: () async {
                    !isLogin
                        ? Navigator.pushNamed(context, Login.id)
                        : logOut();
                  },
                  child: !isLogin
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 0,
                          children: [
                              Icon(
                                Icons.login,
                                color: Colors.black,
                              ),
                              Text(
                                'sign-in',
                                style: TextStyle(color: Colors.black),
                              ),
                            ])
                      : Container(
                          child: Text('log-out here'),
                        ),
                ))
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(height: 10),
              error != ''
                  ? Center(
                    child: Column(
                    children:[
                      Icon(Icons.signal_wifi_connected_no_internet_4 ,size: 50,color: Colors.redAccent[100],),
                      Text('Verify your internet connection' ,style: TextStyle(color: Colors.red[900]),)
                                  ]),
                  )
                  : Center(
                    child: !_loading && session['status'] == 'active'  ?  Text(
                        'Vote your candidate',
                        style:
                            TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                      ):Text(''),
                  ),
              _loading ? Center(child: CircularProgressIndicator()) : Text(''),
              _voting ? Center(child: Container(child: Row(children: [Text('Voting...') ,Container(height:10 ,width:10,child: CircularProgressIndicator())],),)):Text(''),
              SizedBox(height: 15),
              Text(
                msg,
                style: TextStyle(color: Colors.green),
              ),
              SizedBox(
                height: 10,
              ),
              if (session['status'] == 'active' && candidates.length != 0) ...displayCandidates(context),
              if (session['status'] == 'published' && candidates.length != 0) displayResult()

              ,
            ],
          ),
        ));
  }
}
