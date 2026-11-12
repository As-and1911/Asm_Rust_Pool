; =============================================================================
; CORRECTION — Exercice 13 : Extraction Little-Endian
; Variable 0x11223344 en mémoire :
; [val + 0] = 0x44
; [val + 1] = 0x33  <-- C'est cet octet qu'on extrait ! (0x33 = 51 en décimal)
; [val + 2] = 0x22
; [val + 3] = 0x11
; =============================================================================

section .data
    val     dd 0x11223344

section .text
    global _start

_start:
    xor     rdi, rdi            ; Met rdi à zéro
    mov     dil, [val + 1]      ; Charge l'octet situé à l'adresse val + 1 (soit 0x33 = 51)

    mov     rax, 60             ; sys_exit
    syscall
