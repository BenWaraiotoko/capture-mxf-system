#!/bin/bash

# MXF Capture System Test Script
# Validates FFmpeg, DeckLink support, and system configuration

echo "🧪 MXF Capture System Test"
echo "===================================="
echo ""

# Test 1: FFmpeg Installation
echo "1️⃣  Test: FFmpeg Installation"
if command -v ffmpeg &> /dev/null; then
    FFMPEG_VERSION=$(ffmpeg -version | head -n1)
    echo "   ✅ FFmpeg found: $FFMPEG_VERSION"
else
    echo "   ❌ FFmpeg not found"
    echo "   → Run: ./install_ffmpeg_7_silicon.sh"
    exit 1
fi

echo ""

# Test 2: DeckLink Support
echo "2️⃣  Test: DeckLink Support"
if ffmpeg -hide_banner -sources decklink 2>&1 | grep -q "Auto-detected sources"; then
    echo "   ✅ DeckLink support enabled"
else
    echo "   ❌ DeckLink support not available"
    echo "   → Run: ./install_ffmpeg_7_silicon.sh"
    exit 1
fi

echo ""

# Test 3: Device Detection
echo "3️⃣  Test: DeckLink Device Detection"
DEVICES=$(ffmpeg -hide_banner -f decklink -list_devices 1 -i dummy 2>&1 | grep -E "^\[decklink" | grep -v "list_devices")

if [ -z "$DEVICES" ]; then
    echo "   ⚠️  No DeckLink devices detected"
    echo ""
    echo "   Check:"
    echo "   - UltraStudio 4K Mini is connected (Thunderbolt)"
    echo "   - Desktop Video is installed (https://www.blackmagicdesign.com/support)"
    echo "   - Device is powered on and recognized in System Preferences"
else
    echo "   ✅ Devices detected:"
    echo "$DEVICES" | while read -r line; do
        echo "      $line"
    done
fi

echo ""

# Test 4: DNxHD Codec Support
echo "4️⃣  Test: DNxHD Codec Support"
if ffmpeg -hide_banner -codecs 2>&1 | grep -q "dnxhd"; then
    echo "   ✅ DNxHD codec available"
else
    echo "   ❌ DNxHD codec not available"
    exit 1
fi

echo ""

# Test 5: Output Directory
echo "5️⃣  Test: Capture Output Directory"
OUTPUT_DIR="$HOME/Desktop/Captures"
if [ -d "$OUTPUT_DIR" ]; then
    echo "   ✅ Directory exists: $OUTPUT_DIR"
else
    mkdir -p "$OUTPUT_DIR"
    echo "   ✅ Directory created: $OUTPUT_DIR"
fi

echo ""

# Test 6: Format Support
echo "6️⃣  Test: 1080i50 Format Support"
if ffmpeg -hide_banner -f decklink -list_formats 1 -i "UltraStudio 4K Mini" 2>&1 | grep -q "Hi50"; then
    echo "   ✅ Hi50 format (1080i50) supported"
else
    echo "   ⚠️  Hi50 format not listed (may still work)"
fi

echo ""

# Test 7: MXF Container Support
echo "7️⃣  Test: MXF Container Support"
if ffmpeg -hide_banner -formats 2>&1 | grep -q "mxf"; then
    echo "   ✅ MXF container format available"
else
    echo "   ❌ MXF container format not available"
    exit 1
fi

echo ""
echo "======================================"
echo "📊 TEST SUMMARY"
echo "======================================"
echo ""
echo "✅ All essential tests passed!"
echo ""
echo "🚀 Next Steps:"
echo "   1. Connect your SDI source to UltraStudio"
echo "   2. Run: ./capture_mxf_op1a.sh"
echo "   3. Wait 30 seconds, then open MXF file in Premiere Pro"
echo ""
echo "💡 Tip: Create macOS app with ./create-mxf-capture-app.sh"
echo "        to launch capture without Terminal"
echo ""
