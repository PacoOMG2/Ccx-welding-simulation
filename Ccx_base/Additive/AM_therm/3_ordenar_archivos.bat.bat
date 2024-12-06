@echo off
REM Ruta donde se encuentran los archivos a mover
set SOURCE_DIR=%~dp0
rem Formato YYYY-MM-DD_HH-MM-SS
for /f "tokens=2-4 delims=/ " %%a in ("%date%") do set Today=%%c_%%a_%%b
for /f "tokens=1-3 delims=:.," %%a in ("%time%") do set Now=%%a_%%b_%%c
set fulltime=_%Today%_%Now%

REM Ruta de archivos
set DEST_DIR=%SOURCE_DIR%Run%fulltime%

cd /d %SOURCE_DIR%

REM Verificar si existen archivos con las extensiones 12D, CVG, DAT, ROUT, STA
set foundFiles=false
for %%e in (12d cvg dat rout sta) do (
    dir *.%%e >nul 2>&1
    if not errorlevel 1 set foundFiles=true
)

if "%foundFiles%"=="false" (
    echo No se encontraron archivos con las extensiones especificadas
    pause
    exit /b
)

if not exist "%DEST_DIR%" (
    mkdir "%DEST_DIR%"
    echo Carpeta creada: %DEST_DIR%
) else (
    echo La carpeta ya existe en: %DEST_DIR%
)

REM Mover archivos con extensiones 12D, CVG, DAT, ROUT, STA
for %%e in (12d cvg dat rout sta) do (
    move *.%%e "%DEST_DIR%"
)

echo Archivos movidos exitosamente
pause
