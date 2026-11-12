; =============================================================================
; Minilibc : memset
; void *memset(void *s, int c, size_t n);
; =============================================================================

section .text
    global memset

memset:
    mov     rax, rdi            ; Sauvegarde du pointeur original pour la valeur de retour
    mov     rcx, rdx            ; rcx = nombre d'octets n
    mov     al, sil             ; al = caractère c
    cld                         ; Direction avant
    rep     stosb               ; Remplissage matériel en 1 instruction !
    mov     rax, rdi            ; RDI a bougé, on remet le pointeur original
    sub     rax, rdx            ; rax = rdi original
    ret
