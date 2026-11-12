; =============================================================================
; CORRECTION — Exercice 09 : MUL Simple (6 * 7)
; =============================================================================

section .text
    global _start

_start:
    mov     rax, 6
    mov     rbx, 7
    mul     rbx                 ; RDX:RAX = 6 * 7 = 42

    mov     rdi, rax            ; code retour 42
    mov     rax, 60             ; sys_exit
    syscall
