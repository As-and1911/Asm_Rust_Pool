# Chapitre 10 — Outils d'Analyse, Débogage Avancé et Diagnostic Clinique

## 🎯 Objectifs de ce chapitre

À la fin de ce chapitre, tu seras capable de :
- [ ] Piloter **GDB** (*GNU Debugger*) au niveau de l'instruction machine (`stepi`, `nexti`, `layout asm`, `layout regs`).
- [ ] Inspecter la mémoire vive avec la commande `x` (*Examine*) sous tous ses formats (hexadécimal, chaînes, instructions désassemblées, quadwords).
- [ ] Utiliser couramment **LLDB** sur macOS avec les correspondances directes des commandes GDB.
- [ ] Analyser les flux de syscalls avec `strace` et d'appels de bibliothèques avec `ltrace`.
- [ ] Réaliser l'autopsie clinique immédiate des 3 grands signaux de crash : **`SIGSEGV`** (*Segmentation Fault*), **`SIGFPE`** (*Floating Point Exception*), **`SIGILL`** (*Illegal Instruction*).
- [ ] Identifier et corriger instantanément n'importe quelle erreur d'assemblage NASM ou de linkage GNU `ld`.

## 📋 Prérequis
- Avoir complété le Niveau 3 (pile, stack frames, ABI) et le Niveau 4 (syscalls, C).

## ⏱️ Durée estimée : 5–7 heures (Théorie + 8 Exercices de Diagnostic)

---

## 10.1 — GDB en Profondeur : Le Scanner Médical du Processeur

En langage haut niveau, un débogueur avance ligne par ligne de code source C ou Python.
En assembleur, nous déboguons **instruction machine par instruction machine** au cycle d'horloge près.

### 1. Démarrer GDB
```bash
# Compiler obligatoirement avec les symboles de débogage (-g -F dwarf)
nasm -f elf64 -g -F dwarf programme.asm -o programme.o
ld -g programme.o -o programme

# Lancer GDB en mode silencieux
gdb -q ./programme
```

### 2. Les Commandes Essentielles au Niveau Instruction

| Commande | Raccourci | Description |
|---|---|---|
| `break label` ou `break *0x401000` | `b` | Place un point d'arrêt à un label ou une adresse mémoire |
| `run` | `r` | Démarre l'exécution du programme |
| **`stepi`** | **`si`** | Exécute **UNE SEULE instruction assembleur** (entre dans les `call`) |
| **`nexti`** | **`ni`** | Exécute **UNE SEULE instruction** (enjambe les `call` sans y entrer) |
| `continue` | `c` | Reprend l'exécution jusqu'au prochain breakpoint |
| `info registers` | `i r` | Affiche l'état instantané des 16 registres généraux |
| `print/x $rax` | `p/x $rax` | Affiche la valeur de `rax` en hexadécimal (`/t` pour binaire, `/d` pour décimal) |
| `disassemble` | `disas` | Désassemble la fonction courante autour de RIP |

### 3. La Commande d'Examen Mémoire : `x` (*Examine*)
C'est la commande la plus puissante de GDB.  
Syntaxe : **`x / [nombre] [format] [taille]  adresse`**

- **Formats** : `x` (hexa), `d` (décimal), `u` (non signé), `s` (chaîne ASCII `\0`), `i` (instruction assembleur).
- **Tailles** : `b` (byte = 1 octet), `h` (halfword = 2 octets), `w` (word = 4 octets), `g` (giantword = 8 octets / qword).

#### Exemples concrets indispensables :
```gdb
(gdb) x/16gx $rsp       # Affiche les 16 prochains quadwords de la pile en hexadécimal
(gdb) x/s $rdi          # Affiche la chaîne de caractères pointée par RDI
(gdb) x/10i $rip        # Désassemble les 10 prochaines instructions à partir de RIP
(gdb) x/4xw &variable   # Affiche 4 dwords en hexadécimal à l'adresse de variable
```

### 4. L'Interface Graphique Texte de GDB : TUI (*Text User Interface*)
Tape dans ton shell GDB :
```gdb
(gdb) layout asm
(gdb) layout regs
```
L'écran se sépare en deux fenêtres interactives :
- En haut : tes registres mis à jour en temps réel (qui changent de couleur dès qu'ils sont modifiés !).
- Au milieu : le désassemblage avec une flèche montrant l'instruction pointée par `RIP`.
- En bas : ton invite de commande GDB.
*(Pour basculer le curseur si les flèches du terminal se bloquent : `focus cmd` ou `Ctrl+X A` pour quitter le mode TUI).*

---

## 10.2 — Équivalences Complètes GDB $\leftrightarrow$ LLDB (macOS)

Sur macOS (notamment si tu utilises la voie Rosetta 2), le débogueur système par défaut est **LLDB**. Voici la table de conversion directe :

| Action recherchée | Commande GDB | Commande LLDB |
|---|---|---|
| Définir syntaxe Intel | `set disassembly-flavor intel` | `settings set target.x86-disassembly-flavor intel` |
| Point d'arrêt sur symbole | `break _start` | `breakpoint set --name _start` (ou `b _start`) |
| Point d'arrêt sur adresse | `break *0x401050` | `breakpoint set --address 0x401050` (ou `b -a 0x401050`) |
| Lancer | `run` (ou `r`) | `run` (ou `r`) |
| Pas-à-pas instruction (Step Into)| **`stepi`** (ou `si`) | **`thread step-inst`** (ou **`si`**) |
| Pas-à-pas instruction (Step Over)| **`nexti`** (ou `ni`) | **`thread step-inst-over`** (ou **`ni`**) |
| Afficher tous les registres | `info registers` | **`register read`** |
| Afficher un registre précis | `print/x $rax` | `register read rax` |
| Examiner 16 qwords sur la pile | `x/16gx $rsp` | `memory read --format x --size 8 --count 16 $rsp` (ou `x/16gx $rsp`) |
| Désassembler autour de RIP | `x/10i $rip` | `disassemble --pc --count 10` |

---

## 10.3 — Diagnostic Clinique des Crashes

Quand un programme s'arrête prématurément, le noyau envoie un signal matériel. Voici la grille d'investigation d'un ingénieur système :

### 1. `SIGSEGV` (Signal 11 — Segmentation Fault)
> Le CPU a tenté d'accéder à une adresse mémoire virtuelle qui ne lui appartient pas, ou a violé les permissions de la page.

| Cause réelle du Segfault | Signature dans GDB | Comment corriger |
|---|---|---|
| **Déréférencement de pointeur NULL** | Crash sur `mov ..., [rax]` avec `rax = 0x0` | Toujours vérifier `test rax, rax; jz .null` avant d'accéder |
| **Tentative d'écriture en `.rodata` ou `.text`** | Crash sur `mov [rip+0x...], ...` | Déplacer la variable modifiable dans la section `.data` ou `.bss` |
| **Dépilement corrompu lors de `ret`** | Crash au moment exact de l'instruction `ret` | Vérifier que tous les `push` ont leur `pop` (pile déséquilibrée) |
| **Instruction SIMD non-alignée** | Crash sur `movaps` dans `puts` ou `printf` | S'assurer que $RSP \pmod{16} == 0$ juste avant le `call` |

### 2. `SIGFPE` (Signal 8 — Floating Point Exception)
> Malgré son nom historique, ce signal concerne presque toujours des **entiers** en assembleur !

- **Division par zéro** : `div rbx` ou `idiv rbx` alors que `rbx == 0`.
- **Dépassement de capacité du dividende** : Si le quotient de `RDX:RAX / diviseur` ne tient pas sur 64 bits ! (Exemple : oublier de mettre `rdx` à zéro avant un `div`).

### 3. `SIGILL` (Signal 4 — Illegal Instruction)
> Le processeur a tenté de décoder un octet qui ne correspond à aucune instruction x86_64 valide.

- Cause typique : Un saut (`jmp` ou `call`) a sauté dans une zone de données (`.data`) ou sur des zéros non initialisés au lieu d'une adresse de code exécutable.

---

## 10.4 — Guide de Survie : Erreurs NASM et Linker `ld`

### 1. Erreurs NASM (À l'assemblage)

- **`error: operation size not specified`** :
  ```asm
  mov [rdi], 0      ; ❌ NASM ne sait pas si c'est byte, word, dword ou qword !
  mov byte [rdi], 0 ; ✅ Spécifier explicitement la taille
  ```
- **`error: invalid combination of opcode and operands`** :
  Tentative de transfert mémoire-à-mémoire (`mov [rax], [rbx]`) ou mélange de tailles (`mov rax, edx`).
- **`error: symbol 'xxx' redefined`** :
  Deux labels portent le même nom. Utilise des labels locaux avec un point (`.loop:`) pour éviter les collisions.

### 2. Erreurs GNU `ld` (À l'édition de liens)

- **`ld: warning: cannot find entry symbol _start; defaulting to 0000000000401000`** :
  Tu as oublié `global _start` dans ton fichier `.asm`.
- **`ld: undefined reference to 'xxx'`** :
  Une fonction ou variable déclarée avec `extern` n'a pas été trouvée lors du linkage (fichier manquant dans la ligne de commande ou faute de frappe).
- **`relocation R_X86_64_32S against '.rodata' can not be used when making a PIE object`** :
  Tu as utilisé un adressage absolu au lieu d'un adressage RIP-relatif. Ajoute `default rel` en haut de ton fichier assembleur ou utilise `lea rdi, [rel message]`.

---

## 📝 8 Exercices de Diagnostic : Trouve le Bug dans le Code Cassé !

### Exercice 1 — L'Erreur de Division Mystère ⭐⭐
Soit le programme suivant :
```asm
section .text
    global _start
_start:
    mov     rax, 100
    mov     rbx, 2
    div     rbx
    mov     rax, 60
    xor     rdi, rdi
    syscall
```
Ce programme crashe immédiatement avec `Floating point exception (core dumped)` alors que `rbx` vaut 2 (non nul !). Pourquoi ? Comment corriger ?

### Exercice 2 — Le Segfault du `ret` ⭐⭐
```asm
section .text
    global _start

my_routine:
    push    10
    push    20
    ; ... opérations diverses ...
    pop     rax
    ret

_start:
    call    my_routine
    mov     rax, 60
    xor     rdi, rdi
    syscall
```
Pourquoi ce programme segfault-il lors de l'exécution du `ret` de `my_routine` ?

### Exercice 3 — L'Écriture Interdite ⭐⭐
```asm
section .rodata
    counter db 0

section .text
    global _start
_start:
    inc     byte [counter]
    mov     rax, 60
    xor     rdi, rdi
    syscall
```
Quel signal le noyau Linux va-t-il envoyer et pourquoi ? Dans quelle section `counter` devrait-il être déclaré ?

### Exercice 4 — La Boucle Infernale de `RCX` ⭐⭐⭐
```asm
section .text
    global _start
_start:
    mov     rcx, 5
.loop:
    ; Afficher un point '.' sur stdout à chaque tour
    push    rcx
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, dot
    mov     rdx, 1
    syscall
    ; On a oublié de dépiler rcx !
    loop    .loop

    mov     rax, 60
    xor     rdi, rdi
    syscall

section .data
    dot db '.'
```
Décris les deux catastrophes provoquées par ce code.

### Exercice 5 — L'Appel `printf` qui S'Effondre ⭐⭐⭐
```asm
section .rodata
    fmt db "Score = %d", 10, 0

section .text
    global main
    extern printf

main:
    mov     rdi, fmt
    mov     rsi, 100
    call    printf
    xor     eax, eax
    ret
```
Trouve les **DEUX erreurs critiques** d'ABI qui feront planter ce programme sur une machine 64 bits moderne.

### Exercice 6 — L'Argument Perdu du Syscall ⭐⭐
Un développeur tente d'appeler `mmap` en passant les paramètres :
`rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`.
Le syscall `mmap` échoue systématiquement avec le code d'erreur `EINVAL` (Invalid argument). Pourquoi ?

### Exercice 7 — L'Instruction Fantôme (SIGILL) ⭐⭐⭐
Un binaire crashe avec `Illegal instruction (core dumped)`.
En inspectant avec GDB, on constate que `RIP = 0x402008` (une adresse située en section `.data`). Comment un programme peut-il se retrouver à exécuter la section `.data` ?

### Exercice 8 — La Relocation PIE Rejetée par le Linker ⭐⭐
Explique la différence entre :
`mov rsi, msg`
et
`lea rsi, [rel msg]`
Pourquoi la première instruction est-elle rejetée par `gcc` par défaut sur les distributions Linux récentes ?

---

## 🧩 Mini-Quiz de fin de chapitre

1. Quelle commande GDB permet d'exécuter une seule instruction assembleur en entrant dans les fonctions appelées ?
2. Quelle commande GDB permet d'examiner 8 quadwords en hexadécimal à l'adresse de la pile ?
3. Pourquoi une division `div rbx` peut-elle déclencher un `SIGFPE` même si `rbx != 0` ?
4. Quel raccourci clavier permet de quitter le mode d'affichage TUI de GDB ?
5. Dans `strace`, comment reconnaît-on visuellement un appel système qui a échoué ?

<details>
<summary>Réponses du quiz</summary>

1. `stepi` (ou `si`).
2. `x/8gx $rsp`.
3. Parce que si `RDX` n'a pas été remis à zéro avant l'opération, le dividende 128 bits `RDX:RAX` est trop gigantesque et le quotient dépasse la capacité maximale d'un registre 64 bits (*Divide Overflow Exception*).
4. `Ctrl + X` suivi de `A`.
5. Le retour à droite de l'appel est égal à `-1` suivi du nom symbolique de l'erreur entre parenthèses (ex: `= -1 ENOENT (No such file or directory)`).
</details>

---

> 🏅 **Badge débloqué : Dévermineur d'élite** — Les entrailles du processeur et les outils de diagnostic n'ont plus de secret pour toi. Passons aux **Projets Intégrateurs Avancés (Chapitre 11)** !
