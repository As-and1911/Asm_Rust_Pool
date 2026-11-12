; =============================================================================
; Minilibc : memcpy
; void *memcpy(void *dest, const void *src, size_t n);
; =============================================================================

section .text
    global memcpy

memcpy:
    mov     rax, rdi            ; Sauvegarde dest pour le retour
    mov     rcx, rdx            ; Nombre d'octets
    cld                         ; Avance vers l'avant
    rep     movsb               ; Copie [rsi] vers [rdi]
    ret
