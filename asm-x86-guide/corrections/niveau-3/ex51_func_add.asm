; =============================================================================
; CORRECTION — Exercice 51 : add2(a, b)
; =============================================================================

section .text
    global _start

add2:
    mov     rax, rdi
    add     rax, rsi
    ret

_start:
    mov     rdi, 18
    mov     rsi, 24
    call    add2

    mov     rdi, rax
    mov     rax, 60
    syscall
