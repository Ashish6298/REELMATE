import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MaterialApp(
    home: VideoDownloader(),
    debugShowCheckedModeBanner: false,
  ));
}

class VideoDownloader extends StatefulWidget {
  @override
  _VideoDownloaderState createState() => _VideoDownloaderState();
}

class _VideoDownloaderState extends State<VideoDownloader> {
  TextEditingController urlController = TextEditingController();
  double progress = 0.0;
  bool isDownloading = false;
  String statusMessage = "Enter a YouTube URL to download";

  Future<void> requestPermissions() async {
    await Permission.storage.request();
  }

  Future<String> getDownloadDirectory() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download/ReelMate'); // Custom Folder
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
      statusMessage = "Downloading...";
    });

    try {
      final request = http.Request("POST", Uri.parse("http://13.201.87.147/api/download"));//change url according to device
      request.headers["Content-Type"] = "application/json";
      request.body = jsonEncode({"url": url});

      final response = await http.Client().send(request);
      response.stream.transform(utf8.decoder).listen((data) {
        final parsed = jsonDecode(data.replaceFirst("data: ", "").trim());

        if (parsed["progress"] != null) {
          setState(() => progress = parsed["progress"] / 100.0);
        }

        if (parsed["status"] == "completed") {
          String filename = parsed["filename"];
          _downloadFile(filename);
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

    final response = await http.get(Uri.parse("http://13.201.87.147/api/download-file?filename=$filename"));//change url according to device
    if (response.statusCode == 200) {
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        statusMessage = "Download complete: $filePath";
        isDownloading = false;
        progress = 1.0;
        urlController.clear(); // **Clears the URL input field after completion**
      });
    } else {
      setState(() {
        statusMessage = "Download failed.";
        isDownloading = false;
      });
    }
  }

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "YouTube Video Downloader",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: "YouTube Video URL",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              _buildButton("Download Video", Colors.redAccent, isDownloading ? null : downloadVideo),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: isDownloading ? progress : 0.0,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 20),
              Text(statusMessage, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback? onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: color,
        elevation: 5,
        shadowColor: Colors.black26,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
