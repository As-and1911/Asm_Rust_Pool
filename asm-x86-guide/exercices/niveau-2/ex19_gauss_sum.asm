; =============================================================================
; Exercice 19 — Somme de Gauss : n * (n + 1) / 2
; =============================================================================
; Consigne :
; Soit n = 10. Calcule 10 * 11 / 2 = 55 sans boucle.
; Place le résultat dans rdi et quitte avec exit.
;
; Sortie attendue : exit code = 55
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
