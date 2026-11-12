; =============================================================================
; Fichier : [nom_du_fichier].asm
; Auteur  : [ton_nom]
; Date    : [date]
; Desc    : [description courte du programme]
; =============================================================================
;
; Assemblage et linkage :
;   nasm -f elf64 fichier.asm -o fichier.o
;   ld fichier.o -o fichier
;
; Exécution :
;   ./fichier
;
; =============================================================================

section .data
    ; --- Données initialisées ---
    ; exemple : msg db "Hello", 10      ; chaîne + newline
    ; exemple : len equ $ - msg         ; longueur calculée

section .bss
    ; --- Données non initialisées ---
    ; exemple : buffer resb 64          ; réserver 64 octets

section .text
    global _start

_start:
    ; --- Code principal ---


    ; --- Sortie propre ---
    mov     rax, 60         ; syscall : exit
    xor     rdi, rdi        ; code de retour : 0
    syscall
