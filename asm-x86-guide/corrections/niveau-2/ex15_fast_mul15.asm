; =============================================================================
; CORRECTION — Exercice 15 : Multiplier par 15 sans MUL
; 15x = 16x - x = (x << 4) - x
; =============================================================================

section .text
    global _start

_start:
    mov     rax, 4              ; x = 4
    mov     rbx, rax            ; sauvegarde de x
    shl     rax, 4              ; rax = 4 * 16 = 64
    sub     rax, rbx            ; rax = 64 - 4 = 60

    mov     rdi, rax
    mov     rax, 60             ; sys_exit
    syscall
