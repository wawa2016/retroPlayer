#!/bin/bash

# Create GIF from iOS Simulator recording
# 1. First record a video in the simulator
# 2. Then run this script to convert to GIF

echo "=== Retro Player GIF Creator ==="
echo ""
echo "Steps to create a high-quality GIF:"
echo "1. Open iOS Simulator"
echo "2. Run the app: flutter run"
echo "3. Press Cmd+R in simulator to start recording"
echo "4. Play the cassette player for 5-10 seconds"
echo "5. Press Cmd+R again to stop recording"
echo "6. Save the video to Desktop"
echo "7. Run this script with: ./create_gif.sh path/to/video.mov"
echo ""

if [ $# -eq 0 ]; then
    echo "Usage: ./create_gif.sh <input_video.mov>"
    exit 1
fi

INPUT_VIDEO="$1"
OUTPUT_GIF="${INPUT_VIDEO%.*}.gif"

# Check if input file exists
if [ ! -f "$INPUT_VIDEO" ]; then
    echo "Error: Input file not found: $INPUT_VIDEO"
    exit 1
fi

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed"
    echo "Install with: brew install ffmpeg"
    exit 1
fi

echo "Converting video to GIF..."

# Method 1: High quality, smaller file size (recommended)
ffmpeg -i "$INPUT_VIDEO" \
  -vf "fps=15,scale=600:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  -loop 0 \
  "$OUTPUT_GIF"

# Method 2: Ultra high quality, larger file size
# Uncomment to use this method instead
# ffmpeg -i "$INPUT_VIDEO" \
#   -vf "fps=30,scale=600:-1:flags=lanczos,split[s0][s1];[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
#   -loop 0 \
#   "${OUTPUT_GIF%.gif}_hq.gif"

echo "✅ GIF created: $OUTPUT_GIF"
echo ""
echo "Tips for best results:"
echo "- Keep recording under 10 seconds for reasonable file size"
echo "- Crop the simulator window to just the cassette player"
echo "- Use consistent timing when demonstrating features"

# Display file size
if [ -f "$OUTPUT_GIF" ]; then
    FILE_SIZE=$(ls -lh "$OUTPUT_GIF" | awk '{print $5}')
    echo "File size: $FILE_SIZE"
fi