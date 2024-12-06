@echo off

REM Ruta donde se encuentran los archivos .frd
set FRD_DIR=%~dp0

REM formato YYYY-MM-DD_HH-MM-SS
for /f "tokens=2-4 delims=/ " %%a in ("%date%") do set Today=%%c%%a_%%b
for /f "tokens=1-3 delims=:.," %%a in ("%time%") do set Now=%%a_%%b_%%c
set fulltime=%Today%_%Now%

REM Ruta de salida de los resultados
set RESULT_DIR=%FRD_DIR%Resultados_%fulltime%

REM Verifica si existen archivos .frd en el directorio
dir "%FRD_DIR%*.frd" >nul 2>&1
if errorlevel 1 (
    echo No se encontraron archivos .frd en el directorio
    pause
    exit /b
)

REM Crea la carpeta de resultados si no existe
if not exist "%RESULT_DIR%" (
    mkdir "%RESULT_DIR%"
    echo Carpeta de resultados creada
) else (
    echo La carpeta de resultados ya existe en
)

REM ccx2paraview
set MODULE_DIR=%FRD_DIR%..\
set MODULE_DIR2=%MODULE_DIR%\03_FRD_paraview_converter

REM Añade el módulo de paquete ccx2paraview a python
set PYTHONPATH=%MODULE_DIR2%

REM Mueve todos los archivos .frd 
for %%f in ("%FRD_DIR%*.frd") do (
    move "%%f" "%RESULT_DIR%"
)

REM Cambia al directorio de resultados para realizar las conversiones
cd /d "%RESULT_DIR%"

REM Busca archivos .frd y los convierte
for %%f in (*.frd) do (
    echo Procesando archivo: %%f

    REM Ejecuta el convertidor
    python -c "import sys; sys.path.append(r'%MODULE_DIR2%'); import ccx2paraview.ccx2paraview as cpx; c = cpx.Converter(r'%%f', ['vtu']); c.run()"
)

pause
