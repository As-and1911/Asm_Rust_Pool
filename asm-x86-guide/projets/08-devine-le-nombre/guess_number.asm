; =============================================================================
; Projet  : guess_number
; Fichier : guess_number.asm
; Auteur  : Antigravity Senior Engineer
; Desc    : Jeu "Devine le nombre" interactif avec PRNG XORShift (sans libc)
; =============================================================================

section .bss
    in_buf      resb 32
    num_buf     resb 32

section .data
    prompt      db "Devine le nombre (entre 1 et 100) : "
    prompt_len  equ $ - prompt
    too_low     db "Trop petit !", 10
    too_low_len equ $ - too_low
    too_high    db "Trop grand !", 10
    too_high_len equ $ - too_high
    win_prefix  db "Bravo ! Trouve en "
    win_pref_len equ $ - win_prefix
    win_suffix  db " essais !", 10
    win_suff_len equ $ - win_suffix

section .text
    global _start

_start:
    ; 1. Initialiser le PRNG avec getpid (syscall 39)
    mov     rax, 39             ; sys_getpid
    syscall
    mov     rdi, rax
    add     rdi, 123456789      ; Sel non nul

    ; Générer le nombre secret : xorshift64 mod 100 + 1
    call    xorshift64
    xor     rdx, rdx
    mov     rcx, 100
    div     rcx
    inc     rdx
    mov     r12, rdx            ; r12 = Nombre secret (1..100)

    xor     r13, r13            ; r13 = Nombre d'essais

.game_loop:
    inc     r13                 ; essais++

    ; Afficher prompt
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, prompt
    mov     rdx, prompt_len
    syscall

    ; Lire la saisie utilisateur sur stdin (fd = 0)
    mov     rax, 0
    mov     rdi, 0
    mov     rsi, in_buf
    mov     rdx, 31
    syscall

    test    rax, rax
    jle     .exit_game          ; EOF ou erreur

    ; Convertir in_buf en entier dans rax
    mov     byte [in_buf + rax], 0
    lea     rdi, [in_buf]
    call    simple_atoi

    ; Comparer avec le nombre secret (r12)
    cmp     rax, r12
    jl      .is_low
    jg      .is_high

    ; --- Victoire ! ---
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, win_prefix
    mov     rdx, win_pref_len
    syscall

    mov     rax, r13
    call    print_number

    mov     rax, 1
    mov     rdi, 1
    mov     rsi, win_suffix
    mov     rdx, win_suff_len
    syscall
    jmp     .exit_game

.is_low:
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, too_low
    mov     rdx, too_low_len
    syscall
    jmp     .game_loop

.is_high:
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, too_high
    mov     rdx, too_high_len
    syscall
    jmp     .game_loop

.exit_game:
    mov     rax, 60
    xor     rdi, rdi
    syscall

; -----------------------------------------------------------------------------
; xorshift64 : PRNG ultra-rapide
; -----------------------------------------------------------------------------
xorshift64:
    mov     rax, rdi
    mov     rbx, rax
    shl     rbx, 13
    xor     rax, rbx
    mov     rbx, rax
    shr     rbx, 7
    xor     rax, rbx
    mov     rbx, rax
    shl     rbx, 17
    xor     rax, rbx
    ret

; -----------------------------------------------------------------------------
; simple_atoi : Parse les chiffres ASCII dans rdi -> entier dans rax
; -----------------------------------------------------------------------------
simple_atoi:
    xor     rax, rax
.conv:
    movzx   ecx, byte [rdi]
    cmp     cl, '0'
    jl      .done
    cmp     cl, '9'
    jg      .done
    sub     cl, '0'
    imul    rax, 10
    add     rax, rcx
    inc     rdi
    jmp     .conv
.done:
    ret

; -----------------------------------------------------------------------------
; print_number : Affiche l'entier dans rax
; -----------------------------------------------------------------------------
print_number:
    lea     rsi, [num_buf + 31]
    mov     byte [rsi], 0
    dec     rsi

    test    rax, rax
    jnz     .l1
    mov     byte [rsi], '0'
    dec     rsi
    jmp     .w1

.l1:
    test    rax, rax
    jz      .w1
    xor     rdx, rdx
    mov     rcx, 10
    div     rcx
    add     dl, '0'
    mov     [rsi], dl
    dec     rsi
    jmp     .l1

.w1:
    inc     rsi
    lea     rdx, [num_buf + 31]
    sub     rdx, rsi
    mov     rax, 1
    mov     rdi, 1
    syscall
    ret
