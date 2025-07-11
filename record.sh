#!/bin/bash

OUTPUT_DIR="$HOME/Movies"
mkdir -p "$OUTPUT_DIR"

DATE=$(date +"%Y%m%d")

# Find PreSonus Revelator mic source ending with .analog-surround-21
MIC_SOURCE=$(pactl list sources short | grep 'PreSonus_Revelator' | grep 'analog-surround-21' | awk '{print $2}')

if [[ -z "$MIC_SOURCE" ]]; then
  echo "Error: Could not find PreSonus Revelator mic input source."
  exit 1
fi

# Find next available letter a-z for today's date
for letter in {a..z}; do
  VIDEO_FILE="$OUTPUT_DIR/video_${DATE}_${letter}.mp4"
  AUDIO_FILE="$OUTPUT_DIR/audio_${DATE}_${letter}.wav"
  COMBINED_FILE="$OUTPUT_DIR/combined_${DATE}_${letter}.mp4"
  if [[ ! -f "$VIDEO_FILE" && ! -f "$AUDIO_FILE" && ! -f "$COMBINED_FILE" ]]; then
    break
  fi
done

if [[ -f "$VIDEO_FILE" || -f "$AUDIO_FILE" || -f "$COMBINED_FILE" ]]; then
  echo "All letter slots (a-z) are used for today. Please clean up files or try again tomorrow."
  exit 1
fi

echo "Recording video to: $VIDEO_FILE"
echo "Recording audio from mic source: $MIC_SOURCE"
echo "Saving audio to: $AUDIO_FILE"
echo "Combined file will be: $COMBINED_FILE"
echo "Press Ctrl+C to stop recording."

# Start recording mic audio in background
parecord --device="$MIC_SOURCE" "$AUDIO_FILE" &
MIC_PID=$!

# Start recording screen video (no audio)
wf-recorder -f "$VIDEO_FILE"

# When wf-recorder ends (Ctrl+C), kill parecord
kill $MIC_PID
wait $MIC_PID 2>/dev/null

echo "Recording stopped, merging audio and video now..."

# Merge audio + video into final file
ffmpeg -y -i "$VIDEO_FILE" -i "$AUDIO_FILE" -c:v copy -c:a aac -strict experimental "$COMBINED_FILE"

echo "Done!"
echo "Raw video: $VIDEO_FILE"
echo "Raw audio: $AUDIO_FILE"
echo "Combined file: $COMBINED_FILE"
