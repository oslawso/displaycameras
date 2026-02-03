# displaycameras-NEW

A modern Raspberry Pi camera display service using **mpv** for hardware-accelerated video playback. This is a drop-in replacement for the original [displaycameras](https://github.com/Anonymousdog/displaycameras) project, designed to work with Raspberry Pi OS Bullseye/Bookworm.

## Why This Exists

The original displaycameras relied on `omxplayer`, which has been deprecated in Raspberry Pi OS Bullseye and later. This project provides the same functionality using `mpv`, which:

- Uses V4L2 hardware acceleration (open-source)
- Is actively maintained
- Works on modern Raspberry Pi OS versions
- Supports Raspberry Pi 3 and 4

## Features

- **Multi-camera grid display** - Display multiple RTSP camera feeds in a configurable grid
- **Hardware acceleration** - H.264 hardware decoding via V4L2
- **Feed rotation** - Automatically cycle through more cameras than visible windows
- **Auto-repair** - Continuously monitors and restarts failed feeds
- **Resolution auto-detection** - Load different layouts based on display resolution
- **100% configuration compatible** - Uses the same layout.conf format as the original

## Requirements

- Raspberry Pi 3 or 4
- Raspberry Pi OS Bullseye or Bookworm (Lite or Desktop)
- Network-connected RTSP cameras (Ubiquiti or other)

## Installation

```bash
# Clone or copy the files to your Pi
cd displaycameras-NEW

# Run the installer
sudo ./install-NEW.sh
```

## Configuration

### 1. Edit the layout configuration

```bash
sudo nano /etc/displaycameras-NEW/layout.conf.default
```

Configure your cameras:

```bash
# Camera names (identifiers)
camera_names=(NE SE SW West)

# RTSP feed URLs
camera_feeds=(
"rtsp://192.168.1.100:7447/stream1" \
"rtsp://192.168.1.101:7447/stream1" \
"rtsp://192.168.1.102:7447/stream1" \
"rtsp://192.168.1.103:7447/stream1" \
)

# Window positions for 2x2 grid on 1920x1080
window_positions=(
"0 0 959 539" \
"960 0 1919 539" \
"0 540 959 1079" \
"960 540 1919 1079" \
)
```

### 2. Edit global settings (optional)

```bash
sudo nano /etc/displaycameras-NEW/displaycameras-NEW.conf
```

Key options:
- `mpv_timeout` - Network timeout (seconds)
- `hwdec` - Hardware acceleration mode (auto, v4l2m2m, none)
- `rotate` - Enable feed rotation
- `rotatedelay` - Seconds between rotations

## Usage

### Service Commands

```bash
# Start displaying cameras
sudo systemctl start displaycameras-NEW

# Stop displaying cameras
sudo systemctl stop displaycameras-NEW

# Check service status
sudo systemctl status displaycameras-NEW

# Enable auto-start on boot
sudo systemctl enable displaycameras-NEW
```

### Manual Commands

```bash
# Start/stop/restart
sudo displaycameras-NEW start
sudo displaycameras-NEW stop
sudo displaycameras-NEW restart

# Check feed status
sudo displaycameras-NEW status

# Show playback positions
sudo displaycameras-NEW positions

# Manual rotation
sudo displaycameras-NEW rotate
sudo displaycameras-NEW rotaterev

# Repair failed feeds
sudo displaycameras-NEW repair
```

## Layout Examples

### 2x2 Grid (1920x1080)

```bash
windows=(upper_left upper_right lower_left lower_right)
window_positions=(
"0 0 959 539" \
"960 0 1919 539" \
"0 540 959 1079" \
"960 540 1919 1079" \
)
```

### 3x3 Grid (1920x1080)

```bash
windows=(w1 w2 w3 w4 w5 w6 w7 w8 w9)
window_positions=(
"0 0 639 359" \
"640 0 1279 359" \
"1280 0 1919 359" \
"0 360 639 719" \
"640 360 1279 719" \
"1280 360 1919 719" \
"0 720 639 1079" \
"640 720 1279 1079" \
"1280 720 1919 1079" \
)
```

### Feed Rotation (6 cameras on 4 windows)

```bash
# 4 on-screen + 2 off-screen windows
windows=(upper_left upper_right lower_left lower_right off1 off2)
window_positions=(
"0 0 959 539" \
"960 0 1919 539" \
"0 540 959 1079" \
"960 540 1919 1079" \
"1920 0 2879 539" \
"1920 540 2879 1079" \
)

camera_names=(cam1 cam2 cam3 cam4 cam5 cam6)
camera_feeds=(...)

rotate=true
rotatedelay=10
```

## Differences from Original

| Feature | Original | NEW |
|---------|----------|-----|
| Video player | omxplayer | mpv |
| Control | D-Bus | JSON IPC sockets |
| HW acceleration | MMAL (closed) | V4L2 (open) |
| OS Support | Buster only | Bullseye/Bookworm |
| Config directory | /etc/displaycameras | /etc/displaycameras-NEW |

## Troubleshooting

### No video displayed
1. Check camera feed URLs are correct
2. Test manually: `mpv rtsp://your-camera-url`
3. Check logs: `journalctl -u displaycameras-NEW`

### High CPU usage
- Ensure hardware acceleration is working: check for `hwdec=auto` in config
- Reduce camera resolution if needed

### Feeds keep failing
- Increase `mpv_timeout` value
- Increase `startsleep` and `retry` values
- Check network connectivity to cameras

### Window positioning issues on Wayland
- Wayland may not support precise window positioning
- Consider using X11: `sudo raspi-config` > Advanced > Wayland > X11

## License

Same license as the original displaycameras project.

## Credits

- Original displaycameras: https://github.com/Anonymousdog/displaycameras
- mpv media player: https://mpv.io
