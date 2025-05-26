import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'cassette_player.dart';

/// Example 1: Simple usage with asset files
class SimpleExample extends StatelessWidget {
  const SimpleExample({super.key});

  @override
  Widget build(BuildContext context) {
    final playlist = [
      AudioTrack(
        id: '1',
        title: 'Achernar',
        source: AssetSource('audio/pl-PL-Chirp3-HD-Achernar.wav'),
      ),
      AudioTrack(
        id: '2',
        title: 'Enceladus',
        source: AssetSource('audio/pl-PL-Chirp3-HD-Enceladus.wav'),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.amber[100],
      body: Center(
        child: CassettePlayer(
          playlist: playlist,
          autoPlay: true,
        ),
      ),
    );
  }
}

/// Example 2: Customized appearance and callbacks
class CustomizedExample extends StatefulWidget {
  const CustomizedExample({super.key});

  @override
  State<CustomizedExample> createState() => _CustomizedExampleState();
}

class _CustomizedExampleState extends State<CustomizedExample> {
  String _currentTrackInfo = 'No track loaded';
  String _playbackState = 'Stopped';

  @override
  Widget build(BuildContext context) {
    final playlist = [
      AudioTrack(
        id: '1',
        title: 'Summer Vibes',
        artist: 'Cool Band',
        source: AssetSource('audio/summer.mp3'),
      ),
      AudioTrack(
        id: '2',
        title: 'Night Drive',
        artist: 'Retro Wave',
        source: AssetSource('audio/night.mp3'),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CassettePlayer(
              playlist: playlist,
              config: const CassettePlayerConfig(
                backgroundColor: Colors.black,
                cassetteColor: Color(0xff1a1a1a),
                labelColor: Colors.purple,
                width: 350,
                height: 230,
                timeTextStyle: TextStyle(
                  color: Colors.purpleAccent,
                  fontSize: 18,
                  fontFamily: 'monospace',
                ),
              ),
              onTrackChanged: (track) {
                setState(() {
                  _currentTrackInfo = track?.displayTitle ?? 'No track';
                });
              },
              onPlaybackStateChanged: (state) {
                setState(() {
                  _playbackState = state.toString().split('.').last;
                });
              },
              onProgressChanged: (position, total) {
                // You could update a slider here
              },
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error)),
                );
              },
            ),
            const SizedBox(height: 40),
            Text(
              'Now Playing: $_currentTrackInfo',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'State: $_playbackState',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 3: External control with GlobalKey
class ExternalControlExample extends StatefulWidget {
  const ExternalControlExample({super.key});

  @override
  State<ExternalControlExample> createState() => _ExternalControlExampleState();
}

class _ExternalControlExampleState extends State<ExternalControlExample> {
  final GlobalKey<CassettePlayerState> _playerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final playlist = [
      AudioTrack(
        id: '1',
        title: 'Track 1',
        source: AssetSource('audio/track1.mp3'),
      ),
      AudioTrack(
        id: '2',
        title: 'Track 2',
        source: AssetSource('audio/track2.mp3'),
      ),
      AudioTrack(
        id: '3',
        title: 'Track 3',
        source: AssetSource('audio/track3.mp3'),
      ),
    ];

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CassettePlayer(
            key: _playerKey,
            playlist: playlist,
            config: const CassettePlayerConfig(
              showControls: false, // We'll use external controls
            ),
          ),
          const SizedBox(height: 40),
          // Custom controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.fast_rewind),
                onPressed: () => _playerKey.currentState?.seekTo(Duration.zero),
              ),
              IconButton(
                icon: const Icon(Icons.play_circle_filled, size: 48),
                onPressed: () => _playerKey.currentState?.play(),
              ),
              IconButton(
                icon: const Icon(Icons.pause_circle_filled, size: 48),
                onPressed: () => _playerKey.currentState?.pause(),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () => _playerKey.currentState?.next(),
              ),
            ],
          ),
          // Volume slider
          Slider(
            value: 1.0,
            onChanged: (value) {
              _playerKey.currentState?.setVolume(value);
            },
          ),
          // Track selector
          ElevatedButton(
            onPressed: () {
              _playerKey.currentState?.loadTrack(2); // Load track 3
            },
            child: const Text('Jump to Track 3'),
          ),
        ],
      ),
    );
  }
}

/// Example 4: Network audio sources
class NetworkAudioExample extends StatelessWidget {
  const NetworkAudioExample({super.key});

  @override
  Widget build(BuildContext context) {
    final playlist = [
      AudioTrack(
        id: '1',
        title: 'Online Radio',
        artist: 'Cool FM',
        source: UrlSource('https://example.com/stream.mp3'),
      ),
      AudioTrack(
        id: '2',
        title: 'Podcast Episode',
        artist: 'Tech Talk',
        source: UrlSource('https://example.com/episode.mp3'),
      ),
    ];

    return Scaffold(
      body: Center(
        child: CassettePlayer(
          playlist: playlist,
          config: const CassettePlayerConfig(
            backgroundColor: Colors.grey,
            width: 280,
            height: 180,
          ),
        ),
      ),
    );
  }
}

/// Example 5: Dynamic playlist
class DynamicPlaylistExample extends StatefulWidget {
  const DynamicPlaylistExample({super.key});

  @override
  State<DynamicPlaylistExample> createState() => _DynamicPlaylistExampleState();
}

class _DynamicPlaylistExampleState extends State<DynamicPlaylistExample> {
  final List<AudioTrack> _playlist = [];
  int _trackCounter = 0;

  void _addTrack() {
    setState(() {
      _trackCounter++;
      _playlist.add(
        AudioTrack(
          id: '$_trackCounter',
          title: 'Track $_trackCounter',
          source: AssetSource('audio/sample.mp3'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Playlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTrack,
          ),
        ],
      ),
      body: Center(
        child: _playlist.isEmpty
            ? const Text('Add tracks to start')
            : CassettePlayer(
                key: ValueKey(_playlist.length), // Rebuild when playlist changes
                playlist: _playlist,
              ),
      ),
    );
  }
}