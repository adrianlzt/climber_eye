import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/models/slider_step.dart';
import 'package:another_xlider/models/handler.dart';

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

class VideoPlayerWidget extends StatefulWidget {
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
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  double _scale = 1.0;
  double _previousScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.isLeft
          ? Colors.blueGrey
          : Colors.amberAccent, // Set background color
      child: Row(
        children: [
          // Sliders for the Left Video
          if (widget.isLeft)
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
                        values: [widget.playbackSpeed * 10],
                        step: FlutterSliderStep(
                          step: 1,
                          isPercentRange: true,
                        ),
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          widget.onSpeedChanged(lowerValue / 10);
                        },
                        handler: FlutterSliderHandler(
                          decoration: const BoxDecoration(),
                          child: const Material(
                            type: MaterialType.canvas,
                            elevation: 3,
                            child: Icon(
                              Icons.fast_forward,
                              size: 25,
                              color: Colors.amberAccent, // Changed color
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.controller != null &&
                        widget.controller!.value.isInitialized)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 200,
                          child: FlutterSlider(
                            axis: Axis.vertical,
                            min: 0,
                            max: widget
                                .controller!.value.duration.inMilliseconds
                                .toDouble(),
                            values: [widget.position.inMilliseconds.toDouble()],
                            onDragging: (handlerIndex, lowerValue, upperValue) {
                              widget.onSeekChanged(lowerValue);
                            },
                            onDragStarted:
                                (handlerIndex, lowerValue, upperValue) =>
                                    widget.onSeekStart(),
                            onDragCompleted:
                                (handlerIndex, lowerValue, upperValue) =>
                                    widget.onSeekEnd(),
                            handler: FlutterSliderHandler(
                              // Add handler here
                              decoration: const BoxDecoration(),
                              child: const Material(
                                type: MaterialType.canvas,
                                elevation: 3,
                                child: Icon(
                                  Icons.schedule, // Use the schedule icon
                                  size: 25,
                                  color: Colors.amberAccent, // Changed color
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Text("${widget.playbackSpeed.toStringAsFixed(1)}x"),
                    if (widget.controller != null &&
                        widget.controller!.value.isInitialized)
                      Padding(
                        padding: const EdgeInsets.only(left: 45),
                        child: Text("${widget.formatDuration(widget.position)} s"),
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
                    if (widget.controller != null &&
                        widget.controller!.value.isInitialized)
                      GestureDetector(
                        onScaleStart: (ScaleStartDetails details) {
                          _previousScale = _scale;
                        },
                        onScaleUpdate: (ScaleUpdateDetails details) {
                          setState(() {
                            _scale = _previousScale * details.scale;
                          });
                        },
                        onScaleEnd: (ScaleEndDetails details) {
                          // Optional: Add logic for scale end if needed
                        },
                        onTap: () {
                          if (widget.controller!.value.isPlaying) {
                            widget.controller!.pause();
                          } else {
                            widget.controller!.play();
                          }
                        },
                        child: Transform.scale(
                          scale: _scale,
                          child: AspectRatio(
                            aspectRatio: widget.controller!.value.aspectRatio,
                            child: VideoPlayer(widget.controller!),
                          ),
                        ),
                      ),
                    if (widget.controller == null ||
                        !widget.controller!.value.isInitialized)
                      ElevatedButton(
                        onPressed: widget.pickVideo,
                        child: const Text('Pick Video'),
                      ),
                  ],
                ),
                if (widget.controller != null &&
                    widget.controller!.value.isInitialized &&
                    !widget.controller!.value.isPlaying &&
                    widget.controller!.value.position == Duration.zero)
                  ElevatedButton(
                    onPressed: () {
                      widget.controller!.play();
                    },
                    child: const Text('Play Video'),
                  ),
              ],
            ),
          ),
          // Sliders for the Right Video
          if (!widget.isLeft)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    if (widget.controller != null &&
                        widget.controller!.value.isInitialized)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 200,
                          child: FlutterSlider(
                            axis: Axis.vertical,
                            min: 0,
                            max: widget
                                .controller!.value.duration.inMilliseconds
                                .toDouble(),
                            values: [widget.position.inMilliseconds.toDouble()],
                            onDragging: (handlerIndex, lowerValue, upperValue) {
                              widget.onSeekChanged(lowerValue);
                            },
                            onDragStarted:
                                (handlerIndex, lowerValue, upperValue) =>
                                    widget.onSeekStart(),
                            onDragCompleted:
                                (handlerIndex, lowerValue, upperValue) =>
                                    widget.onSeekEnd(),
                            handler: FlutterSliderHandler(
                              // Add handler here
                              decoration: const BoxDecoration(),
                              child: const Material(
                                type: MaterialType.canvas,
                                elevation: 3,
                                child: Icon(
                                  Icons.schedule, // Use the schedule icon
                                  size: 25,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 200,
                      child: FlutterSlider(
                        axis: Axis.vertical,
                        min: 0,
                        max: 20,
                        values: [widget.playbackSpeed * 10],
                        step: FlutterSliderStep(
                          step: 1,
                          isPercentRange: true,
                        ),
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          widget.onSpeedChanged(lowerValue / 10);
                        },
                        handler: FlutterSliderHandler(
                          decoration: const BoxDecoration(),
                          child: const Material(
                            type: MaterialType.canvas,
                            elevation: 3,
                            child: Icon(
                              Icons.fast_forward,
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
                    if (widget.controller != null &&
                        widget.controller!.value.isInitialized)
                      Padding(
                        padding: const EdgeInsets.only(right: 45),
                        child: Text("${widget.formatDuration(widget.position)} s"),
                      ),
                    Text("${widget.playbackSpeed.toStringAsFixed(1)}x"),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
