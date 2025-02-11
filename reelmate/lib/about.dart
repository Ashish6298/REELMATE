import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('About Developer')),
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.blueGrey],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 100,
              backgroundImage:
                  AssetImage('assets/ashish.jpg'), // Ensure image is in assets
            ),
            const SizedBox(height: 20),
            const Text(
              'Ashish Goswami, The Developer Of The ReelMate \nA Platform Where You Can Download\n The Insta Reels And Youtube Videos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'DancingScript'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconButton(
                  FontAwesomeIcons.linkedin,
                  'https://www.linkedin.com/in/ashish-goswami-58797a24a/',
                  Colors.blue,
                ),
                const SizedBox(width: 10),
                _buildIconButton(
                  FontAwesomeIcons.github,
                  'https://github.com/Ashish6298',
                  Colors.black,
                ),
                const SizedBox(width: 10),
                _buildIconButton(
                  FontAwesomeIcons.instagram,
                  'https://www.instagram.com/a.s.h.i.s.h__g.o.s.w.a.m.i?igsh=OWc0OTI0Y3FoajFr',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildIconButton(IconData icon, String url, Color color) {
  return GestureDetector(
    onTap: () => launchUrl(Uri.parse(url)),
    child: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Center(
        child: FaIcon(icon, color: Colors.white, size: 30),
      ),
    ),
  );
}
}