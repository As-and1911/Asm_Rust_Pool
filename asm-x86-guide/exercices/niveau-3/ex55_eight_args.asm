; =============================================================================
; Exercice 55 — Fonction à 8 paramètres (Paramètres sur la pile)
; =============================================================================
; Consigne :
; sum8(a, b, c, d, e, f, g, h)
; Les 6 premiers sont dans rdi, rsi, rdx, rcx, r8, r9.
; Les paramètres 7 et 8 sont empilés avant le call :
;   push 8
;   push 7
; Dans la fonction, récupère [rbp + 16] (7) et [rbp + 24] (8).
; Somme de 1 à 8 = 36.
;
; Sortie attendue : exit code = 36
; =============================================================================

section .text
    global _start

sum8:
    push    rbp
    mov     rbp, rsp

    ; TODO: Additionne rdi, rsi, rdx, rcx, r8, r9 et [rbp + 16], [rbp + 24]

    leave
    ret

_start:
    ; Empile les arguments 8 et 7
    push    8
    push    7

    ; Charge les 6 premiers arguments
    mov     rdi, 1
    mov     rsi, 2
    mov     rdx, 3
    mov     rcx, 4
    mov     r8,  5
    mov     r9,  6

    call    sum8
    add     rsp, 16             ; Nettoyage des 2 arguments empilés

    mov     rdi, rax
    mov     rax, 60
    syscall
