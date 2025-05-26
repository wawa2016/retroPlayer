# CassettePlayer Widget Documentation

## Overview

The `CassettePlayer` is a fully customizable, reusable Flutter widget that provides a nostalgic cassette tape player UI with integrated audio playback functionality.

## Features

- 🎨 **Fully Customizable**: Colors, sizes, and styles
- 🎵 **Multiple Audio Sources**: Assets, URLs, Files
- 📡 **Event Callbacks**: Track changes, playback state, progress
- 🎮 **External Control**: Control playback programmatically
- 📼 **Realistic Animation**: Tape reels that respond to playback progress
- 🔊 **Volume Control**: Adjustable volume levels
- ⏩ **Seek Support**: Jump to any position in the track

## Basic Usage

```dart
import 'package:your_app/cassette_player.dart';
import 'package:audioplayers/audioplayers.dart';

// Create a playlist
final playlist = [
  AudioTrack(
    id: '1',
    title: 'Song One',
    artist: 'Artist Name',
    source: AssetSource('audio/song1.mp3'),
  ),
  AudioTrack(
    id: '2',
    title: 'Song Two',
    source: UrlSource('https://example.com/song2.mp3'),
  ),
];

// Use the widget
CassettePlayer(
  playlist: playlist,
  autoPlay: true,
)
```

## Configuration

### CassettePlayerConfig

```dart
CassettePlayerConfig(
  backgroundColor: Color(0xfff9bf44),    // Background color
  cassetteColor: Color(0xff522f19),      // Cassette body color
  labelColor: Color(0xffd3c5ae),         // Label color
  width: 300,                            // Widget width
  height: 200,                           // Widget height
  showTimeDisplay: true,                 // Show time counter
  showControls: true,                    // Show control buttons
  timeTextStyle: TextStyle(...),         // Time display style
  titleTextStyle: TextStyle(...),        // Title text style
)
```

## Callbacks

### Track Changed
```dart
onTrackChanged: (AudioTrack? track) {
  print('Now playing: ${track?.displayTitle}');
}
```

### Playback State Changed
```dart
onPlaybackStateChanged: (PlayerState state) {
  print('State: $state');
}
```

### Progress Changed
```dart
onProgressChanged: (Duration position, Duration? total) {
  print('Progress: ${position.inSeconds}/${total?.inSeconds}');
}
```

### Error Handling
```dart
onError: (String error) {
  print('Error: $error');
}
```

## External Control

### Using GlobalKey

```dart
final GlobalKey<CassettePlayerState> playerKey = GlobalKey();

// In your widget tree
CassettePlayer(
  key: playerKey,
  playlist: playlist,
)

// Control playback
playerKey.currentState?.play();
playerKey.currentState?.pause();
playerKey.currentState?.stop();
playerKey.currentState?.next();
playerKey.currentState?.previous();
playerKey.currentState?.seekTo(Duration(seconds: 30));
playerKey.currentState?.setVolume(0.5);
playerKey.currentState?.loadTrack(2);
```

### Access Player State

```dart
final state = playerKey.currentState;
if (state != null) {
  print('Is playing: ${state.isPlaying}');
  print('Current track: ${state.currentTrack?.title}');
  print('Position: ${state.currentPosition}');
  print('Duration: ${state.totalDuration}');
  print('Progress: ${state.progress}'); // 0.0 to 1.0
}
```

## Audio Sources

### Asset Files
```dart
AudioTrack(
  id: '1',
  title: 'Local Asset',
  source: AssetSource('audio/song.mp3'),
)
```

### Network URLs
```dart
AudioTrack(
  id: '2',
  title: 'Online Stream',
  source: UrlSource('https://example.com/stream.mp3'),
)
```

### Device Files
```dart
AudioTrack(
  id: '3',
  title: 'Downloaded File',
  source: DeviceFileSource('/path/to/file.mp3'),
)
```

## Advanced Examples

### Custom Controls Only
```dart
CassettePlayer(
  playlist: playlist,
  config: CassettePlayerConfig(
    showControls: false,  // Hide built-in controls
  ),
)
```

### Minimal Time Display
```dart
CassettePlayer(
  playlist: playlist,
  config: CassettePlayerConfig(
    showTimeDisplay: false,  // Hide time display
    height: 180,            // Smaller height
  ),
)
```

### Dark Theme
```dart
CassettePlayer(
  playlist: playlist,
  config: CassettePlayerConfig(
    backgroundColor: Colors.black,
    cassetteColor: Color(0xff1a1a1a),
    labelColor: Colors.purple,
    timeTextStyle: TextStyle(color: Colors.purpleAccent),
  ),
)
```

## Integration Tips

1. **State Management**: The widget manages its own state, but you can integrate with your app's state management solution using callbacks.

2. **Playlist Updates**: To update the playlist, create a new widget instance with a new key:
   ```dart
   CassettePlayer(
     key: ValueKey(playlist.length),
     playlist: updatedPlaylist,
   )
   ```

3. **Memory Management**: The widget properly disposes of resources. No additional cleanup needed.

4. **Error Handling**: Always provide an `onError` callback for production apps.

5. **Performance**: The tape animation is optimized to only repaint when necessary.

## Requirements

- Flutter SDK: ^3.7.2
- audioplayers: ^6.1.0
- iOS 12.1+ / Android API 21+

## Migration from Original App

If migrating from the original tape.dart:

1. Replace `Tape` widget with `CassettePlayer`
2. Convert your audio files to `AudioTrack` objects
3. Update callbacks to use the new signatures
4. Remove old audio management code

## Troubleshooting

### No Audio on iOS
- Check audio session configuration
- Ensure device volume is up
- Test on real device

### Animation Stuttering
- Check if other heavy operations are running
- Consider reducing widget size
- Ensure proper disposal of old instances

### Asset Loading Issues
- Verify assets are declared in pubspec.yaml
- Use correct path format for AssetSource
- Run `flutter clean && flutter pub get`