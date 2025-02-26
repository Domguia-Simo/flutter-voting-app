import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewCandidate extends StatefulWidget {
  static String id = 'view_candidate';

  @override
  State<ViewCandidate> createState() => _ViewCandidateState();
}

class _ViewCandidateState extends State<ViewCandidate> {
  Map<String, dynamic> session = {};
  String error = '';
  List potentials = [];

  bool _loading = false;
  bool _deleteLoading = false;
  String _deletingCandidateId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await getCurrentSession();
    getCandidates();
  }

  Future<void> getCurrentSession() async {
    try {
      final fireStore = FirebaseFirestore.instance;
      final sessions = await fireStore.collection('sessions').get();
      setState(() {
        session = sessions.docs[0].data();
        session['id'] = sessions.docs[0].id;
      });
    } catch (e) {
      print('Error fetching session: $e');
    }
  }

  void getCandidates() async {
    setState(() {
      error = '';
      _loading = true;
    });

    try {
      final fireStore = FirebaseFirestore.instance;
      final res = await fireStore.collection('candidates').get();
      setState(() {
        potentials = res.docs;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load candidates. Check your internet connection.';
      });
      print('Error fetching candidates: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void deleteCandidate(String id) async {
    setState(() {
      _deleteLoading = true;
      _deletingCandidateId = id;
      error = '';
    });
    
    try {
      final fireStore = FirebaseFirestore.instance;
      await fireStore.collection('candidates').doc(id).delete();
      final newItems = await fireStore.collection('candidates').get();
      setState(() {
        potentials = newItems.docs;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Candidate deleted successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() {
        error = 'Failed to delete candidate. Check your internet connection.';
      });
      print('Error deleting candidate: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete candidate'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _deleteLoading = false;
        _deletingCandidateId = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Candidate List',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              if (error.isNotEmpty) _buildErrorMessage(),
              Expanded(
                child: _loading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.green,
                        ),
                      )
                    : potentials.isEmpty
                        ? _buildEmptyState()
                        : _buildCandidatesList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: session['status'] == 'active'
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to add candidate page
                Navigator.of(context).pop();
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.add),
              tooltip: 'Add Candidate',
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.people,
                color: Colors.green[700],
                size: 28,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Candidates',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _loading ? 'Loading...' : '${potentials.length} registered',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(session['status']),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusText(session['status']),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 70,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'No candidates yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10),
          Text(
            session['status'] == 'active'
                ? 'Tap the + button to add a candidate'
                : 'Voting session is not active',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCandidatesList() {
    return ListView.builder(
      itemCount: potentials.length,
      itemBuilder: (context, index) {
        final candidate = potentials[index];
        return _buildCandidateCard(candidate);
      },
    );
  }

  Widget _buildCandidateCard(dynamic candidate) {
    final candidateData = candidate.data();
    final id = candidate.id;
    final isDeleting = _deleteLoading && _deletingCandidateId == id;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Text(
            candidateData['name']?[0] ?? '?',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          candidateData['name'] ?? 'Unnamed Candidate',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            candidateData['description'] ?? 'No description provided',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
        trailing: session['status'] == 'active'
            ? isDeleting
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[400]),
                    onPressed: () => _showDeleteConfirmation(id),
                  )
            : null,
      ),
    );
  }

  void _showDeleteConfirmation(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this candidate?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                deleteCandidate(id);
              },
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
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

  String _getStatusText(String? status) {
    switch (status) {
      case 'active':
        return 'VOTING ACTIVE';
      case 'ended':
        return 'VOTING ENDED';
      case 'published':
        return 'RESULTS PUBLISHED';
      default:
        return 'UNKNOWN';
    }
  }
}