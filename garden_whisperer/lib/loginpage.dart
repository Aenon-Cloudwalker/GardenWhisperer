import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset(0, -0.45), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 3.0),
            duration: Duration(seconds: 5),
            builder: (BuildContext context, double blur, Widget? child) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/backgroundtwoc.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Container(
                    color: Colors.black.withOpacity(0.32),
                  ),
                ),
              );
            },
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 100),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Image.asset('assets/logotwo.png'),
                    ),
                  ),
                  SizedBox(height: 16),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        "Welcome back to GardenWhisperer!",
                        style: GoogleFonts.zcoolXiaoWei(
                          textStyle: TextStyle(
                            color: Color.fromARGB(255, 254, 255, 255),
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.white,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.white,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Get the user's email and password from the text fields
                        String email = _emailController.text
                            .toString()
                            .trim(); // Get the email from the email text field
                        String password = _passwordController.text
                            .toString()
                            .trim(); // Get the password from the password text field
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Logging in...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        // Sign in with email and password
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Logged in..."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        // User is signed in, navigate to the home screen
                        Navigator.pushReplacementNamed(context, '/home');
                      } catch (e) {
                        print(e);
                        if (e.toString() ==
                            "[firebase_auth/unknown] Given String is empty or null") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Username or password is empty"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else if (e.toString() ==
                            "[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "There is no user record corresponding to this Email. The user may have been deleted."),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else if (e.toString() ==
                            "[firebase_auth/wrong-password] The password is invalid or the user does not have a password.") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "The password is invalid or the user does not have a password."),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          // Show an error message if sign-in fails
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    child: Text('Login'),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Handle forgot password button press
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: Text('Register?'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Handle forgot password button press
                      Navigator.pushReplacementNamed(context, '/password');
                    },
                    child: Text('Forgotten Password?'),
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
