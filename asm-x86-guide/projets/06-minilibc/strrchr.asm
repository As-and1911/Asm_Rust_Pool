; =============================================================================
; Minilibc : strrchr
; char *strrchr(const char *s, int c);
; =============================================================================

section .text
    global strrchr

strrchr:
    xor     rax, rax            ; Dernier pointeur trouvé = NULL par défaut

.loop:
    mov     dl, [rdi]
    cmp     dl, sil             ; c
    jne     .check_null
    mov     rax, rdi            ; Met à jour le dernier trouvé

.check_null:
    test    dl, dl
    jz      .done
    inc     rdi
    jmp     .loop

.done:
    ret
