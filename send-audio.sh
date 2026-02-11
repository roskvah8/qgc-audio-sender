#!/bin/bash
# QGC Audio Sender - Captures USB microphone audio and publishes to mediamtx via RTSP.
# mediamtx handles multi-client RTSP serving natively.
#
# Environment variables:
#   AUDIO_DEVICE  - ALSA device (default: hw:2,0)
#   MEDIAMTX_URL  - RTSP publish URL (default: rtsp://localhost:8554/audio)
#   BITRATE       - Audio bitrate in bps (default: 64000)

set -euo pipefail

DEVICE="${AUDIO_DEVICE:-plughw:2,0}"
MEDIAMTX_URL="${MEDIAMTX_URL:-rtsp://localhost:8554/audio}"
BITRATE="${BITRATE:-64000}"

echo "Starting audio capture from device: ${DEVICE}"
echo "Publishing to: ${MEDIAMTX_URL}"
echo "Bitrate: ${BITRATE}"

CHANNELS="${AUDIO_CHANNELS:-1}"

exec ffmpeg -f alsa -i "$DEVICE" \
    -c:a libopus -b:a "$BITRATE" -ar 48000 -ac "$CHANNELS" \
    -f rtsp -rtsp_transport tcp "$MEDIAMTX_URL"
