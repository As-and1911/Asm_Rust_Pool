section .text
global my_putchar

my_putchar:
sub rsp, 1
mov BYTE [rsp], rdi
mov rax, 1
mov rdi, 1
mov rsi, rsp
mov rdx, 1
syscall

add rsp, 1
ret
