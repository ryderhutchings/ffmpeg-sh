#!/bin/bash

OUTPUT_DIR="$HOME/Movies"
mkdir -p "$OUTPUT_DIR"

DATE=$(date +"%Y%m%d")

# Find the next available letter a-z for today's date
for letter in {a..z}; do
  VIDEO_FILE="$OUTPUT_DIR/output_${DATE}_${letter}.mp4"
  AUDIO_FILE="$OUTPUT_DIR/audio_${DATE}_${letter}.wav"
  if [[ ! -f "$VIDEO_FILE" && ! -f "$AUDIO_FILE" ]]; then
    break
  fi
done

# Exit if all letters are taken
if [[ -f "$VIDEO_FILE" || -f "$AUDIO_FILE" ]]; then
  echo "All letter slots (a–z) are used for today. Clean up files or try again tomorrow."
  exit 1
fi

echo "Recording to: $VIDEO_FILE"
echo "Audio will be saved to: $AUDIO_FILE"
echo "Press Ctrl+C to stop recording."

# Record screen and mic audio
wf-recorder -a -f "$VIDEO_FILE"

# Extract mic audio as separate WAV
ffmpeg -i "$VIDEO_FILE" -vn "$AUDIO_FILE"

echo "Recording complete."
