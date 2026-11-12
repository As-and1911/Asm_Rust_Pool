; =============================================================================
; Exercice 12 — Division signée avec CQO et IDIV
; =============================================================================
; Consigne :
; Place -50 dans rax.
; Utilise l'instruction 'cqo' pour étendre le signe dans rdx.
; Divise par 4 avec 'idiv'.
; Place le quotient dans rdi et quitte avec exit.
;
; Sortie attendue : exit code = 244 (-12 mod 256)
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
