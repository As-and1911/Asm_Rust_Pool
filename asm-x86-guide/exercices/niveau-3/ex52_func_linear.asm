; =============================================================================
; Exercice 52 — Fonction à 4 paramètres f(a, b, c, d) = (a * b) + (c * d)
; =============================================================================
; Consigne :
; Arguments dans rdi, rsi, rdx, rcx.
; Résultat retourné dans rax.
; Teste f(2, 3, 4, 5) = 6 + 20 = 26.
;
; Sortie attendue : exit code = 26
; =============================================================================

section .text
    global _start

func_linear:
    ; TODO: Ton code ici
    ret

_start:
    mov     rdi, 2
    mov     rsi, 3
    mov     rdx, 4
    mov     rcx, 5
    call    func_linear

    mov     rdi, rax
    mov     rax, 60
    syscall
