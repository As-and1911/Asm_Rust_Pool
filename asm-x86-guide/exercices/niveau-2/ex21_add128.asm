; =============================================================================
; Exercice 21 — Addition 128 bits avec Retenue (ADC)
; =============================================================================
; Consigne :
; Soit deux nombres 128 bits :
; A = 0x0000000000000001 : 0xFFFFFFFFFFFFFFFF (rdx:rax)
; B = 0x0000000000000000 : 0x0000000000000001 (rbx:rcx)
;
; Additionne rax et rcx avec 'add rax, rcx' (déclenche Carry Flag = 1).
; Additionne rdx et rbx avec 'adc rdx, rbx' (prend en compte la retenue -> rdx = 2).
; Quitte en retournant rdx dans rdi.
;
; Sortie attendue : exit code = 2
; =============================================================================

section .text
    global _start

_start:
    ; TODO: Ton code ici

    mov     rax, 60
    syscall
