; =============================================================================
; Projet  : my_base_converter
; Fichier : my_base_converter.asm
; Auteur  : Antigravity Senior Engineer
; Desc    : Convertisseur de bases universel (2, 8, 10, 16) sans libc
; =============================================================================

section .bss
    out_buf     resb 70         ; Buffer pour la sortie

section .data
    hex_chars   db "0123456789abcdef"
    err_msg     db "Error", 10
    err_len     equ $ - err_msg
    newline     db 10

section .text
    global _start

_start:
    mov     rax, [rsp]          ; argc
    cmp     rax, 4
    jne     .error

    ; argv[1] = chaîne à convertir
    mov     rdi, [rsp + 16]

    ; argv[2] = base source
    mov     rsi, [rsp + 24]
    call    parse_base_num
    test    rax, rax
    jz      .error
    mov     r12, rax            ; r12 = base source (2, 8, 10 ou 16)

    ; argv[3] = base cible
    mov     rsi, [rsp + 32]
    call    parse_base_num
    test    rax, rax
    jz      .error
    mov     r13, rax            ; r13 = base cible (2, 8, 10 ou 16)

    ; Parser la chaîne dans r12 -> entier dans rax
    mov     rsi, r12
    call    atoi_base
    test    rdx, rdx            ; rdx = 0 si OK, 1 si erreur
    jnz     .error

    ; Convertir l'entier dans RAX vers la base R13 et l'afficher
    mov     rsi, r13
    call    itoa_and_print

    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall

.error:
    mov     rax, 1
    mov     rdi, 2
    mov     rsi, err_msg
    mov     rdx, err_len
    syscall

    mov     rax, 60
    mov     rdi, 84
    syscall

; -----------------------------------------------------------------------------
; parse_base_num : Lit la base depuis la chaîne dans rsi (doit être 2, 8, 10, 16)
; -----------------------------------------------------------------------------
parse_base_num:
    cmp     byte [rsi + 1], 0
    je      .single_digit
    ; Deux chiffres : tester si "10" ou "16"
    cmp     byte [rsi], '1'
    jne     .invalid_base
    cmp     byte [rsi + 1], '0'
    je      .is_10
    cmp     byte [rsi + 1], '6'
    je      .is_16
    jmp     .invalid_base

.single_digit:
    movzx   rax, byte [rsi]
    cmp     al, '2'
    je      .is_2
    cmp     al, '8'
    je      .is_8
    jmp     .invalid_base

.is_2:  mov rax, 2  ; ret
        ret
.is_8:  mov rax, 8  ; ret
        ret
.is_10: mov rax, 10 ; ret
        ret
.is_16: mov rax, 16 ; ret
        ret
.invalid_base:
    xor     rax, rax
    ret

; -----------------------------------------------------------------------------
; atoi_base : Convertit chaîne rdi selon base rsi -> rax (rdx=0 si OK, 1 si err)
; -----------------------------------------------------------------------------
atoi_base:
    xor     rax, rax            ; accumulateur
    xor     rcx, rcx            ; index

.parse_loop:
    movzx   edx, byte [rdi + rcx]
    test    dl, dl
    jz      .atoi_success

    ; Conversion du caractère en valeur numérique (0-15)
    cmp     dl, '0'
    jl      .atoi_err
    cmp     dl, '9'
    jle     .digit
    ; Majuscules 'A'-'F'
    cmp     dl, 'A'
    jl      .check_lower
    cmp     dl, 'F'
    jle     .upper
.check_lower:
    cmp     dl, 'a'
    jl      .atoi_err
    cmp     dl, 'f'
    jle     .lower
    jmp     .atoi_err

.digit:
    sub     dl, '0'
    jmp     .validate
.upper:
    sub     dl, 'A' - 10
    jmp     .validate
.lower:
    sub     dl, 'a' - 10

.validate:
    movzx   rdx, dl
    cmp     rdx, rsi
    jge     .atoi_err           ; Chiffre invalide pour cette base

    ; rax = rax * base + chiffre
    imul    rax, rsi
    add     rax, rdx

    inc     rcx
    jmp     .parse_loop

.atoi_success:
    xor     rdx, rdx
    ret

.atoi_err:
    mov     rdx, 1
    ret

; -----------------------------------------------------------------------------
; itoa_and_print : Affiche rax converti dans la base rsi
; -----------------------------------------------------------------------------
itoa_and_print:
    lea     rdi, [out_buf + 68]
    mov     byte [rdi + 1], 10  ; '\n'
    mov     byte [rdi + 2], 0

    test    rax, rax
    jnz     .conv_loop
    mov     byte [rdi], '0'
    dec     rdi
    jmp     .do_write

.conv_loop:
    test    rax, rax
    jz      .do_write
    xor     rdx, rdx
    div     rsi                 ; rax = rax / base, rdx = reste
    mov     dl, [hex_chars + rdx]
    mov     [rdi], dl
    dec     rdi
    jmp     .conv_loop

.do_write:
    inc     rdi
    ; Longueur = (out_buf + 70) - rdi
    lea     rdx, [out_buf + 70]
    sub     rdx, rdi

    mov     rax, 1
    mov     rsi, rdi
    mov     rdi, 1
    syscall
    ret
