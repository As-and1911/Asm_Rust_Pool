; =============================================================================
; Exercice 13 — Moyenne entière de 3 nombres
; =============================================================================
; Consigne :
; Soit 3 nombres : 15, 25, 35.
; Calcule la moyenne entière : (15 + 25 + 35) / 3 = 75 / 3 = 25.
; Retourne le résultat dans rdi et quitte avec exit.
;
; Sortie attendue : exit code = 25
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
