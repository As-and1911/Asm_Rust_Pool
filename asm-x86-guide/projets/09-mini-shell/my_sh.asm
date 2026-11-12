; =============================================================================
; Projet  : my_sh
; Fichier : my_sh.asm
; Auteur  : Antigravity Senior Engineer
; Desc    : Mini-shell Unix interactif complet en assembleur pur (sans libc)
; =============================================================================

section .bss
    cmd_buf     resb 512        ; Buffer pour la ligne saisie
    argv_table  resq 32         ; Table de 32 pointeurs argv[]
    bin_path    resb 256        ; Buffer pour /bin/commande

section .data
    prompt      db "my_sh$ "
    prompt_len  equ $ - prompt
    bin_prefix  db "/bin/"
    bin_pre_len equ 5
    cmd_not_fnd db "Command not found", 10
    cnf_len     equ $ - cmd_not_fnd
    newline     db 10

section .text
    global _start

_start:
.main_loop:
    ; 1. Affiche le prompt "my_sh$ "
    mov     rax, 1              ; sys_write
    mov     rdi, 1              ; stdout
    mov     rsi, prompt
    mov     rdx, prompt_len
    syscall

    ; 2. Lire la ligne de commande sur stdin (FD 0)
    mov     rax, 0              ; sys_read
    mov     rdi, 0
    mov     rsi, cmd_buf
    mov     rdx, 511
    syscall

    ; Si read <= 0 : EOF (Ctrl+D), quitter le shell
    test    rax, rax
    jle     .exit_shell

    ; Remplacer le '\n' final par un '\0'
    mov     byte [cmd_buf + rax], 0
    cmp     byte [cmd_buf + rax - 1], 10
    jne     .parse
    mov     byte [cmd_buf + rax - 1], 0

.parse:
    ; 3. Parser cmd_buf pour remplir argv_table
    call    parse_command_line
    test    rax, rax
    jz      .main_loop          ; Ligne vide, réafficher prompt

    ; 4. Vérifier si commande "exit"
    mov     rdi, [argv_table]
    call    is_exit_cmd
    test    rax, rax
    jnz     .exit_shell

    ; 5. sys_fork (Syscall 57)
    mov     rax, 57
    syscall

    test    rax, rax
    js      .main_loop          ; Erreur de fork
    jz      .child_process      ; Si rax == 0 -> FILS

    ; --- PROCESSUS PARENT ---
    ; Attend la fin du fils avec sys_wait4(pid, status, options, rusage)
    mov     rdi, rax            ; PID du fils
    xor     rsi, rsi            ; status = NULL
    xor     rdx, rdx            ; options = 0
    xor     r10, r10            ; rusage = NULL
    mov     rax, 61             ; sys_wait4
    syscall
    jmp     .main_loop

.child_process:
    ; --- PROCESSUS FILS ---
    mov     rdi, [argv_table]   ; Nom de la commande

    ; Si la commande commence par '/' ou '.', execve direct
    cmp     byte [rdi], '/'
    je      .do_exec
    cmp     byte [rdi], '.'
    je      .do_exec

    ; Sinon, préfixer par "/bin/"
    call    build_bin_path
    mov     rdi, bin_path

.do_exec:
    ; sys_execve(path, argv, envp)
    ; rdi = path, rsi = argv_table, rdx = NULL
    mov     rsi, argv_table
    xor     rdx, rdx
    mov     rax, 59             ; sys_execve
    syscall

    ; Si execve revient ici, c'est qu'il a échoué !
    mov     rax, 1
    mov     rdi, 2
    mov     rsi, cmd_not_fnd
    mov     rdx, cnf_len
    syscall

    ; Quitter le fils avec code 127
    mov     rax, 60
    mov     rdi, 127
    syscall

.exit_shell:
    ; Affiche un dernier saut de ligne et quitte
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, newline
    mov     rdx, 1
    syscall

    mov     rax, 60
    xor     rdi, rdi
    syscall

; -----------------------------------------------------------------------------
; parse_command_line : Découpe cmd_buf en mots dans argv_table
; Retourne rax = nombre d'arguments
; -----------------------------------------------------------------------------
parse_command_line:
    lea     rsi, [cmd_buf]
    lea     rdi, [argv_table]
    xor     rcx, rcx            ; Nombre d'arguments

.skip_spaces:
    mov     al, [rsi]
    test    al, al
    jz      .parsing_done
    cmp     al, ' '
    je      .next_char
    cmp     al, 9               ; Tabulation
    je      .next_char

    ; Début d'un argument
    mov     [rdi + rcx * 8], rsi
    inc     rcx

.find_word_end:
    mov     al, [rsi]
    test    al, al
    jz      .parsing_done
    cmp     al, ' '
    je      .terminate_word
    cmp     al, 9
    je      .terminate_word
    inc     rsi
    jmp     .find_word_end

.terminate_word:
    mov     byte [rsi], 0       ; Remplace espace par '\0'
    inc     rsi
    jmp     .skip_spaces

.next_char:
    inc     rsi
    jmp     .skip_spaces

.parsing_done:
    mov     qword [rdi + rcx * 8], 0 ; NULL terminator pour argv
    mov     rax, rcx
    ret

; -----------------------------------------------------------------------------
; is_exit_cmd : Teste si [rdi] == "exit\0"
; -----------------------------------------------------------------------------
is_exit_cmd:
    cmp     byte [rdi], 'e'
    jne     .no
    cmp     byte [rdi + 1], 'x'
    jne     .no
    cmp     byte [rdi + 2], 'i'
    jne     .no
    cmp     byte [rdi + 3], 't'
    jne     .no
    cmp     byte [rdi + 4], 0
    jne     .no
    mov     rax, 1
    ret
.no:
    xor     rax, rax
    ret

; -----------------------------------------------------------------------------
; build_bin_path : Copie "/bin/" puis le nom de commande dans bin_path
; -----------------------------------------------------------------------------
build_bin_path:
    lea     r8, [bin_path]
    mov     byte [r8], '/'
    mov     byte [r8 + 1], 'b'
    mov     byte [r8 + 2], 'i'
    mov     byte [r8 + 3], 'n'
    mov     byte [r8 + 4], '/'
    add     r8, 5

.copy_name:
    mov     al, [rdi]
    mov     [r8], al
    test    al, al
    jz      .done_path
    inc     rdi
    inc     r8
    jmp     .copy_name

.done_path:
    ret
