; =============================================================================
; Exercice 20 — Extraction de signe sans branchement
; =============================================================================
; Consigne :
; Soit un nombre négatif dans rax (ex: -100).
; Décale rax de 63 bits vers la droite avec 'shr' pour isoler le bit de signe.
; Quitte avec exit(rdi).
;
; Sortie attendue : exit code = 1
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
