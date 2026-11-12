; =============================================================================
; Projet  : Utilitaires Unix
; Fichier : my_cat.asm
; Auteur  : Antigravity Senior Engineer
; Desc    : Implémentation x86_64 pure de cat (fichiers + stdin, sans libc)
; =============================================================================

section .bss
    buffer      resb 4096       ; Tampon de lecture de 4 Ko

section .data
    err_prefix  db "my_cat: "
    err_pref_len equ $ - err_prefix
    err_suffix  db ": No such file or directory", 10
    err_suff_len equ $ - err_suffix

section .text
    global _start

_start:
    mov     r12, [rsp]          ; r12 = argc
    xor     r15, r15            ; r15 = code de retour final (0 par défaut)

    cmp     r12, 1
    jg      .process_files

    ; Pas d'arguments -> Lire sur stdin (FD 0)
    xor     rdi, rdi
    call    cat_fd
    jmp     .exit_prog

.process_files:
    mov     rbx, 1              ; Index de fichier (argv[1])

.file_loop:
    cmp     rbx, r12
    jge     .exit_prog

    mov     rdi, [rsp + 8 + rbx * 8]    ; rdi = nom de fichier
    mov     r13, rdi                    ; Sauvegarde du nom de fichier
    xor     rsi, rsi                    ; O_RDONLY = 0
    xor     rdx, rdx
    mov     rax, 2                      ; sys_open
    syscall

    test    rax, rax
    js      .file_error

    mov     rdi, rax                    ; rdi = FD ouvert
    call    cat_fd

    ; Fermeture du fichier
    mov     rax, 3                      ; sys_close
    syscall
    jmp     .next_file

.file_error:
    mov     r15, 84                     ; Code d'erreur Epitech

    ; Écrire "my_cat: " sur stderr
    mov     rax, 1
    mov     rdi, 2
    mov     rsi, err_prefix
    mov     rdx, err_pref_len
    syscall

    ; Écrire le nom de fichier
    mov     rsi, r13
    xor     rdx, rdx
.len_err:
    cmp     byte [rsi + rdx], 0
    je      .print_name
    inc     rdx
    jmp     .len_err
.print_name:
    mov     rax, 1
    mov     rdi, 2
    syscall

    ; Écrire ": No such file or directory\n"
    mov     rax, 1
    mov     rdi, 2
    mov     rsi, err_suffix
    mov     rdx, err_suff_len
    syscall

.next_file:
    inc     rbx
    jmp     .file_loop

.exit_prog:
    mov     rax, 60
    mov     rdi, r15
    syscall

; -----------------------------------------------------------------------------
; Routine cat_fd : Lit en boucle sur le FD dans rdi et écrit sur stdout
; -----------------------------------------------------------------------------
cat_fd:
    mov     r14, rdi            ; Sauvegarde du FD

.read_loop:
    mov     rax, 0              ; sys_read
    mov     rdi, r14
    mov     rsi, buffer
    mov     rdx, 4096
    syscall

    cmp     rax, 0
    jle     .cat_done           ; Si 0 (EOF) ou négatif (erreur), terminer

    mov     rdx, rax            ; Nombre d'octets lus
    mov     rax, 1              ; sys_write
    mov     rdi, 1              ; stdout
    mov     rsi, buffer
    syscall
    jmp     .read_loop

.cat_done:
    ret
