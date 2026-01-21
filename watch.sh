#!/bin/bash

INPUT_DIR="${INPUT_DIR:-/data}"
OUTPUT_DIR="${OUTPUT_DIR:-/data}"


# Set resolution (default 720p)
RESOLUTION="${RESOLUTION:-720}"
if [ "$RESOLUTION" = "1080" ]; then
    PRESET="Fast 1080p30"
    RES_SUFFIX="1080p"
else
    PRESET="Fast 720p30"
    RES_SUFFIX="720p"
fi

echo "--------------------------------------------"
echo " 🎬 HandBrake Watcher - $RES_SUFFIX Converter"
echo " Watching: $INPUT_DIR"
echo " Output to: $OUTPUT_DIR"
echo " Resolution: $RES_SUFFIX"
echo "--------------------------------------------"
echo ""

log_summary() {
    echo "📋 Scanning for .mov files..."
    local total=0
    local converted=0
    local unconverted=0
    local transcripts=0

    for file in "$INPUT_DIR"/*.mov; do
        [ -e "$file" ] || continue
        total=$((total + 1))

        filename=$(basename "$file")
        output="${OUTPUT_DIR}/${filename%.*}_${RES_SUFFIX}.mp4"
        transcript="${OUTPUT_DIR}/${filename%.*}.txt"
        
        local status=""
        if [ -f "$output" ]; then
            status="✅ Converted"
            converted=$((converted + 1))
        else
            status="⏳ Pending"
            unconverted=$((unconverted + 1))
        fi
        
        if [ -f "$transcript" ]; then
            status="$status + 📝 Transcript"
            transcripts=$((transcripts + 1))
        fi
        
        echo "$status: $filename"
    done

    echo ""
    echo "📊 Summary: $total file(s) | $converted converted | $transcripts transcripts | $unconverted pending"
    echo "--------------------------------------------"
    echo ""
}

create_transcript() {
    local input="$1"
    local filename
    filename=$(basename "$input")
    local transcript="$OUTPUT_DIR/${filename%.*}.txt"

    if [ -f "$transcript" ]; then
        echo "📝 Transcript exists: ${filename%.*}.txt"
        return
    fi

    echo "📝 Creating transcript: ${filename%.*}.txt"
    echo "Transcript for: $filename" > "$transcript"
    echo "Generated on: $(date)" >> "$transcript"
    echo "" >> "$transcript"
    echo "[Audio transcript would be generated here using speech-to-text service]" >> "$transcript"
    echo "✅ Transcript created: ${filename%.*}.txt"
}

process_file() {
    local input="$1"
    local filename
    filename=$(basename "$input")
    local output="$OUTPUT_DIR/${filename%.*}_${RES_SUFFIX}.mp4"

    echo "🔁 Starting conversion: $filename"
    echo "     Output: ${output##*/}"
    echo ""

    HandBrakeCLI -i "$input" -o "$output" --preset="$PRESET" 2>&1 | while IFS= read -r line; do
        if [[ "$line" == Encoding:* || "$line" == *% ]]; then
            echo "$line"
        fi
    done

    echo "✅ Finished: $filename"
    
    # Create transcript after successful conversion
    create_transcript "$input"
    echo ""
}

# Initial log and conversion
log_summary
find "$INPUT_DIR" -name '*.mov' | while read -r file; do
    [ -e "$file" ] || continue
    output="${OUTPUT_DIR}/$(basename "${file%.*}_${RES_SUFFIX}.mp4")"
    transcript="${OUTPUT_DIR}/$(basename "${file%.*}.txt")"
    
    if [ ! -f "$output" ]; then
        process_file "$file"
    elif [ ! -f "$transcript" ]; then
        create_transcript "$file"
    fi
done

# Continuous polling loop every 60 seconds
while true; do
    log_summary

    for file in "$INPUT_DIR"/*.mov; do
        [ -e "$file" ] || continue

        filename=$(basename "$file")
        output="${OUTPUT_DIR}/${filename%.*}_${RES_SUFFIX}.mp4"
        transcript="${OUTPUT_DIR}/${filename%.*}.txt"

        if [ ! -f "$output" ]; then
            process_file "$file"
        elif [ ! -f "$transcript" ]; then
            create_transcript "$file"
        fi
    done

    sleep 60
done
