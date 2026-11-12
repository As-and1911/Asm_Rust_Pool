; =============================================================================
; CORRECTION — Exercice 06 : Bitwise AND
; rdi = 0xF0 & 0x3C = 0x30 = 48
; =============================================================================

section .text
    global _start

_start:
    mov     rdi, 0xF0
    and     rdi, 0x3C           ; rdi devient 0x30 (48 en décimal)

    mov     rax, 60             ; sys_exit
    syscall
