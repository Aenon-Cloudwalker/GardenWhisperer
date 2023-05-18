import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profileupdate.dart';
import 'dart:ui';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isOnboardingEnabled = true;

  Future<void> updateOnboardingStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', status);
  }

  Future<void> getOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool status = prefs.getBool('seenOnboarding') ?? false;
    setState(() {
      isOnboardingEnabled = status;
    });
  }

  void toggleOnboarding(bool value) async {
    setState(() {
      isOnboardingEnabled = value;
    });

    // Update the onboarding status in shared preferences
    await updateOnboardingStatus(value);
  }

  @override
  void initState() {
    super.initState();
    getOnboardingStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        title: Text('Settings'),
      ),
      body: Container(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 100),
              Text(
                'Enable Onboarding',
                style: TextStyle(
                  color: Color.fromARGB(255, 34, 34, 34),
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 16),
              Switch(
                value: isOnboardingEnabled,
                onChanged: toggleOnboarding,
              ),
              Expanded(
                child:
                    Container(), // Add an empty container to occupy the remaining space
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(),
                    ),
                  );
                },
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
