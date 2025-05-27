import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'cassette_player.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // Create playlist from asset files
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
      backgroundColor: const Color.fromARGB(255, 225, 229, 234),
      body: Center(
        child: CassettePlayer(
          playlist: playlist,
          onTrackChanged: (track) {
            debugPrint('Now playing: ${track?.displayTitle}');
          },
          onPlaybackStateChanged: (state) {
            debugPrint('Playback state: $state');
          },
          onError: (error) {
            debugPrint('Error: $error');
          },
        ),
      ),
    );
  }
}
