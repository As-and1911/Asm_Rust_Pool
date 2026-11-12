; =============================================================================
; CORRECTION — Exercice 52 : func_linear(a, b, c, d) = (a * b) + (c * d)
; =============================================================================

section .text
    global _start

func_linear:
    imul    rdi, rsi            ; rdi = a * b
    imul    rdx, rcx            ; rdx = c * d
    lea     rax, [rdi + rdx]    ; rax = (a * b) + (c * d)
    ret

_start:
    mov     rdi, 2
    mov     rsi, 3
    mov     rdx, 4
    mov     rcx, 5
    call    func_linear

    mov     rdi, rax
    mov     rax, 60
    syscall
