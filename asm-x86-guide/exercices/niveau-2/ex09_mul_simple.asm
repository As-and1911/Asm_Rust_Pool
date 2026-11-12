; =============================================================================
; Exercice 09 — Multiplication simple avec MUL
; =============================================================================
; Consigne :
; Multiplie 6 (dans rax) par 7 (dans rbx) avec 'mul rbx'.
; Quitte avec le résultat dans rdi.
;
; Sortie attendue : exit code = 42
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
