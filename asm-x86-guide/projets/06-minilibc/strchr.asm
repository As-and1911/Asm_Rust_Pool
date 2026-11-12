; =============================================================================
; Minilibc : strchr
; char *strchr(const char *s, int c);
; =============================================================================

section .text
    global strchr

strchr:
    mov     rax, rdi            ; Pointeur courant

.loop:
    mov     dl, [rax]
    cmp     dl, sil             ; sil = c (cast en char)
    je      .found

    test    dl, dl              ; Si on atteint le '\0' sans avoir trouvé
    jz      .not_found

    inc     rax
    jmp     .loop

.found:
    ret

.not_found:
    xor     rax, rax            ; return NULL
    ret
