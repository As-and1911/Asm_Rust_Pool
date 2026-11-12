; =============================================================================
; CORRECTION — Exercice 02 : Putstr sur stderr
; =============================================================================

section .data
    err_msg     db "Erreur: fichier introuvable.", 10
    err_len     equ $ - err_msg

section .text
    global _start

_start:
    ; sys_write(2, err_msg, err_len)
    mov     rax, 1              ; syscall write
    mov     rdi, 2              ; stderr
    mov     rsi, err_msg
    mov     rdx, err_len
    syscall

    ; sys_exit(1)
    mov     rax, 60
    mov     rdi, 1
    syscall
