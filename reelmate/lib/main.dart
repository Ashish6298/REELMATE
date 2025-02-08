import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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
  String statusMessage = "";
  bool isDownloading = false;

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isDenied) {
        setState(() => statusMessage = "Storage permission denied.");
        return;
      }

      if (await Permission.manageExternalStorage.request().isDenied) {
        setState(() => statusMessage = "Manage External Storage permission required.");
        return;
      }
    }
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

  Future<void> downloadVideo(String url) async {
    if (url.isEmpty) {
      setState(() => statusMessage = "Please enter a valid URL");
      return;
    }

    // Request permissions
    await requestPermissions();

    setState(() {
      isDownloading = true;
      statusMessage = "Downloading...";
    });

    try {
      final response = await http.post(
        Uri.parse("https://30xqlkjm-5000.inc1.devtunnels.ms/download"),
        headers: {"Content-Type": "application/json"},
        body: '{"url": "$url"}',
      );

      if (response.statusCode == 200) {
        String dirPath = await getDownloadDirectory();
        String filePath = "$dirPath/downloaded_video.mp4";

        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        setState(() => statusMessage = "Download complete: $filePath");
      } else {
        setState(() => statusMessage = "Failed to download");
      }
    } catch (e) {
      setState(() => statusMessage = "Error: $e");
    } finally {
      setState(() => isDownloading = false);
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
              child: isDownloading
                  ? const CircularProgressIndicator()
                  : const Text("Download Video"),
            ),
            const SizedBox(height: 20),
            Text(
              statusMessage,
              style: TextStyle(color: isDownloading ? Colors.blue : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}





