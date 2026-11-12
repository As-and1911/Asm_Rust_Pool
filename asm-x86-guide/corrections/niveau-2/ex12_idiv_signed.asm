; =============================================================================
; CORRECTION — Exercice 12 : Division Signée (-50 / 4)
; =============================================================================

section .text
    global _start

_start:
    mov     rax, -50
    cqo                         ; Étend le bit de signe de RAX dans RDX
    mov     rbx, 4
    idiv    rbx                 ; rax = -12, rdx = -2

    mov     rdi, rax            ; rdi = -12 (mod 256 = 244)
    mov     rax, 60             ; sys_exit
    syscall
