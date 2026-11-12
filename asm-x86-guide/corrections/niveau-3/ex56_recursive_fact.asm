; =============================================================================
; CORRECTION — Exercice 56 : Factorielle récursive
; =============================================================================

section .text
    global _start

fact:
    cmp     rdi, 1
    jle     .base_case

    push    rdi                 ; Sauvegarde n
    dec     rdi                 ; n - 1
    call    fact                ; rax = fact(n - 1)
    pop     rdi                 ; Restaure n
    imul    rax, rdi            ; rax = fact(n - 1) * n
    ret

.base_case:
    mov     rax, 1
    ret

_start:
    mov     rdi, 5
    call    fact

    mov     rdi, rax
    mov     rax, 60
    syscall
