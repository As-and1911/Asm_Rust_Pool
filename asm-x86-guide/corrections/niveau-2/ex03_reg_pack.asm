; =============================================================================
; CORRECTION — Exercice 03 : Assemblage de registres 8b vers 16b
; =============================================================================

section .text
    global _start

_start:
    mov     ah, 0x12            ; Partie haute de ax
    mov     al, 0x34            ; Partie basse de ax (ax = 0x1234)

    movzx   rdi, al             ; Place al (0x34 = 52) dans rdi pour exit

    mov     rax, 60
    syscall
