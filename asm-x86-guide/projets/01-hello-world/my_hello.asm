; =============================================================================
; Projet  : my_hello
; Fichier : my_hello.asm
; Auteur  : Antigravity System Engineer <dev@system.internal>
; Desc    : Hello World et Dispatcher de sortie (stdout/stderr)
; =============================================================================

section .data
%ifndef ERROR_MODE
    ; Mode Standard (stdout)
    msg         db "Hello, World!", 10
    msg_len     equ $ - msg
    FD_OUT      equ 1                   ; stdout
    RET_CODE    equ 0                   ; Succès
%else
    ; Mode Erreur (stderr)
    msg         db "[ERROR] Operation failed successfully.", 10
    msg_len     equ $ - msg
    FD_OUT      equ 2                   ; stderr
    RET_CODE    equ 84                  ; Code d'erreur Epitech
%endif

section .text
    global _start

_start:
    ; --- Syscall write(FD_OUT, msg, msg_len) ---
    mov     rax, 1                      ; sys_write
    mov     rdi, FD_OUT                 ; descripteur de fichier
    mov     rsi, msg                    ; pointeur mémoire sur la chaîne
    mov     rdx, msg_len                ; longueur de la chaîne
    syscall

    ; --- Syscall exit(RET_CODE) ---
    mov     rax, 60                     ; sys_exit
    mov     rdi, RET_CODE               ; code de retour
    syscall
