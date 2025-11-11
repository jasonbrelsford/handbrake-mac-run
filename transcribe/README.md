# Video Transcription Service

Companion service to handbrake-mac-run that automatically generates text transcripts for video files using OpenAI Whisper.

## Features

- Monitors same input/output directories as handbrake service
- Generates `.txt` transcripts with same filename as video
- Supports multiple video formats: `.mov`, `.mp4`, `.avi`, `.mkv`
- Uses OpenAI Whisper for accurate speech-to-text conversion
- Continuous monitoring with 60-second intervals

## Usage

```bash
# Build and run the transcription service
docker-compose up --build

# Run alongside handbrake service
cd .. && docker-compose up handbrake &
cd transcribe && docker-compose up transcriber
```

## Output

For each video file `example.mov`, creates `example.txt` with the transcribed audio content.