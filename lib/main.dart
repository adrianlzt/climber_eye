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
  VideoPlayerController? _controller1;
  File? _videoFile1;
  double _playbackSpeed1 = 1.0;
  Duration _position1 = Duration.zero;
  bool _isSeeking1 = false;

  VideoPlayerController? _controller2;
  File? _videoFile2;
  double _playbackSpeed2 = 1.0;
  Duration _position2 = Duration.zero;
  bool _isSeeking2 = false;

  Future<void> _pickVideo(int videoNumber) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      if (videoNumber == 1) {
        _videoFile1 = File(result.files.single.path!);
        _initializeVideoPlayer(1);
      } else if (videoNumber == 2) {
        _videoFile2 = File(result.files.single.path!);
        _initializeVideoPlayer(2);
      }
    }
  }

  Future<void> _initializeVideoPlayer(int videoNumber) async {
    if (videoNumber == 1 && _videoFile1 != null) {
      _controller1 = VideoPlayerController.file(_videoFile1!)
        ..initialize().then((_) {
          setState(() {});
          _controller1!.addListener(() {
            if (!_isSeeking1) {
              setState(() {
                _position1 = _controller1!.value.position;
              });
            }
          });
        });
    } else if (videoNumber == 2 && _videoFile2 != null) {
      _controller2 = VideoPlayerController.file(_videoFile2!)
        ..initialize().then((_) {
          setState(() {});
          _controller2!.addListener(() {
            if (!_isSeeking2) {
              setState(() {
                _position2 = _controller2!.value.position;
              });
            }
          });
        });
    }
  }

  @override
  void dispose() {
    _controller1?.dispose();
    _controller2?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) {
      return '00:00';
    }
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > constraints.maxHeight) {
            // Landscape
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: VideoPlayerWidget(
                    controller: _controller1,
                    pickVideo: () => _pickVideo(1),
                    playbackSpeed: _playbackSpeed1,
                    position: _position1,
                    isSeeking: _isSeeking1,
                    onSpeedChanged: (value) {
                      setState(() {
                        _playbackSpeed1 = value;
                        _controller1!.setPlaybackSpeed(_playbackSpeed1);
                      });
                    },
                    onSeekChanged: (value) {
                      setState(() {
                        _position1 = Duration(milliseconds: value.toInt());
                        _controller1!.seekTo(_position1);
                      });
                    },
                    onSeekStart: () {
                      setState(() {
                        _isSeeking1 = true;
                      });
                    },
                    onSeekEnd: () {
                      setState(() {
                        _isSeeking1 = false;
                      });
                    },
                    formatDuration: _formatDuration,
                  ),
                ),
                Expanded(
                  child: VideoPlayerWidget(
                    controller: _controller2,
                    pickVideo: () => _pickVideo(2),
                    playbackSpeed: _playbackSpeed2,
                    position: _position2,
                    isSeeking: _isSeeking2,
                    onSpeedChanged: (value) {
                      setState(() {
                        _playbackSpeed2 = value;
                        _controller2!.setPlaybackSpeed(_playbackSpeed2);
                      });
                    },
                    onSeekChanged: (value) {
                      setState(() {
                        _position2 = Duration(milliseconds: value.toInt());
                        _controller2!.seekTo(_position2);
                      });
                    },
                    onSeekStart: () {
                      setState(() {
                        _isSeeking2 = true;
                      });
                    },
                    onSeekEnd: () {
                      setState(() {
                        _isSeeking2 = false;
                      });
                    },
                    formatDuration: _formatDuration,
                  ),
                ),
              ],
            );
          } else {
            // Portrait
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Video Player 1
                    VideoPlayerWidget(
                      controller: _controller1,
                      pickVideo: () => _pickVideo(1),
                      playbackSpeed: _playbackSpeed1,
                      position: _position1,
                      isSeeking: _isSeeking1,
                      onSpeedChanged: (value) {
                        setState(() {
                          _playbackSpeed1 = value;
                          _controller1!.setPlaybackSpeed(_playbackSpeed1);
                        });
                      },
                      onSeekChanged: (value) {
                        setState(() {
                          _position1 = Duration(milliseconds: value.toInt());
                          _controller1!.seekTo(_position1);
                        });
                      },
                      onSeekStart: () {
                        setState(() {
                          _isSeeking1 = true;
                        });
                      },
                      onSeekEnd: () {
                        setState(() {
                          _isSeeking1 = false;
                        });
                      },
                      formatDuration: _formatDuration,
                    ),
                    const SizedBox(height: 40),
                    // Video Player 2
                    VideoPlayerWidget(
                      controller: _controller2,
                      pickVideo: () => _pickVideo(2),
                      playbackSpeed: _playbackSpeed2,
                      position: _position2,
                      isSeeking: _isSeeking2,
                      onSpeedChanged: (value) {
                        setState(() {
                          _playbackSpeed2 = value;
                          _controller2!.setPlaybackSpeed(_playbackSpeed2);
                        });
                      },
                      onSeekChanged: (value) {
                        setState(() {
                          _position2 = Duration(milliseconds: value.toInt());
                          _controller2!.seekTo(_position2);
                        });
                      },
                      onSeekStart: () {
                        setState(() {
                          _isSeeking2 = true;
                        });
                      },
                      onSeekEnd: () {
                        setState(() {
                          _isSeeking2 = false;
                        });
                      },
                      formatDuration: _formatDuration,
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class VideoPlayerWidget extends StatelessWidget {
  final VideoPlayerController? controller;
  final VoidCallback pickVideo;
  final double playbackSpeed;
  final Duration position;
  final bool isSeeking;
  final Function(double) onSpeedChanged;
  final Function(double) onSeekChanged;
  final VoidCallback onSeekStart;
  final VoidCallback onSeekEnd;
  final String Function(Duration?) formatDuration;

  const VideoPlayerWidget({
    super.key,
    required this.controller,
    required this.pickVideo,
    required this.playbackSpeed,
    required this.position,
    required this.isSeeking,
    required this.onSpeedChanged,
    required this.onSeekChanged,
    required this.onSeekStart,
    required this.onSeekEnd,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded( // Wrap the Column with Expanded
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
        children: [
          Stack(
            alignment: Alignment.center, // Center the button
            children: [
              if (controller != null && controller!.value.isInitialized)
                AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: VideoPlayer(controller!),
                ),
              if (controller == null || !controller!.value.isInitialized)
                ElevatedButton(
                  onPressed: pickVideo,
                  child: const Text('Pick Video'),
                ),
            ],
          ),
          // Show a play button if the video is initialized but not playing
          if (controller != null &&
              controller!.value.isInitialized &&
              !controller!.value.isPlaying &&
              controller!.value.position == Duration.zero)
            ElevatedButton(
              onPressed: () {
                controller!.play();
              },
              child: const Text('Play Video'),
            ),

          // Timeline slider and time display
          if (controller != null && controller!.value.isInitialized)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(formatDuration(position)),
                Expanded(
                  child: Slider(
                    value: position.inMilliseconds.toDouble(),
                    min: 0,
                    max: controller!.value.duration.inMilliseconds.toDouble(),
                    onChanged: onSeekChanged,
                    onChangeStart: (_) => onSeekStart(),
                    onChangeEnd: (_) => onSeekEnd(),
                  ),
                ),
                Text(formatDuration(controller!.value.duration)),
              ],
            ),

          // Playback speed controls
          if (controller != null && controller!.value.isInitialized)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: Slider(
                    min: 0.5,
                    max: 2.0,
                    value: playbackSpeed,
                    onChanged: onSpeedChanged,
                  ),
                ),
                Text("${playbackSpeed.toStringAsFixed(1)}x"),
              ],
            ),
          if (controller != null && controller!.value.isInitialized)
            FloatingActionButton(
              onPressed: () {
                  controller!.value.isPlaying
                      ? controller!.pause()
                      : controller!.play();
              },
              child: Icon(
                controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
        ],
      ),
    );
  }
}
