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
4. Una hecho lo anterior, se entra a MINGW64, en la consola se teclea **cd ccx** se da enter y despues se ejecuta el build dentro de la carpeta de ccx con el siguiente comando **./build_ccx.sh**
5. Atomaticamente al dar enter se empezara a construir ccx de forma base.

# Video explicativo de la instalacion 
"video"

# Additive simulation
**Explicacion**
La soldadura aditiva es un proceso en el que se agrega material capa por capa para unir partes de metal, similar a cómo funciona la impresión 3D, pero en lugar de plástico, se utiliza metal. Este tipo de soldadura es útil para reparar piezas dañadas o crear piezas complejas que no pueden fabricarse fácilmente con métodos tradicionales. En lugar de eliminar material como en la soldadura convencional, donde se funden y unen dos piezas de metal, en la soldadura aditiva se va añadiendo material para formar nuevas estructuras, lo que permite mayor control sobre la forma y la calidad del resultado.
Se realizaron 3 ejemplos de este tipo de soldadura, donde se construyo una pieza con un total de 5 capaz distintas simulando este proceso por una subrutina llamada dflux, la cual se encuentra dentro de los archivos.
## AM_therm_total
Este el siguiente archivo contiene código detallado de un archivo .inp de Abaqus utilizado para simular un proceso de soldadura.
El código se organiza en varios pasos que simulan las diferentes fases del proceso de soldadura, incluyendo:

Condiciones Iniciales: Se definen las condiciones térmicas iniciales antes de que comience el proceso de soldadura. En este paso se establece la temperatura inicial de todos los nodos en el modelo.
Fase de Soldadura: En esta fase, se simula el proceso de soldadura en varios pasos. Se actualizan las propiedades del material y se aplica calor a la región de la soldadura utilizando los archivos de flujo de calor (.flm), radiación (.rad) y distribución inhomogénea del calor (.dflux).
Este paso simula la aplicación de calor por convección y radiación en la zona de soldadura, modificando el material a lo largo de la trayectoria de la soldadura.

Ciclo de Material: A lo largo de cada paso, se cambia el material de las diferentes zonas de la soldadura, utilizando el comando *CHANGE SOLID SECTION, para simular cómo la zona afectada por el calor se convierte en un nuevo material con propiedades diferentes.

Enfriamiento: Al final de la simulación, se simula el proceso de enfriamiento donde las condiciones térmicas se modifican para representar el enfriamiento del material soldado. Este paso se simula utilizando la convección y radiación, pero con diferentes parámetros de flujo de calor.

INCLUDE: Se utilizan los comandos *INCLUDE para incluir archivos externos que contienen la información de la malla y los materiales. Esto hace que el código sea modular y fácil de modificar sin tener que cambiar directamente el archivo principal.

STEP: Cada fase del proceso de soldadura está contenida en un paso (*STEP). Estos pasos definen la duración, los incrementos de tiempo, y las condiciones térmicas o mecánicas a aplicar en cada fase del proceso.

FILM, RADIATE, DFLUX: Estos comandos se usan para aplicar condiciones térmicas específicas, como la convección (por *FILM), radiación (por *RADIATE), y flujo de calor inhomogéneo (por *DFLUX).

**Visualizacion de los resultados**
- En la siguiente imagen se muetra los resultados de la simulacion donde se esta construyendo la pieza por medio de capaz
![Am_therm_total](https://github.com/user-attachments/assets/ba0c98f3-6111-4864-8001-eea18c28fdee)

# AM_mech_1


