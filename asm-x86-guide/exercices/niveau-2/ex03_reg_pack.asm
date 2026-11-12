; =============================================================================
; Exercice 03 — Assemblage d'octets dans un registre 16 bits
; =============================================================================
; Consigne :
; Place 0x12 dans ah et 0x34 dans al (pour former ax = 0x1234).
; Place ax dans di (avec zero extension) et quitte avec exit(rdi).
;
; Sortie attendue : code de retour = 52 (valeur de 0x34)
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
