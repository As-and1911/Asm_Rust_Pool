; =============================================================================
; Exercice 07 — Shift & Multiplication
; =============================================================================
; Consigne :
; Multiplier 5 par 10 sans utiliser l'instruction 'mul' ni 'imul'.
; Utilise exclusivement 'shl' et 'add'.
; Quitte avec le résultat dans rdi.
;
; Sortie attendue : code de retour = 50
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60             ; sys_exit
    syscall
