; =============================================================================
; Minilibc : strcasecmp
; int strcasecmp(const char *s1, const char *s2);
; =============================================================================

section .text
    global strcasecmp

strcasecmp:
    xor     rcx, rcx

.loop:
    movzx   eax, byte [rdi + rcx]
    movzx   edx, byte [rsi + rcx]

    ; Mettre al en minuscule si entre 'A' (65) et 'Z' (90)
    cmp     al, 'A'
    jl      .check_dl
    cmp     al, 'Z'
    jg      .check_dl
    add     al, 32

.check_dl:
    cmp     dl, 'A'
    jl      .compare
    cmp     dl, 'Z'
    jg      .compare
    add     dl, 32

.compare:
    cmp     al, dl
    jne     .diff

    test    al, al
    jz      .equal

    inc     rcx
    jmp     .loop

.diff:
    sub     eax, edx
    ret

.equal:
    xor     eax, eax
    ret
