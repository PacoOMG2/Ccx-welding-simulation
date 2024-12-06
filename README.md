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

# AM_therm_1

Este archivo está configurado para simular un proceso de **soldadura aditiva**, en el cual se construye una estructura capa por capa, añadiendo material fundido que se solidifica al enfriarse. A continuación, explico cómo funciona elproceso en el contexto de la soldadura aditiva de este ejemplo:

## Mallas y Materiales

- **Mallas (.msh)**: Incluye las mallas que definen la geometría de la estructura que se va a simular. En este caso, el archivo usa una malla base (`all_1.msh`) y mallas adicionales para las capas de soldadura, como `Eb1.msh`.
- **Materiales (.mat)**: Incluye los materiales que se usan en la simulación. El archivo hace referencia a un material de depósito (`Deposit.mat`), que es el material que se va añadiendo capa por capa durante la soldadura aditiva.

## Condiciones Iniciales

Se establece una **temperatura inicial de 20°C** para todos los nodos, lo que representa el estado inicial del material antes de que se aplique el calor.

## Paso 1: "Do Nothing"

En esta fase, no se realiza ninguna acción, pero el sistema se prepara para las siguientes simulaciones de transferencia de calor. Este paso es útil para crear una base de datos de inicio y verificar que todo está configurado correctamente antes de comenzar a aplicar calor.

## Paso 2: Proceso de Soldadura Aditiva

Este paso simula la adición de material (generalmente en forma de polvo o alambre) sobre la base de la pieza. Se aplican tres mecanismos de transferencia de calor:

1. **Convección**: Transferencia de calor entre el material fundido y la atmósfera circundante. En la soldadura aditiva, el material recién depositado se calienta y transfiere parte de su energía térmica al entorno.
2. **Radiación**: La superficie caliente de la soldadura irradia calor al entorno.
3. **Flux Inhomogéneo**: Esto modela cómo el calor no se distribuye uniformemente en la pieza, lo cual es típico en la soldadura aditiva, donde el calor varía en diferentes puntos de la pieza según la posición de la boquilla de soldadura.

## Reinicio y Almacenamiento de Resultados

El archivo también incluye un comando de **reinicio** para guardar los resultados intermedios, lo cual es esencial en simulaciones largas o complejas como las de soldadura aditiva. Así, los datos de temperatura y flujo de calor se guardan para su posterior análisis y control.

## Resumen

Este archivo simula la **adición de material capa por capa** en un proceso de soldadura aditiva, calculando cómo el calor se distribuye y se transfiere al material durante el proceso de construcción de la pieza. En cada paso, se agregan nuevas capas de material (como se ve en los archivos de malla y material, como `Eb1.msh` y `Deposit.mat`), y se simula cómo la temperatura y el flujo de calor cambian durante el proceso.
![Am_therm_1](https://github.com/user-attachments/assets/c7730e2f-5c11-4d1f-8e0f-074e0076d337)

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

# Visualizacion de los resultados
- En la siguiente imagen se muetra los resultados de la simulacion donde se esta construyendo la pieza por medio de capaz.

![Am_therm_total](https://github.com/user-attachments/assets/ba0c98f3-6111-4864-8001-eea18c28fdee)

# Welding simulation
La siguiente simulacion tambien se compone por un dflux que calcula el flujo de calor en cada punto de integración de la malla durante la simulación de un proceso de soldadura, utilizando un modelo de elementos finitos. Específicamente, este subprograma permite implementar la distribución de calor generada por una fuente de calor (como un láser o arco) a lo largo de una trayectoria de soldadura.
En resumen, este subprograma gestiona cómo se distribuye y aplica el calor en un modelo de elementos finitos a lo largo de una trayectoria de soldadura, permitiendo simular el proceso de transferencia de calor y la evolución de la temperatura en la malla durante la simulación de soldadura. Esto es crucial para predecir los efectos térmicos en la pieza, como la deformación, las tensiones residuales y la microestructura del material.
# Weld_I_dlfux

Este archivo está configurado para simular un proceso de **soldadura en una lámina de metal**, en el que se modela el comportamiento térmico del material durante el proceso de soldadura. 

## Mallas y Materiales

- **Mallas (.msh)**: Incluye la malla que define la geometría de la pieza de metal que se va a simular. En este caso, se utiliza un archivo de malla base llamado `all.msh`.
- **Materiales**: El archivo define un material específico llamado `X6CrNiTi1810`, que es un tipo de acero inoxidable utilizado en el proceso de soldadura. Las propiedades térmicas del material, como la conductividad térmica, la capacidad calorífica y la densidad, se definen en función de la temperatura.

## Condiciones Iniciales

Se establece una **temperatura inicial de 20°C** para todos los nodos, lo que representa el estado inicial del material antes de aplicar el calor de la soldadura.

## Paso 1: Transferencia de Calor Directa

En este paso se realiza la transferencia de calor directa a través del material. Los parámetros del calor aplicado, como la tasa de transferencia de calor y el tiempo, se definen para este paso. Además, se incluye el comando **DFLUX** para modelar el flujo de calor inhomogéneo y se guarda la información de los nodos y elementos.

## Paso 2: Convección y Transferencia de Calor por Película

En este paso, se modela la transferencia de calor a través de una **película de aire**, que simula el enfriamiento del material mediante convección. Se incluye un archivo externo `film1.flm` para definir la película de aire, y el comando **DFLUX** se usa para modelar el flujo de calor. Además, se siguen registrando los resultados de nodos y elementos.

## Paso 3: Radiación y Transferencia de Calor

Este paso simula la transferencia de calor por **radiación** desde la superficie caliente del material hacia el entorno. Se incluye un archivo externo `radiation1.rad` para definir los parámetros de radiación, y nuevamente se utiliza **DFLUX** para modelar el flujo de calor. Además, se mantiene el registro de los resultados intermedios.

## Reinicio y Almacenamiento de Resultados

Cada paso incluye comandos de **reinicio** para guardar los resultados intermedios. Esto es esencial en simulaciones largas para almacenar datos de temperatura y flujo de calor a medida que avanza el proceso de soldadura.

## Resumen

Este archivo simula el comportamiento térmico de una **lámina de metal** durante el proceso de soldadura, aplicando diferentes mecanismos de transferencia de calor, como la transferencia directa, la convección por película de aire y la radiación. A lo largo de los pasos, se agregan nuevos parámetros para cada proceso de transferencia térmica y se registran los resultados de la simulación.

![image](https://github.com/user-attachments/assets/f01ed6de-6184-4d58-83e8-7af4fcc638a6)

# Pasos para ejecutar los archivos
- Para poder ejecutar los archivos se necesitan descargar las carpetas que se desean ejecutar, ya sea la de additive o welding, estas carpetas cuentan con una estructura diseñada para que el usuario que desee replicar el ejemplo o probarlo solo tenga que dar unos clics.
1. El primer paso es ubicar el ejemplo a correr dentro de la capeta principal de soldadura. ![image](https://github.com/user-attachments/assets/ce75d54f-fd3e-4b97-b9ea-e79c8acf79e8)

2. Una vez entre al ejemplo que desea ejecutar, vera la carpeta del ejemplo con una estructura en especifico, la cual cuenta el archivo .inp de el ejemplo, las mayas y archivos .bat.
   ![archivos.bat](https://github.com/user-attachments/assets/b978fdcd-504d-4b1e-85f2-dc40082eec48)
   
3. Se localizan los bat y se ejecutan en el orden que estan asignados, primero el 1_calculix, se abrira una consola donde se tiene que esperar a que se procese el modelo, la velocidad de procesado depende de la potencia del equipo de computo, para saber que ya termino el procesamiento se tiene que esperar hasta que aparezca el siguiente mensaje: ![image](https://github.com/user-attachments/assets/b71b217c-99c6-4df7-a13e-dd7efc58fa16)

4. Al terminar el procesamiento se ejecuta el segundo bat 2_convertido, el cual se encargara crear un archivo .pvd para poder realizar la visualizacion en paraview, al terminar de realizarse el proceso de este bat aparecera el siguiente mensaje: ![image](https://github.com/user-attachments/assets/cd34213f-860e-495b-81ff-7fe818bece9f)

5. Este bat creara una carpeta de resultados con archivos vtu y pvd para poder visualizar la simulación.

6. Para ordenar los archivos generados al momentro de ejecutar los anteriores bat se ejecuta el ultimo bat 3_ordenar_archivos, el cual creara una carpeta con los archivos creados mientras se corria el ejemplo, quedando de la siguiente manera.
   ![image](https://github.com/user-attachments/assets/f54f622d-9242-4caf-a3bf-cb18a93db434)

7. Como ultimo paso se abre la aplicacion paraview, la cual se puede obtener de la siguiente fuente: https://www.paraview.org/download/

8. Dentro de la aplicacion se localiza la pestaña file, se selecciona open, se busca la carpeta donde se encuentra el archivo que se ejecuto y dentro de la carpeta resultados se selecciona el archivo pvd

9. Se habilita el ojo y despues se oprime el boton apply, que se encuentra abajo a la izquierda. ![image](https://github.com/user-attachments/assets/58ed645f-8d3e-478c-8313-fb79ae7f17e4)

10. Dependiendo del analisis termico a visualizar se escoje una opción, en este caso se cuenta con 2 opciones, NT que se refiere a la distribución de la temperatura y Flux que se refiere a al flujo de calor aplicado en una determinada zona, el cual permite simular un cordon de soldadura.![image](https://github.com/user-attachments/assets/35f2df3a-462a-49c1-996b-4bf94d30036f)


11. Para iniciar la simulacion se controla por medio de la barra de pausa, que se encuentra en la parte de arriba del centro del menú y se da play, automaticamente se empezaran a visualizar los resultados de la simulación.![image](https://github.com/user-attachments/assets/5b65c809-abc2-4f5c-9aff-9aa3abe148b4)







