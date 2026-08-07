#!/bin/bash

# Controller script to run both the video converter and transcriber in parallel

# Start the video conversion watcher in the background
/watch.sh &
CONVERT_PID=$!

echo "Started video conversion watcher (PID: $CONVERT_PID)"

# Start the transcription watcher in the background
/transcribe/watch-transcribe.sh &
TRANSCRIBE_PID=$!

echo "Started transcription watcher (PID: $TRANSCRIBE_PID)"

echo "Both watchers are running in parallel. Logs will appear below."

# Wait for both processes to finish (they loop forever)
wait $CONVERT_PID
wait $TRANSCRIBE_PID
