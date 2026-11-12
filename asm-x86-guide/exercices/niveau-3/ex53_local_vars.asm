; =============================================================================
; Exercice 53 — Variables locales sur la pile
; =============================================================================
; Consigne :
; Crée une fonction avec prologue 'push rbp; mov rbp, rsp; sub rsp, 16'.
; Affecte [rbp - 8] = 30 et [rbp - 16] = 12.
; Calcule la somme dans rax, puis termine avec 'leave; ret'.
;
; Sortie attendue : exit code = 42
; =============================================================================

section .text
    global _start

calc_locals:
    ; TODO: Prologue, variables locales, calcul, épilogue
    ret

_start:
    call    calc_locals
    mov     rdi, rax
    mov     rax, 60
    syscall
