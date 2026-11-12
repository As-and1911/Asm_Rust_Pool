# Ressources et Lectures Conseillées pour Aller Plus Loin

## 1. Documentation Officielle et Spécifications de Référence
- **Intel 64 and IA-32 Architectures Software Developer Manuals** : Les manuels de référence absolus d'Intel (Volume 1 : Architecture, Volumes 2A-2D : Référence complète de toutes les instructions).
- **System V Application Binary Interface (AMD64 Architecture Processor Supplement)** : La norme officielle régissant l'ABI sous Linux et Unix.
- **Documentation Officielle NASM** : `https://www.nasm.us/doc/` — Guide exhaustif de la syntaxe, des directives et des macros de NASM.
- **Linux Kernel Syscall Table (x86_64)** : `https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md` ou `syscall.sh`.

---

## 2. Pédagogie & Cursus Epitech / 42
- **Le sujet Minilibc officiel** : Réimplémenter la libc en assembleur x86_64 est l'un des exercices les plus formateurs de la formation Epitech.
- **Projets systèmes avancés** : Écrire un allocator de mémoire (`malloc`/`free`) en assembleur pur via `sys_brk` et `sys_mmap`.

---

## 3. Reverse Engineering & Sécurité
- **Ghidra** (NSA) & **IDA Pro** : Les outils majeurs de désassemblage et de décompilation vers le C.
- **Pwndbg / GEF** : Extensions modernes de GDB indispensables pour les CTF de sécurité bas niveau et l'analyse de mémoire.
- **LiveOverflow (YouTube)** : Excellente chaîne pédagogique sur la mémoire, les binaires, les stack overflows et le reverse engineering.
- **OverTheWire (Wargames)** : Notamment les challenges *Narnia* et *Protostar* pour pratiquer l'exploitation binaire.

---

## 4. Livres de Référence
- *Computer Systems: A Programmer's Perspective* (CS:APP) par Randal E. Bryant et David R. O'Hallaron (La bible du bas niveau).
- *Practical Reverse Engineering* par Bruce Dang, Alexandre Gazet et Elias Bachaalany.
- *Low-Level Programming: C, Assembly, and Program Execution on Intel 64 Architecture* par Igor Zhirkov.
