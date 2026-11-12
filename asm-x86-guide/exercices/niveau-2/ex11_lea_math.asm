; =============================================================================
; Exercice 11 — Calcul de polynôme avec LEA
; =============================================================================
; Consigne :
; Soit x = 5 dans rdi.
; Calcule y = 9*x + 7 en utilisant UNIQUEMENT l'instruction 'lea'.
; Indice : 9x = x + 8x -> lea rax, [rdi + rdi * 8 + 7]
; Quitte avec exit(rdi) contenant le résultat.
;
; Sortie attendue : exit code = 52
; =============================================================================

section .text
    global _start

_start:
    mov     rdi, 5
    ; TODO: Calcule 9*rdi + 7 avec lea

    mov     rax, 60
    syscall
