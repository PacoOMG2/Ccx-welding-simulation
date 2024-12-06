#!/bin/sh

extract() {
    file=$1
    program=$2
    cp -p "$BUILD_HOME/$file" .
    package=$(basename "$file")
    $program -cd "$package" | tar xvf -
}

# Install tools
pacman -S --needed --noconfirm mingw-w64-x86_64-gcc
pacman -S --needed --noconfirm mingw-w64-x86_64-gcc-libgfortran
pacman -S --needed --noconfirm mingw-w64-x86_64-gcc-fortran
pacman -S --needed --noconfirm msys/make
pacman -S --needed --noconfirm msys/perl

export MINGW_HOME=/mingw64
export PATH="$MINGW_HOME/bin:$PATH"

cd "${0%/*}" || exit 1

CCX_VERSION="2.21"
BUILD_HOME=$(pwd)
BUILD_DIR="$BUILD_HOME/x64/build"
INSTALL_DIR="$BUILD_HOME/x64/install"
OUT_DIR="$BUILD_HOME/x64"

# Clean up previous build
rm -rf "$OUT_DIR" > /dev/null 2>&1
mkdir -p "$OUT_DIR" "$BUILD_DIR" "$INSTALL_DIR"

LOG_FILE="$OUT_DIR/buildlog.txt"

echo "Building pthreads"
cd "$BUILD_DIR"
extract "pthreads-w32-2-9-1-release.tar.gz" gzip >> "$LOG_FILE" 2>&1
cp -rp "$BUILD_HOME/patches/pthreads-w32-2-9-1-release" .

echo "Building SPOOLES"
cd "$BUILD_DIR"
mkdir SPOOLES.2.2
cd SPOOLES.2.2
extract "spooles.2.2.tgz" gzip >> "$LOG_FILE" 2>&1
cd ..
cp -rp "$BUILD_HOME/patches/SPOOLES.2.2" .
cd SPOOLES.2.2
make lib >> "$LOG_FILE" 2>&1

echo "Building ARPACK"
cd "$BUILD_DIR"
extract "arpack96.tar.gz" gzip >> "$LOG_FILE" 2>&1
extract "patch.tar.gz" gzip >> "$LOG_FILE" 2>&1
cp -rp "$BUILD_HOME/patches/ARPACK" .
cd ARPACK
export ARPACK_HOME="$BUILD_DIR/ARPACK"
make all >> "$LOG_FILE" 2>&1

echo "Compilación de componentes (sin CCX) completada exitosamente."
