# Différences Majeures : Assembleur x86_64 sur macOS vs Linux

Ce document récapitule les adaptations nécessaires si tu écris ou portes du code assembleur x86_64 pour tourner nativement sous macOS via **Rosetta 2**.

---

## 1. Tableau Comparatif Synthétique

| Caractéristique | Linux x86_64 | macOS x86_64 (Rosetta 2) |
|---|---|---|
| **Format binaire objet** | `nasm -f elf64` | `nasm -f macho64` |
| **Point d'entrée standard** | `global _start` | `global _main` |
| **Préfixe des symboles C** | Aucun (`printf`, `exit`, `strlen`) | **Underscore obligatoire** (`_printf`, `_exit`) |
| **Numérotation des syscalls** | Numéros directs (`rax = 1` pour write) | **Classe BSD : Offset `0x2000000`** (`rax = 0x2000004`) |
| **Adressage des données** | Direct ou relatif (`mov rsi, msg`) | **Strictement RIP-relatif** (`lea rsi, [rel msg]`) |
| **Alignement de la pile** | Recommandé 16 octets | **Strictement obligatoire** (Crash immédiat sinon) |
| **Édition de liens** | `ld prog.o -o prog` | `ld prog.o -lSystem -syslibroot $(xcrun --show-sdk-path) -e _main` |
| **Binaires statiques** | Supportés (`-static`) | **Interdits** (liaison dynamique avec libSystem obligatoire) |
| **Débogueur** | GDB / strace | **LLDB** natif |

---

## 2. Exemple Complet : Hello World comparé

### Version Linux (ELF64) :
```asm
section .data
    msg db "Hello Linux", 10
    len equ $ - msg

section .text
    global _start

_start:
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, msg        ; adresse
    mov rdx, len
    syscall

    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall
```

### Version macOS (Mach-O 64) :
```asm
section .data
    msg db "Hello macOS", 10
    len equ $ - msg

section .text
    global _main        ; Point d'entrée avec underscore

_main:
    mov rax, 0x2000004  ; 0x2000000 + 4 (sys_write BSD)
    mov rdi, 1          ; stdout
    lea rsi, [rel msg]  ; RIP-relatif OBLIGATOIRE
    mov rdx, len
    syscall

    mov rax, 0x2000001  ; 0x2000000 + 1 (sys_exit BSD)
    xor rdi, rdi
    syscall
```

---

## 3. Guide de Portage d'un Programme Linux vers macOS

Pour exécuter un code assembleur Linux du cours sur macOS natif :
1. Remplace `_start` par `_main`.
2. Remplace chaque appel système direct par l'offset `0x2000000` (ex: `1` devient `0x2000004`, `60` devient `0x2000001`, `0` devient `0x2000003`).
3. Remplace les adressages absolus de données `mov reg, label` par `lea reg, [rel label]`.
4. Assemble avec `nasm -f macho64`.
5. Linke avec :
   ```bash
   ld fichier.o -o binaire -lSystem -syslibroot $(xcrun --sdk macosx --show-sdk-path) -e _main
   ```
