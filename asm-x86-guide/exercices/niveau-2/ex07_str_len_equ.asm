; =============================================================================
; Exercice 07 — Longueur de chaîne via EQU
; =============================================================================
; Consigne :
; Déclare la chaîne "Assembleur x86_64 Epitech!" en .data.
; Calcule sa longueur avec 'equ $ - msg'.
; Affiche la chaîne via sys_write, puis retourne sa longueur en exit code.
;
; Sortie attendue : exit code = 26 (longueur exacte)
; =============================================================================

section .data
    msg     db "Assembleur x86_64 Epitech!"
    msg_len equ $ - msg

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
