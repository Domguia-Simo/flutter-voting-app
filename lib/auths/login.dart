import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'register.dart';
import '../dashboard/index.dart';
import '../principal.dart';

class Login extends StatefulWidget {
  static String id = 'login';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  String email = '';
  String password = '';
  String error = '';
  bool _loading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void login(BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        error = 'Please fill all the fields';
      });
      return;
    }
    setState(() {
      _loading = true;
      error = '';
    });
    try {
      final auth = FirebaseAuth.instance;
      final user = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (user.user != null) {
        if (user.user?.email == 'admin@gmail.com') {
          Navigator.pushNamed(context, Index.id);
        } else {
          Navigator.pushReplacementNamed(context, Principal.id);
        }
      }
    } catch (e) {
      setState(() {
        // Display a more user-friendly error message
        if (e.toString().contains('user-not-found')) {
          error = 'No account found with this email';
        } else if (e.toString().contains('wrong-password')) {
          error = 'Incorrect password';
        } else if (e.toString().contains('network-request-failed')) {
          error = 'Network error. Please check your connection';
        } else {
          error = 'Login failed. Please try again';
        }
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[100]!, Colors.green[50]!],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back button
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.green[800]),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              
              // Main content
              Center(
                child: SingleChildScrollView(
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Hero(
                            tag: 'logo',
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'images/logo.png',
                                  width: 120,
                                  height: 120,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Title
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                              letterSpacing: 0.5,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Sign in to continue with IAI vote',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.green[600],
                              fontSize: 14,
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Input fields
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Email address',
                              prefixIcon: Icon(Icons.email, color: Colors.green[600]),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            onChanged: (e) => email = e,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: Icon(Icons.lock, color: Colors.green[600]),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            onChanged: (e) => password = e,
                          ),
                          
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Handle forgot password
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                foregroundColor: Colors.green[700],
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Error message
                          if (error.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      error,
                                      style: TextStyle(color: Colors.red[700], fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Login button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : () => login(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: _loading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Register link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, Register.id),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.only(left: 8),
                                  minimumSize: Size(50, 30),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  foregroundColor: Colors.green[700],
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}