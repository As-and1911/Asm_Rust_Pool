; =============================================================================
; CORRECTION — Exercice 07 : Longueur de chaîne via EQU
; =============================================================================

section .data
    msg         db "Assembleur x86_64 Epitech!"
    msg_len     equ $ - msg     ; Vaut 26 octets

section .text
    global _start

_start:
    ; Afficher la chaîne
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg
    mov     rdx, msg_len
    syscall

    ; Quitter avec la longueur comme exit code
    mov     rax, 60
    mov     rdi, msg_len        ; 26
    syscall
