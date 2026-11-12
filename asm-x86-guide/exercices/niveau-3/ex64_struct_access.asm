; =============================================================================
; Exercice 64 — Accès à une structure Point { long x; long y; }
; =============================================================================
; Consigne :
; Point est stocké avec x à [rdi] et y à [rdi + 8].
; Calcule x^2 + y^2.
; Pour x = 3, y = 4 -> 9 + 16 = 25.
;
; Sortie attendue : exit code = 25
; =============================================================================

section .data
    point_test:
        dq 3            ; x
        dq 4            ; y

section .text
    global _start

get_dist_sq:
    ; TODO: Ton code ici
    ret

_start:
    mov     rdi, point_test
    call    get_dist_sq

    mov     rdi, rax
    mov     rax, 60
    syscall
