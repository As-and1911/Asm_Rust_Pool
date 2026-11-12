; =============================================================================
; Minilibc : strcmp
; int strcmp(const char *s1, const char *s2);
; =============================================================================

section .text
    global strcmp

strcmp:
    xor     rcx, rcx

.loop:
    movzx   eax, byte [rdi + rcx]
    movzx   edx, byte [rsi + rcx]

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
