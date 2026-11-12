; =============================================================================
; Projet  : my_server
; Fichier : my_server.asm
; Auteur  : Antigravity Senior Engineer
; Desc    : Serveur HTTP TCP minimaliste en assembleur x86_64 pur (sans libc)
; =============================================================================

section .bss
    client_buf  resb 1024

section .data
    msg_listen  db "Serveur TCP en ecoute sur http://0.0.0.0:8080 ...", 10
    msg_lis_len equ $ - msg_listen
    msg_client  db "-> Connexion client recue, reponse 200 OK envoyee.", 10
    msg_cli_len equ $ - msg_client

    ; Structure sockaddr_in (16 octets)
    ; struct sockaddr_in {
    ;    short          sin_family;  // AF_INET = 2 (2 octets)
    ;    unsigned short sin_port;    // Port 8080 en Big-Endian (0x901F) (2 octets)
    ;    struct in_addr sin_addr;    // INADDR_ANY = 0 (4 octets)
    ;    char           sin_zero[8]; // Padding de zéros (8 octets)
    ; };
    align 4
    server_addr:
        dw 2                    ; AF_INET = 2
        dw 0x901F               ; Port 8080 en Big-Endian (htons(8080) = 0x1F90 inversé en 0x901F)
        dd 0                    ; INADDR_ANY (0.0.0.0)
        dq 0                    ; 8 octets de padding

    ; Réponse HTTP standard
    http_resp   db "HTTP/1.1 200 OK", 13, 10
                db "Content-Type: text/plain", 13, 10
                db "Content-Length: 39", 13, 10
                db "Connection: close", 13, 10
                db 13, 10
                db "Hello from x86_64 raw assembly server!", 10
    http_len    equ $ - http_resp

section .text
    global _start

_start:
    ; 1. socket(AF_INET=2, SOCK_STREAM=1, 0) -> Syscall 41
    mov     rax, 41             ; sys_socket
    mov     rdi, 2              ; AF_INET
    mov     rsi, 1              ; SOCK_STREAM (TCP)
    xor     rdx, rdx            ; protocol = 0
    syscall

    test    rax, rax
    js      .error
    mov     r12, rax            ; r12 = server_socket_fd

    ; 2. bind(fd, &server_addr, 16) -> Syscall 49
    mov     rax, 49             ; sys_bind
    mov     rdi, r12
    mov     rsi, server_addr
    mov     rdx, 16             ; sizeof(sockaddr_in)
    syscall

    test    rax, rax
    js      .error

    ; 3. listen(fd, 10) -> Syscall 50
    mov     rax, 50             ; sys_listen
    mov     rdi, r12
    mov     rsi, 10             ; backlog = 10
    syscall

    test    rax, rax
    js      .error

    ; Affiche le message de démarrage
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_listen
    mov     rdx, msg_lis_len
    syscall

.server_loop:
    ; 4. accept(fd, NULL, NULL) -> Syscall 43
    mov     rax, 43             ; sys_accept
    mov     rdi, r12
    xor     rsi, rsi            ; client_addr = NULL
    xor     rdx, rdx            ; addrlen = NULL
    syscall

    test    rax, rax
    js      .server_loop        ; Si erreur temporaire, continuer
    mov     r13, rax            ; r13 = client_fd

    ; 5. read(client_fd, client_buf, 1024) -> Syscall 0
    mov     rax, 0              ; sys_read
    mov     rdi, r13
    mov     rsi, client_buf
    mov     rdx, 1024
    syscall

    ; 6. write(client_fd, http_resp, http_len) -> Syscall 1
    mov     rax, 1              ; sys_write
    mov     rdi, r13
    mov     rsi, http_resp
    mov     rdx, http_len
    syscall

    ; Log console
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, msg_client
    mov     rdx, msg_cli_len
    syscall

    ; 7. close(client_fd) -> Syscall 3
    mov     rax, 3              ; sys_close
    mov     rdi, r13
    syscall

    jmp     .server_loop

.error:
    mov     rax, 60
    mov     rdi, 84
    syscall
