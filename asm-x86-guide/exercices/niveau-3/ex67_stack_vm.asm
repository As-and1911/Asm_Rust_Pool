; =============================================================================
; Exercice 67 — Mini Machine Virtuelle à Pile
; =============================================================================
; Consigne :
; Bytecode :
; 0x01 VAL : PUSH VAL
; 0x02     : ADD
; 0x03     : MUL
; 0xFF     : HALT (arrête et retourne la valeur du sommet de pile)
;
; Programme à exécuter : PUSH 5, PUSH 8, ADD, PUSH 2, MUL, HALT
; Résultat : (5 + 8) * 2 = 26.
;
; Sortie attendue : exit code = 26
; =============================================================================

section .data
    prog db 0x01, 5, 0x01, 8, 0x02, 0x01, 2, 0x03, 0xFF

section .text
    global _start

vm_exec:
    ; TODO: Ton interprète de bytecode ici
    ret

_start:
    mov     rdi, prog
    call    vm_exec

    mov     rdi, rax
    mov     rax, 60
    syscall
