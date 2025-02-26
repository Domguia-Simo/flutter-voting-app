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
  Map<String, dynamic> session = {};
  /*
  * session:{status:[active, ended, published]}
  * */
  bool _loading = false;
  bool _endVoteLoading = false;
  bool _publishVoteLoading = false;
  bool _sessionloading = false;

  String msg = '';
  String error = '';

  @override
  void initState() {
    super.initState();
    getCurrentSession();
  }

  void getCurrentSession() async {
    setState(() {
      _loading = true;
      error = '';
      msg = '';
    });
    try {
      final fireStore = FirebaseFirestore.instance;
      final sessions = await fireStore.collection('sessions').get();
      setState(() {
        session = sessions.docs[0].data();
        session['id'] = sessions.docs[0].id;
      });
    } catch (e) {
      setState(() {
        error = 'An error occurred while fetching session data';
      });
      print(e);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Function to end a vote by changing the session status
  void endVotes() async {
    if (session['status'] == 'ended' || session['status'] == 'published') {
      setState(() {
        msg = '';
        error = 'Votes have already been ended';
      });
      return;
    }
    
    setState(() {
      _endVoteLoading = true;
      error = '';
      msg = '';
    });

    try {
      final fireStore = FirebaseFirestore.instance;
      await fireStore.collection('sessions').doc(session['id']).update({
        'status': 'ended'
      });
      setState(() {
        msg = 'Votes ended successfully';
        session['status'] = 'ended';
      });
    } catch (e) {
      setState(() {
        error = 'An error occurred while ending votes';
      });
      print(e);
    } finally {
      setState(() {
        _endVoteLoading = false;
      });
    }
  }

  // Function to publish the vote results
  void publishResults() async {
    if (session['status'] == 'published') {
      setState(() {
        msg = '';
        error = 'Results have already been published';
      });
      return;
    }
    
    setState(() {
      _publishVoteLoading = true;
      error = '';
      msg = '';
    });
    
    try {
      final fireStore = FirebaseFirestore.instance;
      await fireStore.collection('sessions').doc(session['id']).update({
        'status': 'published'
      });
      setState(() {
        msg = 'Vote results published successfully!\nNote: This operation cannot be reversed';
        session['status'] = 'published';
      });
    } catch (e) {
      setState(() {
        error = 'An error occurred while publishing results';
      });
      print(e);
    } finally {
      setState(() {
        _publishVoteLoading = false;
      });
    }
  }

  // Function to start a new session
  void startSession() async {
    setState(() {
      _sessionloading = true;
      error = '';
      msg = '';
    });
    
    try {
      final fireStore = FirebaseFirestore.instance;
      await fireStore.collection('sessions').doc(session['id']).update({
        'status': 'active'
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
        msg = 'New session created successfully\nAll previous candidates have been deleted\nThis operation cannot be reversed';
      });
    } catch (e) {
      setState(() {
        error = 'An error occurred while starting a new session';
      });
      print(e);
    } finally {
      setState(() {
        _sessionloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Administration Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 4,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green[50]!, Colors.white],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: Colors.green,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Welcome, Administrator',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.green[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(session['status']),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Current Status: ${getStatusText(session['status'])}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (error.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                error,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (msg.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.green[300]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.green),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                msg,
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.5,
                        children: [
                          _buildActionCard(
                            title: 'View Candidates',
                            icon: Icons.people,
                            color: Colors.blue,
                            onTap: () {
                              Navigator.pushNamed(context, ViewCandidate.id);
                            },
                          ),
                          _buildActionCard(
                            title: 'Add Candidate',
                            icon: Icons.person_add,
                            color: Colors.amber,
                            onTap: () {
                              if (session['status'] == 'ended' || session['status'] == 'published') {
                                setState(() {
                                  error = 'Votes have been ended\nYou need to start a new session';
                                  msg = '';
                                });
                              } else {
                                Navigator.pushNamed(context, CreateCandidate.id);
                              }
                            },
                          ),
                          _buildActionCard(
                            title: 'End Votes & Publish Results',
                            icon: Icons.how_to_vote,
                            color: Colors.purple,
                            isLoading: _publishVoteLoading,
                            onTap: () {
                              _publishVoteLoading ? null : publishResults();
                            },
                          ),
                          if (session['status'] != 'active')
                            _buildActionCard(
                              title: 'Start New Session',
                              icon: Icons.restart_alt,
                              color: Colors.green,
                              isLoading: _sessionloading,
                              onTap: () {
                                _sessionloading ? null : startSession();
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      color: color,
                      strokeWidth: 3,
                    ),
                  )
                : Icon(
                    icon,
                    color: color,
                    size: 40,
                  ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'ended':
        return Colors.orange;
      case 'published':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String? status) {
    switch (status) {
      case 'active':
        return 'Voting Active';
      case 'ended':
        return 'Voting Ended';
      case 'published':
        return 'Results Published';
      default:
        return 'Unknown';
    }
  }
}