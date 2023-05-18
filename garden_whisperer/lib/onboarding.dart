import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:garden_whisperer/loginpage.dart';
import 'package:garden_whisperer/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  /*
  final List<String> images = [
    'assets/logotwo.png',
    'assets/gardenflower.png',
    'assets/ai.png',
    'assets/datanalysis.png',
    'assets/journal.png',
    'assets/season.png',
    'assets/notifications.png',
    'assets/community.png',
    'assets/planner.png',
    'assets/pest.png',
    'assets/shop.png',
    'assets/weather.png',
    'assets/inspiration.png',
    'assets/inspiration.png',
  ];
  
  final List<String> titles = [
    "Discover New Plants",
    "Create Your Garden",
    "GardenWhisperer AI",
    "Plant Identification",
    "Garden Journal",
    "Seasonal Planting Guide",
    "Plant Care Reminders",
    "Community Forum",
    "Garden Planner",
    "Pest and Disease Identification",
    "Plant Shopping List",
    "Weather Integration",
    "Garden Inspiration",
    
  ];
  
  final List<String> subtitles = [
    "Explore a vast database of plant species and discover new varieties to enhance your gardening experience.",
    "Design and manage your own garden with a user-friendly interface, allowing you to plan and track your plants.",
    "Receive personalized tips and recommendations based on your garden's unique needs and your gardening preferences.",
    "Identify plant species using image recognition technology and access detailed care information.",
    "Keep a digital journal of your gardening activities, progress, and experiences.",
    "Discover a curated list of plants suitable for each season based on your climate and region.",
    "Set reminders for watering, fertilizing, pruning, and other plant care tasks.",
    "Connect with fellow gardening enthusiasts, ask questions, and share tips and experiences.",
    "Design your garden layout, experiment with plant arrangements, and visualize your garden.",
    "Identify common pests and diseases affecting your plants and receive recommended treatments.",
    "Create a shopping list of plants, seeds, and gardening supplies for your garden.",
    "Access real-time weather updates, including temperature, rainfall, and other relevant conditions.",
    "Explore a gallery of inspiring gardens and landscaping ideas to spark your creativity.",
    "Chat with the GardenWhisperer AI to get personalized gardening advice and recommendations.",
  ];
 */

  final List<String> images = [
    'assets/logotwo.png',
    'assets/gardenflower.png',
    'assets/garden.png',
    'assets/datanalysis.png',
    'assets/ai.png',
    'assets/community.png',
    'assets/notifications.png',
    'assets/start.png',
  ];

  final List<String> titles = [
    "Welcome to GardenWhisperer!",
    "Discover the World of Plants",
    "Create Your Personal Garden",
    "Track Your Garden's Progress",
    "Get Expert Advice",
    "Connect with the Gardening Community",
    "Receive Personalized Notifications",
    "Ready to Get Started?"
  ];

  final List<String> subtitles = [
    "Your personal gardening companion with a touch of magic",
    "Explore a vast collection of plants and their characteristics, from exotic flowers to practical herbs",
    "Design and plan your dream garden with our intuitive tools, visualize plant placements and arrangements",
    "Monitor the growth and health of your plants with ease, track watering schedules, and receive growth insights",
    "Chat with the GardenWhisperer AI for personalized tips and guidance, get answers to all your gardening queries",
    "Connect with fellow gardeners in your area, share tips, trade plants, and discover new gardening friends",
    "Stay updated with personalized notifications and reminders, never miss a watering or pruning session",
    "Let the wonders of nature unfold before your eyes as you cultivate a vibrant, flourishing garden of your dreams"
  ];
  SwiperController _swiperController = SwiperController();

  int _currentIndex = 0;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _setOnboardingCompleted();
  }

  Future<void> _setOnboardingCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Add a blurred background to the onboarding page
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 3.0),
            duration: Duration(seconds: 3),
            builder: (BuildContext context, double blur, Widget? child) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/backgroundtwo.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Container(
                    color: Colors.black.withOpacity(0.35),
                  ),
                ),
              );
            },
          ),

          Swiper(
            pagination: SwiperPagination(
              builder: DotSwiperPaginationBuilder(
                color: Colors.grey,
                activeColor: Color.fromARGB(255, 249, 250, 250),
              ),
            ),
            itemCount: images.length,
            itemBuilder: (BuildContext context, int index) {
              // Calculate the font size based on the screen width
              double screenWidth = MediaQuery.of(context).size.width;
              double titleFontSize =
                  screenWidth * 0.06; // Adjust the ratio as needed
              double subtitleFontSize =
                  screenWidth * 0.04; // Adjust the ratio as needed
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 1000),
                    builder:
                        (BuildContext context, double value, Widget? child) {
                      return Opacity(
                        opacity: value,
                        child: child,
                      );
                    },
                    child: Image.asset(
                      images[index],
                      width: MediaQuery.of(context).size.width * 0.6,
                    ),
                  ),
                  SizedBox(height: 32.0),
                  // Custom animation for title
                  TweenAnimationBuilder(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 1000),
                    builder:
                        (BuildContext context, double value, Widget? child) {
                      return Opacity(
                        opacity: value,
                        child: child,
                      );
                    },
                    child: Text(
                      textAlign: TextAlign.center,
                      titles[index],
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 1000),
                        builder: (BuildContext context, double value,
                            Widget? child) {
                          return Opacity(
                            opacity: value,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32.0),
                              child: Text(
                                subtitles[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  color: Colors.white,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              );
            },
            onIndexChanged: (int index) {
              setState(() {
                _currentIndex = index;
                _showButton = _currentIndex == images.length - 1;
              });
            },
            controller: _swiperController,
          ),
          Positioned(
            bottom: 32.0,
            left: 32.0,
            right: 32.0,
            child: _showButton
                ? ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromRGBO(29, 102, 56, 1))),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(seconds: 1),
                          pageBuilder: (_, __, ___) => LoginScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: Text('Get Started'),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
