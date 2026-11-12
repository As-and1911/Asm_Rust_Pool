; =============================================================================
; CORRECTION — Exercice 20 : Extraction de signe sans branchement
; =============================================================================

section .text
    global _start

_start:
    mov     rax, -100           ; Nombre négatif (bit 63 = 1)
    shr     rax, 63             ; Isole le bit 63 dans la position 0 -> rax = 1

    mov     rdi, rax
    mov     rax, 60             ; sys_exit(1)
    syscall
