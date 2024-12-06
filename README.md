# Ccx-welding-simulation
Este repositorio contiene los archivos utilizados para realizar simulaciones de procesos de soldadura convencional y soldadura aditiva. Las simulaciones se llevaron a cabo utilizando CalculiX como solver, aprovechando una subrutina personalizada llamada dflux para modelar la transmisión de calor.

**El propósito de este repositorio es compartir este enfoque de simulación con la comunidad, facilitando que otros puedan:**

- Replicar los experimentos realizados.

- Implementar mejoras en sus propios proyectos.

- Optimizar o ampliar las técnicas utilizadas en el modelado.

**Contenido**

- Archivos .inp configurados para las simulaciones.

- Subrutina dflux para modelar el comportamiento térmico.

- Modelos y mallas asociados a los procesos de soldadura.

- Ccx en forma base sin modificaciones

- Ccx para ejecutar soldaduras y soldaduras aditivas.

- Documentación del flujo de trabajo y detalles técnicos.


**Objetivo**

Promover el uso de software libre en la simulación de procesos de soldadura y fomentar la colaboración en el desarrollo de nuevas técnicas.

#  Instalacion de CalculiX de forma base
Para realiazar una instalacion de limpia de CalculiX se necesita descargar la carpeta de archivos [Ccx_Base](https://github.com/PacoOMG2/Ccx-welding-simulation/tree/main/Ccx_base/ccx_sin_exe).
1. Al descargar la carpeta se necesita instalar el programa [msys2](https://www.msys2.org) para hacer la construccion de ccx mediante su consola en su aplicacion MSYS2 MINGW64
2. Al terminar la instalacion del programa, se busca la carpeta y se entra msys64 en la ruta donde se instalo, se accede a subcarpeta home despues a la siguiente carpeta de tu "usuario" y en ella se pega la carpeta de ccx_sin_exe, importante siempre dejar una copia de esta carpeta.
3. Ahora dejando una copia de la carpeta se procede a cambiar el nombre de la otra carpeta dejandolo solo como ccx.
4. Una hecho lo anterior, se entra a MINGW64, en la consola se teclea **cd ccx** se da enter y despues se ejecuta el build dentro de la carpeta de ccx con el siguiente comando **./build_ccx.sh**.
5. Atomaticamente al dar enter se empezara a construir ccx de forma base.
# Video explicativo de la instalacion 
"video"
