; =============================================================================
; Projet  : Minilibc
; Fichier : my_strcmp.asm
; Auteur  : Antigravity Senior Engineer
; Desc    : Implémentation x86_64 de strcmp (ABI System V AMD64)
; =============================================================================
;
; Prototype C :
;   int my_strcmp(const char *s1, const char *s2);
;
; Paramètres :
;   rdi = const char *s1
;   rsi = const char *s2
;
; Valeur de retour :
;   eax = différence (unsigned char)s1[i] - (unsigned char)s2[i]
; =============================================================================

section .text
    global my_strcmp

my_strcmp:
    xor     rcx, rcx            ; Indice i = 0

.loop:
    movzx   eax, byte [rdi + rcx]   ; eax = (unsigned char)s1[i]
    movzx   edx, byte [rsi + rcx]   ; edx = (unsigned char)s2[i]

    ; Si s1[i] != s2[i], on a trouvé la divergence
    cmp     al, dl
    jne     .divergence

    ; Si s1[i] == '\0' (et donc s2[i] == '\0' aussi), les chaînes sont identiques
    test    al, al
    jz      .equal

    inc     rcx                 ; i++
    jmp     .loop

.divergence:
    sub     eax, edx            ; Différence algébrique signée
    ret

.equal:
    xor     eax, eax            ; Retourne 0
    ret
