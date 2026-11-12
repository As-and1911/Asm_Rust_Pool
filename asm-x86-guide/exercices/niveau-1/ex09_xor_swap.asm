; =============================================================================
; Exercice 09 — XOR Swap
; =============================================================================
; Consigne :
; Mets 12 dans rax, 30 dans rbx.
; Échange leurs valeurs en 3 opérations 'xor' consécutives.
; Place rax dans rdi et quitte avec exit.
;
; Sortie attendue : code de retour = 30
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60             ; sys_exit
    syscall
