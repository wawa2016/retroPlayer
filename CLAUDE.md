# Claude Development Notes

This document contains important information for Claude or other AI assistants working on the Retro Player project.

## Project Overview

Retro Player is a Flutter application that simulates a classic cassette tape player with realistic animations and audio playback capabilities. The app features a custom-painted cassette tape UI with animated reels that respond to audio playback progress.

## Key Technical Details

### Audio Implementation
- Uses `audioplayers` package (v6.1.0)
- Audio files must be placed in `assets/audio/` directory
- `AssetSource` automatically prepends "assets/" to paths, so only specify "audio/filename.wav"
- Proper stream subscription management is crucial to prevent memory leaks

### Common Issues and Solutions

1. **Asset Loading Errors**
   - Problem: "Unable to load asset" errors
   - Solution: Ensure assets are in `assets/audio/` and use `AssetSource('audio/filename.wav')` (not 'assets/audio/filename.wav')

2. **iOS Audio Playback**
   - Problem: No sound on iOS simulator
   - Solution: Check simulator volume settings, test on real device for best results
   - Audio context is configured for playback category with mixWithOthers option

3. **Deprecated APIs**
   - AudioPlayer APIs have changed - use `play()` with Source objects, not URLs
   - Use `resume()` to continue playback, not `play()` without parameters
   - Set source first with `setSource()`, then call `resume()`

### File Structure
```
lib/
├── main.dart          # Entry point, sets up MaterialApp
├── home.dart          # Scaffold wrapper with background color
├── tape.dart          # Core player logic and audio management
├── tape_button.dart   # Reusable button component
└── tape_painter.dart  # Custom painter for cassette graphics

assets/
└── audio/            # Audio files location
```

### Testing Commands
```bash
flutter clean          # Clean build artifacts
flutter pub get        # Get dependencies
flutter run           # Run the app
flutter analyze       # Check for issues
```

### Important Implementation Notes

1. **State Management**: Uses StatefulWidget with setState() for simplicity
2. **Animation**: AnimationController synced with audio playback state
3. **Tape Reel Animation**: Progress (0-1) controls reel sizes:
   - Left reel: `radius = holeRadius * (1 - progress) * 4 + holeRadius`
   - Right reel: `radius = holeRadius * progress * 4 + holeRadius`
4. **Stream Subscriptions**: Must be properly cancelled in dispose() method

### Dependencies to Maintain
- `audioplayers: ^6.1.0` - Core audio functionality
- `file_picker: ^8.1.7` - Optional file selection
- Flutter SDK: ^3.7.2
- iOS minimum: 12.1

### Future Enhancements Considerations
- Add volume control slider
- Implement A/B repeat functionality
- Add equalizer visualization
- Support more audio formats
- Add recording capability
- Implement multiple cassette tape designs

## Debugging Tips

1. Use `debugPrint()` statements to track audio state changes
2. Check Flutter DevTools for performance profiling
3. Monitor memory usage for potential leaks
4. Test on both iOS and Android devices
5. Verify asset bundling with `flutter build` commands

## Code Quality Standards

1. Follow Flutter style guide
2. Use const constructors where possible
3. Properly dispose of resources
4. Handle async operations with try-catch
5. Provide meaningful error messages to users
6. Keep widget tree shallow for performance

Remember: The key to this app's success is the seamless integration of audio playback with visual feedback through the cassette tape animation.