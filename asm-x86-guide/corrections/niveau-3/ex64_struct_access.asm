; =============================================================================
; CORRECTION — Exercice 64 : Accès Structure Point { x, y }
; =============================================================================

section .data
    point_test:
        dq 3            ; x (offset 0)
        dq 4            ; y (offset 8)

section .text
    global _start

get_dist_sq:
    mov     rax, [rdi]          ; x
    imul    rax, rax            ; x^2
    mov     rcx, [rdi + 8]      ; y
    imul    rcx, rcx            ; y^2
    add     rax, rcx            ; x^2 + y^2
    ret

_start:
    mov     rdi, point_test
    call    get_dist_sq

    mov     rdi, rax
    mov     rax, 60
    syscall
