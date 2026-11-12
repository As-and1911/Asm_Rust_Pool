; =============================================================================
; Projet  : my_hexdump
; Fichier : my_hexdump.asm
; Auteur  : Antigravity Senior Engineer
; Desc    : Visualisateur hexadécimal conforme à hexdump -C (sans libc)
; =============================================================================

section .bss
    in_buf      resb 16         ; Bloc de 16 octets
    line_buf    resb 80         ; Ligne formatée

section .data
    hex_digits  db "0123456789abcdef"
    newline     db 10

section .text
    global _start

_start:
    mov     r12, [rsp]          ; argc
    xor     r14, r14            ; r14 = offset total cumulé

    cmp     r12, 1
    jg      .open_file

    ; Lecture sur stdin (FD 0)
    xor     rdi, rdi
    call    dump_fd
    jmp     .exit_ok

.open_file:
    mov     rdi, [rsp + 16]     ; argv[1]
    xor     rsi, rsi            ; O_RDONLY
    xor     rdx, rdx
    mov     rax, 2              ; sys_open
    syscall

    test    rax, rax
    js      .error

    mov     rdi, rax
    call    dump_fd

    mov     rax, 3              ; sys_close
    syscall

.exit_ok:
    ; Affiche l'offset final si au moins un octet a été lu
    test    r14, r14
    jz      .pure_exit
    mov     rax, r14
    call    print_hex_offset
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, newline
    mov     rdx, 1
    syscall

.pure_exit:
    mov     rax, 60
    xor     rdi, rdi
    syscall

.error:
    mov     rax, 60
    mov     rdi, 84
    syscall

; -----------------------------------------------------------------------------
; dump_fd : Traite le FD passé dans rdi par blocs de 16 octets
; -----------------------------------------------------------------------------
dump_fd:
    push    r15
    mov     r15, rdi

.block_loop:
    mov     rax, 0              ; sys_read
    mov     rdi, r15
    mov     rsi, in_buf
    mov     rdx, 16
    syscall

    test    rax, rax
    jle     .dump_end           ; 0 = EOF

    mov     r13, rax            ; r13 = nombre d'octets lus dans ce bloc (1..16)

    ; Formate la ligne dans line_buf et l'affiche
    call    format_line

    add     r14, r13            ; Met à jour l'offset global
    jmp     .block_loop

.dump_end:
    pop     r15
    ret

; -----------------------------------------------------------------------------
; format_line : Formate la ligne de 16 octets
; -----------------------------------------------------------------------------
format_line:
    push    r14

    ; 1. Remplir line_buf d'espaces (78 caractères)
    mov     rcx, 78
    lea     rdi, [line_buf]
    mov     al, ' '
.clear_line:
    mov     [rdi], al
    inc     rdi
    loop    .clear_line
    mov     byte [line_buf + 78], 10    ; '\n'

    ; 2. Écrire l'offset hexadécimal (8 caractères)
    mov     rax, r14
    lea     rdi, [line_buf + 7]
    mov     rcx, 8
.fmt_offset:
    mov     rdx, rax
    and     rdx, 0x0F
    mov     dl, [hex_digits + rdx]
    mov     [rdi], dl
    dec     rdi
    shr     rax, 4
    loop    .fmt_offset

    ; 3. Formater les octets hexadécimaux et la colonne ASCII
    xor     rcx, rcx            ; Index de 0 à r13 - 1
.fmt_bytes:
    cmp     rcx, r13
    jge     .finish_line

    movzx   eax, byte [in_buf + rcx]

    ; Position hexadécimale : 10 + rcx*3 + (rcx >= 8 ? 1 : 0)
    mov     rdx, rcx
    imul    rdx, 3
    add     rdx, 10
    cmp     rcx, 8
    jl      .no_extra_space
    inc     rdx
.no_extra_space:

    ; Écrire les 2 chiffres hex
    mov     rbx, rax
    shr     rbx, 4
    mov     bl, [hex_digits + rbx]
    mov     [line_buf + rdx], bl

    mov     rbx, rax
    and     rbx, 0x0F
    mov     bl, [hex_digits + rbx]
    mov     [line_buf + rdx + 1], bl

    ; Position ASCII : 60 + rcx
    lea     rdx, [line_buf + 60 + rcx]
    cmp     al, 32
    jl      .dot
    cmp     al, 126
    jg      .dot
    mov     [rdx], al
    jmp     .next_b
.dot:
    mov     byte [rdx], '.'

.next_b:
    inc     rcx
    jmp     .fmt_bytes

.finish_line:
    ; Ajouter les barres '|' autour de la colonne ASCII
    mov     byte [line_buf + 59], '|'
    lea     rdx, [line_buf + 60 + r13]
    mov     byte [rdx], '|'
    mov     byte [rdx + 1], 10

    ; Calculer la longueur à écrire : (rdx + 2) - line_buf
    lea     rsi, [line_buf]
    lea     rax, [rdx + 2]
    sub     rax, rsi
    mov     rdx, rax

    ; write(1, line_buf, len)
    mov     rax, 1
    mov     rdi, 1
    syscall

    pop     r14
    ret

; -----------------------------------------------------------------------------
; print_hex_offset : Affiche rax en hexadécimal sur 8 caractères
; -----------------------------------------------------------------------------
print_hex_offset:
    lea     rdi, [line_buf + 7]
    mov     rcx, 8
.po_loop:
    mov     rdx, rax
    and     rdx, 0x0F
    mov     dl, [hex_digits + rdx]
    mov     [rdi], dl
    dec     rdi
    shr     rax, 4
    loop    .po_loop

    mov     rax, 1
    mov     rdi, 1
    lea     rsi, [line_buf]
    mov     rdx, 8
    syscall
    ret
