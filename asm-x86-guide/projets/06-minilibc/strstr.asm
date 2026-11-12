; =============================================================================
; Minilibc : strstr
; char *strstr(const char *haystack, const char *needle);
; =============================================================================

section .text
    global strstr

strstr:
    ; Si needle est vide (""), retourne haystack
    cmp     byte [rsi], 0
    jne     .main_loop
    mov     rax, rdi
    ret

.main_loop:
    cmp     byte [rdi], 0
    je      .not_found

    ; Vérifier si needle correspond à partir de [rdi]
    xor     rcx, rcx
.check_sub:
    mov     al, [rsi + rcx]
    test    al, al
    jz      .found              ; needle correspond entièrement !

    mov     dl, [rdi + rcx]
    cmp     dl, al
    jne     .next_char

    inc     rcx
    jmp     .check_sub

.next_char:
    inc     rdi
    jmp     .main_loop

.found:
    mov     rax, rdi
    ret

.not_found:
    xor     rax, rax            ; NULL
    ret
