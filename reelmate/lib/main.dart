import 'package:flutter/material.dart';
import 'dart:async';
import 'instagram_page.dart';
import 'youtube_page.dart';
import 'about.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReelMate',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/instagram': (context) => ReelsDownloader(),
        '/youtube': (context) => VideoDownloader(),
        '/about': (context) => const AboutPage(),
      },
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Image.asset('assets/social.png', width: 200),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override


Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.blueGrey],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(seconds: 2),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform(
                  transform: Matrix4.identity()
                    ..scale(0.8 + (value * 0.2))
                    ..translate(0.0, (1 - value) * -20), // Smooth vertical movement
                  child: const Text(
                    "ReelMate",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'DancingScript', // Latin/cursive font style
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.blueGrey,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Center(child: Image.asset('assets/social.png', width: 180)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(5),
                    child: IconButton(
                      icon: FaIcon(FontAwesomeIcons.instagram, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pushNamed(context, '/instagram'),
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(5),
                    child: IconButton(
                      icon: FaIcon(FontAwesomeIcons.youtube, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pushNamed(context, '/youtube'),
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(5),
                    child: IconButton(
                      icon: FaIcon(FontAwesomeIcons.infoCircle, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pushNamed(context, '/about'),
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}




  Widget _buildButton(BuildContext context, String text, Color color, String route) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: color,
        elevation: 5,
        shadowColor: Colors.black26,
      ),
      onPressed: () {
        Navigator.of(context).pushNamed(route);
      },
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

