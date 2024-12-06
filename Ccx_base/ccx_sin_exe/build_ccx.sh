#!/bin/sh

# Load environment
export MINGW_HOME=/mingw64
export PATH="$MINGW_HOME/bin:$PATH"

cd "${0%/*}" || exit 1

CCX_VERSION="2.21"
BUILD_HOME=$(pwd)
BUILD_DIR="$BUILD_HOME/x64/build"
INSTALL_DIR="$BUILD_HOME/x64/install"
LOG_FILE="$BUILD_HOME/x64/buildlog_ccx.txt"

echo "Compilando CCX single threaded (ccx.exe)"
cd "$BUILD_DIR"
CCX_PACKAGE_NAME="ccx_$CCX_VERSION.src.tar.bz2"
cp -p "$BUILD_HOME/$CCX_PACKAGE_NAME" .
tar -xjf "$CCX_PACKAGE_NAME"
cp -rp "$BUILD_HOME/patches/CalculiX" .
cd "$BUILD_DIR/CalculiX/ccx_$CCX_VERSION/src"
if ! make -j$(nproc) >> "$LOG_FILE" 2>&1; then
    echo "Error: La compilación de ccx.exe falló."
    exit 1
fi

echo "Compilando CCX MKL (ccx_MKL.exe)"
cd "$BUILD_DIR"
cp -rp "$BUILD_HOME/mkl" .
cd "$BUILD_DIR/CalculiX/ccx_$CCX_VERSION/src"
rm *.o *.a > /dev/null 2>&1
if ! make -f Makefile_MKL -j$(nproc) >> "$LOG_FILE" 2>&1; then
    echo "Error: La compilación de ccx_MKL.exe falló."
    exit 1
fi

# Verificar si los archivos ejecutables existen antes de copiarlos
echo "Copiando binarios a la carpeta de instalación"
cd "$INSTALL_DIR"
cp -p "$BUILD_HOME/gpl.txt" .

if [ -f "$BUILD_DIR/CalculiX/ccx_$CCX_VERSION/src/ccx_$CCX_VERSION" ]; then
    cp -p "$BUILD_DIR/CalculiX/ccx_$CCX_VERSION/src/ccx_$CCX_VERSION" ccx.exe
else
    echo "Error: ccx.exe no se encontró en el directorio de compilación."
    exit 1
fi

if [ -f "$BUILD_DIR/CalculiX/ccx_$CCX_VERSION/src/ccx_${CCX_VERSION}_MKL" ]; then
    cp -p "$BUILD_DIR/CalculiX/ccx_$CCX_VERSION/src/ccx_${CCX_VERSION}_MKL" ccx_MKL.exe
else
    echo "Error: ccx_MKL.exe no se encontró en el directorio de compilación."
    exit 1
fi

# Copiar archivos DLL requeridos
cp -p "$MINGW_HOME/bin/libgfortran-5.dll" .
cp -p "$MINGW_HOME/bin/libgomp-1.dll" .
cp -p "$MINGW_HOME/bin/libquadmath-0.dll" .
cp -p "$MINGW_HOME/bin/libstdc++-6.dll" .
cp -p "$MINGW_HOME/bin/libwinpthread-1.dll" .
cp -p "$MINGW_HOME/bin/libgcc_s_seh-1.dll" .
cp -p "$BUILD_DIR/pthreads-w32-2-9-1-release/Pre-built.2/dll/x64/pthreadGC2.dll" .
cp -p "$BUILD_DIR/mkl/mkl_intel_thread.2.dll" .
cp -p "$BUILD_DIR/mkl/mkl_core.2.dll" .
cp -p "$BUILD_DIR/mkl/libiomp5md.dll" .
cp -p "$BUILD_DIR/mkl/mkl_def.2.dll" .

echo "Compilación de CCX completada exitosamente."
