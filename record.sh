#!/bin/bash

OUTPUT_DIR="$HOME/Movies"
mkdir -p "$OUTPUT_DIR"

DATE=$(date +"%Y%m%d")

# Find the PreSonus Revelator mic source ending with .analog-surround-21
MIC_SOURCE=$(pactl list sources short | grep 'PreSonus_Revelator' | grep 'analog-surround-21' | awk '{print $2}')

if [[ -z "$MIC_SOURCE" ]]; then
  echo "Error: Could not find PreSonus Revelator mic input source."
  exit 1
fi

# Find next available letter a-z for today's date
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

echo "Using microphone source: $MIC_SOURCE"
echo "Recording video to: $VIDEO_FILE"
echo "Extracting audio to: $AUDIO_FILE"
echo "Press Ctrl+C to stop recording."

# Record screen + specified mic audio
wf-recorder -a --audio-source="$MIC_SOURCE" -f "$VIDEO_FILE"

# Extract mic audio as a separate WAV after recording
ffmpeg -i "$VIDEO_FILE" -vn "$AUDIO_FILE"

echo "Recording complete."
