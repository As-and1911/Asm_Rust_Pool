; =============================================================================
; Exercice 57 — Fibonacci récursif
; =============================================================================
; Consigne :
; fibo(n) = n < 2 ? n : fibo(n - 1) + fibo(n - 2)
; Calcule fibo(6) = 8.
;
; Sortie attendue : exit code = 8
; =============================================================================

section .text
    global _start

fibo:
    ; TODO: Ton code ici
    ret

_start:
    mov     rdi, 6
    call    fibo

    mov     rdi, rax
    mov     rax, 60
    syscall
