; =============================================================================
; macros.asm - Biblioteca de macros utilitarias (Laboratorio Post1 U4, Parte 2)
; Se incluye desde programa2.asm con:  %include "macros.asm"
; Solo contiene definiciones de macros: no genera bytes hasta que se invocan.
; =============================================================================

; -----------------------------------------------------------------------------
; fin_dos: termina el programa DOS con codigo de salida 0 (INT 21h, 4Ch)
; -----------------------------------------------------------------------------
%macro fin_dos 0
    mov  ax, 4C00h
    int  21h
%endmacro

; -----------------------------------------------------------------------------
; nueva_linea: imprime CR + LF con INT 21h, funcion 02h
; Modifica: AH, DL (y AL, que DOS devuelve con el ultimo caracter impreso)
; -----------------------------------------------------------------------------
%macro nueva_linea 0
    mov  ah, 02h
    mov  dl, 0Dh
    int  21h
    mov  dl, 0Ah
    int  21h
%endmacro

; -----------------------------------------------------------------------------
; print_str: imprime una cadena terminada en "$" (INT 21h, funcion 09h)
; %1 = etiqueta de la cadena
; Nota: la funcion 09h devuelve AL = 24h ("$"), por eso la macro preserva AX
; con PUSH/POP; asi el valor que el llamador tenga en AL no se pierde.
; -----------------------------------------------------------------------------
%macro print_str 1
    push ax
    mov  ah, 09h
    mov  dx, %1
    int  21h
    pop  ax
%endmacro

; -----------------------------------------------------------------------------
; print_char: imprime un caracter (INT 21h, funcion 02h)
; %1 = valor ASCII (inmediato o registro de 8 bits)
; -----------------------------------------------------------------------------
%macro print_char 1
    mov  ah, 02h
    mov  dl, %1
    int  21h
%endmacro

; -----------------------------------------------------------------------------
; leer_char: lee un caracter del teclado sin eco (INT 21h, funcion 07h)
; Resultado en AL
; -----------------------------------------------------------------------------
%macro leer_char 0
    mov  ah, 07h
    int  21h
%endmacro

; -----------------------------------------------------------------------------
; repetir_str: imprime una cadena N veces usando LOOP (en tiempo de ejecucion)
; %1 = etiqueta de la cadena, %2 = numero de repeticiones
; %%ciclo genera una etiqueta distinta en cada expansion de la macro.
; -----------------------------------------------------------------------------
%macro repetir_str 2
    mov  cx, %2             ; CX = contador de repeticiones
%%ciclo:                    ; etiqueta local unica por expansion
    mov  ah, 09h
    mov  dx, %1
    int  21h
    loop %%ciclo            ; CX--; si CX != 0, repetir
%endmacro

; -----------------------------------------------------------------------------
; print_digito: imprime como digito ASCII el nibble bajo de AL (valores 0-9)
; Preserva AX.
; -----------------------------------------------------------------------------
%macro print_digito 0
    push ax                 ; preservar AX
    and  al, 0Fh            ; quedarse con el nibble bajo
    add  al, 30h            ; 0 -> "0", ..., 9 -> "9"
    mov  ah, 02h
    mov  dl, al
    int  21h
    pop  ax                 ; restaurar AX
%endmacro

; -----------------------------------------------------------------------------
; bloque_decorativo (Paso 7): imprime separador_corto N veces, desenrollado en
; tiempo de ensamblado con %rep. No usa CX ni LOOP ni etiquetas.
; %1 = numero de copias (constante conocida al ensamblar)
; -----------------------------------------------------------------------------
%macro bloque_decorativo 1
    %rep %1
    print_str separador_corto    ; cada copia es codigo independiente
    %endrep
%endmacro
