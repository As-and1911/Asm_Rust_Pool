; =============================================================================
; Exercice 10 — Détection de parité
; =============================================================================
; Consigne :
; Mets 43 dans rax. Isole son bit de parité (bit 0) dans rdi en utilisant 'and'.
; Quitte avec exit(rdi).
;
; Sortie attendue : code de retour = 1
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
