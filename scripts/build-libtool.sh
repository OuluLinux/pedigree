#!/bin/bash

# Script to build libtool from source if not available via PUP
set -e

if [ -z "$SRCDIR" ] || [ -z "$TARGETDIR" ]; then
    echo "Error: SRCDIR and TARGETDIR must be set"
    exit 1
fi

echo "Building libtool from source for Pedigree build..."

# Set variables
LIBTOOL_VERSION="2.4.6"
LIBTOOL_TARBALL="libtool-$LIBTOOL_VERSION.tar.gz"
LIBTOOL_URL="https://ftp.gnu.org/gnu/libtool/$LIBTOOL_TARBALL"
LIBTOOL_DIR="$SRCDIR/external/libtool-$LIBTOOL_VERSION"

# Create external directory if it doesn't exist
mkdir -p "$SRCDIR/external"

# Download libtool if not already present
if [ ! -f "$SRCDIR/external/$LIBTOOL_TARBALL" ]; then
    echo "Downloading libtool $LIBTOOL_VERSION..."
    wget "$LIBTOOL_URL" -O "$SRCDIR/external/$LIBTOOL_TARBALL" || {
        echo "Error: Failed to download libtool. Check your internet connection."
        exit 1
    }
fi

# Extract libtool if not already extracted
if [ ! -d "$LIBTOOL_DIR" ]; then
    echo "Extracting libtool..."
    tar -xzf "$SRCDIR/external/$LIBTOOL_TARBALL" -C "$SRCDIR/external/" || {
        echo "Error: Failed to extract libtool archive."
        exit 1
    }
fi

# Check if already built by looking for the libtool binary
if [ -f "$TARGETDIR/bin/libtool" ]; then
    echo "Libtool already built. Skipping."
    exit 0
fi

echo "Configuring and building libtool..."

cd "$LIBTOOL_DIR"

# Configure libtool with appropriate settings for Pedigree build
./configure --prefix="$TARGETDIR" || {
    echo "Error: Failed to configure libtool."
    exit 1
}

# Build and install
make || {
    echo "Error: Failed to build libtool."
    exit 1
}
make install || {
    echo "Error: Failed to install libtool."
    exit 1
}

echo "Libtool built and installed successfully."