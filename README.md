# handbrake-mac-run
Launch a container purpose built to auto process .mov files into .mp4 files with handbrake.

## Services

### Video Conversion (Main Service)
- Converts .mov files to .mp4 using HandBrake
- Monitors input directory for new files
- Outputs converted videos with `_720p` suffix

### Transcription Service (Optional)
- Located in `transcribe/` directory
- Generates text transcripts for video files using OpenAI Whisper
- Creates `.txt` files with same name as video files
- Can run simultaneously with main service

## Usage

```bash
# Run video conversion only
docker-compose up handbrake

# Run transcription service separately
cd transcribe && docker-compose up

# Run both services
docker-compose up handbrake &
cd transcribe && docker-compose up
```
