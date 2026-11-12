; =============================================================================
; Projet  : Utilitaires Unix
; Fichier : my_wc.asm
; Auteur  : Antigravity Senior Engineer
; Desc    : Implémentation x86_64 de wc (comptage de lignes et octets)
; =============================================================================

section .bss
    buffer      resb 4096
    num_buf     resb 32

section .data
    space       db ' '
    newline     db 10

section .text
    global _start

_start:
    mov     r12, [rsp]          ; argc
    xor     r13, r13            ; r13 = total lignes
    xor     r14, r14            ; r14 = total octets

    cmp     r12, 1
    jg      .open_file

    ; Lecture sur stdin (FD 0)
    xor     rdi, rdi
    call    count_fd
    jmp     .print_stats

.open_file:
    mov     rdi, [rsp + 16]     ; argv[1]
    xor     rsi, rsi            ; O_RDONLY
    xor     rdx, rdx
    mov     rax, 2              ; sys_open
    syscall

    test    rax, rax
    js      .err_exit

    mov     rdi, rax
    call    count_fd

    mov     rax, 3              ; sys_close
    syscall

.print_stats:
    ; Affiche le nombre de lignes
    mov     rax, r13
    call    print_num

    ; Espace
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, space
    mov     rdx, 1
    syscall

    ; Affiche le nombre d'octets
    mov     rax, r14
    call    print_num

    ; Saut de ligne
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, newline
    mov     rdx, 1
    syscall

    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall

.err_exit:
    mov     rax, 60
    mov     rdi, 84
    syscall

; -----------------------------------------------------------------------------
; Routine count_fd : Compte lignes et octets sur le FD dans rdi
; -----------------------------------------------------------------------------
count_fd:
    push    r15
    mov     r15, rdi

.read_chunk:
    mov     rax, 0              ; sys_read
    mov     rdi, r15
    mov     rsi, buffer
    mov     rdx, 4096
    syscall

    test    rax, rax
    jle     .done

    add     r14, rax            ; Ajoute les octets lus au total

    ; Compte les '\n' dans ce bloc
    xor     rcx, rcx
.count_nl:
    cmp     rcx, rax
    jge     .read_chunk
    cmp     byte [buffer + rcx], 10
    jne     .next_char
    inc     r13                 ; Lignes++
.next_char:
    inc     rcx
    jmp     .count_nl

.done:
    pop     r15
    ret

; -----------------------------------------------------------------------------
; Routine itoa : affiche le nombre non signé dans RAX
; -----------------------------------------------------------------------------
print_num:
    lea     rsi, [num_buf + 31]
    mov     byte [rsi], 0
    dec     rsi

    test    rax, rax
    jnz     .conv
    mov     byte [rsi], '0'
    dec     rsi
    jmp     .write_num

.conv:
    test    rax, rax
    jz      .write_num
    xor     rdx, rdx
    mov     rcx, 10
    div     rcx
    add     dl, '0'
    mov     [rsi], dl
    dec     rsi
    jmp     .conv

.write_num:
    inc     rsi
    lea     rdx, [num_buf + 31]
    sub     rdx, rsi
    mov     rax, 1
    mov     rdi, 1
    syscall
    ret
