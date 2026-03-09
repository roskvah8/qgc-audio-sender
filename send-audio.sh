#!/bin/bash
set -euo pipefail

TARGET_NAME="AB13X USB Audio"

CARD_NUM=$(arecord -l | awk -v name="$TARGET_NAME" '
  $0 ~ name {
    for(i=1;i<=NF;i++){
      if($i=="card"){
        gsub(":", "", $(i+1))
        print $(i+1)
        exit
      }
    }
  }
')

if [[ -z "${CARD_NUM}" ]]; then
  echo "ERROR: Audio device '${TARGET_NAME}' not found"
  exit 1
fi

DEVICE="plughw:${CARD_NUM},0"

MEDIAMTX_URL="${MEDIAMTX_URL:-rtsp://localhost:8554/audio}"
BITRATE="${BITRATE:-64000}"
CHANNELS="${AUDIO_CHANNELS:-1}"

echo "Detected device: ${DEVICE}"
echo "Publishing to: ${MEDIAMTX_URL}"

exec ffmpeg -f alsa -i "$DEVICE" \
  -c:a libopus -b:a "$BITRATE" -ar 48000 -ac "$CHANNELS" \
  -f rtsp -rtsp_transport tcp "$MEDIAMTX_URL"