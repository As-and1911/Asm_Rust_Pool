; =============================================================================
; Exercice 63 — Tours de Hanoï : Nombre de mouvements récursifs
; =============================================================================
; Consigne :
; H(1) = 1
; H(N) = 2 * H(N - 1) + 1
; Calcule H(5) = 31.
;
; Sortie attendue : exit code = 31
; =============================================================================

section .text
    global _start

hanoi:
    ; TODO: Ton code récursif ici
    ret

_start:
    mov     rdi, 5
    call    hanoi

    mov     rdi, rax
    mov     rax, 60
    syscall
