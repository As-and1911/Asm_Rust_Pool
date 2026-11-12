; =============================================================================
; CORRECTION — Exercice 53 : Variables locales sur la pile
; =============================================================================

section .text
    global _start

calc_locals:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16             ; Alloue 16 octets (maintient l'alignement sur 16 !)

    mov     qword [rbp - 8], 30
    mov     qword [rbp - 16], 12

    mov     rax, [rbp - 8]
    add     rax, [rbp - 16]

    leave                       ; mov rsp, rbp + pop rbp
    ret

_start:
    call    calc_locals
    mov     rdi, rax
    mov     rax, 60
    syscall
