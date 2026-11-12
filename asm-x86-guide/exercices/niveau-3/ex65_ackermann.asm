; =============================================================================
; Exercice 65 — Fonction d'Ackermann-Péter A(m, n)
; =============================================================================
; Consigne :
; A(0, n) = n + 1
; A(m, 0) = A(m - 1, 1)           pour m > 0
; A(m, n) = A(m - 1, A(m, n - 1)) pour m > 0, n > 0
; Calcule A(2, 2) = 7.
;
; Sortie attendue : exit code = 7
; =============================================================================

section .text
    global _start

ackermann:
    ; TODO: Ton code récursif ici
    ret

_start:
    mov     rdi, 2
    mov     rsi, 2
    call    ackermann

    mov     rdi, rax
    mov     rax, 60
    syscall
