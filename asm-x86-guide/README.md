# 🚀 Guide Ultime d'Apprentissage de l'Assembleur x86_64
### *Conçu pour MacBook Pro Apple Silicon (M1–M5) — Pédagogie d'Excellence Style Epitech*

Bienvenue dans le cursus complet d'apprentissage de l'assembleur x86_64 sous Linux, spécialement adapté aux développeurs travaillant sur Mac Apple Silicon (ARM64).

Ce cours adopte une pédagogie active inspirée d'**Epitech** (*Learning by doing*, 30% théorie / 70% pratique, projets progressifs, tests automatisés type moulinette et autonomie).

---

## ⚡ Démarrage Rapide (En 2 minutes)

Depuis ton terminal macOS :

```bash
# 1. Se placer dans le dossier du cours
cd /Users/ola1911/.gemini/antigravity/scratch/asm-x86-guide

# 2. Construire l'image Docker x86_64 (une seule fois)
docker build --platform linux/amd64 -t asm-x86 ./docker

# 3. Lancer l'environnement de développement interactif
docker run --platform linux/amd64 -it --rm \
  --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
  -v "$(pwd)":/workspace -w /workspace \
  asm-x86
```

> **Conseil confort** : Ajoute l'alias dans ton `~/.zshrc` sur macOS :
> ```bash
> alias asmx='docker run --platform linux/amd64 -it --rm --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -v "$(pwd)":/workspace -w /workspace asm-x86'
> ```

---

## 🗺️ Sommaire Général du Cours

### [NIVEAU 0 — L'Environnement de Travail](cours/00-environnement.md) 🏅 *Badge Bootstrapper*
- Comprendre la différence ARM64 (ton Mac M5) vs x86_64 (la cible).
- Configuration optimale de Docker Desktop avec **Rosetta for Linux** (80-90% de performance native).
- Ton premier **Hello World** assemblé, linké et exécuté en 15 minutes.
- Voie alternative macOS via Rosetta 2 (`nasm -f macho64`, `lldb`).
- Guide de dépannage (*Troubleshooting*) des 10 erreurs les plus courantes.

### [NIVEAU 1 — Fondations Matérielles & Mémoire](cours/01-fondations-ordinateur.md) 🏅 *Badge Numérologue & Archéologue Binaire*
- **[Chapitre 1 — Comment fonctionne un ordinateur](cours/01-fondations-ordinateur.md)** : CPU, ALU, Bus, RAM, cycle *Fetch-Decode-Execute*, binaire, hexadécimal, complément à 2, Little-Endian, opérations bit à bit (`AND`, `OR`, `XOR`, `NOT`, `SHL`, `SAR`).
- **[Chapitre 2 — Du Code Source au Binaire (ELF & Mémoire)](cours/02-compilation-et-memoire.md)** : Préprocesseur, assembleur, linker, loader. Structure du binaire ELF (`.text`, `.data`, `.bss`, `.rodata`). Cartographie mémoire d'un processus Linux (pile vs tas). Boîte à outils : `readelf`, `objdump`, `nm`, `strings`, `xxd`.

### [NIVEAU 2 — Le Langage Assembleur en Action](cours/03-premiers-pas-asm.md) 🏅 *Badge Assembleur Débutant, Calculateur & Dompteur de Mémoire*
- **[Chapitre 3 — Premiers Pas en Assembleur](cours/03-premiers-pas-asm.md)** : Syntaxe Intel vs AT&T, les 16 registres x86_64 et leur découpage (`rax`, `eax`, `ax`, `al`), règle de mise à zéro des 32b de poids fort, `mov`, `movzx`, `movsx`, norme de style Epitech.
  - 🎯 **[Projet 1 : Hello World & Output Dispatcher](projets/01-hello-world/sujet.md)**
- **[Chapitre 4 — Arithmétique, RFLAGS et LEA](cours/04-arithmetique-et-logique.md)** : `add`, `sub`, `inc`, `dec`, `neg`. Multiplication 128b sur `RDX:RAX` (`mul`/`imul`). Division (`div`/`idiv`) avec `cqo` et prévention du crash de division par zéro. Les 5 drapeaux de `RFLAGS` (`ZF`, `CF`, `SF`, `OF`, `PF`). La puissance de calcul de `lea`.
  - 🎯 **[Projet 2 : La Calculatrice Arithmétique](projets/02-calculatrice/sujet.md)**
- **[Chapitre 5 — Contrôle de Flux et Boucles](cours/05-controle-de-flux.md)** : Comparaisons `cmp` et `test`. Sauts signés (`jg`, `jl`) vs non-signés (`ja`, `jb`). Traduction systématique C $\rightarrow$ Asm (`if/else`, `while`, `for`). Instructions sans branchement `cmov` et `setcc`. Bannissement de `loop`. Les tables de saut (*Jump Tables*) pour les `switch/case`.
- **[Chapitre 6 — Adressage Avancé, Directives NASM et Chaînes](cours/06-adressage-et-donnees.md)** : Formule universelle `[Base + Index*Échelle + Déplacement]`. Adressage RIP-relatif pour PIE et macOS. Directives `db`, `resb`, `equ`, `$`, `times`, macros. Instructions matérielles de chaînes (`rep movsb`, `rep stosb`, `repne scasb`). Inversion d'endianness avec `bswap`.
  - 🎯 **[Projet 3 : Les Fondations de la Minilibc (strlen & strcmp)](projets/03-mini-strlen/sujet.md)**

### [NIVEAU 3 — La Pile, les Fonctions et l'ABI System V](cours/07-pile-et-fonctions.md) 🏅 *Badge Maître de la Pile*
- **[Chapitre 7 — Pile et Fonctions](cours/07-pile-et-fonctions.md)** : Mécanique de la pile vers le bas (`push`, `pop`, `rsp`). Le cadre de pile (*Stack Frame*) : prologue, repère `RBP`, variables locales et épilogue (`leave; ret`). L'**ABI System V AMD64** : ordre des arguments (`rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`), registres *caller-saved* vs *callee-saved*. **Règle absolue d'alignement 16 octets de la pile**. La Red Zone de 128 octets. Fonctions récursives (Factorielle, Fibonacci, Hanoï). Structures en mémoire et padding.

### [NIVEAU 4 — Interface avec le Système et le C](cours/08-appels-systeme.md) 🏅 *Badge Syscall Ninja & Polyglotte*
- **[Chapitre 8 — Les Appels Système Linux](cours/08-appels-systeme.md)** : Transition Ring 3 $\rightarrow$ Ring 0 (`syscall`). Le 4ème argument dans **`R10`** (et non pas `RCX`). Écrasement matériel de `RCX` et `R11`. Gestion des erreurs $[-4095, -1] \equiv -\text{errno}$. Récupération de `argc`, `argv`, `envp` sur la pile au démarrage. I/O Fichiers (`open`, `read`, `write`, `close`, `lseek`). Processus (`fork`, `execve`, `wait4`).
  - 🎯 **[Projet 4 : Utilitaires Unix (my_echo, my_cat, my_wc)](projets/04-mini-cat-wc-echo/sujet.md)**
  - 🎯 **[Projet 5 : Visualisateur Hexadécimal (my_hexdump)](projets/05-mini-hexdump/sujet.md)**
- **[Chapitre 9 — Interfaçage avec le C et la Minilibc](cours/09-interface-avec-le-c.md)** : Appeler le C depuis l'assembleur (`printf`, `malloc`, `puts`...). Mettre `AL = 0` pour les fonctions variadiques. Appeler de l'assembleur depuis le C. La PLT et la GOT (résolution dynamique). Création d'une bibliothèque partagée dynamique **`libasm.so`** et injection via **`LD_PRELOAD`**.
  - 🎯 **[Projet 6 : La Minilibc Complète (12 fonctions)](projets/06-minilibc/sujet.md)**

### [NIVEAU 5 — Outils, Débogage et Projets Intégrateurs](cours/10-outils-et-debug.md) 🏅 *Badge Architecte Système*
- **[Chapitre 10 — Outils et Débogage Avancé](cours/10-outils-et-debug.md)** : Maîtriser **GDB** au niveau de l'instruction (`stepi`, `nexti`, inspection mémoire `x/16gx`, mode TUI). Correspondance avec **LLDB**. Autopsie des crashes (`SIGSEGV`, `SIGFPE`, `SIGILL`). Résolution des erreurs NASM et LD.
- **[Chapitre 11 — Les Projets Intégrateurs Avancés](cours/11-projets-avances.md)** :
  - 🎯 **[Projet 7 : Convertisseur de Bases Universel](projets/07-convertisseur-bases/sujet.md)** (binaire, octal, décimal, hexa).
  - 🎯 **[Projet 8 : Jeu "Devine le Nombre"](projets/08-devine-le-nombre/sujet.md)** (PRNG XORShift 64 en assembleur pur).
  - 🎯 **[Projet 9 : Mini-Shell Unix (my_sh)](projets/09-mini-shell/sujet.md)** (prompt, parsing, fork, execve, wait4, builtin exit).
  - 🎯 **[Projet 10 : Serveur Web TCP Minimaliste](projets/10-serveur-tcp/sujet.md)** (socket, bind, listen, accept, read, write HTTP).

### [NIVEAU 6 — Ouverture et Approfondissement](cours/12-notions-avancees.md) 🏅 *Badge Sage de l'Assembleur*
- **[Chapitre 12 — SIMD, Micro-Architecture, Sécurité et Pont ARM64](cours/12-notions-avancees.md)** :
  - Instructions vectorielles **SIMD** (SSE / AVX) sur registres `XMM0-15`.
  - Micro-architecture : pipeline superscalaire, exécution out-of-order, caches L1/L2/L3.
  - Sécurité : anatomie du *Buffer Overflow*, Stack Canaries, NX/DEP, ASLR, PIE.
  - Lecture de désassemblage optimisé (`gcc -O0` vs `gcc -O3`).
  - **Le Pont vers l'Apple Silicon M5 : Comparaison détaillée x86_64 (CISC) vs ARM64 (RISC)**.

---

## 📚 Les Annexes de Référence Imprimables

- **[A-cheatsheet-registres.md](annexes/A-cheatsheet-registres.md)** : Découpage, rôles ABI et statuts des 16 registres.
- **[A-cheatsheet-instructions.md](annexes/A-cheatsheet-instructions.md)** : Toutes les instructions essentielles regroupées par famille.
- **[A-cheatsheet-syscalls.md](annexes/A-cheatsheet-syscalls.md)** : Table complète des numéros et paramètres de syscalls Linux x86_64.
- **[A-cheatsheet-abi.md](annexes/A-cheatsheet-abi.md)** : Résumé de l'ABI System V AMD64 (paramètres, retour, alignement 16b, Red Zone).
- **[A-cheatsheet-gdb.md](annexes/A-cheatsheet-gdb.md)** : Guide comparatif des commandes GDB et LLDB.
- **[A-macos-differences.md](annexes/A-macos-differences.md)** : Guide de portage et différences majeures macOS (Mach-O) vs Linux (ELF).
- **[A-glossaire.md](annexes/A-glossaire.md)** : Dictionnaire bilingue français-anglais des termes système.
- **[A-ressources.md](annexes/A-ressources.md)** : Liens officiels, manuels Intel, livres et plateformes d'entraînement.

---

## 🧪 Lancer les Moulinettes de Tests Automatisées

Chaque niveau et chaque projet dispose de son script de test automatisé :

```bash
# Dans le conteneur Docker :
bash exercices/niveau-0/run_tests.sh       # Tests Niveau 0
bash exercices/niveau-1/run_tests.sh       # Tests Niveau 1
bash exercices/niveau-2/run_tests_chap03.sh # Tests Niveau 2 (Série 3)
bash exercices/niveau-2/run_tests_chap04.sh # Tests Niveau 2 (Série 4)
bash exercices/niveau-3/run_tests_chap07.sh # Tests Niveau 3 (Pile & Fonctions)

# Tester les Projets :
bash projets/01-hello-world/tests/test_hello.sh
bash projets/02-calculatrice/tests/test_calc.sh
bash projets/03-mini-strlen/tests/test_minilibc.sh
bash projets/04-mini-cat-wc-echo/tests/test_tools.sh
bash projets/05-mini-hexdump/tests/test_hexdump.sh
bash projets/06-minilibc/tests/test_minilibc_full.sh
bash projets/07-convertisseur-bases/tests/test_base.sh
```

Bon apprentissage ! 🚀
