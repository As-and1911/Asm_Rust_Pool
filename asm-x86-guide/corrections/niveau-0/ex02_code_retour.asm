; =============================================================================
; CORRECTION — Exercice 2 : Code de retour 42
; =============================================================================

section .text
    global _start

_start:
    mov     rax, 60             ; syscall exit
    mov     rdi, 42             ; code de retour = 42
    syscall
