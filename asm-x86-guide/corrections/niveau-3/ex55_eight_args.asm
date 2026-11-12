; =============================================================================
; CORRECTION — Exercice 55 : Fonction à 8 paramètres
; =============================================================================

section .text
    global _start

sum8:
    push    rbp
    mov     rbp, rsp

    ; Somme des 6 premiers paramètres dans les registres
    mov     rax, rdi
    add     rax, rsi
    add     rax, rdx
    add     rax, rcx
    add     rax, r8
    add     rax, r9

    ; Paramètres 7 et 8 sur la pile
    ; [rbp] = ancien rbp, [rbp + 8] = return address
    ; [rbp + 16] = 7ème argument
    ; [rbp + 24] = 8ème argument
    add     rax, [rbp + 16]
    add     rax, [rbp + 24]

    leave
    ret

_start:
    push    8
    push    7

    mov     rdi, 1
    mov     rsi, 2
    mov     rdx, 3
    mov     rcx, 4
    mov     r8,  5
    mov     r9,  6

    call    sum8
    add     rsp, 16

    mov     rdi, rax
    mov     rax, 60
    syscall
