; =============================================================================
; CORRECTION — Exercice 1 : Afficher ton nom
; =============================================================================

section .data
    nom     db "Jean Dupont", 10        ; Remplace par ton vrai nom !
    nom_len equ $ - nom

section .text
    global _start

_start:
    mov     rax, 1              ; write
    mov     rdi, 1              ; stdout
    mov     rsi, nom            ; adresse de la chaîne
    mov     rdx, nom_len        ; longueur
    syscall

    mov     rax, 60             ; exit
    xor     rdi, rdi            ; code 0
    syscall
