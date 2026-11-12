; =============================================================================
; CORRECTION — Exercice 01 : Putchar 'Z' sans .data
; =============================================================================

section .text
    global _start

_start:
    ; Allouer le caractère sur la pile
    push    'Z'                 ; Dépose 'Z' sur la pile (rsp pointe dessus)

    ; sys_write(1, rsp, 1)
    mov     rax, 1              ; write
    mov     rdi, 1              ; stdout
    mov     rsi, rsp            ; adresse du caractère au sommet de la pile
    mov     rdx, 1              ; 1 octet
    syscall

    ; Nettoyer la pile
    pop     rax                 ; ou 'add rsp, 8'

    ; sys_exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall
