#!/bin/bash

# Automated GIF recording from iOS Simulator

echo "🎬 Retro Player GIF Recorder"
echo "============================"

# Check dependencies
check_dependency() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 is not installed"
        echo "   Install with: brew install $1"
        exit 1
    fi
}

check_dependency "ffmpeg"
check_dependency "xcrun"

# Function to get simulator window ID
get_simulator_window_id() {
    osascript -e 'tell application "Simulator" to id of window 1' 2>/dev/null
}

# Start recording
record_simulator() {
    echo "📱 Starting iOS Simulator recording..."
    echo "   Press Ctrl+C when done recording"
    echo ""
    
    OUTPUT_FILE="cassette_recording_$(date +%Y%m%d_%H%M%S).mov"
    
    # Record using xcrun simctl
    xcrun simctl io booted recordVideo "$OUTPUT_FILE" &
    RECORD_PID=$!
    
    # Wait for user to stop
    echo "🔴 Recording... (Press Enter to stop)"
    read -r
    
    # Stop recording
    kill -INT $RECORD_PID 2>/dev/null
    
    echo "✅ Recording saved: $OUTPUT_FILE"
    
    # Convert to GIF
    convert_to_gif "$OUTPUT_FILE"
}

# Convert MOV to GIF
convert_to_gif() {
    INPUT="$1"
    OUTPUT="${INPUT%.*}_demo.gif"
    
    echo "🎨 Converting to GIF..."
    
    # Create high-quality GIF with optimized palette
    ffmpeg -i "$INPUT" \
        -vf "fps=20,scale=400:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128:stats_mode=single[p];[s1][p]paletteuse=dither=bayer:bayer_scale=5" \
        -loop 0 \
        "$OUTPUT" \
        -loglevel error
    
    if [ $? -eq 0 ]; then
        echo "✅ GIF created: $OUTPUT"
        echo "   Size: $(ls -lh "$OUTPUT" | awk '{print $5}')"
        
        # Optional: Delete original video
        echo ""
        read -p "Delete original video? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm "$INPUT"
            echo "🗑️  Original video deleted"
        fi
    else
        echo "❌ Failed to create GIF"
    fi
}

# Main menu
echo "Choose recording method:"
echo "1) Record iOS Simulator"
echo "2) Convert existing video to GIF"
echo ""
read -p "Enter choice (1-2): " choice

case $choice in
    1)
        record_simulator
        ;;
    2)
        read -p "Enter path to video file: " video_path
        if [ -f "$video_path" ]; then
            convert_to_gif "$video_path"
        else
            echo "❌ File not found: $video_path"
        fi
        ;;
    *)
        echo "❌ Invalid choice"
        ;;
esac