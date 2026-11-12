; =============================================================================
; Exercice 01 — Afficher un caractère unique ('Z')
; =============================================================================
; Consigne :
; Affiche le caractère 'Z' sans utiliser de section .data.
; Utilise la pile (push) pour allouer le caractère en mémoire et pointe rsi dessus.
; Quitte avec le code 0.
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Pousse 'Z' sur la pile, prépare write(1, rsp, 1) et exit(0)

    mov     rax, 60
    xor     rdi, rdi
    syscall
