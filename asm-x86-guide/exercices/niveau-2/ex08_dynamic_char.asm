; =============================================================================
; Exercice 08 — Caractère dynamique calculé
; =============================================================================
; Consigne :
; 1. Démarre avec le caractère 'A' (0x41)
; 2. Ajoute 3 pour obtenir 'D' (0x44)
; 3. Affiche le caractère calculé sur stdout, suivi d'un saut de ligne
; 4. Quitte avec le code 0
;
; Sortie attendue : "D\n"
; =============================================================================

section .bss
    buffer resb 2

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    xor     rdi, rdi
    syscall
