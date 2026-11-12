; =============================================================================
; CORRECTION — Exercice 06 : Extension signée (MOVSX)
; =============================================================================

section .text
    global _start

_start:
    mov     al, -15             ; 0xF1 en hexadécimal
    movsx   rdi, al             ; Étend le signe sur 64 bits (0xFFFFFFFFFFFFFFF1)

    mov     rax, 60             ; sys_exit(rdi) -> code retour 241
    syscall
