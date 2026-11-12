; =============================================================================
; Projet  : Utilitaires Unix
; Fichier : my_echo.asm
; Auteur  : Antigravity Senior Engineer
; Desc    : Implémentation x86_64 pure de echo (sans libc)
; =============================================================================

section .data
    space       db ' '
    newline     db 10

section .text
    global _start

_start:
    mov     r12, [rsp]          ; r12 = argc
    cmp     r12, 1
    jle     .print_nl           ; Si aucun argument, juste afficher \n

    mov     rbx, 1              ; rbx = index de l'argument (commence à 1)

.arg_loop:
    ; Récupère le pointeur de argv[rbx]
    ; rsp + 8*(rbx + 1)
    mov     rsi, [rsp + 8 + rbx * 8]

    ; Calcule la longueur de argv[rbx]
    xor     rdx, rdx
.len_loop:
    cmp     byte [rsi + rdx], 0
    je      .write_arg
    inc     rdx
    jmp     .len_loop

.write_arg:
    ; sys_write(1, rsi, rdx)
    mov     rax, 1
    mov     rdi, 1
    syscall

    inc     rbx
    cmp     rbx, r12
    jge     .print_nl

    ; Afficher l'espace séparateur
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, space
    mov     rdx, 1
    syscall
    jmp     .arg_loop

.print_nl:
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, newline
    mov     rdx, 1
    syscall

    ; sys_exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall
