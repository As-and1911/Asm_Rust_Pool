; =============================================================================
; CORRECTION — Exercice 16 : ASCII vers Chiffre
; =============================================================================

section .text
    global _start

_start:
    mov     al, '7'             ; Code ASCII 55
    sub     al, '0'             ; 55 - 48 = 7

    movzx   rdi, al             ; rdi = 7
    mov     rax, 60             ; sys_exit
    syscall
