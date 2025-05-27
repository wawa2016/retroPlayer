import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'tape_button.dart';

import 'tape_painter.dart';

enum TapeStatus { initial, playing, pausing, stopping, choosing }

class AudioFile {
  final String path;
  final String title;

  AudioFile({required this.path, required this.title});
}

class Tape extends StatefulWidget {
  const Tape({super.key});

  @override
  State<Tape> createState() => _TapeState();
}

class _TapeState extends State<Tape> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _audioPlayer;

  // Audio state
  TapeStatus _status = TapeStatus.initial;
  String? _url;
  String? _title;
  double _currentPosition = 0.0;
  int _currentTrackIndex = 0;
  Duration? _totalDuration;
  Duration _currentDuration = Duration.zero;
  bool _isLoading = false;

  // Stream subscriptions
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<void>? _completionSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;

  final List<AudioFile> _playlist = [
    AudioFile(path: 'pl-PL-Chirp3-HD-Achernar.wav', title: 'Achernar'),
    AudioFile(path: 'pl-PL-Chirp3-HD-Enceladus.wav', title: 'Enceladus'),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    // Listen for duration changes
    _durationSubscription = _audioPlayer.onDurationChanged.listen((
      Duration duration,
    ) {
      setState(() {
        _totalDuration = duration;
      });
    });

    // Listen for position changes
    _positionSubscription = _audioPlayer.onPositionChanged.listen((
      Duration position,
    ) {
      setState(() {
        _currentDuration = position;
        if (_totalDuration != null && _totalDuration!.inMilliseconds > 0) {
          _currentPosition =
              position.inMilliseconds / _totalDuration!.inMilliseconds;
        }
      });
    });

    // Listen for completion
    _completionSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      _handleTrackCompletion();
    });

    // Listen for state changes
    _stateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      PlayerState state,
    ) {
      if (state == PlayerState.playing) {
        setState(() {
          _status = TapeStatus.playing;
        });
        _controller.repeat();
      } else if (state == PlayerState.paused) {
        setState(() {
          _status = TapeStatus.pausing;
        });
        _controller.stop();
      } else if (state == PlayerState.stopped) {
        setState(() {
          _status = TapeStatus.stopping;
          _currentPosition = 0.0;
          _currentDuration = Duration.zero;
        });
        _controller.stop();
      }
    });
  }

  void _handleTrackCompletion() {
    if (_currentTrackIndex < _playlist.length - 1) {
      _loadTrack(_currentTrackIndex + 1);
    } else {
      stop();
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _completionSubscription?.cancel();
    _stateSubscription?.cancel();
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300,
          height: 200,
          child: AnimatedBuilder(
            builder: (BuildContext context, Widget? child) {
              return CustomPaint(
                painter: TapePainter(
                  rotationValue: _controller.value,
                  title: _title ?? '',
                  progress: _currentPosition,
                  timeDisplay:
                      _isLoading
                          ? 'Loading...'
                          : '${_formatDuration(_currentDuration)} / ${_formatDuration(_totalDuration ?? Duration.zero)}',
                ),
              );
            },
            animation: _controller,
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TapeButton(
              icon: Icons.play_arrow,
              onTap: play,
              isTapped: _status == TapeStatus.playing,
            ),
            SizedBox(width: 8),
            TapeButton(
              icon: Icons.pause,
              onTap: pause,
              isTapped: _status == TapeStatus.pausing,
            ),
            SizedBox(width: 8),
            TapeButton(
              icon: Icons.stop,
              onTap: stop,
              isTapped: _status == TapeStatus.stopping,
            ),
            SizedBox(width: 8),
            TapeButton(
              icon: Icons.skip_previous,
              onTap: previousTrack,
              isTapped: false,
            ),
            SizedBox(width: 8),
            TapeButton(
              icon: Icons.skip_next,
              onTap: nextTrack,
              isTapped: false,
            ),
            SizedBox(width: 8),
            TapeButton(
              icon: Icons.volume_up,
              onTap: _testSound,
              isTapped: false,
            ),
          ],
        ),
      ],
    );
  }

  void stop() async {
    await _audioPlayer.stop();
  }

  void pause() async {
    await _audioPlayer.pause();
  }

  void play() async {
    if (_url == null && _playlist.isNotEmpty) {
      // If no URL but we have playlist, load first track
      _loadTrack(0);
    } else if (_url != null) {
      await _audioPlayer.resume();
    }
  }

  void previousTrack() {
    if (_currentTrackIndex > 0) {
      _loadTrack(_currentTrackIndex - 1);
    }
  }

  void nextTrack() {
    if (_currentTrackIndex < _playlist.length - 1) {
      _loadTrack(_currentTrackIndex + 1);
    }
  }

  void _testSound() async {
    try {
      // Play a system sound to test if audio works at all
      await _audioPlayer.play(
        AssetSource('audio/pl-PL-Chirp3-HD-Achernar.wav'),
        volume: 1.0,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  void _loadTrack(int index) async {
    if (index < 0 || index >= _playlist.length) return;

    setState(() {
      _isLoading = true;
      _currentTrackIndex = index;
      _title = _playlist[index].title;
      _currentPosition = 0.0;
      _currentDuration = Duration.zero;
      _totalDuration = null;
    });

    // Stop any current playback
    await _audioPlayer.stop();

    final filename = _playlist[index].path;
    _url = 'audio/$filename';

    try {
      // AssetSource automatically prepends "assets/" so we just need "audio/filename"
      // Set source first
      await _audioPlayer.setSource(AssetSource('audio/$filename'));

      // Then resume
      await _audioPlayer.resume();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Try without audio/ prefix
      try {
        await _audioPlayer.setSource(AssetSource(filename));
        await _audioPlayer.resume();
      } catch (e2) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> choose() async {
    stop();

    setState(() {
      _status = TapeStatus.choosing;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result == null) {
      setState(() {
        _status = TapeStatus.initial;
      });
      return;
    }

    PlatformFile file = result.files.first;

    _url = file.path;

    // Get title from filename
    String title = file.name;
    // Remove file extension from title
    if (title.contains('.')) {
      title = title.substring(0, title.lastIndexOf('.'));
    }

    setState(() {
      _title = title;
      _currentPosition = 0.0;
      _currentDuration = Duration.zero;
    });

    try {
      await _audioPlayer.play(DeviceFileSource(_url!));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audio file: ${e.toString()}')),
        );
      }
      setState(() {
        _status = TapeStatus.initial;
      });
    }
  }
}
