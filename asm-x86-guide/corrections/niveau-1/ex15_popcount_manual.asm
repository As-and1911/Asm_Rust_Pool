; =============================================================================
; CORRECTION — Exercice 15 : Comptage de bits à un (Popcount manuel)
; Valeur : 0b00101101 (4 bits à 1)
; =============================================================================

section .text
    global _start

_start:
    mov     rax, 00101101b      ; 0x2D
    xor     rdi, rdi            ; rdi sera notre compteur

    ; On teste et additionne chaque bit successivement en décalant vers la droite
    ; Bit 0
    mov     rbx, rax
    and     rbx, 1
    add     rdi, rbx

    ; Bit 1
    shr     rax, 1
    mov     rbx, rax
    and     rbx, 1
    add     rdi, rbx

    ; Bit 2
    shr     rax, 1
    mov     rbx, rax
    and     rbx, 1
    add     rdi, rbx

    ; Bit 3
    shr     rax, 1
    mov     rbx, rax
    and     rbx, 1
    add     rdi, rbx

    ; Bit 4
    shr     rax, 1
    mov     rbx, rax
    and     rbx, 1
    add     rdi, rbx

    ; Bit 5
    shr     rax, 1
    mov     rbx, rax
    and     rbx, 1
    add     rdi, rbx

    ; Bit 6
    shr     rax, 1
    mov     rbx, rax
    and     rbx, 1
    add     rdi, rbx

    ; Bit 7
    shr     rax, 1
    mov     rbx, rax
    and     rbx, 1
    add     rdi, rbx

    mov     rax, 60             ; sys_exit(rdi) -> retourne 4
    syscall
