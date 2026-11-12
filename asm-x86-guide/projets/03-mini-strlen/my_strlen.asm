; =============================================================================
; Projet  : Minilibc
; Fichier : my_strlen.asm
; Auteur  : Antigravity Senior Engineer
; Desc    : Implémentation x86_64 de strlen (ABI System V AMD64)
; =============================================================================
;
; Prototype C :
;   size_t my_strlen(const char *s);
;
; Paramètre :
;   rdi = const char *s
;
; Valeur de retour :
;   rax = longueur de la chaîne
; =============================================================================

section .text
    global my_strlen

my_strlen:
    xor     rax, rax            ; Initialise le compteur de longueur à 0

.loop:
    cmp     byte [rdi + rax], 0 ; Vérifie si le caractère courant est '\0'
    je      .done               ; Si oui, fin de la chaîne

    inc     rax                 ; Caractère suivant (longueur++)
    jmp     .loop

.done:
    ret                         ; Retourne avec la longueur dans RAX
