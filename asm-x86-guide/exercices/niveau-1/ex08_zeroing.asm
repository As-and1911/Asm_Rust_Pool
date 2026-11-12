; =============================================================================
; Exercice 08 — Remise à zéro avec XOR
; =============================================================================
; Consigne :
; Mettre rdi à 0 en utilisant l'instruction xor (pas de 'mov rdi, 0').
; Quitte avec exit(rdi).
;
; Sortie attendue : code de retour = 0
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60             ; sys_exit
    syscall
