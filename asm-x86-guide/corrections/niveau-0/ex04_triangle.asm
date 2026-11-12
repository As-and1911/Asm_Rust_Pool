; =============================================================================
; CORRECTION — Exercice 4 : Triangle d'étoiles
; =============================================================================
; Affiche :
;   *
;   **
;   ***
;   ****
;   *****
;
; Astuce : on définit les 5 lignes en .data car on ne sait pas encore
; faire de boucles. C'est normal à ce stade ! On apprendra les boucles
; au chapitre 5.
; =============================================================================

section .data
    l1      db "*", 10
    l1_len  equ $ - l1
    l2      db "**", 10
    l2_len  equ $ - l2
    l3      db "***", 10
    l3_len  equ $ - l3
    l4      db "****", 10
    l4_len  equ $ - l4
    l5      db "*****", 10
    l5_len  equ $ - l5

section .text
    global _start

_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, l1
    mov rdx, l1_len
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, l2
    mov rdx, l2_len
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, l3
    mov rdx, l3_len
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, l4
    mov rdx, l4_len
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, l5
    mov rdx, l5_len
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall
