Creado por Omwekiatl 2024

Video:
https://youtu.be/b-_vHnF2lto

Introducción:
editor y lector de librocuentos, el presente proyecto permite editar secuencias textuales en árbol de decisiónes, aquí puede organizar, escribir y conectar sus hojas para dar forma a su narrativa guiada. El sistema incluye un analizador estocástico de posibilidades y detector de bucles, así como diferentes formas de exportación.

Incluye:
- proyecto Godot editor de librocuentos.
- proyecto Godot lector de librocuentos.
- archivo para draw.io de ejemplo.

Características:
- exportación por hojas txt separadas, ideal para publicación en blogs o páginas web.
- exportación en un solo documento txt, preparado para ser editado y organizado en Word o similares, ideal para escribir un libro.
- exportación e importación en formato compacto txt, para ser leído por el mismo programa o por el lector de librocuentos.
- modificación fácil de las plantillas de exportación, para personalizar la misma.
- motor estocástico que permite detectar bucles y títulos repetidos, genera un par de archivos txt con los resultados. Además el motor puede ajustarse según número de iteraciónes y punto de partida y finalización, para analizar solo un tramo del librocuento.
- herramienta visual para saber segun transparencia, qué titulos o textos faltan por escribir.
- contador de palabras escritas en cada hoja.
- poner imágen de fondo, por ejemplo para guiarse con un esquema hecho exteranamente en software como draw.io aunque esto no es necesario, puede hacerse todo en Godot.
- fácil edición de hojas / nodos, permitiendo conexión y desconexión, incluso con etiquetas de salto en retroceso.
- lector de librocuentos soporta imágenes también.
- lector de librocuentos listo para ser exportado a web.
- espacio para poner notas en el editor.

Uso:
- para escribir un librocuento, tenga la carpeta con los proyectos descomprimida.
- cree un esquema guía, por ejemplo en draw.io si es que requiere uno, luego colóquelo en la carpeta "Data" con el nombre "esquema.png".
- ejecute Godot, pulse en importar proyecto si no lo ha hecho antes, y elija el archivo de proyecto dentro de la carpeta "CuentaCuentos".
- pulse "ejecutar" o "play" en la parte superior derecha de Godot.
- coloque las hojas, conéctelas y escriba su librocuento.
- exporte sus archivos.
- si quiere usar el software de lectura de librocuentos, abralo con Godot.
- arrastre el archivo "save.txt" de la carpeta "Data" del "CuentaCuentos" a Godot.
- ejecute Godot y podrá leer su librocuento.
- haga modificaciónes en Godot, de títulos de botónes, aspecto, colores, etc.
- puede agregar imágenes PNG a la carpeta "Dibujos" de "CuentoContado" o a Godot en dicha carpeta, con el formato "dN.png" donde N es el índice de la hoja a la que pertenece la imágen.
- puede exportar un ejecutable html5 de Godot para por ejemplo subirlo a itch.io u otro sitio web.

Limitantes:
- el motor estocástico quizá se modifique a futuro por una búsqueda por nodos, dado que es ineficiente en casos de cuentos muy grandes y complejos.
- el lector de librocuentos debe editarse en Godot para personalizarlo antes de su exportación, cambiar nombres de botónes y demás, por lo que requiere conocimiento de Godot.
- el sistema es para librocuentos, no videojuegos de novela gráfica, rol o ficción interactiva, por lo que carece de variables o máquinas de estados que guarden información de las deciciónes, esto tendría que hacerlo por su cuenta.

Notas:
- no es obligatorio usar software externo como draw.io para hacer los esquemas, puede trabajar en Godot solamente, pero si tiene que usar una imágen en blanco como esquema.png ya que este es el fondo clickeable que define el límite del "escritorio" de trabajo.
- cualquier imágen como esquema.png sirve, sea hecha en paint o una foto de un cuaderno, ya que esto es solo una guía visual.
- cuando el análisis arroje un número de historias cercano al número de iteraciónes, por ejemplo: 968 de 1000, hay que subir el número de iteraciónes o el resultado puede no ser el número de historias real, saturación del sistema.
- cuando tenga cuentos con cuellos de botella, puede hacer el análisis por partes, poniendo hoja de inicio y final, luego puede multiplicar los resultados de número de historias de ambas partes si son consecutivas.

Versión 3:
esta es una versión preliminar, aún no exportada por lo que requiere Godot 4.2.1 para ejecutarse, es un proyecto en curso por lo que aún puede tener fallos y trabajos por hacer, pero está totalmente utilizable, cumple con lo necesario para crear librocuentos.

Licencia:
este software es de libre uso y modificación para proyectos personales NO comerciales, y deben darse créditos a Omwekiatl en caso de alguna publicación. Para otros usos, comunicarse al correo ojorcio@gmail.com
Cualquier cuento creado es SU propiedad intelectual, pero si va a vender o monetizar el código, el proyecto, un exportable digital, en ese caso se aplican las reglas de licencia descritas arriba.
