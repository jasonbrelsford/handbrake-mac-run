#!/bin/bash

INPUT_DIR="${INPUT_DIR:-/data}"
OUTPUT_DIR="${OUTPUT_DIR:-/data}"

echo "--------------------------------------------"
echo " 🎬 HandBrake Watcher - 720p Converter"
echo " Watching: $INPUT_DIR"
echo " Output to: $OUTPUT_DIR"
echo "--------------------------------------------"
echo ""

log_summary() {
    echo "📋 Scanning for .mov files..."
    local total=0
    local converted=0
    local unconverted=0

    for file in "$INPUT_DIR"/*.mov; do
        [ -e "$file" ] || continue
        total=$((total + 1))

        filename=$(basename "$file")
        output="${OUTPUT_DIR}/${filename%.*}_720p.mp4"

        if [ -f "$output" ]; then
            echo "✅ Already converted: $filename"
            converted=$((converted + 1))
        else
            echo "⏳ Needs conversion:  $filename"
            unconverted=$((unconverted + 1))
        fi
    done

    echo ""
    echo "📊 Summary: $total file(s) found | $converted converted | $unconverted pending"
    echo "--------------------------------------------"
    echo ""
}

process_file() {
    local input="$1"
    local filename
    filename=$(basename "$input")
    local output="$OUTPUT_DIR/${filename%.*}_720p.mp4"

    echo "🔁 Starting conversion: $filename"
    echo "     Output: ${output##*/}"
    echo ""

    HandBrakeCLI -i "$input" -o "$output" --preset="Fast 1080p30" 2>&1 | while IFS= read -r line; do
        if [[ "$line" == Encoding:* || "$line" == *% ]]; then
            echo "$line"
        fi
    done

    echo "✅ Finished: $filename"
    echo ""
}

# Initial log and conversion
log_summary
find "$INPUT_DIR" -name '*.mov' | while read -r file; do
    [ -e "$file" ] || continue
    output="${OUTPUT_DIR}/$(basename "${file%.*}_720p.mp4")"
    if [ ! -f "$output" ]; then
        process_file "$file"
    fi
done

# Continuous polling loop every 60 seconds
while true; do
    log_summary

    for file in "$INPUT_DIR"/*.mov; do
        [ -e "$file" ] || continue

        filename=$(basename "$file")
        output="${OUTPUT_DIR}/${filename%.*}_720p.mp4"

        if [ ! -f "$output" ]; then
            process_file "$file"
        fi
    done

    sleep 60
done
