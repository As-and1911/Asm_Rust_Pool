; =============================================================================
; Minilibc : memmove
; void *memmove(void *dest, const void *src, size_t n);
; Gestion rigoureuse du chevauchement (overlap)
; =============================================================================

section .text
    global memmove

memmove:
    mov     rax, rdi            ; Sauvegarde dest pour retour
    test    rdx, rdx
    jz      .done

    ; Vérifier si dest > src ET dest < src + n (chevauchement par la droite)
    cmp     rdi, rsi
    jle     .forward            ; Si dest <= src, copie vers l'avant ordinaire

    lea     rcx, [rsi + rdx]    ; src + n
    cmp     rdi, rcx
    jge     .forward            ; Si dest >= src + n, pas de chevauchement

    ; --- Chevauchement détecté : Copie de DROITE À GAUCHE (en reculant) ---
    lea     rdi, [rdi + rdx - 1] ; Pointer sur le dernier octet de dest
    lea     rsi, [rsi + rdx - 1] ; Pointer sur le dernier octet de src
    mov     rcx, rdx            ; Nombre d'octets
    std                         ; Direction arrière (décrémente rdi et rsi)
    rep     movsb
    cld                         ; Toujours remettre CLD à la fin !
    ret

.forward:
    mov     rcx, rdx
    cld
    rep     movsb

.done:
    ret
