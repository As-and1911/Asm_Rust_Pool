; =============================================================================
; Exercice 02 — Afficher sur stderr
; =============================================================================
; Consigne :
; Affiche "Erreur: fichier introuvable.\n" sur stderr (File descriptor 2).
; Quitte avec le code de sortie 1.
; =============================================================================

section .data
    err_msg     db "Erreur: fichier introuvable.", 10
    err_len     equ $ - err_msg

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    mov     rdi, 1
    syscall
