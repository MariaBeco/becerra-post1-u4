; =============================================================================
; programa.asm - Laboratorio Post1, Unidad 4 (Parte 1)
; Proposito: demostrar las secciones .data, .bss y .text, las directivas de
; datos (DB, DW, DD, RESB, RESW, TIMES), las constantes EQU y la salida por
; pantalla con las funciones 09h y 02h de la interrupcion 21h del DOS.
;
; Ensamblado : nasm -f obj programa.asm -o programa.obj
; Enlazado   : alink programa.obj -oEXE -o programa.exe -entry main
; =============================================================================

; -- Constantes (EQU no reserva memoria: NASM sustituye el valor numerico) ----
CR          EQU  0Dh            ; Carriage Return (retorno de carro)
LF          EQU  0Ah            ; Line Feed (salto de linea)
TERMINADOR  EQU  24h            ; "$": terminador de cadena para INT 21h/09h
ITERACIONES EQU  5              ; numero de elementos de tabla_bytes
ANCHO_LINEA EQU  40             ; ancho de la linea decorativa (Paso 7 y 8)

; -- Datos inicializados ------------------------------------------------------
section .data
    bienvenida  db "=== Laboratorio NASM - Unidad 4 ===", CR, LF, TERMINADOR
    separador   db "----------------------------------------", CR, LF, TERMINADOR

    ; Paso 7: linea de 40 signos "=" generada por NASM en tiempo de ensamblado
    linea_gruesa:
        TIMES ANCHO_LINEA DB '='     ; repite el byte '=' ANCHO_LINEA veces
                          DB CR, LF, TERMINADOR

    etiqueta_a  db "Variable A (word):  ", TERMINADOR
    etiqueta_b  db "Variable B (dword): ", TERMINADOR
    etiqueta_t  db "Tabla de bytes:     ", TERMINADOR
    fin_msg     db "Programa finalizado correctamente.", CR, LF, TERMINADOR

    ; Tipos de datos demostrados
    var_byte    db  42              ; 1 byte con valor 42 (2Ah)
    var_word    dw  1234h           ; 2 bytes con valor 1234h
    var_dword   dd  0DEADBEEFh      ; 4 bytes con valor DEADBEEFh
    tabla_bytes db  1, 2, 3, 4, 5   ; 5 bytes consecutivos (digitos 0-9)

; -- Datos no inicializados ---------------------------------------------------
section .bss
    buffer      resb 80             ; 80 bytes reservados (no usados aun)
    resultado   resw 1              ; 1 word para almacenar un calculo

; -- Pila (el formato EXE de DOS necesita un segmento de pila) ---------------
section pila stack
                resb 256            ; 256 bytes de pila

; .data y .bss se agrupan para que DS cubra ambas secciones con un solo valor.
; (En formato obj, NASM registra .data y .bss como los segmentos "data" y "bss".)
group DGROUP data bss

; -- Codigo ejecutable --------------------------------------------------------
section .text
    global main

main:
    ; Inicializar el registro de segmento de datos.
    ; En NASM no existe @data (es sintaxis MASM/TASM); se usa el grupo DGROUP.
    mov  ax, DGROUP             ; AX = segmento del grupo de datos
    mov  ds, ax                 ; DS apunta a .data/.bss

    ; === Funcion 09h: imprimir cadenas terminadas en "$" ===
    mov  ah, 09h                ; funcion DOS: imprimir cadena
    mov  dx, bienvenida         ; DX = desplazamiento del mensaje
    int  21h                    ; llamar a DOS

    mov  ah, 09h                ; INT 21h/09h devuelve AL=24h; AH se recarga
    mov  dx, separador
    int  21h

    mov  ah, 09h
    mov  dx, etiqueta_a
    int  21h

    ; === Funcion 02h: imprimir un caracter (DL) ===
    mov  al, [var_byte]         ; AL = 42 (2Ah)
    add  al, 30h                ; 42 + 48 = 90 -> "Z" (conversion solo de demo)
    mov  ah, 02h                ; funcion DOS: imprimir caracter de DL
    mov  dl, al
    int  21h

    ; Nueva linea
    mov  ah, 02h
    mov  dl, CR
    int  21h
    mov  dl, LF
    int  21h

    ; === Recorrer tabla_bytes e imprimir cada elemento ===
    mov  ah, 09h
    mov  dx, etiqueta_t
    int  21h

    lea  si, [tabla_bytes]      ; SI apunta al inicio de la tabla
    mov  cx, ITERACIONES        ; CX = 5 iteraciones

imprimir_tabla:
    mov  al, [si]               ; AL = byte actual
    add  al, 30h                ; conversion a ASCII (valida para 0-9)
    mov  ah, 02h
    mov  dl, al
    int  21h

    mov  ah, 02h                ; espacio entre elementos
    mov  dl, 20h
    int  21h

    inc  si                     ; siguiente byte
    loop imprimir_tabla         ; CX--; si CX != 0, repetir

    ; Nueva linea despues de la tabla
    mov  ah, 02h
    mov  dl, CR
    int  21h
    mov  dl, LF
    int  21h

    ; Mensaje final
    mov  ah, 09h
    mov  dx, fin_msg
    int  21h

    ; === Paso 7: linea decorativa generada con TIMES ===
    mov  ah, 09h
    mov  dx, linea_gruesa
    int  21h

    ; Terminar el programa
    mov  ax, 4C00h              ; funcion DOS 4Ch: terminar, codigo 0
    int  21h
