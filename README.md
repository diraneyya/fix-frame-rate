# fix-frame-rate
A Makefile to fix the speed or the frame-rate of an mp4 video (uses 'ffmpeg').

## Usage

Assuming that you have a video file with the name 'video.mp4' that is, for whatever reason, damaged or have an odd framerate (let's say, `108928000 frames/9021 seconds`).

You can use this script to fix the speed of the video file by entering the target (i.e. desired) frame-rate as follows:

```bash
make FPS=value video.fixed.mp4
```
