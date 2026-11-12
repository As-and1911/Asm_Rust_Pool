; =============================================================================
; Exercice 05 — Compte à rebours statique
; =============================================================================
; Consigne :
; Affiche la chaîne "3 2 1 0\n" en un seul syscall write, puis quitte avec 0.
; =============================================================================

section .data
    ; TODO: Déclare la chaîne ici

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    xor     rdi, rdi
    syscall
