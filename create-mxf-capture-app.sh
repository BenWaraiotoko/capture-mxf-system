#!/bin/bash

# Script to create macOS application "Capture MXF.app"
# Provides double-click capture without opening Terminal manually

set -e

APP_NAME="Capture MXF"
APP_DIR="$HOME/Applications/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "🎨 Creating application '$APP_NAME.app'..."

# Create app bundle structure
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Create main launcher script
cat > "$MACOS_DIR/capture-launcher" << 'EOFSCRIPT'
#!/bin/bash

# Configuration
OUTPUT_DIR="$HOME/Desktop/Captures"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="$OUTPUT_DIR/capture_${TIMESTAMP}.mxf"
DEVICE_NAME="UltraStudio 4K Mini"
START_TC=$(date +'%H:%M:%S:00')

mkdir -p "$OUTPUT_DIR"

# Display startup notification
osascript -e 'display notification "Initializing MXF capture..." with title "Capture MXF"'

# Open Terminal and launch capture
osascript <<EOF
tell application "Terminal"
    activate
    set newTab to do script "
echo '🎬 MXF Capture - UltraStudio 4K Mini'
echo '======================================'
echo ''
echo '📹 Device: $DEVICE_NAME'
echo '💾 Output: $OUTPUT_FILE'
echo '📊 Format: DNxHD 120Mb/s, 1080i50, MXF OP1a'
echo ''
echo '🔴 Starting in 3 seconds...'
sleep 3

ffmpeg \\
    -f decklink \\
    -format_code Hi50 \\
    -audio_input embedded \\
    -channels 2 \\
    -video_input sdi \\
    -i '$DEVICE_NAME' \\
    -c:v dnxhd \\
    -b:v 120M \\
    -flags +ilme+ildct \\
    -top 1 \\
    -c:a pcm_s16le \\
    -ar 48000 \\
    -ac 2 \\
    -timecode '$START_TC' \\
    -f mxf \\
    -store_user_comments 0 \\
    '$OUTPUT_FILE'

echo ''
echo '✅ Recording completed!'
echo '📁 File: $OUTPUT_FILE'
open '$OUTPUT_DIR'
"
end tell
EOF

# Display completion notification
osascript -e 'display notification "MXF capture started. Use Ctrl+C in Terminal to stop." with title "Capture MXF"'
EOFSCRIPT

# Make launcher executable
chmod +x "$MACOS_DIR/capture-launcher"

# Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" << 'EOFPLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>capture-launcher</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.custom.capturemxf</string>
    <key>CFBundleName</key>
    <string>Capture MXF</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOFPLIST

# Create placeholder icon file
cat > "$RESOURCES_DIR/AppIcon.icns" << 'EOFICON'
# Empty icon file - you can replace with a custom icon
EOFICON

echo ""
echo "✅ Application created successfully!"
echo "📁 Location: $APP_DIR"
echo ""
echo "🚀 To use the application:"
echo "   1. Open Finder"
echo "   2. Navigate to: $HOME/Applications/"
echo "   3. Double-click 'Capture MXF.app'"
echo ""
echo "🎯 The application will automatically launch capture in Terminal"

# Open Applications folder
open "$HOME/Applications"
