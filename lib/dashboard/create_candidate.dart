import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateCandidate extends StatefulWidget {
  static String id = 'create_candidate';

  @override
  State<CreateCandidate> createState() => _CreateCandidateState();
}

class _CreateCandidateState extends State<CreateCandidate> {
  String name = '';
  String description = '';
  String image = '';
  String msg = '';
  String error = '';
  bool _loading = false;

  // Theme colors
  final Color primaryColor = const Color(0xFF4CAF50);
  final Color accentColor = const Color(0xFFAED581);
  final Color backgroundColor = const Color(0xFFF5F5F5);
  final Color textColor = const Color(0xFF333333);
  final Color errorColor = const Color(0xFFE53935);
  final Color successColor = const Color(0xFF43A047);

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void addCandidate() async {
    setState(() {
      name = _nameController.text.trim();
      description = _descriptionController.text.trim();
    });

    if (name.isEmpty || description.isEmpty) {
      setState(() {
        error = 'Please fill all required fields';
      });
      _showSnackBar('Please fill all required fields', isError: true);
      return;
    }
    
    try {
      setState(() {
        error = '';
        msg = '';
        _loading = true;
      });
      
      final fireStore = FirebaseFirestore.instance;
      await fireStore.collection('candidates').add({
        'name': name,
        'description': description,
        'votes': []
      });
      
      setState(() {
        msg = 'Candidate added successfully';
        // Clear form fields after successful submission
        _nameController.clear();
        _descriptionController.clear();
        name = '';
        description = '';
      });
      
      _showSnackBar('Candidate added successfully');
      
    } catch (e) {
      setState(() {
        error = 'Failed to add candidate. Please check your connection.';
      });
      _showSnackBar('Failed to add candidate', isError: true);
    } finally {
      setState(() {
        _loading = false;
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Add Candidate',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  margin: EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Candidate',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add a new candidate to the election ballot',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Form Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name field
                        Text(
                          'Candidate Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Enter candidate full name',
                            prefixIcon: Icon(Icons.person, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              name = value;
                            });
                          },
                        ),
                        
                        SizedBox(height: 24),
                        
                        // Description field
                        Text(
                          'Candidate Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 8,
                          minLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Enter candidate biography, qualifications, and campaign platform',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          onChanged: (value) {
                            setState(() {
                              description = value;
                            });
                          },
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Status message
                        if (error.isNotEmpty || msg.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: error.isNotEmpty
                                  ? Colors.red[50]
                                  : Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: error.isNotEmpty
                                    ? Colors.red[300]!
                                    : Colors.green[300]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  error.isNotEmpty
                                      ? Icons.error_outline
                                      : Icons.check_circle_outline,
                                  color: error.isNotEmpty
                                      ? Colors.red[700]
                                      : Colors.green[700],
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    error.isNotEmpty ? error : msg,
                                    style: TextStyle(
                                      color: error.isNotEmpty
                                          ? Colors.red[700]
                                          : Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : addCandidate,
                            icon: _loading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : Icon(Icons.person_add),
                            label: Text(
                              _loading ? 'Adding...' : 'Add Candidate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: primaryColor,
                              disabledBackgroundColor: primaryColor.withOpacity(0.6),
                              elevation: 3,
                              shadowColor: primaryColor.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Instructions card
                Container(
                  margin: EdgeInsets.only(top: 24),
                  child: Card(
                    elevation: 2,
                    color: accentColor.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: primaryColor),
                              SizedBox(width: 8),
                              Text(
                                'Instructions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            '• Enter the full name of the candidate',
                            style: TextStyle(fontSize: 14, color: textColor),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• Provide a detailed description including qualifications and platform',
                            style: TextStyle(fontSize: 14, color: textColor),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• All candidates will start with zero votes',
                            style: TextStyle(fontSize: 14, color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}