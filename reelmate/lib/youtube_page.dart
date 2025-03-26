import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MaterialApp(
    home: VideoDownloader(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Orbitron', // Futuristic font (add to pubspec.yaml)
    ),
  ));
}

class VideoDownloader extends StatefulWidget {
  @override
  _VideoDownloaderState createState() => _VideoDownloaderState();
}

class _VideoDownloaderState extends State<VideoDownloader>
    with SingleTickerProviderStateMixin {
  TextEditingController urlController = TextEditingController();
  double progress = 0.0;
  bool isDownloading = false;
  String statusMessage = "Enter a YouTube URL to download";
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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

  Future<void> downloadVideo() async {
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
      // Use 10.0.2.2:5000 for emulator testing, update as needed
      final request = http.Request("POST", Uri.parse("http://10.0.2.2:5000/download"));
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
            statusMessage = "Error: ${parsed["error"]}";
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

    final response = await http.get(Uri.parse("http://10.0.2.2:5000/download-file?filename=$filename"));
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
              Colors.black87,
              Colors.blueGrey.shade900,
              Colors.deepPurple.shade900,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background waves
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(_controller.value),
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
                      // Title with fade animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          "YouTube Downloader",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.cyanAccent.withOpacity(0.5),
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
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
                      SizedBox(height: 40),
                      // URL Input with neumorphic design
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black45,
                                offset: Offset(4, 4),
                                blurRadius: 10,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.05),
                                offset: Offset(-4, -4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: urlController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Paste YouTube URL",
                              hintStyle: TextStyle(color: Colors.white54),
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
                      // Download Button with glow effect
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: GestureDetector(
                          onTap: isDownloading ? null : downloadVideo,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDownloading
                                    ? [Colors.grey, Colors.grey.shade700]
                                    : [Colors.cyanAccent, Colors.blueAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: isDownloading ? 0 : 5,
                                ),
                              ],
                            ),
                            child: Text(
                              "Download",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      // Progress Indicator with futuristic style
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: 300,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.cyanAccent.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Status Message with fade effect
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          statusMessage,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 5,
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

// Custom painter for futuristic wave background
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.8 + sin((x / size.width * pi) + animationValue * 2 * pi) * 20;
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