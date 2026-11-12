# apellido-post1-u4

## Descripción

Laboratorio de la Unidad 4 de Arquitectura de Computadores (UFPS). El repositorio contiene dos programas en lenguaje ensamblador NASM para DOS de 16 bits:

- **Parte 1 (`programa.asm`)**: programa con las secciones `.data`, `.bss` y `.text`, directivas de datos (`DB`, `DW`, `DD`, `RESB`, `RESW`, `TIMES`), constantes `EQU` y salida por pantalla con las funciones `09h` y `02h` de `INT 21h`.
- **Parte 2 (`macros.asm` + `programa2.asm`)**: biblioteca de macros con parámetros y etiquetas locales `%%`, una macro desenrollada con `%rep`, un bucle acumulador con `LOOP` y dos procedimientos condicionales con `CMP`/`Jcc` (`JE`/`JG` y `JLE`).

## Prerrequisitos

- DOSBox 0.74 o superior
- NASM 2.14 o superior (`nasm.exe` en la carpeta de trabajo)
- ALINK (`alink.exe` en la carpeta de trabajo)
- Editor de texto plano; los `.asm` se guardan en ASCII sin BOM

## Compilación y ejecución

```
nasm -f obj programa.asm -o programa.obj
alink programa.obj -oEXE -o programa.exe -entry main
```

Ejecutar programa.exe dentro de DOSBox.
