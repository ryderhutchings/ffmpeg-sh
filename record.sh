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
  VIDEO_RAW="$OUTPUT_DIR/source_${DATE}_${letter}.mp4"
  AUDIO_RAW="$OUTPUT_DIR/source_${DATE}_${letter}.wav"
  OUTPUT_COMBINED="$OUTPUT_DIR/combined_${DATE}_${letter}.mp4"
  if [[ ! -f "$VIDEO_RAW" && ! -f "$AUDIO_RAW" && ! -f "$OUTPUT_COMBINED" ]]; then
    break
  fi
done

if [[ -f "$VIDEO_RAW" || -f "$AUDIO_RAW" || -f "$OUTPUT_COMBINED" ]]; then
  echo "All letter slots (a–z) are used for today. Please clean up files or try again tomorrow."
  exit 1
fi

echo "Using mic source: $MIC_SOURCE"
echo "Recording video to: $VIDEO_RAW"
echo "Recording audio to: $AUDIO_RAW"
echo "Final merged output: $OUTPUT_COMBINED"
echo "Press Ctrl+C to stop recording."

# Start recording mic audio in background
parecord --device="$MIC_SOURCE" "$AUDIO_RAW" &
MIC_PID=$!

# Start recording screen video (no audio)
wf-recorder -f "$VIDEO_RAW"

# When wf-recorder ends (Ctrl+C), kill parecord
kill $MIC_PID

# Wait for parecord to stop fully
wait $MIC_PID 2>/dev/null

echo "Recording stopped, merging audio and video now..."

# Merge audio + video into final file
ffmpeg -y -i "$VIDEO_RAW" -i "$AUDIO_RAW" -c:v copy -c:a aac -strict experimental "$OUTPUT_COMBINED"

echo "Done!"
echo "Raw video: $VIDEO_RAW"
echo "Raw audio: $AUDIO_RAW"
echo "Combined file: $OUTPUT_COMBINED"
