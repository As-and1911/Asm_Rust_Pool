; =============================================================================
; CORRECTION — Exercice 13 : Moyenne entière (15 + 25 + 35) / 3
; =============================================================================

section .text
    global _start

_start:
    mov     rax, 15
    add     rax, 25
    add     rax, 35             ; rax = 75

    xor     rdx, rdx
    mov     rbx, 3
    div     rbx                 ; rax = 25

    mov     rdi, rax
    mov     rax, 60             ; sys_exit
    syscall
