; =============================================================================
; CORRECTION — Exercice 11 : Complément à deux manuel
; Inverser les bits puis ajouter 1 donne -X
; Pour 10 : NOT(10) + 1 = -10.
; Le code de sortie Linux est tronqué sur 8 bits non signés (256 - 10 = 246).
; =============================================================================

section .text
    global _start

_start:
    mov     rax, 10
    not     rax                 ; Inverse tous les bits (complément à un)
    inc     rax                 ; Ajoute 1 (complément à deux)

    mov     rdi, rax            ; rdi = -10 (0xFFFFFFFFFFFFFFF6)
    mov     rax, 60             ; sys_exit
    syscall
