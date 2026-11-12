; =============================================================================
; Exercice 16 — Conversion caractère ASCII vers chiffre numérique
; =============================================================================
; Consigne :
; Le caractère ASCII '7' a pour code 55 (0x37).
; Soustrais le code de '0' (48) pour obtenir le chiffre 7.
; Quitte avec ce code de retour dans rdi.
;
; Sortie attendue : exit code = 7
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
