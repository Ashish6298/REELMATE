import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MaterialApp(
    home: ReelsDownloader(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Orbitron', // Futuristic font (add to pubspec.yaml)
    ),
  ));
}

class ReelsDownloader extends StatefulWidget {
  @override
  _ReelsDownloaderState createState() => _ReelsDownloaderState();
}

class _ReelsDownloaderState extends State<ReelsDownloader>
    with TickerProviderStateMixin {
  TextEditingController urlController = TextEditingController();
  double progress = 0.0;
  bool isDownloading = false;
  String statusMessage = "Enter an Instagram Reel URL to download";
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _spinController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _spinAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _spinAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.linear),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _spinController.dispose();
    urlController.dispose();
    super.dispose();
  }

  Future<void> requestPermissions() async {
    await Permission.storage.request();
  }

  Future<String> getDownloadDirectory() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download/ReelMate');
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  Future<void> downloadReel() async {
    String url = urlController.text.trim();
    if (url.isEmpty) {
      setState(() => statusMessage = "Please enter a valid URL");
      return;
    }

    await requestPermissions();
    setState(() {
      isDownloading = true;
      progress = 0.0;
      statusMessage = "Initializing download...";
    });

    try {
      final request = http.Request("POST", Uri.parse("http://13.201.87.147/api/download-reel"));
      request.headers["Content-Type"] = "application/json";
      request.body = jsonEncode({"url": url});

      final response = await http.Client().send(request);
      response.stream.transform(utf8.decoder).listen((data) {
        final parsed = jsonDecode(data.replaceFirst("data: ", "").trim());

        if (parsed["progress"] != null) {
          setState(() {
            progress = parsed["progress"] / 100.0;
            statusMessage = "Downloading: ${(progress * 100).toStringAsFixed(0)}%";
          });
        }

        if (parsed["status"] == "completed") {
          String filename = parsed["filename"];
          _downloadFile(filename);
        } else if (parsed["status"] == "error") {
          setState(() {
            isDownloading = false;
            statusMessage = "Error: ${parsed["error"] ?? "Unknown error"}";
          });
        }
      });
    } catch (e) {
      setState(() {
        isDownloading = false;
        statusMessage = "Error: $e";
      });
    }
  }

  Future<void> _downloadFile(String filename) async {
    String dirPath = await getDownloadDirectory();
    String filePath = "$dirPath/$filename.mp4";

    final response = await http.get(Uri.parse("http://13.201.87.147/api/download-file?filename=$filename"));
    if (response.statusCode == 200) {
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        statusMessage = "Saved to $filePath";
        isDownloading = false;
        progress = 1.0;
        urlController.clear();
      });
    } else {
      setState(() {
        statusMessage = "Download failed: ${response.statusCode}";
        isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black,
              Colors.purple.shade900,
              Colors.deepPurple.shade900,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated waves
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(_controller.value),
                  size: Size.infinite,
                );
              },
            ),
            // Orbiting particles
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(_pulseController.value),
                  size: Size.infinite,
                );
              },
            ),
            // Main content
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Static Title with "Powered by" below and aligned left
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Reels Downloader",
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    blurRadius: 15,
                                    color: Colors.purpleAccent.withOpacity(0.7),
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                "Powered by ReelMate",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                      // Holographic Input Field
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.purpleAccent.withOpacity(0.5),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purpleAccent.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: urlController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Paste Instagram Reel URL",
                              hintStyle: TextStyle(color: Colors.white38),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      // Static Glowing Button (No Animation)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: GestureDetector(
                          onTap: isDownloading ? null : downloadReel,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDownloading
                                    ? [Colors.grey.shade800, Colors.grey.shade600]
                                    : [Colors.purpleAccent, Colors.deepPurple.shade900],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purpleAccent.withOpacity(0.6),
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Text(
                              "Download Reel",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      // Holographic Progress Bar with Spinning Loader
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 300,
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.purpleAccent.withOpacity(0.5),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purpleAccent.withOpacity(0.2),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.black.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.purpleAccent.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ),
                            if (isDownloading)
                              AnimatedBuilder(
                                animation: _spinController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _spinAnimation.value,
                                    child: Icon(
                                      Icons.loop,
                                      size: 24,
                                      color: Colors.purpleAccent.withOpacity(0.8),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Status Message with Holographic Effect
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          statusMessage,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            letterSpacing: 1,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.purpleAccent.withOpacity(0.5),
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Wave Painter
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.7 + sin((x / size.width * pi) + animationValue * 2 * pi) * 30;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Particle Painter
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.purpleAccent.withOpacity(0.3);
    for (int i = 0; i < 15; i++) {
      final angle = animationValue * 2 * pi + (i * pi / 7);
      final radius = 60 + (i * 15);
      final x = size.width / 2 + cos(angle) * radius;
      final y = size.height / 2 + sin(angle) * radius;
      canvas.drawCircle(Offset(x, y), 2 + (i % 4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}