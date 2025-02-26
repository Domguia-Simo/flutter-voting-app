import 'package:flutter/material.dart';
import 'principal.dart';

class Welcome extends StatelessWidget {
  static String id = 'welcome';
  const Welcome({super.key});

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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with subtle animation
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Image.asset(
                          'images/logo.png',
                          height: 150,
                          width: 150,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Title with text shadow for depth
                  Text(
                    'Welcome to IAI vote',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  Text(
                    'Your trusted platform for secure and transparent voting',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green[600],
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Elevated button with hover effect
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, Principal.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32, 
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                      shadowColor: Colors.green[800]!.withOpacity(0.5),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // Footer text
                  Text(
                    '© 2025 IAI vote',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}