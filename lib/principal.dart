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
  Map<String, dynamic> session = {};
  List candidates = [];
  String error = '';
  String msg = '';

  bool _loading = false;
  bool isLogin = false;
  bool _voting = false;

  // App theme colors
  final Color primaryColor = const Color(0xFF4CAF50);
  final Color accentColor = const Color(0xFFAED581);
  final Color backgroundColor = const Color(0xFFF5F5F5);
  final Color cardColor = const Color(0xFFFFFFFF);
  final Color textColor = const Color(0xFF333333);
  final Color errorColor = const Color(0xFFE53935);
  final Color successColor = const Color(0xFF43A047);

  @override
  void initState() {
    super.initState();
    getCandidates();
    verifyUser();
  }

  // Function to get the active session to verify if it has ended or not
  Future<void> getSession() async {
    try {
      final fireStore = FirebaseFirestore.instance;
      final sessions = await fireStore.collection('sessions').get();
      setState(() {
        session = sessions.docs[0].data();
        session['id'] = sessions.docs[0].id;
      });
    } catch (e) {
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
      setState(() {
        _loading = false;
      });
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

  void voteCandidate(BuildContext context, String id, List votes) async {
    setState(() {
      _voting = true;
      msg = '';
    });
    try {
      List newVotes = votes;
      final auth = FirebaseAuth.instance;
      final fireStore = FirebaseFirestore.instance;

      final user = auth.currentUser;
      if (user != null) {
        final votingUser = await fireStore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (votingUser.docs.first.data()['hasVoted']) {
          setState(() {
            msg = 'You have already voted';
            _voting = false;
          });
          _showSnackBar('You cannot vote twice', isError: true);
          return;
        }
        newVotes.add(user.email);

        await fireStore
            .collection('candidates')
            .doc(id)
            .update({'votes': newVotes});

        String voterId = votingUser.docs.first.id;
        await fireStore.collection('users').doc(voterId).update({
          'email': user.email,
          'hasVoted': true
        });
        setState(() {
          msg = "Your vote was registered successfully";
        });
        _showSnackBar("Your vote was registered successfully");
      } else {
        Navigator.pushNamed(context, Login.id);
      }
    } catch (e) {
      setState(() {
        msg = e.toString();
      });
      _showSnackBar('An error occurred: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _voting = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? errorColor : successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Function to display the candidates to be voted
  List<Widget> displayCandidates(BuildContext context) {
    if (candidates.isEmpty) {
      return [
        Center(
          child: Text(
            'No candidates available',
            style: TextStyle(fontSize: 18, color: textColor),
          ),
        )
      ];
    }

    int i = 0;
    var result = candidates.map((candidate) {
      i++;
      return Card(
        elevation: 3,
        margin: EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primaryColor,
                      child: Text(
                        i.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        candidate.data()['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  candidate.data()['description'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _voting
                        ? null
                        : () {
                            voteCandidate(context, candidate.id,
                                candidate.data()['votes']);
                          },
                    icon: Icon(Icons.how_to_vote),
                    label: Text('Vote'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: primaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
    return result.toList();
  }

  // Function to display candidates results
  Widget displayResult() {
    if (candidates.isEmpty) {
      return Container();
    }

    int max = 0;
    var winner;
    List<Map<String, dynamic>> results = [];

    for (int i = 0; i < candidates.length; i++) {
      int votes = candidates[i].data()['votes'].length;
      results.add({
        'name': candidates[i].data()['name'],
        'votes': votes,
      });

      if (votes >= max) {
        max = votes;
        winner = candidates[i].data();
      }
    }

    // Sort results by votes (descending)
    results.sort((a, b) => b['votes'].compareTo(a['votes']));

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: accentColor,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 50,
                    color: Colors.amber,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Election Results',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Winner: ${winner['name']}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'with ${max} votes',
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'All Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 10),
          ...results.map((candidate) {
            double percentage = candidates.isNotEmpty && max > 0
                ? (candidate['votes'] / max * 100)
                : 0;
            return Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                minHeight: 20,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '${candidate['votes']} (${percentage.toStringAsFixed(1)}%)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void logOut() async {
    final auth = FirebaseAuth.instance;
    await auth.signOut();
    setState(() {
      isLogin = false;
    });
    _showSnackBar('Successfully logged out');
  }

  Widget _buildErrorDisplay() {
    return Center(
      child: Card(
        color: Colors.red[50],
        elevation: 2,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.signal_wifi_connected_no_internet_4,
                size: 50,
                color: errorColor,
              ),
              SizedBox(height: 10),
              Text(
                'Verify your internet connection',
                style: TextStyle(
                  color: errorColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: getCandidates,
                icon: Icon(Icons.refresh),
                label: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Loading election data...',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'IAI President Election',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
        actions: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
            child: TextButton.icon(
              onPressed: () async {
                !isLogin ? Navigator.pushNamed(context, Login.id) : logOut();
              },
              icon: Icon(
                !isLogin ? Icons.login : Icons.logout,
                color: Colors.white,
              ),
              label: Text(
                !isLogin ? 'Sign In' : 'Log Out',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: _loading
            ? _buildLoadingIndicator()
            : error.isNotEmpty
                ? _buildErrorDisplay()
                : SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (session['status'] == 'active')
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 24),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Vote for Your Candidate',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        if (_voting)
                          Center(
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 16),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.amber[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.amber),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Processing your vote...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[900],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (msg.isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: msg.contains('cannot') || msg.contains('error')
                                  ? Colors.red[50]
                                  : Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: msg.contains('cannot') || msg.contains('error')
                                    ? Colors.red[300]!
                                    : Colors.green[300]!,
                              ),
                            ),
                            child: Text(
                              msg,
                              style: TextStyle(
                                color: msg.contains('cannot') || msg.contains('error')
                                    ? Colors.red[700]
                                    : Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (session['status'] == 'active' && candidates.isNotEmpty) 
                          ...displayCandidates(context),
                        if (session['status'] == 'published' && candidates.isNotEmpty) 
                          displayResult(),
                      ],
                    ),
                  ),
      ),
    );
  }
}