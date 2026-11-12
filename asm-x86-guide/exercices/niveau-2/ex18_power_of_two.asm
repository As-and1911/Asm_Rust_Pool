; =============================================================================
; Exercice 18 — Test Puissance de 2
; =============================================================================
; Consigne :
; Soit N = 16 dans rax.
; Formule : N & (N - 1) == 0 si et seulement si N est une puissance de 2.
; Calcule rax & (rax - 1).
; Si le résultat vaut 0, mets rdi = 1 (vrai), sinon rdi = 0.
; Quitte avec exit(rdi).
;
; Sortie attendue : exit code = 1
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
