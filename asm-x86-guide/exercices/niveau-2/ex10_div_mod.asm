; =============================================================================
; Exercice 10 — Division et Modulo
; =============================================================================
; Consigne :
; Divise 100 par 7.
; Récupère le RESTE (modulo) qui se trouve dans rdx et place-le dans rdi.
; Quitte avec exit(rdi).
; N'oublie pas de mettre rdx à 0 avant la division !
;
; Sortie attendue : exit code = 2 (100 = 7 * 14 + 2)
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
