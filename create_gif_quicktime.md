# Creating High-Quality GIF with QuickTime

## Steps:

1. **Install gifski** (best GIF encoder):
   ```bash
   brew install gifski
   ```

2. **Record with QuickTime**:
   - Open QuickTime Player
   - File → New Screen Recording
   - Click the down arrow next to record button
   - Select "iPhone" or "iPad" if connected, or record simulator
   - Record just the cassette player area
   - Keep it under 10 seconds

3. **Convert to GIF**:
   ```bash
   # Basic conversion
   gifski -o cassette_player_demo.gif recording.mov

   # With custom settings
   gifski --fps 20 --width 600 --quality 100 -o cassette_player_demo.gif recording.mov
   ```

## Alternative Tools:

### Using Kap (Free, macOS)
1. Download from: https://getkap.co/
2. Record directly to GIF
3. Built-in editor for trimming

### Using Gifox (Paid, macOS)
1. Download from App Store
2. Record window or selection
3. Optimizes automatically

### Using GIPHY Capture (Free)
1. Download from: https://giphy.com/apps/giphycapture
2. Simple interface
3. Direct upload to GIPHY

## Tips for Best Quality:

1. **Keep it short**: 5-10 seconds max
2. **Show key features**:
   - Tape reels spinning
   - Time advancing
   - Track changing
   - Play/pause animations

3. **Optimize the recording**:
   - Use consistent timing
   - Start with player stopped
   - Show smooth animations
   - End gracefully

4. **Post-processing**:
   ```bash
   # Optimize file size without losing quality
   gifsicle -O3 --colors 128 input.gif -o optimized.gif
   ```

## Example Recording Script:

1. Start with cassette stopped (1 sec)
2. Press play - show reels start spinning (3 sec)
3. Show time advancing (2 sec)
4. Press next track - show title change (2 sec)
5. Press pause - show reels stop (1 sec)

Total: ~9 seconds for a perfect demo loop!