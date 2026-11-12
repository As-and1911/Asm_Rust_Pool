# Chapitre 8 — Les Appels Système Linux en Profondeur : Fichiers, Processus et I/O

## 🎯 Objectifs de ce chapitre

À la fin de ce chapitre, tu seras capable de :
- [ ] Maîtriser le mécanisme matériel de transition en mode noyau via l'instruction **`syscall`**.
- [ ] Retenir la différence subtile entre la convention de fonction C (`rcx` en 4ème argument) et la convention de syscall (`r10` en 4ème argument !).
- [ ] Savoir que l'instruction matérielle `syscall` détruit **systématiquement** les registres `RCX` et `R11`.
- [ ] Détecter et traiter les erreurs de syscall comme le fait la libc (plage d'erreur $-4095$ à $-1 \equiv -\text{errno}$).
- [ ] Lire les arguments de la ligne de commande (`argc`, `argv`) et l'environnement (`envp`) directement depuis la pile au démarrage (`_start`).
- [ ] Manipuler les fichiers du système d'exploitation (`open`, `read`, `write`, `close`, `lseek`).
- [ ] Cloner des processus avec `fork`, exécuter des binaires avec `execve` et attendre leur fin avec `wait4`.
- [ ] Réaliser le **Projet 4 : Mini-cat / Mini-wc / Mini-echo** et le **Projet 5 : Mini-hexdump**.

## 📋 Prérequis
- Avoir complété le Niveau 3 (pile, conventions de registres, stack frames).

## ⏱️ Durée estimée : 8–10 heures (Théorie + 15 Exercices + Projets 4 & 5)

---

## 8.1 — Le Mécanisme Matériel du Syscall

Dans un système d'exploitation moderne comme Linux, un programme utilisateur tourne en **Ring 3 (Mode Utilisateur)**. Il n'a aucun droit direct sur le matériel : interdiction de toucher aux disques durs, à la carte réseau ou aux ports de communication.

Pour effectuer la moindre opération sur le monde réel (afficher du texte, lire un fichier, créer un processus), il doit demander poliment au **Noyau Linux (Ring 0 - Mode Privilégié)** via un **Appel Système (*System Call*)**.

```
    RING 3 (Espace Utilisateur)
  ┌─────────────────────────────────────────────────────────┐
  │  Ton programme x86_64                                   │
  │  mov rax, 1           ; Syscall n°1 = sys_write         │
  │  mov rdi, 1           ; fd = stdout                     │
  │  mov rsi, tampon      ; pointeur mémoire                │
  │  mov rdx, 14          ; taille                          │
  │  syscall              ; ─── Bascule matérielle CPU ────┐│
  └────────────────────────────────────────────────────────┼┘
                                                           │
                                                           ▼
    RING 0 (Espace Noyau / Kernel Linux)
  ┌─────────────────────────────────────────────────────────┐
  │  Vérification des droits d'accès mémoire                │
  │  Exécution du pilote matériel (GPU, Disque, TTY...)     │
  │  Retour de statut dans RAX                              │
  │  Instruction SYSRET   ; ─── Retour au mode utilisateur ─┘│
  └─────────────────────────────────────────────────────────┘
```

### 1. La Convention des Registres de Syscall

```
  Numéro de Syscall :  RAX
  1er argument      :  RDI
  2ème argument     :  RSI
  3ème argument     :  RDX
  4ème argument     :  R10   <── ATTENTION ! R10, et NON PAS RCX !
  5ème argument     :  R8
  6ème argument     :  R9
  -------------------------------------------------------------
  Valeur de retour  :  RAX
```

> [!CAUTION]
> **LE PIÈGE HISTORIQUE DE RCX vs R10 :**
> - Lors d'un appel de fonction C ordinaire : le 4ème argument est dans **`RCX`**.
> - Lors d'un appel système via `syscall` : le 4ème argument est **OBLIGATOIREMENT dans `R10`** !
> **Pourquoi ?** Parce que l'instruction matérielle `syscall` du processeur x86_64 utilise en interne le registre `RCX` pour sauvegarder l'adresse de retour (`RIP`) de ton programme ! Pour ne pas écraser ton 4ème argument, les créateurs de l'architecture ont choisi d'utiliser `R10` pour les syscalls.

### 2. Les Deux Registres Massacreurs : `RCX` et `R11`
Dès que l'instruction `syscall` est exécutée par le processeur :
- Le processeur copie `RIP` dans **`RCX`**.
- Le processeur copie `RFLAGS` dans **`R11`**.
> **Conséquence directe : Tout ce que tu avais stocké dans `RCX` et `R11` est DÉTRUIT à chaque syscall !**

---

## 8.2 — La Table des Syscalls Linux Essentiels (x86_64)

| RAX (N°) | Nom | RDI (Arg 1) | RSI (Arg 2) | RDX (Arg 3) | R10 (Arg 4) | Description |
|:---:|---|---|---|---|---|---|
| **0** | **`sys_read`** | `unsigned int fd` | `char *buf` | `size_t count` | - | Lit jusqu'à `count` octets |
| **1** | **`sys_write`**| `unsigned int fd` | `const char *buf` | `size_t count` | - | Écrit jusqu'à `count` octets |
| **2** | **`sys_open`** | `const char *file`| `int flags` | `umode_t mode` | - | Ouvre un fichier et renvoie son FD |
| **3** | **`sys_close`**| `unsigned int fd` | - | - | - | Ferme le descripteur |
| **8** | **`sys_lseek`**| `unsigned int fd` | `off_t offset` | `unsigned int whence` | - | Déplace la tête de lecture/écriture |
| **9** | **`sys_mmap`** | `void *addr` | `size_t len` | `int prot` | `int flags`, `r8=fd`, `r9=off` | Mappe de la mémoire virtuelle |
| **12**| **`sys_brk`**  | `void *addr` | - | - | - | Déplace la limite du tas (*heap*) |
| **22**| **`sys_pipe`** | `int pipefd[2]` | - | - | - | Crée un canal de communication IPC |
| **33**| **`sys_dup2`** | `int oldfd` | `int newfd` | - | - | Duplique un descripteur (redirection) |
| **39**| **`sys_getpid`**| - | - | - | - | Renvoie le PID du processus courant |
| **57**| **`sys_fork`** | - | - | - | - | Clone le processus courant |
| **59**| **`sys_execve`**| `const char *file`| `char **argv` | `char **envp` | - | Remplace le processus par un binaire |
| **60**| **`sys_exit`** | `int error_code` | - | - | - | Termine le processus |
| **61**| **`sys_wait4`**| `pid_t pid` | `int *wstatus` | `int options` | `struct rusage *ru` | Attend la fin d'un processus fils |

---

## 8.3 — La Gestion des Erreurs : La Règle du $-4095$

En programmation C, quand un appel système comme `read` ou `open` échoue, la fonction renvoie `-1` et met à jour une variable globale nommée `errno`.

**Mais en assembleur, `errno` n'existe pas !** C'est une invention de la libc.
Au niveau du noyau Linux brut :
> **Si un syscall échoue, `RAX` contient une valeur négative égale à $-\text{errno}$.**
> Sous Linux x86_64, les codes d'erreur vont de `-1` (ex: `EPERM`) à `-4095`.

```
Valeur dans RAX après SYSCALL :
┌──────────────────────────────────────┬───────────────────────────────────────────┐
│     Plage de valeurs                 │ Signification                             │
├──────────────────────────────────────┼───────────────────────────────────────────┤
│ `0` à `0x7FFFFFFFFFFFFFFF` (Positif) │ Succès ! (Nombre d'octets lus/écrits, FD) │
│ `-4095` à `-1` (0xFFFFFFFFFFFFF001)  │ ERREUR KERNEL ! Le code d'erreur = -RAX   │
└──────────────────────────────────────┴───────────────────────────────────────────┘
```

### Motif de Vérification Robuste :
```asm
    mov     rax, 0              ; sys_read
    mov     rdi, rbx            ; fd
    mov     rsi, buffer
    mov     rdx, 1024
    syscall

    ; Vérification d'erreur : est-ce que rax est dans [-4095, -1] ?
    cmp     rax, -4095
    jae     .handle_error       ; jae sur un nombre non signé détecte les grands nombres négatifs !
```

---

## 8.4 — Démarrage du Programme : `argc`, `argv` et `envp` sur la Pile

Quand le noyau Linux charge ton binaire au point d'entrée `_start` (sans passer par la libc `main`), **aucun registre ne contient tes arguments** !

Le noyau a tout déposé sur la pile au sommet de `RSP` :

```
  Sommet de pile à l'entrée exacte de _start :
  ─────────────────────────────────────────────────────────────
  [ RSP + 0 ]       : argc (Nombre d'arguments, entier 64 bits)
  [ RSP + 8 ]       : argv[0] (Pointeur sur le nom de l'exécutable)
  [ RSP + 16 ]      : argv[1] (Pointeur sur le 1er argument)
  [ RSP + 24 ]      : argv[2] (Pointeur sur le 2ème argument)
  ...
  [ RSP + 8*(argc+1)] : NULL (Pointeur 0 marquant la fin de argv)
  ─────────────────────────────────────────────────────────────
  [ Pointeur envp[0] ] : 1ère variable d'environnement ("PATH=...")
  [ Pointeur envp[1] ] : 2ème variable d'environnement
  ...
  [ NULL ]             : Fin des variables d'environnement
  ─────────────────────────────────────────────────────────────
```

### Exemple canonique : Lire `argc` et `argv[1]`
```asm
section .text
    global _start

_start:
    mov     r12, [rsp]          ; r12 = argc
    cmp     r12, 2
    jl      .no_argument        ; Si argc < 2, pas d'argument passé !

    mov     rsi, [rsp + 16]     ; rsi = argv[1] (pointeur vers la chaîne)
    ; Tu peux maintenant afficher ou analyser argv[1] !
```

---

## 8.5 — Entrées / Sorties sur Fichiers : Ouvrir, Lire, Écrire, Fermer

### Les Constantes de Drapeaux (*Flags*) pour `open` sous Linux x86_64 :
- **`O_RDONLY`** : `0` (Lecture seule)
- **`O_WRONLY`** : `1` (Écriture seule)
- **`O_RDWR`**   : `2` (Lecture et Écriture)
- **`O_CREAT`**  : `64` (`0x40` - Créer le fichier s'il n'existe pas)
- **`O_TRUNC`**  : `512` (`0x200` - Écraser et vider le fichier existant)
- **`O_APPEND`** : `1024` (`0x400` - Écrire à la suite)

### Le Pattern Complet d'I/O Fichier :
```asm
section .data
    filename    db "test.txt", 0
    content     db "Assembleur en action !", 10
    len         equ $ - content

section .text
    global _start

_start:
    ; 1. OPEN (Créer et ouvrir en écriture avec droits 0644)
    mov     rax, 2              ; sys_open
    mov     rdi, filename       ; chemin
    mov     rsi, 65             ; O_WRONLY (1) | O_CREAT (64) = 65
    mov     rdx, 0644o          ; permissions rw-r--r--
    syscall

    test    rax, rax
    js      .error              ; Si rax < 0, erreur
    mov     r12, rax            ; Sauvegarde du descripteur de fichier (FD)

    ; 2. WRITE
    mov     rax, 1              ; sys_write
    mov     rdi, r12            ; FD
    mov     rsi, content
    mov     rdx, len
    syscall

    ; 3. CLOSE
    mov     rax, 3              ; sys_close
    mov     rdi, r12
    syscall

    mov     rax, 60
    xor     rdi, rdi
    syscall

.error:
    mov     rax, 60
    mov     rdi, 84             ; Code d'erreur Epitech
    syscall
```

---

## 8.6 — Processus : `fork`, `execve` et `wait4`

Pour créer de nouveaux processus (comme le fera ton mini-shell au Projet 9), on utilise le triumvirat classique d'Unix :

1. **`sys_fork` (RAX = 57)** :
   Clone le processus courant.
   - Dans le processus **Parent** : `RAX` reçoit le **PID du fils** ($> 0$).
   - Dans le processus **Fils** : `RAX` reçoit **`0`**.
2. **`sys_execve` (RAX = 59)** :
   Exécute un binaire (`rdi = path`, `rsi = argv`, `rdx = envp`). Ne retourne que si une erreur survient.
3. **`sys_wait4` (RAX = 61)** :
   Le parent s'endort jusqu'à ce que son fils ait terminé.

---

## 📝 15 Exercices Pratiques — Niveau 4 (Série Chapitre 8)

### Exercice 1 — Afficher le premier argument passé en ligne de commande : `ex68_print_argv1.asm` ⭐⭐
- **Fichier** : `exercices/niveau-4/ex68_print_argv1.asm`
- **Consigne** :
  Récupère `argv[1]` depuis la pile. S'il existe, affiche-le sur `stdout` suivi d'un `\n` et quitte avec 0.
  Si aucun argument n'est fourni (`argc < 2`), quitte avec 84.
- **Test** : `./ex68_print_argv1 "Hello"` affiche `"Hello\n"`.

### Exercice 2 — Lire du texte au clavier (stdin) : `ex69_read_stdin.asm` ⭐⭐
- **Fichier** : `exercices/niveau-4/ex69_read_stdin.asm`
- **Consigne** :
  Utilise le syscall `read` sur le descripteur `0` (`stdin`) pour lire jusqu'à 64 octets dans un buffer en `.bss`.
  Réécris immédiatement ce qui a été lu sur `stdout`.

### Exercice 3 — Créer un fichier et y écrire : `ex70_create_file.asm` ⭐⭐
- **Fichier** : `exercices/niveau-4/ex70_create_file.asm`
- **Consigne** :
  Crée un fichier nommé `"output.txt"` avec les permissions `0644`.
  Écris-y `"OK\n"`, ferme le fichier et termine avec 0.

### Exercice 4 — Lire un fichier existant : `ex71_read_file.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-4/ex71_read_file.asm`
- **Consigne** :
  Ouvre le fichier `"output.txt"` créé à l'exercice précédent en lecture seule.
  Lis son contenu et affiche-le sur `stdout`. Si le fichier n'existe pas, quitte avec 84.

### Exercice 5 — Déplacer la tête de lecture avec `lseek` : `ex72_lseek.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-4/ex72_lseek.asm`
- **Consigne** :
  Soit un fichier contenant l'alphabet `"ABCDEFGHIJKLMNOPQRSTUVWXYZ"`.
  Utilise `lseek` pour sauter directement au 10ème caractère (offset 9 = `'J'`), lis 3 octets (`"JKL"`) et affiche-les.

### Exercice 6 — Obtenir son PID avec `getpid` : `ex73_getpid.asm` ⭐
- **Fichier** : `exercices/niveau-4/ex73_getpid.asm`
- **Consigne** :
  Appelle le syscall 39 (`getpid`). Le PID est renvoyé dans `rax`.
  Quitte avec les 8 bits de poids faible de ton PID comme code de sortie.

### Exercice 7 — Détecteur d'erreur de syscall : `ex74_check_error.asm` ⭐⭐
- **Fichier** : `exercices/niveau-4/ex74_check_error.asm`
- **Consigne** :
  Tente d'ouvrir un fichier qui n'existe absolument pas (`"inexistant_xyz.txt"`).
  Détecte que le retour est négatif. Affiche `"Erreur d'ouverture\n"` sur `stderr` et quitte avec 84.

### Exercice 8 — Somme des arguments passés en ligne de commande : `ex75_sum_args.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-4/ex75_sum_args.asm`
- **Consigne** :
  Reçois deux arguments numériques (ex: `./ex75_sum_args 12 30`).
  Convertis-les d'ASCII en entiers (`atoi`), additionne-les et quitte avec la somme (42).

### Exercice 9 — Redirection de descripteur avec `dup2` : `ex76_dup2.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-4/ex76_dup2.asm`
- **Consigne** :
  Ouvre un fichier en écriture. Utilise `dup2` pour rediriger `stdout` (FD 1) vers ce fichier.
  Fais un appel `write(1, ...)` ordinaire : le texte doit atterrir dans le fichier et rien ne doit sortir dans la console !

### Exercice 10 — Cloner un processus avec `fork` : `ex77_fork_simple.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-4/ex77_fork_simple.asm`
- **Consigne** :
  Appelle `fork`.
  - Le fils affiche `"Je suis le fils\n"` et quitte avec 10.
  - Le parent affiche `"Je suis le pere\n"`, attend le fils avec `wait4` et quitte avec 0.

### Exercice 11 — Lancer une commande avec `execve` : `ex78_execve_ls.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-4/ex78_execve_ls.asm`
- **Consigne** :
  Construis le tableau `argv` pour lancer `/bin/ls` avec `execve`.

### Exercice 12 — Remplacer `malloc` par `mmap` anonyme : `ex79_mmap_alloc.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-4/ex79_mmap_alloc.asm`
- **Consigne** :
  Alloue dynamiquement 4096 octets de mémoire vive vierge via `sys_mmap` (flags: `MAP_ANONYMOUS | MAP_PRIVATE`, protection `PROT_READ | PROT_WRITE`).
  Écris la valeur 42 au début de cette page, relis-la et retourne-la en exit code.

### Exercice 13 — Trouver la fin de l'environnement (`envp`) ⭐⭐
- **Fichier** : `exercices/niveau-4/ex80_count_env.asm`
- **Consigne** :
  Parcours la table `envp` sur la pile et compte combien de variables d'environnement sont transmises au démarrage de ton programme.

### Exercice 14 — Créer un Pipe IPC anonyme : `ex81_pipe_ipc.asm` ⭐⭐⭐⭐
- **Fichier** : `exercices/niveau-4/ex81_pipe_ipc.asm`
- **Consigne** :
  Crée un pipe avec `sys_pipe`. Écris `"PING"` dans `pipefd[1]`, puis lis depuis `pipefd[0]` et affiche la chaîne lue sur `stdout`.

### Exercice 15 — Pause temporelle avec `nanosleep` : `ex82_sleep.asm` ⭐⭐
- **Fichier** : `exercices/niveau-4/ex82_sleep.asm`
- **Consigne** :
  Déclare une structure `timespec { long tv_sec; long tv_nsec; }` avec 1 seconde et 0 nanoseconde.
  Appelle le syscall 35 (`nanosleep`) pour endormir le processus pendant exactement 1 seconde.

---

## 🎯 PROJET 4 (Style Epitech) — Les Outils du Système Unix : `my_cat`, `my_wc` & `my_echo`

```
================================================================================
                       ÉCOLE VIRTUELLE D'INGÉNIERIE SYSTÈME
                    Projet 4 : Utilitaires Système en Asm Pur
================================================================================
  Binaires attendus : my_echo, my_cat, my_wc
  Fichiers de rendu : Makefile, my_echo.asm, my_cat.asm, my_wc.asm
  Langage           : Assembleur x86_64 pur (NASM)
  Fonctions autoris.: Syscalls Linux directs uniquement (read, write, open, close, exit)
  Liaison           : Statique (ld) — AUCUNE LIBC
================================================================================
```

### 1. `my_echo`
- Affiche tous les arguments passés sur la ligne de commande séparés par un espace, suivi d'un retour à la ligne.
- Si aucun argument n'est fourni : affiche simplement un saut de ligne `\n`.

### 2. `my_cat`
- Si exécuté avec des noms de fichiers : lit chaque fichier et affiche son contenu intégral sur `stdout`.
- Si un fichier est introuvable : écrit sur `stderr` : `my_cat: fichier: No such file or directory\n` et continue les fichiers suivants, puis termine avec le code d'erreur `84`.
- Si exécuté sans argument : lit en continu sur l'entrée standard (`stdin`, fd 0) et le réécrit sur `stdout` jusqu'à rencontrer la fin de fichier (EOF / Ctrl+D).

### 3. `my_wc`
- Lit le fichier passé en paramètre (ou `stdin` par défaut) et compte :
  - Le nombre de lignes (`\n`)
  - Le nombre d'octets (*bytes*)
- Affiche les totaux formatés en colonnes.

---

## 🎯 PROJET 5 (Style Epitech) — L'Analyseur Binaire : `my_hexdump`

```
================================================================================
                       ÉCOLE VIRTUELLE D'INGÉNIERIE SYSTÈME
                    Projet 5 : Visualisateur Hexadécimal de Fichiers
================================================================================
  Binaire attendu   : my_hexdump
  Fichiers de rendu : Makefile, my_hexdump.asm
  Langage           : Assembleur x86_64 pur (NASM)
================================================================================
```

### Format d'Affichage Standard :
Pour chaque bloc de 16 octets lu dans le fichier, `my_hexdump` doit produire exactement une ligne formatée comme l'utilitaire système `hexdump -C` :

```
00000000  7f 45 4c 46 02 01 01 00  00 00 00 00 00 00 00 00  |.ELF............|
00000010  02 00 3e 00 01 00 00 00  00 10 40 00 00 00 00 00  |..>.......@.....|
```
- Colonne 1 : Déplacement d'offset en hexadécimal (8 chiffres hex).
- Colonne 2 : Les 16 octets imprimés en hexadécimal avec un double espace de séparation au milieu.
- Colonne 3 : Encadrement `|...|` affichant les caractères ASCII imprimables (ou un point `.` pour les octets non-imprimables < 32 ou > 126).

---

## 🧩 Mini-Quiz de fin de chapitre

1. Quel registre reçoit le 4ème argument lors d'un appel système x86_64 ?
2. Quels sont les deux registres irrémédiablement détruits par l'instruction processeur `syscall` ?
3. Comment le noyau Linux signale-t-il une erreur lors d'un syscall ?
4. Où se trouve le nombre d'arguments (`argc`) au démarrage de `_start` ?
5. Quels sont les 3 descripteurs de fichiers standard ouverts par défaut au démarrage d'un processus ?

<details>
<summary>Réponses du quiz</summary>

1. Le registre `R10` (contrairement à une fonction C où c'est `RCX`).
2. `RCX` (qui reçoit le RIP de retour) et `R11` (qui reçoit les RFLAGS).
3. Il renvoie dans `RAX` une valeur négative dans l'intervalle $[-4095, -1]$ équivalente à $-\text{errno}$.
4. Au sommet direct de la pile pointé par `RSP` (`[rsp]`).
5. `0` = Entrée standard (stdin), `1` = Sortie standard (stdout), `2` = Sortie d'erreur standard (stderr).
</details>

---

> 🏅 **Badge débloqué : Syscall Ninja** — Tu maîtrises la totalité de l'interface noyau de Linux. Passons à la mise en œuvre des Projets 4 et 5 !
