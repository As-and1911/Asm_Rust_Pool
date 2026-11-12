; =============================================================================
; CORRECTION — Exercice 09 : XOR Swap sans variable temporaire
; Échange rax (12) et rbx (30) en 3 XOR
; =============================================================================

section .text
    global _start

_start:
    mov     rax, 12
    mov     rbx, 30

    ; L'algorithme XOR Swap :
    xor     rax, rbx            ; rax = rax ^ rbx
    xor     rbx, rax            ; rbx = rbx ^ (rax ^ rbx) = rax d'origine (12)
    xor     rax, rbx            ; rax = (rax ^ rbx) ^ rax = rbx d'origine (30)

    mov     rdi, rax            ; rdi reçoit 30
    mov     rax, 60             ; sys_exit
    syscall
