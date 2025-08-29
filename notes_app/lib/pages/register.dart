import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Login.dart';
import 'notes_list.dart';

// RegisterPage StatefulWidget for user registration
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// State class for RegisterPage
class _RegisterPageState extends State<RegisterPage> {
  // Controllers for registration input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reenterPasswordController =
      TextEditingController();

  // State variables for password visibility and loading indicator
  bool _obscurePassword = true;
  bool _obscureRePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _autoLogin(); // Attempt auto-login if user is already authenticated
  }

  // Checks shared preferences and navigates to notes if already logged in
  Future<void> _autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn && FirebaseAuth.instance.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DisplayNotesPage()),
      );
    }
  }

  // Handles user registration and navigation on success
  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _ageController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _reenterPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All fields are required'),
          backgroundColor: Color(0xFFFF7F50),
        ),
      );
      return;
    }
    if (_passwordController.text.trim() !=
        _reenterPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Color(0xFFFF7F50),
        ),
      );
      return;
    }
    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Color(0xFFFF7F50),
        ),
      );
      return;
    }
    if (!_emailController.text.trim().contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid email address'),
          backgroundColor: Color(0xFFFF7F50),
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration Successful!'),
          backgroundColor: Color(0xFFFF7F50),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DisplayNotesPage()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        msg = 'Email already in use';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email address';
      } else if (e.code == 'weak-password') {
        msg = 'Password is too weak';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Color(0xFFFF7F50)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Builds the UI for the Register page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Decorative top-right circle
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: Color(0xFF3CB371).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Decorative bottom-left circle
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Color(0xFFFF7F50).withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main registration card
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Color(0xFFFFFFFF),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 16,
                              spreadRadius: 0,
                              offset: Offset(0, 4),
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 36,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title text
                              Text(
                                'Create Account',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              SizedBox(height: 6),
                              // Subtitle text
                              Text(
                                'Register a new account',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF4B4B4B),
                                ),
                              ),
                              SizedBox(height: 24),
                              Divider(thickness: 1.2, color: Color(0xFFF0F4F8)),
                              SizedBox(height: 24),
                              // Name input field
                              TextField(
                                controller: _nameController,
                                cursorColor: Color(0xFF3CB371),
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Color(0xFF3CB371),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Color(0xFFF0F4F8),
                                  labelStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                  ),
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                  ),
                                ),
                                keyboardType: TextInputType.name,
                                style: TextStyle(color: Color(0xFF1A1A1A)),
                              ),
                              SizedBox(height: 18),
                              // Email input field
                              TextField(
                                controller: _emailController,
                                cursorColor: Color(0xFF3CB371),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF3CB371),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Color(0xFFF0F4F8),
                                  labelStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                  ),
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(color: Color(0xFF1A1A1A)),
                              ),
                              SizedBox(height: 18),
                              // Age input field
                              TextField(
                                controller: _ageController,
                                cursorColor: Color(0xFF3CB371),
                                decoration: InputDecoration(
                                  labelText: 'Age',
                                  prefixIcon: Icon(
                                    Icons.cake_outlined,
                                    color: Color(0xFF3CB371),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Color(0xFFF0F4F8),
                                  labelStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                  ),
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: Color(0xFF1A1A1A)),
                              ),
                              SizedBox(height: 18),
                              // Password input field with visibility toggle
                              TextField(
                                controller: _passwordController,
                                cursorColor: Color(0xFF3CB371),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Color(0xFF3CB371),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Color(0xFFF0F4F8),
                                  labelStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                  ),
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Color(0xFF3CB371),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                style: TextStyle(color: Color(0xFF1A1A1A)),
                              ),
                              SizedBox(height: 18),
                              // Re-enter password input field with visibility toggle
                              TextField(
                                controller: _reenterPasswordController,
                                cursorColor: Color(0xFF3CB371),
                                decoration: InputDecoration(
                                  labelText: 'Re-enter Password',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Color(0xFF3CB371),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Color(0xFFF0F4F8),
                                  labelStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                  ),
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureRePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Color(0xFF3CB371),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureRePassword =
                                            !_obscureRePassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscureRePassword,
                                style: TextStyle(color: Color(0xFF1A1A1A)),
                              ),
                              SizedBox(height: 28),
                              // Register button with loading indicator
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    backgroundColor: Color(0xFF3CB371),
                                    elevation: 0,
                                    disabledBackgroundColor: Color(0xFF3CB371),
                                    disabledForegroundColor: Colors.white,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: _isLoading ? null : _register,
                                  child:
                                      _isLoading
                                          ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF87CEFA),
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : Text(
                                            'Register',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                              ),
                              SizedBox(height: 16),
                              // Link to login page
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Already have an account? Login',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
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
        ],
      ),
    );
  }
}
