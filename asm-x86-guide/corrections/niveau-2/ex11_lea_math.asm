; =============================================================================
; CORRECTION — Exercice 11 : Polynôme LEA (9x + 7 avec x = 5)
; =============================================================================

section .text
    global _start

_start:
    mov     rdi, 5

    ; 9*rdi + 7 = rdi + 8*rdi + 7
    lea     rax, [rdi + rdi * 8 + 7]    ; rax = 5 + 40 + 7 = 52

    mov     rdi, rax
    mov     rax, 60             ; sys_exit
    syscall
