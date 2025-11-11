#!/bin/bash

INPUT_DIR="${INPUT_DIR:-/data}"
OUTPUT_DIR="${OUTPUT_DIR:-/data}"

echo "--------------------------------------------"
echo " 📝 Video Transcription Watcher"
echo " Watching: $INPUT_DIR"
echo " Output to: $OUTPUT_DIR"
echo "--------------------------------------------"
echo ""

log_summary() {
    echo "📋 Scanning for video files..."
    local total=0
    local transcribed=0
    local untranscribed=0

    for file in "$INPUT_DIR"/*.{mov,mp4,avi,mkv}; do
        [ -e "$file" ] || continue
        total=$((total + 1))

        filename=$(basename "$file")
        transcript="$OUTPUT_DIR/${filename%.*}.txt"

        if [ -f "$transcript" ]; then
            echo "✅ Already transcribed: $filename"
            transcribed=$((transcribed + 1))
        else
            echo "⏳ Needs transcription: $filename"
            untranscribed=$((untranscribed + 1))
        fi
    done

    echo ""
    echo "📊 Summary: $total file(s) found | $transcribed transcribed | $untranscribed pending"
    echo "--------------------------------------------"
    echo ""
}

process_file() {
    local input="$1"
    local filename
    filename=$(basename "$input")
    local transcript="$OUTPUT_DIR/${filename%.*}.txt"

    echo "📝 Starting transcription: $filename"
    echo "     Output: ${transcript##*/}"
    echo ""

    # Extract audio to temporary file
    local temp_audio="/tmp/${filename%.*}.wav"
    
    echo "   🎵 Extracting audio..."
    if ffmpeg -i "$input" -vn -acodec pcm_s16le -ar 16000 -ac 1 "$temp_audio" -y 2>/dev/null; then
        echo "   🤖 Generating transcript with Whisper..."
        
        # Use whisper to transcribe
        if whisper "$temp_audio" --output_dir "/tmp" --output_format txt --model base --verbose False 2>/dev/null; then
            # Move the generated transcript to the correct location
            local whisper_output="/tmp/$(basename "$temp_audio" .wav).txt"
            if [ -f "$whisper_output" ]; then
                mv "$whisper_output" "$transcript"
                echo "✅ Finished transcription: $filename"
            else
                echo "❌ Whisper output not found for: $filename"
            fi
        else
            echo "❌ Whisper transcription failed for: $filename"
        fi
        
        # Clean up temporary audio file
        rm -f "$temp_audio"
    else
        echo "❌ Audio extraction failed for: $filename"
        rm -f "$temp_audio"
    fi
    
    echo ""
}

# Initial log and transcription
log_summary
find "$INPUT_DIR" -name '*.mov' -o -name '*.mp4' -o -name '*.avi' -o -name '*.mkv' | while read -r file; do
    [ -e "$file" ] || continue
    transcript="${OUTPUT_DIR}/$(basename "${file%.*}.txt")"
    if [ ! -f "$transcript" ]; then
        process_file "$file"
    fi
done

# Continuous polling loop every 60 seconds
while true; do
    log_summary

    for file in "$INPUT_DIR"/*.{mov,mp4,avi,mkv}; do
        [ -e "$file" ] || continue

        filename=$(basename "$file")
        transcript="$OUTPUT_DIR/${filename%.*}.txt"

        if [ ! -f "$transcript" ]; then
            process_file "$file"
        fi
    done

    sleep 60
done