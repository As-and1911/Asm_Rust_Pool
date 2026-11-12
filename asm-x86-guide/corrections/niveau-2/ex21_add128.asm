; =============================================================================
; CORRECTION — Exercice 21 : Addition 128 bits avec Retenue (ADC)
; =============================================================================

section .text
    global _start

_start:
    ; A = 1 : 0xFFFFFFFFFFFFFFFF (rdx:rax)
    mov     rdx, 1
    mov     rax, 0xFFFFFFFFFFFFFFFF

    ; B = 0 : 1 (rbx:rcx)
    xor     rbx, rbx
    mov     rcx, 1

    ; Addition 64 bits de poids faible -> Déclenche Carry Flag = 1
    add     rax, rcx            ; rax déborde à 0, CF = 1

    ; Addition 64 bits de poids fort avec propagation de retenue
    adc     rdx, rbx            ; rdx = 1 + 0 + CF(1) = 2

    mov     rdi, rdx            ; exit(2)
    mov     rax, 60
    syscall
