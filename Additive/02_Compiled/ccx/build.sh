#!/bin/sh


#Source files downloaded from:
#ftp://sourceware.org/pub/pthreads-win32/pthreads-w32-2-9-1-release.zip
# zip converted to .tar.gz so msys's tools can extract it
#http://www.dhondt.de/ccx_2.21.src.tar.bz2
#http://netlib.sandia.gov/linalg/spooles/spooles.2.2.tgz
#http://www.caam.rice.edu/software/ARPACK/SRC/arpack96.tar.gz
#http://www.caam.rice.edu/software/ARPACK/SRC/patch.tar.gz
#https://software.intel.com/content/www/us/en/develop/tools/oneapi/base-toolkit/download.html?operatingsystem=window&distributions=webdownload&options=online

extract() {
    file=$1
    program=$2

    cp -p "$BUILD_HOME"/"$file" .
    package=`basename "$file"`
    $program -cd "$package" | tar xvf -

}

# Install tools
pacman -S --needed --noconfirm mingw-w64-x86_64-gcc
pacman -S --needed --noconfirm mingw-w64-x86_64-gcc-libgfortran
pacman -S --needed --noconfirm mingw-w64-x86_64-gcc-fortran
pacman -S --needed --noconfirm msys/make
pacman -S --needed --noconfirm msys/perl


export MINGW_HOME=/mingw64
export PATH="$MINGW_HOME"/bin:$PATH

cd ${0%/*} || exit 1    # run from this directory

CCX_VERSION="2.21"
BUILD_HOME=`pwd`
BUILD_DIR="$BUILD_HOME"/x64/build
INSTALL_DIR="$BUILD_HOME"/x64/install
OUT_DIR="$BUILD_HOME"/x64

# Clean up previous build
rm -rf "$OUT_DIR" > /dev/null 2>&1
mkdir "$OUT_DIR"
mkdir "$BUILD_DIR"
mkdir "$INSTALL_DIR"


LOG_FILE="$OUT_DIR"/buildlog.txt


echo "Building pthreads"
cd "$BUILD_DIR"
extract "pthreads-w32-2-9-1-release.tar.gz" gzip >> "$LOG_FILE" 2>&1
cp -rp "$BUILD_HOME"/patches/pthreads-w32-2-9-1-release .
cd pthreads-w32-2-9-1-release


echo "Building SPOOLES"
cd "$BUILD_DIR"
mkdir SPOOLES.2.2
cd SPOOLES.2.2
extract "spooles.2.2.tgz" gzip >> "$LOG_FILE" 2>&1
cd ..
cp -rp "$BUILD_HOME"/patches/SPOOLES.2.2 .
cd SPOOLES.2.2
make lib >> "$LOG_FILE" 2>&1


echo "Building ARPACK"
cd "$BUILD_DIR"
extract "arpack96.tar.gz" gzip >> "$LOG_FILE" 2>&1
extract "patch.tar.gz" gzip >> "$LOG_FILE" 2>&1
cp -rp "$BUILD_HOME"/patches/ARPACK .
cd ARPACK
# ARmake.inc uses ARPACK_HOME environment variable to find out where to build sources
# The path must not contain spaces because of Make.
export ARPACK_HOME="$BUILD_DIR"/ARPACK
make all >> "$LOG_FILE" 2>&1


echo "Building CCX single threaded (ccx.exe)"
cd "$BUILD_DIR"
CCX_PACKAGE_NAME=ccx_$CCX_VERSION.src.tar.bz2
extract "$CCX_PACKAGE_NAME" bzip2 >> "$LOG_FILE" 2>&1
cp -rp "$BUILD_HOME"/patches/CalculiX .
cd "$BUILD_DIR"/CalculiX/ccx_$CCX_VERSION/src
make >> "$LOG_FILE" 2>&1


echo "Building CCX MKL (ccx_MKL.exe)"
cd "$BUILD_DIR"
cp -rp "$BUILD_HOME"/mkl .
cd "$BUILD_DIR"/CalculiX/ccx_$CCX_VERSION/src
rm *.o *.a > /dev/null 2>&1
make -f Makefile_MKL >> "$LOG_FILE" 2>&1


# Copy binaries to install directory
cd "$INSTALL_DIR"
cp -p "$BUILD_HOME"/gpl.txt .
cp -p "$BUILD_DIR"/CalculiX/ccx_$CCX_VERSION/src/ccx_$CCX_VERSION ccx.exe
cp -p "$BUILD_DIR"/CalculiX/ccx_$CCX_VERSION/src/ccx_${CCX_VERSION}_MKL ccx_MKL.exe
cp -p "$MINGW_HOME"/bin/libgfortran-5.dll .
cp -p "$MINGW_HOME"/bin/libgomp-1.dll .
cp -p "$MINGW_HOME"/bin/libquadmath-0.dll .
cp -p "$MINGW_HOME"/bin/libstdc++-6.dll .
cp -p "$MINGW_HOME"/bin/libwinpthread-1.dll .
cp -p "$MINGW_HOME"/bin/libgcc_s_seh-1.dll .
cp -p "$BUILD_DIR"/pthreads-w32-2-9-1-release/Pre-built.2/dll/x64/pthreadGC2.dll .
cp -p "$BUILD_DIR"/mkl/mkl_intel_thread.2.dll .
cp -p "$BUILD_DIR"/mkl/mkl_core.2.dll .
cp -p "$BUILD_DIR"/mkl/libiomp5md.dll .
cp -p "$BUILD_DIR"/mkl/mkl_def.2.dll .


# The end
