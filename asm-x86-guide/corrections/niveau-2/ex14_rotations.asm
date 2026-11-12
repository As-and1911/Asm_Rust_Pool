; =============================================================================
; CORRECTION — Exercice 14 : Rotation ROL
; =============================================================================

section .text
    global _start

_start:
    mov     al, 10000001b       ; 0x81
    rol     al, 1               ; Le bit 7 (1) tourne et devient le bit 0 -> 00000011b (3)

    movzx   rdi, al             ; rdi = 3
    mov     rax, 60             ; sys_exit
    syscall
