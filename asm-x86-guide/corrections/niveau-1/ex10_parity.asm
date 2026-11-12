; =============================================================================
; CORRECTION — Exercice 10 : Détection de parité
; 43 est impair -> bit 0 est à 1
; =============================================================================

section .text
    global _start

_start:
    mov     rax, 43
    mov     rdi, rax
    and     rdi, 1              ; Isole le bit 0 : rdi = 1 si impair, 0 si pair

    mov     rax, 60             ; sys_exit
    syscall
