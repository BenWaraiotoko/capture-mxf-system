# 🎬 Capture MXF System

Professional video capture system for Blackmagic DeckLink/UltraStudio devices with FFmpeg on macOS (Apple Silicon).

Capture broadcast-quality DNxHD video directly from SDI sources to MXF OP1a format compatible with Adobe Premiere Pro and broadcast workflows.

## 📋 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Project Components](#-project-components)
- [Usage](#-usage)
- [Output Formats](#-output-formats)
- [Premiere Pro Integration](#-premiere-pro-integration)
- [Troubleshooting](#-troubleshooting)
- [Technical Specifications](#-technical-specifications)

---

## ✨ Features

- **Real-time capture** from SDI sources via Blackmagic DeckLink/UltraStudio devices
- **DNxHD 120 Mb/s** broadcast-quality codec
- **MXF OP1a format** - broadcast-standard with partial index writing
- **Live editing** capability - file readable after 30 seconds of recording
- **Embedded timecode** - automatic timecode generation
- **Automated macOS app** - capture without Terminal
- **Comprehensive testing** - validate setup before capture

---

## 🔧 Prerequisites

### Hardware Requirements

- **Mac with Apple Silicon** (M1/M2/M3/M4)
- **Blackmagic DeckLink/UltraStudio device** (e.g., UltraStudio 4K Mini)
- **Thunderbolt connection** to Mac
- **SDI video source** outputting 1080i50 (or compatible format)
- **Fast storage** - SSD recommended (DNxHD 120 = ~54 GB/hour)

### Software Requirements

1. **macOS 11+** (Big Sur or later)
2. **Blackmagic Desktop Video** - Download from:
   - <https://www.blackmagicdesign.com/support>
   - Search for "Desktop Video" for macOS
   - **Version**: 12.x or later recommended
   - **Important**: Restart Mac after installation

3. **Xcode Command Line Tools**:
   ```bash
   xcode-select --install
   ```

4. **Homebrew** (optional but recommended for dependencies):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

---

## 📦 Installation

### Step 1: Download Blackmagic Desktop Video SDK

The SDK is required to compile FFmpeg with DeckLink support.

1. Visit: <https://www.blackmagicdesign.com/support/family/capture-and-playback>
2. Download **Desktop Video SDK** (v12.5)
3. Extract the downloaded archive
4. Create build directory and copy SDK:

```bash
mkdir -p ~/ffmpeg-decklink-build
cp -r "Blackmagic DeckLink SDK 12.5/Mac/include" ~/ffmpeg-decklink-build/Blackmagic_DeckLink_SDK
```

**Note**: Adjust path according to your SDK version (e.g., "12.5", "12.9", etc.)

### Step 2: Install Homebrew Dependencies (Optional)

If you don't have codec libraries installed, install via Homebrew:

```bash
brew install libass fdk-aac freetype lame opus libvorbis libvpx x264 x265
```

### Step 3: Run FFmpeg Installation Script

This will compile FFmpeg 7.1 with DeckLink support:

```bash
cd ~/ffmpeg-decklink-build
curl -O https://raw.githubusercontent.com/BenWaraiotoko/capture-mxf-system/main/install_ffmpeg_7_silicon.sh
chmod +x install_ffmpeg_7_silicon.sh
./install_ffmpeg_7_silicon.sh
```

**Expected duration**: 15-30 minutes (compiling FFmpeg)

The script will:
- Download FFmpeg 7.1 source code
- Configure with DeckLink and codec support
- Compile for Apple Silicon (arm64)
- Install to `/usr/local/bin/ffmpeg`

### Step 4: Clone Capture System Scripts

```bash
cd ~
git clone https://github.com/BenWaraiotoko/capture-mxf-system.git
cd capture-mxf-system
chmod +x *.sh
```

### Step 5: Verify Installation

Run the test script to validate your setup:

```bash
./test-setup.sh
```

Expected output:

```text
✅ FFmpeg found
✅ DeckLink support enabled
✅ UltraStudio 4K Mini detected
✅ DNxHD codec available
✅ Capture folder created
```

---

## 🗂️ Project Components

### 1. `install_ffmpeg_7_silicon.sh`

**Location**: `~/ffmpeg-decklink-build/install_ffmpeg_7_silicon.sh`

**Purpose**: Compiles FFmpeg 7.1 with Blackmagic DeckLink support for Apple Silicon.

**Key Features**:
- Configures FFmpeg with `--enable-decklink` flag
- Links Blackmagic DeckLink SDK headers
- Enables popular codecs (x264, x265, DNxHD, etc.)
- Optimized for arm64 architecture
- Installs to `/usr/local/bin/ffmpeg`

**Configuration highlights**:

```bash
./configure \
    --enable-gpl \
    --enable-nonfree \
    --enable-decklink \
    --extra-cflags="-I$WORK_DIR/Blackmagic_DeckLink_SDK" \
    --arch=arm64
```

**Output**: FFmpeg binary with DeckLink input device support

---

### 2. `capture_mxf_op1a.sh`

**Purpose**: Captures DNxHD video to MXF OP1a format (broadcast standard).

**Key Features**:
- **MXF OP1a format** - Industry-standard broadcast container
- **Partial index writing** - File becomes readable after ~30 seconds
- **Embedded timecode** - Records start time automatically
- **1080i50 interlaced** capture with proper field order
- **Configurable output directory**

**Configuration**:

```bash
OUTPUT_DIR="/Volumes/..."  # Edit this path
DEVICE_NAME="UltraStudio 4K Mini"
```

**FFmpeg command structure**:

```bash
ffmpeg \
    -f decklink \
    -format_code Hi50 \              # 1080i50 format
    -audio_input embedded \
    -video_input sdi \
    -i "$DEVICE_NAME" \
    -c:v dnxhd -b:v 120M \          # DNxHD 120 Mb/s
    -flags +ilme+ildct \            # Interlaced encoding
    -top 1 \                        # Top field first
    -c:a pcm_s16le \                # PCM audio
    -timecode "$START_TC" \         # Embedded timecode
    -f mxf \                        # MXF container
    "$OUTPUT_FILE"
```

**Usage**:

```bash
./capture_mxf_op1a.sh
# Press Enter to start
# Ctrl+C to stop
```

**When to use**:

- Broadcast delivery requirements (BBC, CNN workflows)
- Long-form content (>1 hour)
- Archive purposes with timecode metadata
- Professional post-production workflows

---

### 3. `test-setup-script.sh`

**Purpose**: Comprehensive validation of the capture environment.

**Tests performed**:

1. **FFmpeg Installation Check**
   - Verifies FFmpeg is in PATH
   - Displays version information

2. **DeckLink Support Check**
   - Confirms `decklink` input device is available
   - Tests FFmpeg was compiled with `--enable-decklink`

3. **Device Detection**
   - Lists all connected DeckLink/UltraStudio devices
   - Verifies device name matches configuration

4. **DNxHD Codec Check**
   - Confirms DNxHD encoder is available
   - Tests codec library linkage

5. **Output Directory Check**
   - Creates `~/Desktop/Captures` if missing
   - Verifies write permissions

6. **Format Support Check**
   - Tests 1080i50 (Hi50) format availability
   - Lists compatible video formats

7. **MXF Container Check**
   - Verifies MXF muxer is available
   - Confirms OP1a format support

**Usage**:

```bash
./test-setup.sh
```

**Run this**:

- After installation
- Before important captures
- When troubleshooting issues
- After system updates

---

### 4. `create-mxf-capture-app.sh`

**Purpose**: Creates a double-clickable macOS application for capture without Terminal.

**Generated app**:

- **Name**: `Capture MXF.app`
- **Location**: `~/Applications/`
- **Function**: Launches Terminal with MXF capture script

**Features**:

- macOS notification alerts
- Automatic Terminal window opening
- Same capture parameters as `capture_mxf_op1a.sh`
- Saves to `~/Desktop/Captures/`

**App structure**:

```text
Capture MXF.app/
├── Contents/
│   ├── Info.plist          # macOS app metadata
│   ├── MacOS/
│   │   └── capture-launcher # Shell script wrapper
│   └── Resources/
│       └── AppIcon.icns    # App icon (placeholder)
```

**Usage**:

```bash
# Create the app (one-time)
./create-mxf-capture-app.sh

# Then double-click in Finder
open ~/Applications/Capture\ MXF.app
```

**Customization**:

Edit the script before running to change:
- Output directory (`OUTPUT_DIR`)
- Device name (`DEVICE_NAME`)
- Capture format parameters

**When to use**:

- Frequent captures without Terminal access
- Simplified workflow for non-technical users
- Quick capture initiation

---

## 🎥 Usage

### Method 1: Terminal Capture (MXF OP1a)

**Recommended for professional workflows**

1. Connect SDI source to UltraStudio
2. Verify signal in Blackmagic Desktop Video Setup
3. Run test:
   ```bash
   ./test-setup.sh
   ```
4. Start capture:
   ```bash
   ./capture_mxf_op1a.sh
   ```
5. Press Enter to begin
6. **Ctrl+C** to stop

Output: `~/Desktop/Captures/capture_YYYYMMDD_HHMMSS.mxf`

**Note**: Edit `OUTPUT_DIR` in the script to change output location.

---

### Method 2: macOS Application

**Best for simplified workflows**

1. Create app (one-time):
   ```bash
   ./create-mxf-capture-app.sh
   ```

2. Launch from Finder:
   ```
   ~/Applications/Capture MXF.app
   ```

3. Terminal opens automatically with capture running
4. **Ctrl+C** to stop

---

### Method 3: Custom Integration

Import capture functions into your own scripts:

```bash
#!/bin/bash
source ~/capture-mxf-system/capture_mxf_op1a.sh

# Your custom pre-capture logic here
# ...

# Capture will start automatically
```

---

## 📊 Output Format

### MXF OP1a Format (Material Exchange Format)

**Extension**: `.mxf`

**Advantages**:

- ✅ **Industry standard** (BBC, CNN, professional broadcast)
- ✅ Embedded timecode
- ✅ Rich metadata (reel name, camera info)
- ✅ Partial index - readable after 30 seconds
- ✅ Optimized for editing software

**Disadvantages**:

- ❌ 30-second delay before Premiere can read
- ❌ More sensitive to corrupted writes

**Best for**:

- Broadcast delivery
- Archive/library content
- Professional post-production
- Content requiring embedded metadata

---

## 🎞️ Premiere Pro Integration

### MXF Workflow

**Timeline**:

```text
00:00 → Start capture (./capture_mxf_op1a.sh)
00:30 → MXF file becomes readable
01:00 → Import MXF to Premiere Pro (File → Import)
01:30 → Drag to timeline, start editing
...   → Continue editing while capture runs
90:00 → Stop capture (Ctrl+C)
90:05 → Finalize edit and export
```

**MXF Import Notes**:

- Wait at least 30 seconds after capture starts before importing
- File updates live as capture continues
- Premiere refreshes timeline automatically
- Full timecode support with embedded start time

**Benefits**:

- Industry-standard broadcast format
- Rich metadata support
- Embedded timecode
- Edit while recording (after 30s delay)
- Reduce turnaround time by 70%+

---

### Import Settings

1. **File → Import** or drag file to Project panel
2. Premiere detects DNxHD automatically
3. No transcoding required
4. Native playback performance

**Timeline Settings** (for 1080i50):

- Editing Mode: **Custom**
- Timebase: **25 fps** (50i = 25 frames interlaced)
- Frame Size: **1920x1080**
- Field Order: **Upper Field First**
- Pixel Aspect Ratio: **Square (1.0)**

---

## ❓ Troubleshooting

### "No DeckLink devices found"

**Symptoms**:

```text
[decklink @ 0x...] No DeckLink devices found
```

**Solutions**:

1. Check Thunderbolt connection (try different port/cable)
2. Open **Blackmagic Desktop Video Setup**:
   - Verify device appears in device list
   - Check firmware version (update if needed)
3. Restart UltraStudio (unplug Thunderbolt for 10 seconds)
4. Verify Desktop Video is running:

   ```bash
   ps aux | grep "Desktop Video"
   ```

5. Reinstall Desktop Video if necessary

---

### "Unknown input format: 'decklink'"

**Symptoms**:

```text
[in#0 @ 0x...] Unknown input format: 'decklink'
```

**Solutions**:

1. FFmpeg was not compiled with DeckLink support
2. Run installation again:

   ```bash
   cd ~/ffmpeg-decklink-build
   ./install_ffmpeg_7_silicon.sh
   ```

3. Verify SDK path:

   ```bash
   ls ~/ffmpeg-decklink-build/Blackmagic_DeckLink_SDK
   ```

4. Check FFmpeg configuration:

   ```bash
   ffmpeg -hide_banner -sources decklink
   ```

---

### No Video Signal

**Symptoms**:
- Capture starts but black screen
- "No input signal" in Desktop Video Setup

**Solutions**:

1. **Check physical connections**:
   - SDI cable firmly connected
   - Correct SDI output on source device
   - Try different SDI cable

2. **Verify source format**:
   - Source must output **1080i50** (PAL) or **1080i60** (NTSC)
   - Check source device settings
   - Use Desktop Video Setup to view incoming signal format

3. **Change capture format if needed**:

   ```bash
   # For 1080i60 (NTSC):
   -format_code Hi60

   # For 1080p25:
   -format_code Hp25
   ```

4. **List available formats**:

   ```bash
   ffmpeg -f decklink -list_formats 1 -i "UltraStudio 4K Mini"
   ```

---

### No Audio

**Symptoms**:
- Video captures but no audio in file

**Solutions**:

1. **Verify audio is embedded in SDI**:
   - Check source device SDI audio embedding settings
   - Desktop Video Setup → Capture tab → Audio meters should show signal

2. **Increase audio channel count**:

   ```bash
   -channels 8   # Instead of -channels 2
   ```

3. **Test with separate audio input**:

   ```bash
   -audio_input embedded   # Try 'analog' if available
   ```

---

### MXF File Corrupted in Premiere

**Symptoms**:
- "File could not be opened" error
- Premiere crashes on import

**Solutions**:

1. **Wait longer before opening** - MXF needs 30+ seconds to write index
2. **Verify file integrity**:

   ```bash
   ffprobe ~/Desktop/Captures/capture_*.mxf
   ```

3. **Test in VLC**:

   ```bash
   open -a VLC ~/Desktop/Captures/capture_*.mxf
   ```

4. **If capture was interrupted**, file may be partially recoverable:

   ```bash
   ffmpeg -i corrupted.mxf -c copy repaired.mxf
   ```

---

### Permission Denied Errors

**Symptoms**:

```text
/Users/.../Captures: Permission denied
```

**Solutions**:

1. Create directory manually:
   ```bash
   mkdir -p ~/Desktop/Captures
   ```
2. Check permissions:

   ```bash
   ls -ld ~/Desktop/Captures
   ```

3. Grant Premiere full disk access:
   - System Preferences → Privacy & Security → Full Disk Access
   - Add Adobe Premiere Pro

---

## 📐 Technical Specifications

### Video Specifications

| Parameter | Value |
|-----------|-------|
| **Resolution** | 1920x1080 |
| **Scan Type** | Interlaced (1080i) |
| **Frame Rate** | 50i (25 fps interlaced) |
| **Field Order** | Top field first |
| **Codec** | DNxHD (Avid DNxHR HQ profile) |
| **Bitrate** | 120 Mb/s |
| **Color Space** | Rec.709 (HD) |
| **Chroma Subsampling** | 4:2:2 |
| **Bit Depth** | 8-bit |

### Audio Specifications

| Parameter | Value |
|-----------|-------|
| **Codec** | PCM (uncompressed) |
| **Sample Format** | 16-bit signed little-endian |
| **Sample Rate** | 48 kHz |
| **Channels** | 2 (stereo) - configurable to 8 |
| **Source** | SDI embedded audio |

### File Size Calculations

**DNxHD 120 Mb/s = 15 MB/s = 900 MB/min = 54 GB/hour**

| Duration | Approximate Size |
|----------|------------------|
| 1 minute | ~900 MB |
| 10 minutes | ~9 GB |
| 30 minutes | ~27 GB |
| 1 hour | ~54 GB |
| 2 hours | ~108 GB |

**Storage recommendations**:

- **SSD** (Thunderbolt 3/4): 500+ MB/s write speed - **recommended**
- **HDD** (7200 RPM): 150-200 MB/s - may drop frames
- **Network storage**: depends on bandwidth - test first

---

## 🔄 Format Code Reference

Use these codes with `-format_code` parameter:

| Code | Description | Frame Rate |
|------|-------------|------------|
| `Hi50` | 1080i 50 Hz (PAL) | 25 fps interlaced |
| `Hi60` | 1080i 60 Hz (NTSC) | 29.97 fps interlaced |
| `Hp25` | 1080p 25 fps | 25 fps progressive |
| `Hp30` | 1080p 30 fps | 30 fps progressive |
| `Hp50` | 1080p 50 fps | 50 fps progressive |
| `Hp60` | 1080p 60 fps | 60 fps progressive |

List all available formats:

```bash
ffmpeg -f decklink -list_formats 1 -i "UltraStudio 4K Mini"
```

---

## 📝 License

This project is provided as-is for professional video capture workflows.

FFmpeg is licensed under LGPL/GPL (depending on build configuration).
Blackmagic DeckLink SDK is © Blackmagic Design Pty. Ltd.

---

## 🙏 Credits

- **FFmpeg**: https://ffmpeg.org
- **Blackmagic Design**: Desktop Video and DeckLink SDK
- **DNxHD Codec**: Avid Technology, Inc.

---

## 📞 Support

For issues or questions:

1. Run `./test-setup.sh` and share output
2. Check FFmpeg logs for detailed error messages
3. Verify Blackmagic Desktop Video Setup shows device
4. Consult FFmpeg DeckLink documentation: <https://trac.ffmpeg.org/wiki/Capture/DeckLink>

---

**Last Updated**: January 2025
**FFmpeg Version**: 7.1
**Compatible macOS**: 11.0+ (Apple Silicon)
