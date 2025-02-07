import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReelMate Downloader',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const VideoDownloader(),
    );
  }
}

class VideoDownloader extends StatefulWidget {
  const VideoDownloader({super.key});

  @override
  _VideoDownloaderState createState() => _VideoDownloaderState();
}

class _VideoDownloaderState extends State<VideoDownloader> {
  TextEditingController urlController = TextEditingController();
  double progress = 0.0;
  bool isDownloading = false;

  Future<void> requestPermissions() async {
    if (await Permission.storage.request().isDenied) {
      return;
    }
  }

  Future<void> downloadVideo(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid URL")),
      );
      return;
    }

    await requestPermissions();
    setState(() {
      isDownloading = true;
      progress = 0.0;
    });

    try {
      var request = http.Request(
        "POST",
        Uri.parse("http://10.0.2.2:5000/download"),
      )
        ..headers["Content-Type"] = "application/json"
        ..body = jsonEncode({"url": url});

      var streamedResponse = await http.Client().send(request);

      streamedResponse.stream.transform(utf8.decoder).listen((output) {
        try {
          Map<String, dynamic> data = jsonDecode(output);

          if (data.containsKey("progress")) {
            double newProgress = data["progress"].toDouble();
            setState(() => progress = newProgress);

            if (newProgress >= 100) {
              setState(() => isDownloading = false);

              showDialog(
                context: context,
                barrierDismissible: false, // Prevent closing by tapping outside
                builder: (context) => AlertDialog(
                  title: const Text("Download Complete"),
                  content: const Text("The video has been downloaded successfully."),
                  actions: [
                    TextButton(
                      child: const Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        setState(() {
                          urlController.clear(); // Clear the URL field
                        });
                      },
                    ),
                  ],
                ),
              );
            }
          }
        } catch (e) {
          print("Error parsing progress: $e");
        }
      });
    } catch (e) {
      setState(() => isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ReelMate Downloader")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: "Enter YouTube URL",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isDownloading ? null : () => downloadVideo(urlController.text),
              child: isDownloading ? const CircularProgressIndicator() : const Text("Download Video"),
            ),
            const SizedBox(height: 20),
            if (isDownloading)
              Column(
                children: [
                  LinearProgressIndicator(value: progress / 100),
                  const SizedBox(height: 10),
                  Text("${progress.toStringAsFixed(1)}% downloaded"),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
