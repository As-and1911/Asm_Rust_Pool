; =============================================================================
; CORRECTION — Exercice 14 : Gestion de drapeaux de permission
; Bit 0 (0x01) = Exécution (X)
; Bit 1 (0x02) = Écriture (W)
; Bit 2 (0x04) = Lecture (R)
; =============================================================================

section .text
    global _start

_start:
    xor     rdi, rdi            ; Permissions initiales : 0

    ; Activer Lecture (0x04) et Exécution (0x01)
    or      rdi, (0x04 | 0x01)  ; rdi = 0b0101 = 5

    ; Désactiver Exécution (bit 0) : AND avec le complément du bit 0 (~0x01)
    and     rdi, ~0x01          ; rdi = 0b0100 = 4 (Lecture seule)

    mov     rax, 60             ; sys_exit
    syscall
