#!/bin/bash
set -e

# =======================
# XZ Utils 5.4.4 
# ============================

XZ_VERSION="5.4.4"
BUILD_DIR="$(pwd)/build"
DEST_DIR="$(pwd)/xz_pkg_fixed"
DEB_NAME="xz_${XZ_VERSION}_iphoneos-arm_ios9_fixed.deb"

if ! command -v dpkg-deb &> /dev/null; then
    echo "Error: dpkg-deb not found. Install dpkg via Homebrew: brew install dpkg"
    exit 1
fi

if ! command -v ldid &> /dev/null; then
    echo "Error: ldid not found. Install ldid via Homebrew: brew install ldid"
    exit 1
fi

echo "==> Clean old build..."
rm -rf "$BUILD_DIR" "$DEST_DIR" "$DEB_NAME"
mkdir -p "$BUILD_DIR" "$DEST_DIR/DEBIAN"

echo "==> Downlaoding xz-$XZ_VERSION..."
cd "$BUILD_DIR"
curl -sLO "https://tukaani.org/xz/xz-$XZ_VERSION.tar.gz"
tar -xzf "xz-$XZ_VERSION.tar.gz"
cd "xz-$XZ_VERSION"

echo "==> Configuring for iOS 9 (arm64)..."

# disable clock_gettime because only ios 10 have it
export ac_cv_func_clock_gettime=no
export ac_cv_search_clock_gettime=no

SDK_PATH=$(xcrun -sdk iphoneos --show-sdk-path)
CLANG_PATH=$(xcrun -sdk iphoneos --find clang)

./configure --host=arm64-apple-darwin \
    --prefix=/usr \
    --disable-shared \
    --enable-static \
    CC="$CLANG_PATH -arch arm64 -miphoneos-version-min=9.0 -isysroot $SDK_PATH"

echo "==> Compiling..."
make -j$(sysctl -n hw.ncpu)

echo "==> Installing to staging directory..."
make install DESTDIR="$DEST_DIR"

echo "==> Preparing Debian package..."
cd ../../

cp control "$DEST_DIR/DEBIAN/control"

# checksum
cd "$DEST_DIR"
find usr -type f -exec md5sum {} + > DEBIAN/md5sums
cd ..

echo "==> Codesign executables..."
for file in "$DEST_DIR/usr/bin/"*; do
    if [ -f "$file" ] && [ ! -L "$file" ]; then
        ldid -S "$file" 2>/dev/null || true
        echo " Signed $(basename "$file")"
    fi
done

echo "==> Make .deb package..."
rm -f "$DEST_DIR/usr/bin/".ldid.* 2>/dev/null || true
chmod -R 755 "$DEST_DIR/DEBIAN"
chmod 644 "$DEST_DIR/DEBIAN/control" "$DEST_DIR/DEBIAN/md5sums"
chmod 755 "$DEST_DIR/usr/bin/"* || true

dpkg-deb --root-owner-group -b -Zgzip "$DEST_DIR" "$DEB_NAME"

echo "==> Cleaning up..."
rm -rf "$BUILD_DIR" "$DEST_DIR"

echo "==> DONE! Successfully built $DEB_NAME"
