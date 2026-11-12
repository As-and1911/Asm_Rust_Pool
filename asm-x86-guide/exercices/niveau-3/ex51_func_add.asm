; =============================================================================
; Exercice 51 — Fonction add2(a, b)
; =============================================================================
; Consigne :
; 1. Écris la fonction 'add2' qui prend rdi et rsi et retourne rdi + rsi dans rax.
; 2. Appelle 'add2' depuis _start avec 18 et 24.
; 3. Quitte avec le résultat dans rdi.
;
; Sortie attendue : exit code = 42
; =============================================================================

section .text
    global _start

add2:
    ; TODO: Ton code de fonction ici
    ret

_start:
    mov     rdi, 18
    mov     rsi, 24
    call    add2

    mov     rdi, rax
    mov     rax, 60
    syscall
