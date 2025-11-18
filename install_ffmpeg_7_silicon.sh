#!/bin/bash

# Installation FFmpeg 7.1 + DeckLink pour Mac Silicon
# Version compatible avec le SDK DeckLink moderne

set -e

echo "🎬 Installation FFmpeg 7.1 + DeckLink (Mac Silicon)"
echo "===================================================="

# Chemins pour Apple Silicon
HOMEBREW_PREFIX="/opt/homebrew"
export PATH="$HOMEBREW_PREFIX/bin:$PATH"
export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/lib/pkgconfig"
export LDFLAGS="-L$HOMEBREW_PREFIX/lib"
export CPPFLAGS="-I$HOMEBREW_PREFIX/include"

WORK_DIR="$HOME/ffmpeg-decklink-build"

# Vérifier que le SDK est présent
if [ ! -d "$WORK_DIR/Blackmagic_DeckLink_SDK" ]; then
    echo "❌ SDK DeckLink manquant : $WORK_DIR/Blackmagic_DeckLink_SDK"
    exit 1
fi

cd "$WORK_DIR"

# Supprimer l'ancien FFmpeg 6.1 si présent
if [ -d "ffmpeg" ]; then
    echo "🧹 Suppression de l'ancienne version FFmpeg..."
    rm -rf ffmpeg
fi

# Télécharger FFmpeg 7.1
echo "📥 Téléchargement de FFmpeg 7.1..."
git clone --depth 1 --branch release/7.1 https://git.ffmpeg.org/ffmpeg.git

cd ffmpeg

echo ""
echo "🔧 Configuration de FFmpeg 7.1 avec DeckLink..."
echo ""

./configure \
    --prefix=/usr/local \
    --enable-gpl \
    --enable-nonfree \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-decklink \
    --extra-cflags="-I${WORK_DIR}/Blackmagic_DeckLink_SDK -I${HOMEBREW_PREFIX}/include" \
    --extra-ldflags="-L${HOMEBREW_PREFIX}/lib -framework CoreFoundation" \
    --arch=arm64

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Configuration échouée"
    exit 1
fi

echo ""
echo "✅ Configuration réussie !"
echo ""
echo "🔨 Compilation (15-30 minutes)..."

make -j$(sysctl -n hw.ncpu)

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Compilation échouée"
    exit 1
fi

echo ""
echo "✅ Compilation réussie !"
echo ""
echo "📦 Installation système requise"
echo ""
echo "⚠️  L'installation nécessite des privilèges administrateur (sudo)"
echo "   FFmpeg sera installé dans : /usr/local/bin/ffmpeg"
echo ""
read -p "Continuer avec l'installation ? (o/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
    echo ""
    echo "❌ Installation annulée"
    echo ""
    echo "💡 FFmpeg compilé disponible dans : ${WORK_DIR}/ffmpeg/ffmpeg"
    echo "   Vous pouvez l'installer manuellement plus tard avec :"
    echo "   cd ${WORK_DIR}/ffmpeg && sudo make install"
    echo ""
    exit 0
fi

echo ""
echo "📦 Installation en cours..."

sudo make install

echo ""
echo "🧪 Vérification..."
ffmpeg -version | head -n 1
echo ""
echo "Support DeckLink :"
ffmpeg -hide_banner -sources decklink 2>&1 | head -n 10

echo ""
echo "🎉 Installation terminée !"
echo ""
echo "✅ FFmpeg 7.1 avec DeckLink installé"
echo "📍 /usr/local/bin/ffmpeg"
echo ""
echo "🚀 Testez maintenant : ./test-setup.sh"
echo ""