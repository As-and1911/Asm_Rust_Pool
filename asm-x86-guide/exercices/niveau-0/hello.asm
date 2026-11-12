; =============================================================================
; Fichier : hello.asm
; Desc    : Premier programme — Hello World en assembleur x86_64 Linux
; =============================================================================
;
; Assemblage et linkage :
;   nasm -f elf64 hello.asm -o hello.o
;   ld hello.o -o hello
;
; Exécution :
;   ./hello
;
; =============================================================================

section .data
    msg     db "Hello, World!", 10      ; La chaîne + un saut de ligne (10 = '\n')
    msg_len equ $ - msg                 ; Longueur calculée automatiquement

section .text
    global _start                       ; Point d'entrée du programme

_start:
    ; --- Afficher "Hello, World!\n" sur stdout ---
    mov     rax, 1              ; syscall numéro 1 = write
    mov     rdi, 1              ; fd 1 = stdout (sortie standard)
    mov     rsi, msg            ; adresse de la chaîne à afficher
    mov     rdx, msg_len        ; nombre d'octets à écrire
    syscall                     ; appel au noyau Linux

    ; --- Quitter proprement avec le code 0 ---
    mov     rax, 60             ; syscall numéro 60 = exit
    xor     rdi, rdi            ; code de retour 0 (xor rdi, rdi → rdi = 0)
    syscall                     ; appel au noyau Linux
