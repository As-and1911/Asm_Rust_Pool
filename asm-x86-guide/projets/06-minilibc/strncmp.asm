; =============================================================================
; Minilibc : strncmp
; int strncmp(const char *s1, const char *s2, size_t n);
; =============================================================================

section .text
    global strncmp

strncmp:
    xor     rcx, rcx
    test    rdx, rdx
    jz      .equal              ; Si n == 0, renvoie 0

.loop:
    cmp     rcx, rdx
    je      .equal              ; Si on a comparé n caractères sans divergence

    movzx   eax, byte [rdi + rcx]
    movzx   r8d, byte [rsi + rcx]

    cmp     al, r8b
    jne     .diff

    test    al, al
    jz      .equal

    inc     rcx
    jmp     .loop

.diff:
    sub     eax, r8d
    ret

.equal:
    xor     eax, eax
    ret
