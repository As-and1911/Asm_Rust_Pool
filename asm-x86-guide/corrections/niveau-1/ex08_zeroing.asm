; =============================================================================
; CORRECTION — Exercice 08 : Remise à zéro avec XOR
; =============================================================================

section .text
    global _start

_start:
    xor     rdi, rdi            ; rdi = 0 de manière idiomatique et rapide

    mov     rax, 60             ; sys_exit
    syscall
