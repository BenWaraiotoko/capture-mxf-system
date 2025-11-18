#!/bin/bash

# DNxHD Capture to MXF OP1a Format
# MXF file becomes readable after ~30 seconds

set -e

# Trap Ctrl+C for clean shutdown
trap 'echo ""; echo "🛑 Arrêt de la capture..."; echo "💾 Finalisation du fichier MXF..."; exit 0' SIGINT SIGTERM

# Configuration - Edit these values for your setup
OUTPUT_DIR="$HOME/Desktop/Captures"  # Change to your desired output directory
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="$OUTPUT_DIR/capture_${TIMESTAMP}.mxf"
DEVICE_NAME="UltraStudio 4K Mini"  # Change if using different device
START_TC=$(date +'%H:%M:%S:00')

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check available disk space (DNxHD 120Mb/s = ~54 GB/hour = ~900 MB/min)
echo "🔍 Vérification de l'espace disque disponible..."
AVAILABLE_GB=$(df -g "${OUTPUT_DIR}" | awk 'NR==2 {print $4}')
REQUIRED_GB=60  # Minimum 60 GB recommended for 1 hour capture

if [ "${AVAILABLE_GB}" -lt "${REQUIRED_GB}" ]; then
    echo ""
    echo "⚠️  ATTENTION : Espace disque insuffisant !"
    echo ""
    echo "   Disponible : ${AVAILABLE_GB} GB"
    echo "   Recommandé  : ${REQUIRED_GB} GB minimum"
    echo ""
    echo "   📊 Capacité de capture estimée :"
    echo "      ~${AVAILABLE_GB} GB = ~$((AVAILABLE_GB * 60 / 54)) minutes de vidéo"
    echo ""
    echo "   💡 DNxHD 120 Mb/s = ~54 GB/heure = ~900 MB/minute"
    echo ""
    read -p "Continuer malgré l'espace limité ? (o/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
        echo ""
        echo "❌ Capture annulée - Libérez de l'espace disque et réessayez"
        exit 1
    fi
    echo ""
fi

echo "✅ Espace disque : ${AVAILABLE_GB} GB disponible"
echo ""

echo "🎬 DNxHD Capture to MXF OP1a"
echo "============================="
echo ""
echo "📹 Device: $DEVICE_NAME"
echo "💾 Output File: $OUTPUT_FILE"
echo "📊 Format: DNxHD 120Mb/s, 1080i50, MXF OP1a"
echo ""
echo "ℹ️  MXF OP1a writes partial index every second"
echo "   File becomes readable after ~30 seconds"
echo ""
echo "✅ Broadcast standard format (BBC, CNN, etc.)"
echo ""

read -p "▶️  Press Enter to start (Ctrl+C to stop)..."

echo ""
echo "🔴 RECORDING IN PROGRESS..."
echo "Output: $OUTPUT_FILE"
echo ""
echo "⏱️  Wait at least 30 seconds before opening in Premiere Pro"
echo ""
echo "Press Ctrl+C to stop recording"
echo ""

# FFmpeg capture command with MXF OP1a output
ffmpeg \
    -f decklink \
    -format_code Hi50 \
    -audio_input embedded \
    -channels 2 \
    -video_input sdi \
    -i "${DEVICE_NAME}" \
    -c:v dnxhd \
    -b:v 120M \
    -flags +ilme+ildct \
    -top 1 \
    -c:a pcm_s16le \
    -ar 48000 \
    -ac 2 \
    -timecode "${START_TC}" \
    -f mxf \
    -store_user_comments 0 \
    "${OUTPUT_FILE}"

echo ""
echo "✅ Recording completed!"
echo "📁 File: ${OUTPUT_FILE}"

# Display file size and open folder
if [ -f "${OUTPUT_FILE}" ]; then
    FILE_SIZE=$(du -h "${OUTPUT_FILE}" | cut -f1)
    echo "📊 Size: ${FILE_SIZE}"
    open "${OUTPUT_DIR}"
fi
