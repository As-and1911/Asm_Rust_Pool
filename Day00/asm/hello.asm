    section .rodata
    msg db "Hello, Epitech!", 0x0A
    len equ $ - msg
    stdout equ 1

    section .text
    global _start
_start:
    ;; System call for sys_write(write in stdout)
    mov rax, 1                   ;move code number of sys_write into rax register
    mov rdi, stdout              ;move file descriptor of stdout into rdi register
    mov rsi, msg                 ;move message adress into rsi register
    mov rdx, len                 ;move message lenght into rdx register
    syscall

    ;; System call for sys_exit (exit program)

    mov rax, 60                  ;move code num of sys_exit into rax
    mov rdi, 0                   ;move the exit status we want to be returned into rdi
    syscall
