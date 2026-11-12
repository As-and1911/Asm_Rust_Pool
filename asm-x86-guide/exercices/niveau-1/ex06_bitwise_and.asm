; =============================================================================
; Exercice 06 — Bitwise AND
; =============================================================================
; Consigne :
; 1. Initialise rdi avec 0xF0
; 2. Fais un 'and' bit à bit avec 0x3C
; 3. Quitte avec le syscall 60 (exit)
;
; Sortie attendue : code de retour = 48
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60             ; sys_exit
    syscall
