; =============================================================================
; Exercice 13 — Extraction Little-Endian
; =============================================================================
; Consigne :
; La variable 'val' contient 0x11223344.
; Charge l'octet 0x33 (soit 51 en décimal) dans le registre dil.
; Quitte avec exit(rdi).
;
; Sortie attendue : code de retour = 51
; =============================================================================

section .data
    val dd 0x11223344

section .text
    global _start

_start:
    xor     rdi, rdi
    ; TODO: Charge l'octet [val + ?] dans dil

    mov     rax, 60
    syscall
