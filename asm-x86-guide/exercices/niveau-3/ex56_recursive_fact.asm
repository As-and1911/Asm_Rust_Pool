; =============================================================================
; Exercice 56 — Factorielle récursive
; =============================================================================
; Consigne :
; Calcule fact(5) = 120 récursivement.
; fact(n) = n <= 1 ? 1 : n * fact(n - 1)
;
; Sortie attendue : exit code = 120
; =============================================================================

section .text
    global _start

fact:
    ; TODO: Ton code récursif ici
    ret

_start:
    mov     rdi, 5
    call    fact

    mov     rdi, rax
    mov     rax, 60
    syscall
