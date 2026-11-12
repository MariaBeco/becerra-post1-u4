; =============================================================================
; programa2.asm - Laboratorio Post1 Unidad 4 (Parte 2)
; Proposito: usar macros con parametros y etiquetas locales (%%), una macro
; basada en %rep, un bucle acumulador con LOOP y dos procedimientos
; condicionales con CMP/Jcc (JE/JG y JLE).
;
; Ensamblado : nasm -f obj programa2.asm -o programa2.obj -l programa2.lst
; Enlazado   : alink programa2.obj -oEXE -o programa2.exe -entry main
; =============================================================================

%include "macros.asm"       ; insertar textualmente la biblioteca de macros

section .data
    titulo          db "=== Macros y Control de Flujo ===", 0Dh, 0Ah, 24h
    linea_a         db "[Linea A] Primera impresion", 0Dh, 0Ah, 24h
    linea_b         db "[Linea B] Segunda impresion", 0Dh, 0Ah, 24h
    msg_suma        db "Suma 1+2+3 = ", 24h
    msg_mayor       db "El valor mayor es: ", 24h
    msg_iguales     db "Los valores son iguales.", 0Dh, 0Ah, 24h
    msg_fin         db "Fin del programa.", 0Dh, 0Ah, 24h

section .bss
    valor_a         resw 1
    valor_b         resw 1

section pila stack
                    resb 256    ; segmento de pila para el EXE

group DGROUP data bss           ; DS cubre .data y .bss

section .text
    global main

main:
    mov  ax, DGROUP             ; NASM no usa @data (sintaxis MASM)
    mov  ds, ax

    ; 1. Encabezado con macro
    print_str titulo

    ; 2. Demostracion de repetir_str (bucle LOOP dentro de la macro)
    repetir_str linea_a, 3
    repetir_str linea_b, 2

    ; 3. Suma 1+2+3 = 6 con el procedimiento sumar_serie
    mov  cx, 3
    call sumar_serie            ; AX = 6
    print_str msg_suma          ; print_str preserva AX
    print_digito                ; imprime "6"
    nueva_linea

    ; 4. Comparar 9 vs 4 -> mayor es 9
    mov  ax, 9
    mov  bx, 4
    call comparar_e_imprimir

    ; 5. Comparar 5 vs 5 -> iguales
    mov  ax, 5
    mov  bx, 5
    call comparar_e_imprimir

    ; 6. Mensaje final y terminacion
    print_str msg_fin
    fin_dos

; -----------------------------------------------------------------------------
; sumar_serie: suma 1 + 2 + ... + N
; Entrada: CX = N      Salida: AX = suma      Preserva: CX
; -----------------------------------------------------------------------------
sumar_serie:
    push cx                     ; LOOP modifica CX
    xor  ax, ax                 ; AX = 0 (acumulador)
.paso:
    add  ax, cx                 ; AX += CX (N, N-1, ..., 1)
    loop .paso                  ; CX--; si CX != 0, continuar
    pop  cx
    ret

; -----------------------------------------------------------------------------
; comparar_e_imprimir: imprime el mayor entre AX y BX, o que son iguales
; Decide con JE / JG (comparacion con signo). Preserva AX y BX.
; -----------------------------------------------------------------------------
comparar_e_imprimir:
    push ax
    push bx

    cmp  ax, bx                 ; flags segun AX - BX
    je   .son_iguales           ; ZF = 1
    jg   .ax_mayor              ; ZF = 0 y SF = OF

    ; Caso: BX es mayor
    print_str msg_mayor
    mov  al, bl                 ; AL = valor de BX
    print_digito
    nueva_linea
    jmp  .fin_comp

.ax_mayor:
    print_str msg_mayor         ; AL conserva el valor de AX (print_str lo preserva)
    print_digito
    nueva_linea
    jmp  .fin_comp

.son_iguales:
    print_str msg_iguales

.fin_comp:
    pop  bx
    pop  ax
    ret
