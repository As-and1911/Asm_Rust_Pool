; =============================================================================
; Projet  : my_calculator
; Fichier : my_calculator.asm
; Auteur  : Antigravity Senior Engineer
; Desc    : Calculatrice arithmétique en assembleur pur (NASM x86_64)
; =============================================================================

section .data
    ; Paramètres par défaut (peuvent être surchargés à la compilation avec -D)
%ifndef OP_A
    %define OP_A 6
%endif
%ifndef OP_B
    %define OP_B 7
%endif
%ifndef OP_TYPE
    %define OP_TYPE '*'     ; '+', '-', '*', '/', '%'
%endif

    err_div0    db "Error: Division by zero.", 10
    err_len     equ $ - err_div0

section .bss
    num_buf     resb 32     ; Tampon pour itoa

section .text
    global _start

_start:
    mov     rax, OP_A
    mov     rbx, OP_B
    mov     cl, OP_TYPE

    ; --- Dispatch selon l'opérateur ---
    cmp     cl, '+'
    je      .do_add
    cmp     cl, '-'
    je      .do_sub
    cmp     cl, '*'
    je      .do_mul
    cmp     cl, '/'
    je      .do_div
    cmp     cl, '%'
    je      .do_mod
    jmp     .do_add         ; Par défaut

.do_add:
    add     rax, rbx
    jmp     .print_result

.do_sub:
    sub     rax, rbx
    jmp     .print_result

.do_mul:
    imul    rax, rbx
    jmp     .print_result

.do_div:
    ; Sécurité : vérification diviseur nul
    test    rbx, rbx
    jz      .err_div_zero
    xor     rdx, rdx
    div     rbx
    jmp     .print_result

.do_mod:
    test    rbx, rbx
    jz      .err_div_zero
    xor     rdx, rdx
    div     rbx
    mov     rax, rdx        ; On garde le reste
    jmp     .print_result

.err_div_zero:
    ; Écriture sur stderr (fd = 2)
    mov     rax, 1
    mov     rdi, 2
    mov     rsi, err_div0
    mov     rdx, err_len
    syscall

    ; Sortie code 84
    mov     rax, 60
    mov     rdi, 84
    syscall

; -----------------------------------------------------------------------------
; Routine itoa : convertit le nombre non signé dans RAX en ASCII et l'affiche
; -----------------------------------------------------------------------------
.print_result:
    lea     rsi, [num_buf + 31]     ; Pointeur sur la fin du buffer
    mov     byte [rsi], 10          ; Placer le saut de ligne '\n' à la fin
    dec     rsi

    ; Cas particulier si rax == 0
    test    rax, rax
    jnz     .convert_loop
    mov     byte [rsi], '0'
    dec     rsi
    jmp     .write_out

.convert_loop:
    test    rax, rax
    jz      .write_out
    xor     rdx, rdx
    mov     rcx, 10
    div     rcx                     ; rax = rax / 10, rdx = reste
    add     dl, '0'                 ; conversion en caractère ASCII
    mov     [rsi], dl
    dec     rsi
    jmp     .convert_loop

.write_out:
    inc     rsi                     ; Repositionner sur le premier caractère

    ; Calculer la longueur : (num_buf + 32) - rsi
    lea     rdx, [num_buf + 32]
    sub     rdx, rsi

    ; write(1, rsi, rdx)
    mov     rax, 1
    mov     rdi, 1
    syscall

    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall
