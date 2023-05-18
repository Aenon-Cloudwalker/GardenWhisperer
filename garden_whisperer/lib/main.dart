import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:garden_whisperer/register.dart';
import 'dart:ui';
import 'onboarding.dart';
import 'home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'loginpage.dart';
import 'register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';
import 'forgottenpassword.dart';
import 'profileupdate.dart';
import 'garden_blueprint.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  runApp(GardenWhispererApp());
}

class GardenWhispererApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/settings': (context) => SettingsScreen(),
        '/password': (context) => ForgotPasswordScreen(),
        '/updateProfile': (context) => UserProfilePage(),
        '/gardenBlueprint': (context) => GardenBedDesigner(),

        // Other routes
      },
      title: 'GardenWhisperer',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _blurValue = 0.0;
  double _opacityValue = 0.0;
  bool isLoggedIn = false; // Placeholder variable for authentication status

  Future<void> navigateBasedOnOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (hasSeenOnboarding) {
      // User has seen onboarding, navigate to the main screen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // User hasn't seen onboarding, navigate to the onboarding screen
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  Future<void> checkAuthenticationStatus() async {
    bool userLoggedIn = FirebaseAuth.instance.currentUser != null;
    print(userLoggedIn.toString());
    setState(() {
      isLoggedIn = userLoggedIn;
    });

    if (userLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      setState(() {
        _blurValue = 10.0;
        _opacityValue = 1.0;
      });
    });
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(seconds: 1),
          pageBuilder: (_, __, ___) => OnboardingScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
      checkAuthenticationStatus();
    });

    navigateBasedOnOnboardingStatus(); // Added this line to check onboarding status
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(seconds: 4),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/backgroundtwo.jpg'), // Replace with your own background image
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _blurValue, sigmaY: _blurValue),
              child: Container(color: Color.fromARGB(68, 0, 0, 0)),
            ),
            Center(
              child: AnimatedOpacity(
                duration: Duration(seconds: 2),
                curve: Curves.easeInOut,
                opacity: _opacityValue,
                child: Image.asset(
                    'assets/logotwo.png'), // Replace with your own logo image
              ),
            ),
          ],
        ),
      ),
    );
  }
}
