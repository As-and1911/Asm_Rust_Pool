; =============================================================================
; Minilibc : strpbrk
; char *strpbrk(const char *s, const char *accept);
; =============================================================================

section .text
    global strpbrk

strpbrk:
.loop_s:
    mov     al, [rdi]
    test    al, al
    jz      .not_found

    ; Recherche de al dans accept (rsi)
    xor     rcx, rcx
.loop_accept:
    mov     dl, [rsi + rcx]
    test    dl, dl
    jz      .next_s
    cmp     al, dl
    je      .found
    inc     rcx
    jmp     .loop_accept

.next_s:
    inc     rdi
    jmp     .loop_s

.found:
    mov     rax, rdi
    ret

.not_found:
    xor     rax, rax            ; NULL
    ret
