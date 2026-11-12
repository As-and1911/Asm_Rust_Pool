; =============================================================================
; CORRECTION — Exercice 63 : Tours de Hanoï H(N) = 2*H(N-1) + 1
; =============================================================================

section .text
    global _start

hanoi:
    cmp     rdi, 1
    jle     .base_case

    dec     rdi                 ; N - 1
    call    hanoi               ; rax = H(N - 1)
    lea     rax, [rax * 2 + 1]  ; rax = 2 * H(N - 1) + 1
    ret

.base_case:
    mov     rax, 1
    ret

_start:
    mov     rdi, 5
    call    hanoi

    mov     rdi, rax
    mov     rax, 60
    syscall
