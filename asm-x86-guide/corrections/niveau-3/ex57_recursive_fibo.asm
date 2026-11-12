; =============================================================================
; CORRECTION — Exercice 57 : Fibonacci récursif
; =============================================================================

section .text
    global _start

fibo:
    cmp     rdi, 1
    jle     .base_case

    push    rbx                 ; Callee-saved utilisé pour cumuler
    push    rdi                 ; Sauvegarde n

    dec     rdi                 ; n - 1
    call    fibo                ; rax = fibo(n - 1)
    mov     rbx, rax            ; Sauvegarde fibo(n - 1) dans rbx

    mov     rdi, [rsp]          ; Récupère n original sans le dépiler
    sub     rdi, 2              ; n - 2
    call    fibo                ; rax = fibo(n - 2)

    add     rax, rbx            ; rax = fibo(n - 1) + fibo(n - 2)

    pop     rdi
    pop     rbx
    ret

.base_case:
    mov     rax, rdi
    ret

_start:
    mov     rdi, 6
    call    fibo

    mov     rdi, rax
    mov     rax, 60
    syscall
