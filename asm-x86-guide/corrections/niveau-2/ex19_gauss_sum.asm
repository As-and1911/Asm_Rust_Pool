; =============================================================================
; CORRECTION — Exercice 19 : Somme de Gauss (n * (n + 1) / 2)
; Pour n = 10 : 10 * 11 / 2 = 55
; =============================================================================

section .text
    global _start

_start:
    mov     rax, 10             ; n = 10
    lea     rbx, [rax + 1]      ; n + 1 = 11

    mul     rbx                 ; rdx:rax = 10 * 11 = 110
    shr     rax, 1              ; rax = 110 / 2 = 55 (plus rapide que div !)

    mov     rdi, rax
    mov     rax, 60             ; sys_exit(55)
    syscall
