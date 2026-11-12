; =============================================================================
; CORRECTION — Exercice 07 : Multiplication par 10 via SHL / ADD
; 5 * 10 = (5 * 8) + (5 * 2) = (5 << 3) + (5 << 1) = 40 + 10 = 50
; =============================================================================

section .text
    global _start

_start:
    mov     rax, 5              ; Valeur initiale

    mov     rbx, rax            ; Sauvegarde pour le x2
    shl     rax, 3              ; rax = 5 << 3 = 40

    shl     rbx, 1              ; rbx = 5 << 1 = 10

    add     rax, rbx            ; rax = 40 + 10 = 50
    mov     rdi, rax            ; code de retour

    mov     rax, 60             ; sys_exit
    syscall
