; =============================================================================
; Exercice 15 — Comptage de bits à un (Popcount manuel)
; =============================================================================
; Consigne :
; Compte sans boucle les bits à un de la valeur 00101101b.
; Place le compteur dans rdi et quitte avec exit.
;
; Sortie attendue : code de retour = 4
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
