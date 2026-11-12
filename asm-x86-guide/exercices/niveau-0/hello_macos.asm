; =============================================================================
; Fichier : hello_macos.asm
; Desc    : Hello World en assembleur x86_64 macOS (voie alternative Rosetta 2)
; =============================================================================
;
; Assemblage et linkage (macOS) :
;   nasm -f macho64 hello_macos.asm -o hello_macos.o
;   ld hello_macos.o -o hello_macos -lSystem \
;      -syslibroot $(xcrun --sdk macosx --show-sdk-path) -e _main
;
; Exécution :
;   ./hello_macos
;
; =============================================================================

section .data
    msg     db "Hello, World!", 10      ; La chaîne + un saut de ligne
    msg_len equ $ - msg                 ; Longueur calculée automatiquement

section .text
    global _main                        ; macOS attend _main (pas _start)

_main:
    ; --- Afficher "Hello, World!\n" sur stdout ---
    mov     rax, 0x2000004      ; syscall macOS : write (0x2000000 + 4)
    mov     rdi, 1              ; fd 1 = stdout
    lea     rsi, [rel msg]      ; adresse de la chaîne (RIP-relatif OBLIGATOIRE)
    mov     rdx, msg_len        ; nombre d'octets
    syscall

    ; --- Quitter proprement ---
    mov     rax, 0x2000001      ; syscall macOS : exit (0x2000000 + 1)
    xor     rdi, rdi            ; code de retour 0
    syscall
