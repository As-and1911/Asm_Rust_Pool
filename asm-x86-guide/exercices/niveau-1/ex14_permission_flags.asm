; =============================================================================
; Exercice 14 — Flags de permission
; =============================================================================
; Consigne :
; 1. Démarre avec rdi = 0
; 2. Active Lecture (0x04) et Exécution (0x01) avec OR
; 3. Désactive Exécution (0x01) avec AND et le complément ~0x01
; 4. Quitte avec exit(rdi)
;
; Sortie attendue : code de retour = 4
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
