# Retro Player 🎵

A nostalgic Flutter app that recreates the classic cassette tape player experience with realistic animations and audio playback. Now available as a **reusable widget** for your Flutter projects!

![Flutter](https://img.shields.io/badge/Flutter-3.29.3-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.7.2-blue.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-green.svg)

<p align="center">
  <img src="https://github.com/wawa2016/retroPlayer/blob/main/assets/screenshots/cassette_recording_20250527_171401_demo.gif" alt="Retro Cassette Player Widget Demo" width="350">
</p>

## 🎯 How to Use in Another App

The cassette player is now a **fully reusable widget** that you can easily integrate into any Flutter project!

### Quick Start

1. **Copy these files** to your project:
   ```
   lib/
   ├── cassette_player.dart    # Main widget
   ├── tape_painter.dart       # Cassette graphics
   └── tape_button.dart        # Control buttons
   ```

2. **Add dependency** to your `pubspec.yaml`:
   ```yaml
   dependencies:
     audioplayers: ^6.1.0
   ```

3. **Use the widget** in your app:
   ```dart
   import 'package:your_app/cassette_player.dart';
   
   CassettePlayer(
     playlist: [
       AudioTrack(
         id: '1',
         title: 'My Song',
         artist: 'Artist Name',
         source: AssetSource('audio/song.mp3'),
       ),
     ],
     autoPlay: true,
   )
   ```

### Customization Example

```dart
CassettePlayer(
  playlist: myPlaylist,
  config: CassettePlayerConfig(
    backgroundColor: Colors.purple,
    width: 350,
    height: 230,
    timeTextStyle: TextStyle(color: Colors.white),
  ),
  onTrackChanged: (track) {
    print('Now playing: ${track?.displayTitle}');
  },
  onError: (error) {
    showSnackBar(error);
  },
)
```

## Features

- 🎼 **Audio Playback**: Play any audio format supported by audioplayers
- 📼 **Realistic Cassette Animation**: Watch the tape reels spin and transfer tape as the audio plays
- ⏱️ **Time Display**: Track current position and total duration in MM:SS format
- 🎨 **Fully Customizable**: Colors, sizes, fonts - make it match your app's theme
- 🎵 **Playlist Support**: Built-in playlist management with next/previous
- 📁 **Multiple Audio Sources**: Assets, URLs, or device files
- 🎮 **External Control**: Control playback programmatically via GlobalKey
- 📡 **Event Callbacks**: Listen to track changes, playback state, and progress

## Widget API

### Basic Properties

| Property | Type | Description |
|----------|------|-------------|
| `playlist` | `List<AudioTrack>` | List of tracks to play |
| `config` | `CassettePlayerConfig` | Visual customization options |
| `autoPlay` | `bool` | Start playing immediately |
| `initialTrackIndex` | `int` | Which track to load first |

### Callbacks

| Callback | Type | Description |
|----------|------|-------------|
| `onTrackChanged` | `Function(AudioTrack?)` | Called when track changes |
| `onPlaybackStateChanged` | `Function(PlayerState)` | Called on play/pause/stop |
| `onProgressChanged` | `Function(Duration, Duration?)` | Called during playback |
| `onError` | `Function(String)` | Called on errors |

### External Control

```dart
final playerKey = GlobalKey<CassettePlayerState>();

// Use the key
CassettePlayer(key: playerKey, ...)

// Control playback
playerKey.currentState?.play();
playerKey.currentState?.pause();
playerKey.currentState?.next();
playerKey.currentState?.seekTo(Duration(seconds: 30));
```

## Project Structure

```
lib/
├── main.dart                    # Example app entry point
├── home.dart                    # Example usage
├── cassette_player.dart         # ⭐ Main reusable widget
├── tape_painter.dart           # Custom painter for graphics
├── tape_button.dart            # Button component
├── example_usage.dart          # Multiple usage examples
└── CASSETTE_PLAYER_WIDGET.md   # Widget documentation

assets/
└── audio/                      # Audio files for demo
    ├── pl-PL-Chirp3-HD-Achernar.wav
    └── pl-PL-Chirp3-HD-Enceladus.wav
```

## Running the Demo App

### Prerequisites

- Flutter SDK: ^3.7.2
- Dart SDK: ^3.7.2
- iOS 12.1+ / Android API 21+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/retroPlayer.git
cd retroPlayer
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Usage Examples

### Simple Usage
```dart
CassettePlayer(
  playlist: [
    AudioTrack(
      id: '1',
      title: 'Song Name',
      source: AssetSource('audio/song.mp3'),
    ),
  ],
)
```

### With Network Audio
```dart
CassettePlayer(
  playlist: [
    AudioTrack(
      id: '1',
      title: 'Online Radio',
      source: UrlSource('https://stream.example.com/radio.mp3'),
    ),
  ],
)
```

### Custom Theme
```dart
CassettePlayer(
  playlist: myTracks,
  config: CassettePlayerConfig(
    backgroundColor: Colors.black,
    cassetteColor: Color(0xff1a1a1a),
    labelColor: Colors.purple,
    width: 280,
    height: 180,
  ),
)
```

### With All Callbacks
```dart
CassettePlayer(
  playlist: myTracks,
  onTrackChanged: (track) => updateUI(track),
  onPlaybackStateChanged: (state) => handleState(state),
  onProgressChanged: (pos, total) => updateSlider(pos, total),
  onError: (error) => showError(error),
)
```

## Documentation

- 📖 [Widget API Documentation](CASSETTE_PLAYER_WIDGET.md) - Detailed widget documentation
- 🤖 [Development Notes](CLAUDE.md) - Technical notes for AI assistants
- 📝 [Example Usage](lib/example_usage.dart) - Complete code examples

## Troubleshooting

### No Sound on iOS Simulator
- Increase volume: Device → Increase Volume (Cmd+Up)
- Check Mac system volume
- Test on a real device for best results

### Asset Loading Issues
- Ensure audio files are in `assets/audio/` directory
- Run `flutter clean && flutter pub get` after adding new assets
- Check that `pubspec.yaml` includes the assets section

### Widget Integration Issues
- Make sure all three files are copied (cassette_player, tape_painter, tape_button)
- Check that audioplayers dependency is added
- Verify import paths are correct

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is open source and available under the [MIT License](LICENSE).

---

<p align="center">
  Made with ❤️ for the nostalgic souls who miss the analog days
</p>