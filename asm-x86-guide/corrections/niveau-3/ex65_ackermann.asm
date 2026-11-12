; =============================================================================
; CORRECTION — Exercice 65 : Fonction d'Ackermann A(m, n)
; =============================================================================

section .text
    global _start

ackermann:
    test    rdi, rdi            ; if m == 0
    jnz     .m_gt_zero
    lea     rax, [rsi + 1]      ; return n + 1
    ret

.m_gt_zero:
    test    rsi, rsi            ; if n == 0
    jnz     .both_gt_zero
    dec     rdi                 ; m - 1
    mov     rsi, 1              ; n = 1
    jmp     ackermann           ; Tail call optimization ! A(m - 1, 1)

.both_gt_zero:
    push    rdi                 ; Sauvegarde m
    dec     rsi                 ; n - 1
    call    ackermann           ; rax = A(m, n - 1)

    pop     rdi                 ; Restaure m
    dec     rdi                 ; m - 1
    mov     rsi, rax            ; n = A(m, n - 1)
    jmp     ackermann           ; A(m - 1, A(m, n - 1))

_start:
    mov     rdi, 2
    mov     rsi, 2
    call    ackermann

    mov     rdi, rax
    mov     rax, 60
    syscall
