; =============================================================================
; CORRECTION — Exercice 08 : Caractère dynamique calculé
; =============================================================================

section .bss
    buffer      resb 2          ; 1 octet pour le caractère + 1 pour '\n'

section .text
    global _start

_start:
    ; Calcul du caractère : 'A' (0x41) + 3 = 'D' (0x44)
    mov     al, 'A'
    add     al, 3

    ; Écriture dans le buffer
    mov     byte [buffer], al
    mov     byte [buffer + 1], 10       ; Saut de ligne '\n'

    ; Affichage via write(1, buffer, 2)
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, buffer
    mov     rdx, 2
    syscall

    ; Sortie propre
    mov     rax, 60
    xor     rdi, rdi
    syscall
