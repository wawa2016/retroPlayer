import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'tape_painter.dart';
import 'tape_button.dart';

/// Audio track model
class AudioTrack {
  final String id;
  final String title;
  final String? artist;
  final Source source;

  AudioTrack({
    required this.id,
    required this.title,
    this.artist,
    required this.source,
  });

  String get displayTitle => artist != null ? '$artist - $title' : title;
}

/// Cassette player configuration
class CassettePlayerConfig {
  final Color backgroundColor;
  final Color cassetteColor;
  final Color labelColor;
  final double width;
  final double height;
  final bool showTimeDisplay;
  final bool showControls;
  final TextStyle? timeTextStyle;
  final TextStyle? titleTextStyle;

  const CassettePlayerConfig({
    this.backgroundColor = const Color.fromARGB(255, 225, 229, 234),
    this.cassetteColor = const Color.fromARGB(255, 202, 204, 206),
    this.labelColor = const Color(0xffd3c5ae),
    this.width = 300,
    this.height = 200,
    this.showTimeDisplay = true,
    this.showControls = true,
    this.timeTextStyle,
    this.titleTextStyle,
  });
}

/// Callback definitions
typedef OnTrackChanged = void Function(AudioTrack? track);
typedef OnPlaybackStateChanged = void Function(PlayerState state);
typedef OnProgressChanged = void Function(Duration position, Duration? total);
typedef OnError = void Function(String error);

/// Reusable Cassette Player Widget
class CassettePlayer extends StatefulWidget {
  final List<AudioTrack> playlist;
  final CassettePlayerConfig config;
  final OnTrackChanged? onTrackChanged;
  final OnPlaybackStateChanged? onPlaybackStateChanged;
  final OnProgressChanged? onProgressChanged;
  final OnError? onError;
  final bool autoPlay;
  final int initialTrackIndex;

  const CassettePlayer({
    super.key,
    required this.playlist,
    this.config = const CassettePlayerConfig(),
    this.onTrackChanged,
    this.onPlaybackStateChanged,
    this.onProgressChanged,
    this.onError,
    this.autoPlay = false,
    this.initialTrackIndex = 0,
  });

  @override
  State<CassettePlayer> createState() => CassettePlayerState();
}

class CassettePlayerState extends State<CassettePlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late AudioPlayer _audioPlayer;

  // Player state
  PlayerState _playerState = PlayerState.stopped;
  AudioTrack? _currentTrack;
  int _currentTrackIndex = 0;
  Duration _currentPosition = Duration.zero;
  Duration? _totalDuration;
  double _progress = 0.0;
  bool _isLoading = false;

  // Stream subscriptions
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<void>? _completionSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _setupAudioListeners();

    if (widget.playlist.isNotEmpty) {
      _currentTrackIndex = widget.initialTrackIndex.clamp(
        0,
        widget.playlist.length - 1,
      );
      if (widget.autoPlay) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          play();
        });
      }
    }
  }

  void _setupAudioListeners() {
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
        if (_totalDuration != null && _totalDuration!.inMilliseconds > 0) {
          _progress = position.inMilliseconds / _totalDuration!.inMilliseconds;
        }
      });
      widget.onProgressChanged?.call(position, _totalDuration);
    });

    _completionSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      _handleTrackCompletion();
    });

    _stateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });

      widget.onPlaybackStateChanged?.call(state);

      if (state == PlayerState.playing) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    });
  }

  void _handleTrackCompletion() {
    if (_currentTrackIndex < widget.playlist.length - 1) {
      next();
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
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Public methods for external control
  Future<void> play() async {
    if (_currentTrack == null && widget.playlist.isNotEmpty) {
      await _loadTrack(_currentTrackIndex);
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    setState(() {
      _currentPosition = Duration.zero;
      _progress = 0.0;
    });
  }

  Future<void> next() async {
    if (_currentTrackIndex < widget.playlist.length - 1) {
      await _loadTrack(_currentTrackIndex + 1);
    }
  }

  Future<void> previous() async {
    if (_currentTrackIndex > 0) {
      await _loadTrack(_currentTrackIndex - 1);
    }
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> loadTrack(int index) async {
    if (index >= 0 && index < widget.playlist.length) {
      await _loadTrack(index);
    }
  }

  // Getters for external state access
  PlayerState get playerState => _playerState;
  AudioTrack? get currentTrack => _currentTrack;
  Duration get currentPosition => _currentPosition;
  Duration? get totalDuration => _totalDuration;
  double get progress => _progress;
  bool get isPlaying => _playerState == PlayerState.playing;

  Future<void> _loadTrack(int index) async {
    setState(() {
      _isLoading = true;
      _currentTrackIndex = index;
      _currentTrack = widget.playlist[index];
      _currentPosition = Duration.zero;
      _progress = 0.0;
      _totalDuration = null;
    });

    await _audioPlayer.stop();

    try {
      await _audioPlayer.setSource(_currentTrack!.source);
      await _audioPlayer.resume();

      setState(() {
        _isLoading = false;
      });

      widget.onTrackChanged?.call(_currentTrack);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      widget.onError?.call('Failed to load track: ${e.toString()}');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.config.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cassette tape
          SizedBox(
            width: widget.config.width,
            height: widget.config.height,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: TapePainter(
                    rotationValue: _animationController.value,
                    title: _currentTrack?.displayTitle ?? '',
                    progress: _progress,
                  ),
                );
              },
            ),
          ),

          if (widget.config.showTimeDisplay) ...[
            const SizedBox(height: 10),
            Text(
              _isLoading
                  ? 'Loading...'
                  : '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration ?? Duration.zero)}',
              style:
                  widget.config.timeTextStyle ??
                  const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
          ],

          if (widget.config.showControls) ...[
            const SizedBox(height: 20),
            _buildControls(),
          ],
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TapeButton(
          icon: Icons.skip_previous,
          onTap: _currentTrackIndex > 0 ? () => previous() : null,
          isTapped: false,
        ),
        const SizedBox(width: 8),
        TapeButton(
          icon: Icons.play_arrow,
          onTap: play,
          isTapped: _playerState == PlayerState.playing,
        ),
        const SizedBox(width: 8),
        TapeButton(
          icon: Icons.pause,
          onTap: pause,
          isTapped: _playerState == PlayerState.paused,
        ),
        const SizedBox(width: 8),
        TapeButton(
          icon: Icons.stop,
          onTap: stop,
          isTapped: _playerState == PlayerState.stopped,
        ),
        const SizedBox(width: 8),
        TapeButton(
          icon: Icons.skip_next,
          onTap:
              _currentTrackIndex < widget.playlist.length - 1
                  ? () => next()
                  : null,
          isTapped: false,
        ),
      ],
    );
  }
}
