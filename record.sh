#!/bin/bash

OUTPUT_DIR="$HOME/Movies"
mkdir -p "$OUTPUT_DIR"

DATE=$(date +"%Y%m%d")

# Find the next available letter a-z for today
for letter in {a..z}; do
  VIDEO_FILE="$OUTPUT_DIR/output_${DATE}_${letter}.mp4"
  AUDIO_FILE="$OUTPUT_DIR/audio_${DATE}_${letter}.wav"
  if [[ ! -f "$VIDEO_FILE" && ! -f "$AUDIO_FILE" ]]; then
    break
  fi
done

if [[ -f "$VIDEO_FILE" || -f "$AUDIO_FILE" ]]; then
  echo "All letters a-z are taken for today. Please delete some files or wait for tomorrow."
  exit 1
fi

echo "Recording to:"
echo "Video: $VIDEO_FILE"
echo "Audio: $AUDIO_FILE"

ffmpeg -video_size 1920x1080 -framerate 60 -f x11grab -i :0.0 \
-f alsa -i default \
-c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p \
-c:a aac -b:a 128k \
-map 0:v -map 1:a \
"$VIDEO_FILE" \
-map 1:a "$AUDIO_FILE"
