; =============================================================================
; Exercice 14 — Rotation de bits (ROL)
; =============================================================================
; Consigne :
; Soit al = 10000001b (0x81).
; Fais une rotation de 1 bit vers la gauche avec 'rol al, 1'.
; Le résultat est 00000011b (3).
; Place al dans dil (avec rdi = 0) et quitte avec exit.
;
; Sortie attendue : exit code = 3
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
