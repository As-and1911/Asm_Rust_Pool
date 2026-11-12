; =============================================================================
; Exercice 06 — Extension signée (MOVSX)
; =============================================================================
; Consigne :
; Place le nombre signé -15 dans al.
; Étend ce nombre dans rdi avec 'movsx'.
; Appelle sys_exit (60).
;
; Sortie attendue : code retour = 241 (-15 mod 256)
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
