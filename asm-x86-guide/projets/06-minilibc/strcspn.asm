; =============================================================================
; Minilibc : strcspn
; size_t strcspn(const char *s, const char *reject);
; =============================================================================

section .text
    global strcspn

strcspn:
    xor     rax, rax            ; Longueur comptée

.loop_s:
    mov     cl, [rdi + rax]
    test    cl, cl
    jz      .done

    ; Recherche si cl est dans reject (rsi)
    xor     rdx, rdx
.loop_reject:
    mov     r8b, [rsi + rdx]
    test    r8b, r8b
    jz      .next_char
    cmp     cl, r8b
    je      .done
    inc     rdx
    jmp     .loop_reject

.next_char:
    inc     rax
    jmp     .loop_s

.done:
    ret
