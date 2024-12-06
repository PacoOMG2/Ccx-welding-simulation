@echo off
REM Ruta del archivo inp
set INP_DIR=%~dp0

REM Ruta del ejecutable de CalculiX
REM Retrocede una carpeta
set EXE_DIR=%INP_DIR%..\

REM Ruta a la subcarpeta 04_Calculix
set EXE_mkl=%EXE_DIR%\04_Calculix

REM Cambio de directorio
cd /d %INP_DIR%

REM funcion para detectar el archivo
 for %%f in (*.inp) do (
    REM %%n elimina la extension del archivo y solo deja el nombre, para poder importarlo
    "%EXE_mkl%\ccx_MKL" %%~nf
)	
pause
