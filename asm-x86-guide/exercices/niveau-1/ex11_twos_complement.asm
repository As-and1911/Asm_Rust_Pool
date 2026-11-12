; =============================================================================
; Exercice 11 — Complément à deux manuel
; =============================================================================
; Consigne :
; Mets 10 dans rax.
; Applique manuellement la formule du complément à deux (NOT puis INC).
; Mets le résultat dans rdi et quitte avec exit.
; Note : sous Linux le code de sortie est tronqué sur 8 bits non signés (résultat: 246).
;
; Sortie attendue : code de retour = 246
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
