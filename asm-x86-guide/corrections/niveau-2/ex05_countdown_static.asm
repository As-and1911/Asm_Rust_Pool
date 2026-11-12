; =============================================================================
; CORRECTION — Exercice 05 : Compte à rebours statique
; =============================================================================

section .data
    countdown   db "3 2 1 0", 10
    cd_len      equ $ - countdown

section .text
    global _start

_start:
    mov     rax, 1              ; sys_write
    mov     rdi, 1              ; stdout
    mov     rsi, countdown
    mov     rdx, cd_len
    syscall

    mov     rax, 60             ; sys_exit
    xor     rdi, rdi
    syscall
