; =============================================================================
; CORRECTION — Exercice 3 : Affichage multi-lignes
; =============================================================================

section .data
    ligne1      db "Ligne 1 : Bonjour !", 10
    ligne1_len  equ $ - ligne1
    ligne2      db "Ligne 2 : Je fais de l'assembleur.", 10
    ligne2_len  equ $ - ligne2
    ligne3      db "Ligne 3 : Et c'est genial !", 10
    ligne3_len  equ $ - ligne3

section .text
    global _start

_start:
    ; Afficher ligne 1
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, ligne1
    mov     rdx, ligne1_len
    syscall

    ; Afficher ligne 2
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, ligne2
    mov     rdx, ligne2_len
    syscall

    ; Afficher ligne 3
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, ligne3
    mov     rdx, ligne3_len
    syscall

    ; Quitter
    mov     rax, 60
    xor     rdi, rdi
    syscall
