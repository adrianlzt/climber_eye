import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/models/slider_step.dart';

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
      _controller1 = VideoPlayerController.file(_videoFile1!,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
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
      _controller2 = VideoPlayerController.file(_videoFile2!,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
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
      return '00.000';
    }
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String threeDigits(int n) => n.toString().padLeft(3, '0');
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String threeDigitMilliseconds =
        threeDigits(duration.inMilliseconds.remainder(1000));
    return "$twoDigitSeconds.$threeDigitMilliseconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
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
                  isLeft: true,
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
                  isLeft: false, // This is important for correct slider placement
                ),
              ),
            ],
          );
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
  final bool isLeft;

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
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sliders for the Left Video
        if (isLeft)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 200,
                    child: FlutterSlider(
                      axis: Axis.vertical,
                      min: 0,
                      max: 20,
                      values: [playbackSpeed * 10],
                      step: FlutterSliderStep(
                        step: 1,
                        isPercentRange: true,
                      ),
                      onDragging: (handlerIndex, lowerValue, upperValue) {
                        onSpeedChanged(lowerValue / 10);
                      },
                      handler: FlutterSliderHandler( // Correct usage
                        decoration: const BoxDecoration(),
                        child: const Material(
                          type: MaterialType.canvas,
                          color: Colors.transparent,
                          elevation: 3,
                          child: Icon(
                            Icons.speed, // Use the speed icon
                            size: 25,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (controller != null && controller!.value.isInitialized)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 200,
                        child: FlutterSlider(
                          axis: Axis.vertical,
                          min: 0,
                          max: controller!.value.duration.inMilliseconds
                              .toDouble(),
                          values: [position.inMilliseconds.toDouble()],
                          onDragging: (handlerIndex, lowerValue, upperValue) {
                            onSeekChanged(lowerValue);
                          },
                          onDragStarted: (handlerIndex, lowerValue, upperValue) =>
                              onSeekStart(),
                          onDragCompleted:
                              (handlerIndex, lowerValue, upperValue) =>
                                  onSeekEnd(),
                        ),
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  Text("${playbackSpeed.toStringAsFixed(1)}x"),
                  if (controller != null && controller!.value.isInitialized)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(formatDuration(position)),
                    )
                ],
              ),
            ],
          ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (controller != null && controller!.value.isInitialized)
                    GestureDetector(
                      onTap: () {
                        if (controller!.value.isPlaying) {
                          controller!.pause();
                        } else {
                          controller!.play();
                        }
                      },
                      child: AspectRatio(
                        aspectRatio: controller!.value.aspectRatio,
                        child: VideoPlayer(controller!),
                      ),
                    ),
                  if (controller == null || !controller!.value.isInitialized)
                    ElevatedButton(
                      onPressed: pickVideo,
                      child: const Text('Pick Video'),
                    ),
                ],
              ),
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
            ],
          ),
        ),
        // Sliders for the Right Video
        if (!isLeft)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  if (controller != null && controller!.value.isInitialized)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 200,
                        child: FlutterSlider(
                          axis: Axis.vertical,
                          min: 0,
                          max: controller!.value.duration.inMilliseconds
                              .toDouble(),
                          values: [position.inMilliseconds.toDouble()],
                          onDragging: (handlerIndex, lowerValue, upperValue) {
                            onSeekChanged(lowerValue);
                          },
                          onDragStarted: (handlerIndex, lowerValue, upperValue) =>
                              onSeekStart(),
                          onDragCompleted:
                              (handlerIndex, lowerValue, upperValue) =>
                                  onSeekEnd(),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 200,
                    child: FlutterSlider(
                      axis: Axis.vertical,
                      min: 0,
                      max: 20,
                      values: [playbackSpeed * 10],
                      step: FlutterSliderStep(
                        step: 1,
                        isPercentRange: true,
                      ),
                      onDragging: (handlerIndex, lowerValue, upperValue) {
                        onSpeedChanged(lowerValue / 10);
                      },
                      handler: FlutterSliderHandler( //correct usage
                        decoration: const BoxDecoration(),
                        child: const Material(
                          type: MaterialType.canvas,
                          color: Colors.transparent,
                          elevation: 3,
                          child: Icon(
                            Icons.speed, // Use the speed icon
                            size: 25,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (controller != null && controller!.value.isInitialized)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(formatDuration(position)),
                    ),
                  Text("${playbackSpeed.toStringAsFixed(1)}x"),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
