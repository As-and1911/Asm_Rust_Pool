; =============================================================================
; CORRECTION — Exercice 18 : Test Puissance de 2 (N & (N - 1))
; =============================================================================

section .text
    global _start

_start:
    mov     rax, 16             ; 16 est une puissance de 2 (0b00010000)
    mov     rbx, rax
    dec     rbx                 ; rbx = 15 (0b00001111)

    and     rax, rbx            ; rax = 16 & 15 = 0

    ; Si rax == 0, c'est une puissance de 2
    test    rax, rax
    setz    dil                 ; dil = 1 si ZF est allumé (résultat nul)
    movzx   rdi, dil

    mov     rax, 60             ; sys_exit(1)
    syscall
