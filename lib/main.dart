import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video Player Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Video Player Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  VideoPlayerController? _controller;
  File? _videoFile;
  double _playbackSpeed = 1.0; // Add playback speed variable

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      _videoFile = File(result.files.single.path!);
      _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (_videoFile != null) {
      _controller = VideoPlayerController.file(_videoFile!)
        ..initialize().then((_) {
          setState(() {});
          // Remove autoplay from here: _controller!.play();
        });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _controller != null && _controller!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                : const Text('No video selected'),
            ElevatedButton(
              onPressed: _pickVideo,
              child: const Text('Pick Video'),
            ),
            // Show a play button if the video is initialized but not playing
            if (_controller != null &&
                _controller!.value.isInitialized &&
                !_controller!.value.isPlaying &&
                _controller!.value.position == Duration.zero)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controller!.play();
                  });
                },
                child: const Text('Play Video'),
              ),

            // Playback speed controls
            if (_controller != null && _controller!.value.isInitialized)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: Slider(
                      min: 0.5,
                      max: 2.0,
                      value: _playbackSpeed,
                      onChanged: (value) {
                        setState(() {
                          _playbackSpeed = value;
                          _controller!.setPlaybackSpeed(_playbackSpeed);
                        });
                      },
                    ),
                  ),
                  Text("${_playbackSpeed.toStringAsFixed(1)}x"),
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: _controller != null && _controller!.value.isInitialized
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}
