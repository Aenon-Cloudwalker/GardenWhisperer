import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'garden_blueprint.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  User? _currentUser;
  String _displayName = '';
  String _email = '';
  String _profileImageUrl = '';

  bool isLoggedIn = false; // Placeholder variable for authentication status
  late String selectedImage;
  List<String> imageUrls = [
    "assets/backgroundtwoc.png",
    "assets/backgroundtwo.jpg",
    // Add more image URLs here
  ];
  void getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    print(user.toString());
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
      fetchUserDetails();
    }
  }

  void fetchUserDetails() async {
    if (_currentUser != null) {
      String userId = _currentUser!.uid;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      print(userSnapshot.id);
      if (userSnapshot.exists) {
        setState(() {
          _displayName = userSnapshot['displayName'];
          _email = userSnapshot['email'];
          _profileImageUrl = userSnapshot['photoUrl'];
        });
        print('Display Name: $_displayName');
        print('Email: $_email');
        print('Profile Image URL: $_profileImageUrl');
        print("hello");
      }
    }
  }

  String getImageByDate(DateTime date) {
    int index = date.day % imageUrls.length;
    return imageUrls[index];
  }

  Future<void> checkAuthenticationStatus() async {
    bool userLoggedIn = FirebaseAuth.instance.currentUser != null;
    print(userLoggedIn.toString());
    setState(() {
      isLoggedIn = userLoggedIn;
    });

    if (userLoggedIn) {
      getCurrentUser();
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    checkAuthenticationStatus();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, -0.45), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    super.initState();
  }

  void _showAIAssistantPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('GardenWhisperer AI Assistant'),
        content: Text('This is the AI assistant popup'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    // Select the background image based on the current date
    selectedImage = getImageByDate(currentDate);
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Color.fromRGBO(18, 27, 61, 1),
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.home,
                color: Color.fromRGBO(18, 27, 61, 1),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/home');
              },
            ),
            IconButton(
              icon: Icon(
                Icons.info,
                color: Color.fromRGBO(18, 27, 61, 1),
              ),
              onPressed: () {
                // Handle info hub button press
              },
            ),
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: Color.fromRGBO(18, 27, 61, 1),
              ),
              onPressed: () {
                // Handle notification button press
              },
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(18, 27, 61, 1), // Change the background color here
              ),
              accountName: Text(_displayName),
              accountEmail: Text(_email),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    (_profileImageUrl.isNotEmpty) ? NetworkImage(_profileImageUrl) as ImageProvider<Object>? : AssetImage('assets/logonotextthree.jpg'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Handle Home menu item tap
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/updateProfile');
              },
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text('Premium Features'),
              onTap: () {
                // Handle premium features item tap
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
              onTap: () {
                // Handle Help menu item tap
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                // Handle About menu item tap
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback'),
              onTap: () {
                // Handle Feedback menu item tap
              },
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text('Privacy Policy'),
              onTap: () {
                // Handle Privacy Policy menu item tap
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  // User signed out successfully
                  // Navigate to login screen or any other desired screen
                } catch (e) {
                  // Error occurred during sign out
                  print('Sign Out Error: $e');
                }
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(167, 202, 168, 106),
        onPressed: () {
          _showAIAssistantPopup(context);
        },
        child: Icon(Icons.chat),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      body: Stack(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 3.0),
            duration: Duration(seconds: 5),
            builder: (BuildContext context, double blur, Widget? child) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(selectedImage),
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
          ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                          "Welcome to GardenWhisperer!",
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FeatureTile(
                          imagePath: "assets/datanalysis.png",
                          title: 'Plant identification',
                        ),
                        FeatureTile(
                          imagePath: "assets/gardendesign.png",
                          title: 'Garden designer',
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FeatureTile(
                          imagePath: "assets/food.png",
                          title: 'Food',
                        ),
                        FeatureTile(
                          imagePath: "assets/plant.png",
                          title: 'Plants',
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FeatureTile(
                          imagePath: "assets/garden.png",
                          title: 'Virtual garden',
                        ),
                        FeatureTile(
                          imagePath: "assets/journal.png",
                          title: 'Tips & Guides',
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FeatureTile(
                          imagePath: "assets/ai.png",
                          title: 'GardenWhisperer AI',
                        ),
                        FeatureTile(
                          imagePath: "assets/journaltwo.png",
                          title: 'Journal',
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FeatureTile(
                          imagePath: "assets/pest.png",
                          title: 'Pest and Disease',
                        ),
                        FeatureTile(
                          imagePath: "assets/notifications.png",
                          title: 'Plant Care Reminders',
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FeatureTile(
                          imagePath: "assets/season.png",
                          title: 'Calendar',
                        ),
                        FeatureTile(
                          imagePath: "assets/weather.png",
                          title: 'Weather',
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FeatureTile(
                          imagePath: "assets/inspiration.png",
                          title: 'Inspiration',
                        ),
                        FeatureTile(
                          imagePath: "assets/shop.png",
                          title: 'Garden Supplies',
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FeatureTile(
                          imagePath: "assets/community.png",
                          title: 'Community',
                        ),
                        FeatureTile(
                          imagePath: "assets/shop.png",
                          title: 'Garden Supplies',
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeatureTile extends StatefulWidget {
  final String imagePath;
  final String title;

  const FeatureTile({
    required this.imagePath,
    required this.title,
  });

  @override
  _FeatureTileState createState() => _FeatureTileState();
}

class _FeatureTileState extends State<FeatureTile> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 3), // Adjust the duration as needed
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward(); // Start the animation

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the design screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GardenBedDesigner()),
        );
      },
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (BuildContext context, Widget? child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4, // Adjust the width as needed
              child: Column(
                children: [
                  Image.asset(
                    widget.imagePath,
                    height: 80,
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.title,
                    style: GoogleFonts.zcoolXiaoWei(
                      textStyle: TextStyle(
                        color: Color.fromARGB(255, 254, 255, 255),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
