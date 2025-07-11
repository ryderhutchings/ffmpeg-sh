# ffmpeg-sh

```bash

ffmpeg -video_size 1920x1080 -framerate 60 -f x11grab -i :0.0 \
-f alsa -i default \
-c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p \
-c:a aac -b:a 128k -map 0:v -map 1:a \
output_1080p60.mp4 -map 1:a output_audio.wav
```

```bash
sudo apt update
sudo apt install ffmpeg
sudo apt install alsa-utils
sudo apt install libnotify-bin
```
