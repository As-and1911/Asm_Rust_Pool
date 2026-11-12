; =============================================================================
; Exercice 15 — Multiplication rapide par 15
; =============================================================================
; Consigne :
; Soit x = 4 dans rax.
; Calcule 15 * x sans instruction mul ni imul.
; Astuce : 15x = 16x - x = (x << 4) - x
; Retourne le résultat dans rdi.
;
; Sortie attendue : exit code = 60
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
