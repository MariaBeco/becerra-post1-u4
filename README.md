# becerra-post1-u4

## Descripción

Laboratorio de la Unidad 4 de Arquitectura de Computadores (UFPS). El repositorio contiene dos programas en lenguaje ensamblador NASM para DOS de 16 bits:

- **Parte 1 (`programa.asm`)**: programa con las secciones `.data`, `.bss` y `.text`, directivas de datos (`DB`, `DW`, `DD`, `RESB`, `RESW`, `TIMES`), constantes `EQU` y salida por pantalla con las funciones `09h` y `02h` de `INT 21h`.
- **Parte 2 (`macros.asm` + `programa2.asm`)**: biblioteca de macros con parámetros y etiquetas locales `%%`, una macro desenrollada con `%rep`, un bucle acumulador con `LOOP` y dos procedimientos condicionales con `CMP`/`Jcc` (`JE`/`JG` y `JLE`).

## Prerrequisitos

- DOSBox 0.74 o superior
- NASM 2.14 o superior (`nasm.exe` en la carpeta de trabajo)
- ALINK (`alink.exe` en la carpeta de trabajo)
- Editor de texto plano; los `.asm` se guardan en ASCII sin BOM

## Estructura

```
becerra-post1-u4/
├── programa.asm     Parte 1
├── macros.asm       Parte 2: biblioteca de macros
├── programa2.asm    Parte 2: programa integrador
├── README.md
└── capturas/        Capturas de compilación y ejecución en DOSBox
```

## Compilación y ejecución

Dentro de DOSBox:

```
Z:\> mount C C:\ruta\a\becerra-post1-u4
Z:\> C:

; Parte 1
C:\> nasm -f obj programa.asm -o programa.obj
C:\> alink programa.obj -oEXE -o programa.exe -entry main
C:\> programa.exe

; Parte 2 (con archivo de listado para ver las macros expandidas)
C:\> nasm -f obj programa2.asm -o programa2.obj -l programa2.lst
C:\> alink programa2.obj -oEXE -o programa2.exe -entry main
C:\> programa2.exe
```

> Si ALINK muestra `rsx_32 loader error: No DPMI-host found!`, se debe cargar primero un servidor DPMI. El paquete DOS de NASM incluye `cwsdpmi.exe`; basta con ejecutar `cwsdpmi -p` una vez por sesión de DOSBox antes de `alink`.

### Salida esperada

Parte 1:

```
=== Laboratorio NASM - Unidad 4 ===
----------------------------------------
Variable A (word):  Z
Tabla de bytes:     1 2 3 4 5
Programa finalizado correctamente.
========================================
```

Parte 2:

```
=== Macros y Control de Flujo ===
[Linea A] Primera impresion
[Linea A] Primera impresion
[Linea A] Primera impresion
[Linea B] Segunda impresion
[Linea B] Segunda impresion
Suma 1+2+3 = 6
El valor mayor es: 9
Los valores son iguales.
---
---
---
AX es menor o igual: 3
Fin del programa.
```

## Ajustes respecto a la guía

Durante el desarrollo se identificaron cuatro detalles de la guía que impedían ensamblar o producían una salida incorrecta; se documentan aquí porque el código los corrige:

1. **`mov ax, @data` no existe en NASM.** `@data` es sintaxis de MASM/TASM. En formato `obj`, NASM registra `.data` y `.bss` como los segmentos `data` y `bss`; el programa los agrupa con `group DGROUP data bss` y carga `DS` con `mov ax, DGROUP`.
2. **Segmento de pila.** Un EXE de DOS sin segmento de pila deja `SS:SP` en una posición arbitraria. Se añadió `section pila stack` con 256 bytes reservados.
3. **`INT 21h` función `09h` devuelve `AL = 24h`.** En la guía, `print_str` va justo antes de `print_digito`, así que el dígito impreso sería siempre `4` (nibble bajo de `24h`) en lugar de `6` o `9`. La macro `print_str` preserva `AX` con `PUSH`/`POP`.
4. **Valores de `tabla_bytes`.** Con `10, 20, 30, 40, 50` la conversión `+30h` produce `:`, `D`, `N`, `X` y `b`, no dígitos. Se usan `1, 2, 3, 4, 5` para que la salida sea coherente con la conversión, que solo es válida para 0-9. Además, el carácter "—" del título se reemplazó por "-" porque el archivo debe ser ASCII.

## Decisiones técnicas — Parte 1

### Decisión 1: EQU frente a %define para ANCHO_LINEA

`EQU` crea un símbolo numérico que resuelve el propio ensamblador: el valor se evalúa una sola vez como expresión, queda asociado a una etiqueta y NASM rechaza redefinirlo con otro valor, lo que detecta errores en tiempo de ensamblado. `%define`, en cambio, es una sustitución de texto que hace el preprocesador antes de ensamblar una sola instrucción; NASM no sabe que el nombre representa un número, solo pega los caracteres donde aparece. Como `ANCHO_LINEA` se usa como argumento numérico de `TIMES` y podría usarse más adelante en una comparación (`cmp cx, ANCHO_LINEA`), `EQU` es la opción correcta: si se escribiera `%define ANCHO_LINEA 30+10`, la expresión `ANCHO_LINEA*2` se expandiría a `30+10*2 = 50` y no a 80, un error silencioso de precedencia que `EQU` evita porque evalúa la expresión completa antes de usarla. `%define` sí sería preferible para fragmentos de texto reutilizados literalmente, por ejemplo `%define FIN_CADENA 0Dh, 0Ah, 24h`, que se pega al final de cada `db`, o para un nombre alternativo de registro como `%define PUNTERO si`; en esos casos lo que se necesita es justamente sustituir texto, no un valor.

### Decisión 2: TIMES en .data frente a RESB con relleno en tiempo de ejecución

`TIMES ANCHO_LINEA DB '='` es preferible a escribir los 40 caracteres a mano dentro de un literal `DB` porque el ancho aparece en un único lugar del código fuente: cambiar la línea a 60 caracteres implica editar un número, no contar y teclear signos, con el riesgo de equivocarse en uno. La alternativa de reservar `RESB 40` en `.bss` y llenarlo con un bucle `LOOP` al inicio de `main` funcionaría, porque produce los mismos bytes en memoria antes de imprimir, pero en este caso es innecesaria: el contenido de la línea es fijo y se conoce en el momento de ensamblar, así que no hay ningún dato de tiempo de ejecución que justifique construirlo dinámicamente. La diferencia de costo está en el arranque: con `TIMES`, los 40 bytes ya forman parte de la imagen del ejecutable y DOS los carga junto con el resto de `.data`, sin ejecutar ninguna instrucción adicional. Con `RESB` más bucle, cada ejecución gasta alrededor de 120 instrucciones (un `MOV`, un `INC` y un `LOOP` por cada uno de los 40 bytes) más la inicialización de `CX`, `SI` y `AL`, además de los bytes de código del propio bucle. `RESB` solo se justifica cuando el contenido depende de datos que se conocen en tiempo de ejecución.

## Decisiones técnicas — Parte 2

### Decisión 3: %rep frente a LOOP para un número fijo de repeticiones

`bloque_decorativo` siempre se invoca con un número pequeño de copias que se conoce al escribir el programa (3), por lo que `%rep` es una alternativa razonable a `repetir_str`: el preprocesador duplica el cuerpo tres veces y el resultado son tres expansiones de `print_str` consecutivas. Cada expansión ocupa unos 9 bytes (`push ax`, `mov ah,09h`, `mov dx,imm16`, `int 21h`, `pop ax`), así que tres copias suman unos 27 bytes, un tamaño comparable al de la versión con bucle. Con 1000 copias el costo crecería linealmente hasta unos 9000 bytes de código, casi 9 KB dentro de un segmento de 64 KB, mientras que `repetir_str` ocupa el mismo tamaño fijo (unos 12 bytes) sin importar el número de repeticiones. Si el número de repeticiones se leyera en tiempo de ejecución, por ejemplo con `leer_char`, `%rep` dejaría de ser posible, porque el preprocesador necesita un valor constante antes de ensamblar y no puede conocer una tecla pulsada después. En ese caso, `repetir_str` sería la única opción correcta: carga el valor en `CX` y repite con `LOOP`. En el listado `programa2.lst`, la expansión de `repetir_str` contiene `mov cx, 3` y `loop ..@N.ciclo` (`E2 F7`), mientras que la de `bloque_decorativo` no contiene `CX`, `LOOP` ni comparaciones. Esa ausencia es justamente el costo cero en tiempo de ejecución que ofrece `%rep`: no se decrementa ningún contador ni se evalúa ningún salto.

### Decisión 4: ¿necesitan etiquetas locales %% las extensiones de los pasos 7 y 8?

`bloque_decorativo` no necesita ninguna etiqueta porque su cuerpo no contiene saltos: `%rep` copia instrucciones lineales (`print_str`) que se ejecutan una tras otra, y no hay ningún punto al que haya que regresar o saltar. Aunque la macro se invoque varias veces, cada expansión solo genera instrucciones sin nombre, y por eso no puede haber símbolos duplicados. La situación cambiaría si se agregara un salto condicional interno, por ejemplo `cmp bx, 0` seguido de `je` hacia una etiqueta colocada antes de la última copia: desde ese momento la macro definiría un nombre, y dos invocaciones lo definirían dos veces, lo que NASM reporta como símbolo redefinido. Por eso, la sola presencia de un salto hacia una etiqueta dentro del cuerpo exige `%%`, que genera un nombre único (`..@N.nombre`) en cada expansión. `comparar_menor_o_igual`, en cambio, es un procedimiento: su código existe una sola vez en el archivo y se reutiliza con `CALL`, no por expansión. Sus etiquetas con punto (`.menor_o_igual`, `.fin_cmp2`) son locales a la última etiqueta global anterior, así que NASM las registra internamente como `comparar_menor_o_igual.menor_o_igual`, mientras que las de `comparar_e_imprimir` quedan como `comparar_e_imprimir.son_iguales`. Como cada nombre completo se define una sola vez, no hay colisión y el mecanismo `%%`, reservado para macros que se expanden muchas veces, no hace falta.

## Capturas

| Captura | Descripción |
|---|---|
| `capturas/01_compilacion.png` | Ensamblado de `programa.asm` y `programa2.asm` (con listado `-l`) sin errores ni advertencias |
| `capturas/02_ejecucion_parte1.png` | Ejecución de la Parte 1 en DOSBox, con la línea de 40 "=" generada con `TIMES` |
| `capturas/03_listado_macros.png` | Extracto de `programa2.lst` con las expansiones de `repetir_str`, `bloque_decorativo` (`%rep`) y `fin_dos` |
| `capturas/04_ejecucion_parte2.png` | Ejecución completa de la Parte 2 en DOSBox, incluidos el bloque `%rep` y `comparar_menor_o_igual` |

Las capturas de ejecución corresponden a una compilación de verificación en formato `.COM` (`nasm -f bin`, con `org 100h`) del mismo código fuente, ejecutada en DOSBox 0.74; la salida es idéntica a la del `.exe` enlazado con ALINK.
