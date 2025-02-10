import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

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
                radius: 60,
                backgroundImage:
                    AssetImage('assets/ashish.jpg'), // Ensure image is in assets
              ),
              const SizedBox(height: 20),
              const Text(
                'Ashish Goswami, the developer of the ReelMate',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLinkButton(
                      'LinkedIn',
                      'https://www.linkedin.com/in/ashish-goswami-58797a24a/',
                      Colors.blue),
                  const SizedBox(width: 10),
                  _buildLinkButton(
                      'GitHub', 'https://github.com/Ashish6298', Colors.black),
                  const SizedBox(width: 10),
                  _buildLinkButton(
                      'Instagram', 'https://www.instagram.com/a.s.h.i.s.h__g.o.s.w.a.m.i?igsh=OWc0OTI0Y3FoajFr', const Color.fromARGB(255, 213, 184, 239)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkButton(String text, String url, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
        shadowColor: Colors.black26,
      ),
      onPressed: () async {
        Uri uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      },
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
