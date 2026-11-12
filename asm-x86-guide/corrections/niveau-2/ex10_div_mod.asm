; =============================================================================
; CORRECTION — Exercice 10 : Division et Modulo (100 % 7)
; =============================================================================

section .text
    global _start

_start:
    mov     rax, 100
    xor     rdx, rdx            ; RDX doit être nul avant DIV
    mov     rbx, 7
    div     rbx                 ; rax = 14 (quotient), rdx = 2 (reste)

    mov     rdi, rdx            ; code retour = 2 (modulo)
    mov     rax, 60             ; sys_exit
    syscall
