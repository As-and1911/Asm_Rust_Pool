# Chapitre 0 — Environnement de travail

## 🎯 Objectifs de ce chapitre

À la fin de ce chapitre, tu seras capable de :
- [ ] Comprendre pourquoi tu as besoin d'un environnement spécial sur ton Mac Apple Silicon
- [ ] Installer et configurer Docker pour exécuter du code x86_64
- [ ] Écrire, assembler, linker et exécuter ton premier programme assembleur
- [ ] Connaître le workflow « éditer sur macOS, compiler dans Docker »
- [ ] (Optionnel) Utiliser la voie alternative Rosetta 2 pour le debugging

## 📋 Prérequis

- Un Mac Apple Silicon (M1 à M5)
- Être à l'aise avec le terminal (cd, ls, mkdir, cat)
- Avoir des bases en C (pas obligatoire, mais recommandé)
- De la motivation ! 💪

## ⏱️ Durée estimée : 2–3 heures

---

## 0.1 — Pourquoi apprendre l'assembleur ?

### Démystifions l'assembleur

L'assembleur (ou « asm ») a une réputation intimidante. On l'imagine réservé aux hackers, aux développeurs de drivers, ou aux barbus du noyau Linux. C'est un mythe.

**L'assembleur, c'est simple.** Non, vraiment. Chaque instruction fait *une seule chose*. `mov rax, 42` met le nombre 42 dans le registre rax. Point. Pas de classes abstraites, pas d'héritage, pas de templates. Juste des instructions qui déplacent des nombres.

Ce qui est *difficile*, ce n'est pas le langage — c'est de **penser comme la machine**. Et c'est justement ça qui est précieux.

### Pourquoi investir du temps ?

| Raison | Détail |
|--------|--------|
| **Comprendre la machine** | Tu sauras comment un programme tourne *réellement* |
| **Devenir meilleur en C** | Tu comprendras les pointeurs, la pile, la mémoire |
| **Sécurité informatique** | Reverse engineering, exploitation, CTF |
| **Performance** | Optimiser du code critique (jeux, audio, crypto) |
| **Systèmes embarqués** | Bootloaders, drivers, firmware |
| **Culture d'ingénieur** | Un dev qui connaît l'asm a un avantage définitif |
| **Épater tes camarades** | Soyons honnêtes, ça joue aussi 😄 |

### Ce que tu vas construire dans ce cours

Au fil des semaines, tu passeras de « Hello World » à des projets réels :
- Une **calculatrice** en asm pur
- Ta propre **bibliothèque C** (strlen, strcmp, memcpy…) écrite en assembleur
- Un **mini-cat** et un **mini-hexdump** qui lisent de vrais fichiers
- Un **mini-shell** qui fork et exec des commandes
- Et même un **serveur TCP** qui communique via les syscalls du noyau

Chaque étape te donnera un sentiment de puissance croissant. Tu verras.

---

## 0.2 — Ta machine vs ta cible : ARM64 ≠ x86_64

### Le problème

Ton MacBook Pro M5 utilise un processeur **Apple Silicon**, basé sur l'architecture **ARM64** (aussi appelée AArch64). C'est une architecture de type **RISC** (Reduced Instruction Set Computer).

Mais dans ce cours, tu vas apprendre l'assembleur **x86_64** (aussi appelé AMD64 ou Intel 64). C'est une architecture de type **CISC** (Complex Instruction Set Computer), utilisée par les processeurs Intel et AMD.

```
┌───────────────────────────────────┬───────────────────────────────────┐
│       TON MAC (M5)                │       CE QUE TU VAS APPRENDRE    │
├───────────────────────────────────┼───────────────────────────────────┤
│  Architecture : ARM64 (AArch64)   │  Architecture : x86_64 (AMD64)   │
│  Type : RISC                      │  Type : CISC                      │
│  Registres : x0–x30, sp, pc      │  Registres : rax–r15, rsp, rip   │
│  Instructions : fixes (32 bits)  │  Instructions : variables (1–15)  │
│  Syscall : svc #0x80             │  Syscall : syscall                │
│  OS : macOS (Mach-O)             │  OS : Linux (ELF)                 │
└───────────────────────────────────┴───────────────────────────────────┘
```

### Pourquoi apprendre x86_64 et pas ARM64 ?

- **x86_64 est le standard de l'enseignement** (Epitech, 42, universités)
- La **documentation** et les **tutoriels** sont beaucoup plus abondants
- C'est l'architecture des **serveurs**, du **reverse engineering** et des **CTF**
- La majorité du code désassemblé que tu rencontreras sera en x86_64
- Tu pourras toujours apprendre ARM64 ensuite — le chapitre 12 fait le pont

### La solution : l'émulation

Puisque ton processeur ne comprend pas le x86_64, on va utiliser un **traducteur** : un conteneur Docker qui fait tourner un Linux x86_64 émulé.

```
   Ton code x86_64
        │
        ▼
  ┌──────────────┐
  │   Conteneur  │  Linux x86_64 (Ubuntu)
  │   Docker     │  NASM, GCC, LD, GDB*
  │              │
  │  ┌────────┐  │
  │  │Rosetta │  │  Traduit x86_64 → ARM64
  │  │  for   │  │  à la volée (rapide !)
  │  │ Linux  │  │
  │  └────────┘  │
  └──────────────┘
        │
        ▼
  Processeur ARM64 (M5)
  Exécute les instructions ARM64 traduites
```

---

## 0.3 — Installation : la voie Docker (recommandée)

### Étape 1 : Installer Docker Desktop

Si Docker Desktop n'est pas installé :

1. Va sur [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)
2. Télécharge la version **Apple Silicon**
3. Installe et lance Docker Desktop
4. Attends que l'icône Docker dans la barre de menu indique « Running »

> [!TIP]
> **Alternatives gratuites à Docker Desktop :**
> - **OrbStack** (gratuit pour usage personnel) : plus léger, plus rapide → [orbstack.dev](https://orbstack.dev)
> - **Colima** (open source) : `brew install colima docker` puis `colima start --vm-type=vz --vz-rosetta`

### Étape 2 : Activer Rosetta for Linux

C'est **crucial** pour les performances. Sans Rosetta, Docker utilise QEMU qui est 5 à 10 fois plus lent.

1. Ouvre Docker Desktop → **Settings** (⚙️)
2. Va dans **General**
3. Coche ✅ **« Use Virtualization framework »**
4. Coche ✅ **« Use Rosetta for x86_64/amd64 emulation on Apple Silicon »**
5. Clique **Apply & Restart**

> [!IMPORTANT]
> Si l'option Rosetta n'apparaît pas, assure-toi que Rosetta 2 est installé sur macOS :
> ```bash
> softwareupdate --install-rosetta
> ```

### Étape 3 : Créer le dossier de travail

```bash
# Crée le dossier principal pour tout le cours
mkdir -p ~/asm-x86
cd ~/asm-x86

# Clone ou copie le guide (si tu l'as en local)
# Sinon, crée la structure minimale :
mkdir -p exercices/niveau-0
```

### Étape 4 : Construire l'image Docker

Le Dockerfile est fourni dans `docker/Dockerfile`. Il installe tout ce dont tu as besoin : NASM, GCC, LD, GDB, Make, objdump, xxd, strace.

```bash
# Depuis la racine du projet (~/asm-x86)
docker build --platform linux/amd64 -t asm-x86 ./docker
```

⏱️ La première construction prend 2–5 minutes (téléchargement d'Ubuntu + outils).

> [!NOTE]
> Tu ne construis l'image qu'**une seule fois**. Ensuite, tu ne fais que la lancer.

### Étape 5 : Lancer le conteneur

```bash
# Lancer un shell interactif dans le conteneur
docker run --platform linux/amd64 -it --rm \
  --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
  -v "$(pwd)":/workspace \
  -w /workspace \
  asm-x86
```

Décomposons cette commande :

| Option | Rôle |
|--------|------|
| `--platform linux/amd64` | Force l'architecture x86_64 |
| `-it` | Mode interactif avec terminal |
| `--rm` | Supprime le conteneur à la sortie |
| `--cap-add=SYS_PTRACE` | Permet à GDB/strace d'utiliser ptrace |
| `--security-opt seccomp=unconfined` | Désactive les restrictions de sécurité (nécessaire pour le debug) |
| `-v "$(pwd)":/workspace` | Monte ton dossier local dans le conteneur |
| `-w /workspace` | Se place dans ce dossier au démarrage |

Tu devrais voir un prompt qui ressemble à :
```
[asm-x86] /workspace $
```

**🎉 Tu es dans un Linux x86_64 !** Vérifie :

```bash
uname -m
# Doit afficher : x86_64

nasm --version
# Doit afficher : NASM version 2.15.xx

gcc --version
# Doit afficher : gcc (Ubuntu ...) ...
```

### Étape 6 : Créer un alias pour gagner du temps

Pour ne pas retaper la longue commande Docker à chaque fois, ajoute cet alias à ton `~/.zshrc` (sur macOS) :

```bash
# Ajouter à ~/.zshrc sur macOS
echo 'alias asmx="docker run --platform linux/amd64 -it --rm --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -v \"\$(pwd)\":/workspace -w /workspace asm-x86"' >> ~/.zshrc
source ~/.zshrc
```

Désormais, un simple `asmx` depuis ton dossier de travail te place dans le conteneur.

### Workflow quotidien

```
┌─────────────── macOS ───────────────┐    ┌──────── Conteneur Docker ────────┐
│                                     │    │                                  │
│  1. Ouvre ton éditeur (VSCode/Vim)  │    │  3. nasm -f elf64 hello.asm      │
│  2. Écris/modifie ton fichier .asm  │    │     -o hello.o                   │
│                                     │    │  4. ld hello.o -o hello          │
│  Les fichiers sont partagés ! ◄─────┼────┤  5. ./hello                     │
│  (volume monté)                     │    │                                  │
│                                     │    │  Tes fichiers sont ici,          │
│  Tu édites ici ────────────────────►│    │  tu compiles/exécutes ici.       │
└─────────────────────────────────────┘    └──────────────────────────────────┘
```

> [!TIP]
> **Conseil VSCode** : installe l'extension « x86 and x86_64 Assembly » (13xforever) pour la coloration syntaxique des fichiers `.asm`.

---

## 0.4 — Ton premier programme : Hello World en 15 minutes 🚀

C'est le moment de vérité. On va écrire, assembler, linker et exécuter ton tout premier programme assembleur.

### Le code

Crée le fichier `exercices/niveau-0/hello.asm` sur macOS (dans ton éditeur favori) :

```asm
; =============================================================================
; Fichier : hello.asm
; Desc    : Premier programme — Hello World en assembleur x86_64 Linux
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
```

### Comprendre chaque ligne

Ne t'inquiète pas si tout n'est pas clair — on détaillera chaque concept dans les chapitres suivants. Pour l'instant, voici l'essentiel :

```
section .data          ← Zone des données (chaînes, constantes)
    msg db "Hello..."  ← Définit une suite d'octets en mémoire
    msg_len equ $ - msg ← Calcule la longueur (position courante - début)

section .text          ← Zone du code exécutable
    global _start      ← Rend _start visible pour l'éditeur de liens

_start:                ← Label = adresse du début du programme
    mov rax, 1         ← Met 1 dans le registre rax (numéro du syscall write)
    mov rdi, 1         ← Met 1 dans rdi (file descriptor = stdout)
    mov rsi, msg       ← Met l'adresse de msg dans rsi (tampon à écrire)
    mov rdx, msg_len   ← Met la longueur dans rdx (combien d'octets)
    syscall            ← Appelle le noyau Linux pour exécuter write(1, msg, 14)

    mov rax, 60        ← Numéro du syscall exit
    xor rdi, rdi       ← Astuce classique : met rdi à 0 (code de retour)
    syscall            ← Appelle exit(0)
```

**Analogie** : imagine que tu es au restaurant. Tu ne cuisines pas toi-même — tu *demandes* au serveur (le noyau Linux). Tu remplis un bon de commande (les registres) et tu sonnes (syscall). Le serveur lit ton bon et exécute.

| Registre | Rôle dans le « bon de commande » |
|----------|----------------------------------|
| `rax` | Numéro de la commande (quel syscall) |
| `rdi` | 1er argument |
| `rsi` | 2ème argument |
| `rdx` | 3ème argument |

### Assembler, linker, exécuter

Dans le **conteneur Docker** :

```bash
# 1. Se placer dans le bon dossier
cd exercices/niveau-0

# 2. Assembler : transforme le code source en code objet (.o)
nasm -f elf64 hello.asm -o hello.o

# 3. Linker : transforme le code objet en exécutable
ld hello.o -o hello

# 4. Exécuter !
./hello
```

**Sortie attendue :**
```
Hello, World!
```

### 🎉 Félicitations !

Tu viens d'exécuter ton premier programme en assembleur x86_64. Ce programme a parlé *directement au noyau Linux*, sans passer par aucune bibliothèque. Pas de printf, pas de libc. Juste toi et le processeur.

Vérifie aussi le code de retour :
```bash
./hello
echo $?
# Doit afficher : 0
```

### Comprendre les 3 étapes

```
  hello.asm          hello.o              hello
 ┌──────────┐      ┌──────────┐        ┌──────────┐
 │  Code    │ nasm │  Code    │   ld   │Exécutable│
 │  source  │─────►│  objet   │───────►│  ELF     │
 │  (texte) │      │ (binaire)│        │ (binaire)│
 └──────────┘      └──────────┘        └──────────┘
   Lisible par       Lisible par         Exécutable
   un humain         la machine          par Linux
                     (pas encore
                      exécutable)
```

| Étape | Outil | Entrée | Sortie | Que fait-il ? |
|-------|-------|--------|--------|---------------|
| Assemblage | `nasm` | `.asm` (texte) | `.o` (binaire) | Traduit les mnémoniques en opcodes |
| Édition de liens | `ld` | `.o` (objet) | exécutable | Résout les adresses, crée l'ELF final |

### Explorer le binaire

Avant de passer à la suite, explorons ce que tu as créé :

```bash
# Taille du fichier
ls -la hello
# → environ 8.7 Ko pour un simple Hello World !

# Type du fichier
file hello
# → hello: ELF 64-bit LSB executable, x86-64, version 1 (SYSV),
#   statically linked, not stripped

# Désassembler — retrouver tes instructions
objdump -d -M intel hello
# Tu devrais retrouver tes mov, syscall, etc.

# Voir les octets bruts en hexadécimal
xxd hello | head -20
```

---

## 0.5 — Voie alternative : Rosetta 2 sur macOS (optionnel)

> [!NOTE]
> Cette section est **optionnelle**. La voie Docker (section 0.3) est la voie principale du cours. Utilise cette voie si tu veux un debugging interactif avec lldb, ou si Docker te pose problème.

### Pourquoi une voie alternative ?

Le **debugging** (GDB/strace) est très limité dans Docker sur Apple Silicon à cause de problèmes avec `ptrace` sous émulation. Sur macOS natif, **lldb** fonctionne parfaitement avec les binaires x86_64 via Rosetta 2.

> [!WARNING]
> **Rosetta 2 vit ses dernières années.** Apple a annoncé que macOS 28 (~automne 2027) retirera le support général de Rosetta 2. Le cours reste donc centré sur Docker/Linux pour la portabilité. Mais pour l'apprentissage, Rosetta 2 fonctionne très bien aujourd'hui.

### Installation

```bash
# 1. Installer Rosetta 2 (si pas déjà fait)
softwareupdate --install-rosetta

# 2. Installer NASM via Homebrew
brew install nasm

# 3. Vérifier
nasm --version
# → NASM version 2.16.xx
```

### Hello World sur macOS

Crée le fichier `hello_macos.asm` :

```asm
; =============================================================================
; Hello World — x86_64 macOS (Rosetta 2)
; =============================================================================

section .data
    msg     db "Hello, World!", 10
    msg_len equ $ - msg

section .text
    global _main                        ; ← _main, pas _start !

_main:
    mov     rax, 0x2000004      ; ← write = 0x2000000 + 4
    mov     rdi, 1
    lea     rsi, [rel msg]      ; ← RIP-relatif OBLIGATOIRE sur macOS
    mov     rdx, msg_len
    syscall

    mov     rax, 0x2000001      ; ← exit = 0x2000000 + 1
    xor     rdi, rdi
    syscall
```

### Compiler et exécuter

```bash
# Assembler en format Mach-O 64 bits
nasm -f macho64 hello_macos.asm -o hello_macos.o

# Linker avec la bibliothèque système macOS
ld hello_macos.o -o hello_macos \
   -lSystem \
   -syslibroot $(xcrun --sdk macosx --show-sdk-path) \
   -e _main

# Exécuter (Rosetta 2 traduit automatiquement)
./hello_macos
```

### Les 5 différences clés macOS vs Linux

```
┌─────────────────────┬─────────────────────┬─────────────────────┐
│                     │      LINUX          │      macOS          │
├─────────────────────┼─────────────────────┼─────────────────────┤
│ Format objet        │ nasm -f elf64       │ nasm -f macho64     │
│ Point d'entrée      │ _start              │ _main               │
│ Préfixe symboles    │ (aucun)             │ _ (underscore)      │
│ Syscall write       │ rax = 1             │ rax = 0x2000004     │
│ Adressage données   │ mov rsi, msg        │ lea rsi, [rel msg]  │
│ Linker              │ ld prog.o -o prog   │ ld prog.o -o prog   │
│                     │                     │  -lSystem -syslibroot│
│                     │                     │  ... -e _main       │
└─────────────────────┴─────────────────────┴─────────────────────┘
```

> [!IMPORTANT]
> **Tous les exercices du cours utilisent la syntaxe Linux.** Si tu utilises la voie macOS, tu devras adapter chaque programme avec les 5 différences ci-dessus. Un chapitre d'annexe (`A-macos-differences.md`) fournira un guide de traduction systématique.

### Debugging avec lldb (le vrai avantage de cette voie)

```bash
# Lancer le debugger
lldb -arch x86_64 ./hello_macos

# Commandes essentielles
(lldb) b _main                      # Breakpoint au début
(lldb) run                          # Lancer le programme
(lldb) si                           # Exécuter UNE instruction
(lldb) register read                # Voir tous les registres x86_64
(lldb) register read rax rdi rsi    # Voir des registres spécifiques
(lldb) x/4gx $rsp                   # Examiner la mémoire (pile)
(lldb) disassemble --pc --count 10  # Voir les prochaines instructions
(lldb) quit                         # Quitter
```

Pour avoir la syntaxe Intel dans lldb :
```bash
echo 'settings set target.x86-disassembly-flavor intel' >> ~/.lldbinit
```

---

## 0.6 — Éditeur et bonnes habitudes

### Éditeur recommandé

**VSCode** avec les extensions :
- **x86 and x86_64 Assembly** (13xforever) — coloration syntaxique
- **Docker** (Microsoft) — gestion des conteneurs
- **Hex Editor** (Microsoft) — visualiser les binaires

Alternatives : Vim, Emacs, Sublime Text — n'importe quel éditeur de texte fait l'affaire. L'assembleur n'a pas besoin d'IDE sophistiqué.

### Conventions de code (style Epitech)

Dès le début, prends de bonnes habitudes. Voici les conventions que nous suivrons :

```asm
; =============================================================================
; Fichier : nom_du_fichier.asm
; Auteur  : ton_nom
; Date    : YYYY-MM-DD
; Desc    : description courte du programme
; =============================================================================

section .data
    msg     db "Hello", 10          ; Commentaire utile
    msg_len equ $ - msg             ; Pas de commentaire inutile

section .bss
    buffer  resb 64                 ; Buffer de lecture (64 octets)

section .text
    global _start

; -----------------------------------------------------------------------------
; _start — Point d'entrée du programme
; Description : affiche un message et quitte
; -----------------------------------------------------------------------------
_start:
    ; --- Afficher le message ---
    mov     rax, 1                  ; syscall write
    mov     rdi, 1                  ; stdout
    mov     rsi, msg                ; adresse du message
    mov     rdx, msg_len            ; longueur
    syscall

    ; --- Quitter ---
    mov     rax, 60                 ; syscall exit
    xor     rdi, rdi                ; code 0
    syscall
```

**Règles :**
1. **En-tête** en haut de chaque fichier (nom, auteur, date, description)
2. **Une instruction par ligne** — jamais deux sur la même ligne
3. **Alignement** des opérandes avec des espaces/tabulations
4. **Commentaires utiles** — expliquent le *pourquoi*, pas le *quoi*
   - ❌ `mov rax, 1   ; met 1 dans rax` (inutile)
   - ✅ `mov rax, 1   ; syscall write` (utile)
5. **Séparateurs visuels** entre les blocs logiques
6. **Labels explicites** — `print_message:` plutôt que `l1:`

---

## 0.7 — « Mon environnement ne marche pas » (Troubleshooting)

### Problème 1 : `docker: Cannot connect to the Docker daemon`

**Cause** : Docker Desktop n'est pas lancé.

**Solution** : Lance Docker Desktop depuis le Launchpad ou le dossier Applications.

### Problème 2 : `exec format error` ou `Exec format error`

**Cause** : Tu essaies d'exécuter un binaire compilé pour la mauvaise architecture.

**Solutions** :
```bash
# Vérifie que tu compiles DANS le conteneur, pas sur macOS
docker run --platform linux/amd64 -it --rm asm-x86

# Dans le conteneur :
nasm -f elf64 hello.asm -o hello.o    # ← elf64, pas macho64
ld hello.o -o hello
./hello
```

### Problème 3 : `nasm: command not found` (dans le conteneur)

**Cause** : L'image Docker n'a pas été construite correctement.

**Solution** :
```bash
# Reconstruire l'image
docker build --platform linux/amd64 --no-cache -t asm-x86 ./docker
```

### Problème 4 : `ld: warning: cannot find entry symbol _start`

**Cause** : Tu as oublié `global _start` dans ton code, ou tu as une faute de frappe.

**Solution** : Vérifie que ton code contient bien :
```asm
section .text
    global _start       ; ← cette ligne est indispensable

_start:                 ; ← et ce label aussi
```

### Problème 5 : `Segmentation fault (core dumped)`

**Cause** : Ton programme essaie d'accéder à de la mémoire interdite, ou tu as oublié de quitter proprement.

**Solution** : Assure-toi que ton programme se termine avec le syscall `exit` :
```asm
    mov     rax, 60     ; syscall exit
    xor     rdi, rdi    ; code 0
    syscall
```

Sans ces 3 lignes, le CPU continue à exécuter n'importe quoi après ton code → segfault garanti.

### Problème 6 : GDB ne fonctionne pas dans Docker (`ptrace: Operation not permitted`)

**Cause** : C'est une limitation connue de l'émulation x86_64 sur Apple Silicon. `ptrace` (utilisé par GDB et strace) n'est pas entièrement supporté sous Rosetta for Linux ni sous QEMU.

**Solutions** (par ordre de praticité) :

1. **Printf-debugging** : utilise le syscall `write` pour afficher l'état de tes variables (c'est ce que les vrais devs asm font souvent !)

2. **objdump** : désassemble ton binaire pour vérifier qu'il est correct
   ```bash
   objdump -d -M intel hello
   ```

3. **ROSETTA_DEBUGSERVER_PORT** (fragile, mais ça peut marcher) :
   ```bash
   # Terminal 1 : lancer le programme avec le debug server
   ROSETTA_DEBUGSERVER_PORT=1234 ./hello &

   # Terminal 2 : connecter GDB
   gdb ./hello
   (gdb) target remote localhost:1234
   (gdb) continue
   ```

4. **Voie macOS** : utilise la voie Rosetta 2 (section 0.5) avec lldb pour le debugging interactif — c'est la meilleure solution pour le debug sur Apple Silicon.

5. **VM distante** : Si tu as accès à un serveur Linux x86_64 (AWS free tier, université, etc.), GDB y fonctionne parfaitement via SSH.

### Problème 7 : `strace` ne fonctionne pas dans Docker

**Cause** : Même problème que GDB — `ptrace` est cassé sous émulation.

**Solution** : Utilise `QEMU_STRACE=1` (nécessite de désactiver Rosetta dans Docker Desktop) :
```bash
# Dans Docker Desktop : décocher Rosetta, Apply & Restart
# Puis dans le conteneur :
QEMU_STRACE=1 ./hello
```

Ou désassemble simplement le programme pour voir ses syscalls :
```bash
objdump -d -M intel hello | grep syscall -B5
```

### Problème 8 : macOS — `ld: unsupported relocation type`

**Cause** : Tu utilises un adressage absolu au lieu de RIP-relatif sur macOS.

**Solution** : Remplace `mov rsi, msg` par `lea rsi, [rel msg]` :
```asm
; ❌ Ne fonctionne PAS sur macOS
mov     rsi, msg

; ✅ Fonctionne sur macOS (RIP-relatif)
lea     rsi, [rel msg]
```

### Problème 9 : macOS — `zsh: killed ./hello_macos`

**Cause** : Le point d'entrée est incorrect. macOS avec `-lSystem` attend `_main`, pas `_start`.

**Solution** :
```asm
global _main        ; ← pas _start
_main:              ; ← pas _start:
```

### Problème 10 : Le conteneur est très lent

**Cause** : Rosetta for Linux n'est pas activé. Docker utilise QEMU (5-10x plus lent).

**Solution** : Active Rosetta dans Docker Desktop → Settings → General (voir section 0.3, étape 2).

---

## 📝 Exercices du Niveau 0

### Exercice 0 — Vérification de l'environnement ⭐
- **Durée** : 10 min
- **Objectif** : Confirmer que tous les outils fonctionnent
- **Consigne** :

1. Lance ton conteneur Docker
2. Vérifie que ces commandes fonctionnent :
   ```bash
   uname -m          # → x86_64
   nasm --version     # → NASM version 2.15+
   ld --version       # → GNU ld ...
   gcc --version      # → gcc ...
   make --version     # → GNU Make ...
   objdump --version  # → GNU objdump ...
   ```
3. Lance le script de tests :
   ```bash
   bash exercices/niveau-0/run_tests.sh
   ```
   Les tests des outils doivent passer. Les tests des exercices seront en « SKIP » — c'est normal, tu ne les as pas encore faits !

---

### Exercice 1 — Afficher ton nom ⭐
- **Durée** : 15 min
- **Objectif** : Modifier un programme existant pour l'adapter
- **Fichier à créer** : `exercices/niveau-0/ex01_mon_nom.asm`
- **Consigne** : Écris un programme qui affiche **ton prénom et nom** suivi d'un retour à la ligne. Par exemple : `Jean Dupont\n`

<details>
<summary>💡 Indice niveau 1 (piste)</summary>

Reprends le code de `hello.asm` et modifie la chaîne dans `section .data`.
</details>

<details>
<summary>💡 Indice niveau 2 (plus précis)</summary>

Change la ligne `msg db "Hello, World!", 10` en `msg db "Ton Nom", 10`. N'oublie pas que `msg_len` se calcule tout seul grâce à `equ $ - msg`.
</details>

<details>
<summary>💡 Indice niveau 3 (squelette)</summary>

```asm
section .data
    nom     db "___TON_NOM___", 10
    nom_len equ $ - nom

section .text
    global _start

_start:
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, nom
    mov     rdx, nom_len
    syscall

    mov     rax, 60
    xor     rdi, rdi
    syscall
```
</details>

---

### Exercice 2 — Code de retour personnalisé ⭐
- **Durée** : 10 min
- **Objectif** : Comprendre le code de retour d'un programme
- **Fichier à créer** : `exercices/niveau-0/ex02_code_retour.asm`
- **Consigne** : Écris un programme qui ne fait **rien** (n'affiche rien) mais qui retourne le code de sortie **42**.

Vérifie avec :
```bash
./ex02_code_retour
echo $?
# Doit afficher : 42
```

<details>
<summary>💡 Indice niveau 1</summary>

Tu n'as besoin que de la section `.text` et du syscall `exit`. Pas de `write`, pas de `section .data`.
</details>

<details>
<summary>💡 Indice niveau 2</summary>

Le code de retour est passé dans `rdi` au syscall `exit`. Remplace `xor rdi, rdi` par `mov rdi, 42`.
</details>

---

### Exercice 3 — Affichage multi-lignes ⭐⭐
- **Durée** : 20 min
- **Objectif** : Appeler le syscall `write` plusieurs fois
- **Fichier à créer** : `exercices/niveau-0/ex03_multi_lignes.asm`
- **Consigne** : Affiche au moins **3 lignes** de texte différentes, chacune suivie d'un retour à la ligne.

Exemple de sortie :
```
Ligne 1 : Bonjour !
Ligne 2 : Je fais de l'assembleur.
Ligne 3 : Et c'est genial !
```

<details>
<summary>💡 Indice niveau 1</summary>

Tu dois définir 3 chaînes séparées dans `.data`, chacune avec sa propre longueur, et faire 3 appels `write` successifs.
</details>

<details>
<summary>💡 Indice niveau 2</summary>

Attention : après chaque `syscall`, les registres `rax`, `rcx` et `r11` sont modifiés par le noyau. Tu dois donc remettre `rax = 1` et `rdi = 1` avant chaque nouveau `write`.
</details>

---

### Exercice 4 — Triangle d'étoiles ⭐⭐
- **Durée** : 25 min
- **Objectif** : Manipuler plusieurs données, commencer à « dessiner » en terminal
- **Fichier à créer** : `exercices/niveau-0/ex04_triangle.asm`
- **Consigne** : Affiche un triangle de 5 lignes fait d'étoiles :

```
*
**
***
****
*****
```

> [!NOTE]
> À ce stade, tu ne sais pas encore faire de boucles. C'est normal ! Définis les 5 lignes en dur dans `.data`. On apprendra les boucles au chapitre 5.

<details>
<summary>💡 Indice niveau 1</summary>

Définis 5 chaînes : `"*\n"`, `"**\n"`, `"***\n"`, etc. Chacune avec sa propre longueur. Puis 5 appels `write`.
</details>

---

### Exercice 5 — Écris ton premier Makefile ⭐⭐
- **Durée** : 20 min
- **Objectif** : Automatiser la compilation
- **Fichier à créer** : `exercices/niveau-0/Makefile`
- **Consigne** : Écris un Makefile qui :
  1. Compile **tous** les fichiers `.asm` du répertoire (cible `all`)
  2. Supprime les fichiers `.o` et les exécutables (cible `clean`)
  3. Fait un `clean` + `all` (cible `re`)

Test :
```bash
make          # Compile tout
make clean    # Nettoie
make re       # Recompile
```

<details>
<summary>💡 Indice niveau 1</summary>

Tu peux utiliser `$(wildcard *.asm)` pour lister tous les fichiers `.asm` et les règles de pattern `%: %.asm` pour la compilation générique.
</details>

<details>
<summary>💡 Indice niveau 2</summary>

```makefile
ASM = nasm
ASMFLAGS = -f elf64
LD = ld

SRCS = $(wildcard *.asm)
BINS = $(SRCS:.asm=)

all: $(BINS)

%: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@.o
	$(LD) $@.o -o $@

clean:
	rm -f *.o $(BINS)

re: clean all

.PHONY: all clean re
```
</details>

---

### Exercice 6 — Exploration d'un binaire ⭐
- **Durée** : 15 min
- **Objectif** : Utiliser les outils d'analyse
- **Consigne** : En utilisant le binaire `hello` que tu as compilé à l'exercice 0.4, réponds à ces questions :

1. Quelle est la taille du fichier `hello` en octets ? (`ls -la`)
2. Quel est le type du fichier ? (`file hello`)
3. Combien d'instructions assembleur contient-il ? (`objdump -d -M intel hello`)
4. Quelle est l'adresse mémoire de `_start` ? (`objdump -d hello | grep _start`)
5. Peux-tu retrouver la chaîne "Hello, World!" dans le binaire ? (`strings hello` ou `xxd hello | grep -i "Hello"`)

**Pas de code à écrire** — juste de l'exploration. Note tes réponses, on y reviendra au chapitre 2.

---

## 🧪 Lance la moulinette !

Après avoir fait les exercices, lance les tests :

```bash
# Dans le conteneur Docker, depuis la racine du projet
bash exercices/niveau-0/run_tests.sh
```

Objectif : **tous les tests en vert** (sauf ceux des exercices que tu n'as pas encore faits, qui seront en SKIP).

---

## ⚠️ Erreurs classiques et pièges du Niveau 0

| Erreur | Cause | Solution |
|--------|-------|----------|
| `Segmentation fault` | Pas de syscall `exit` à la fin | Ajoute toujours `mov rax, 60; xor rdi, rdi; syscall` |
| `hello.asm:3: error: ...` | Erreur de syntaxe NASM | Lis le message : il indique la ligne et le problème |
| Rien ne s'affiche | `rdi = 0` au lieu de `rdi = 1` dans write | `rdi = 1` pour stdout |
| Affichage tronqué | Mauvaise longueur dans `rdx` | Utilise `equ $ - msg` pour calculer automatiquement |
| `ld: ... undefined reference to _start` | Oublié `global _start` | Ajoute `global _start` avant le label |
| Le Makefile ne marche pas | Tabulations remplacées par des espaces | Les commandes Makefile DOIVENT utiliser des TAB, pas des espaces |

---

## 📊 Récapitulatif du Niveau 0

| Concept | Ce que tu as appris |
|---------|---------------------|
| **Architecture** | Ton Mac est ARM64, tu cibles x86_64 via Docker |
| **Docker** | Conteneur linux/amd64 avec NASM, GCC, LD |
| **Workflow** | Éditer sur macOS → compiler/exécuter dans Docker |
| **NASM** | `nasm -f elf64 fichier.asm -o fichier.o` |
| **LD** | `ld fichier.o -o fichier` |
| **Structure d'un programme** | `.data` (données) + `.text` (code) + `_start` |
| **Syscalls** | `write` (rax=1) et `exit` (rax=60) |
| **Commentaires** | `;` pour commenter en assembleur |
| **Makefile** | Automatiser assemblage + linkage |

---

## 🧩 Mini-quiz de fin de chapitre

Réponds sans regarder le cours :

1. Quelle commande assemble un fichier `.asm` en format ELF 64 bits ?
2. Quel est le numéro du syscall `write` sous Linux x86_64 ?
3. Dans quel registre met-on le numéro du syscall ?
4. Que se passe-t-il si on oublie le syscall `exit` à la fin ?
5. Quelle est la différence entre `section .data` et `section .text` ?
6. Que fait `xor rdi, rdi` ?
7. Pourquoi doit-on utiliser `lea rsi, [rel msg]` sur macOS au lieu de `mov rsi, msg` ?

<details>
<summary>Réponses</summary>

1. `nasm -f elf64 fichier.asm -o fichier.o`
2. 1
3. `rax`
4. Le CPU continue à exécuter la mémoire après le code → Segmentation fault
5. `.data` contient les données (chaînes, constantes), `.text` contient le code exécutable
6. Met `rdi` à 0 (tout nombre XOR lui-même = 0). C'est plus court et plus rapide que `mov rdi, 0`
7. macOS exige du code position-indépendant (PIE). L'adressage absolu est interdit — il faut utiliser l'adressage relatif au pointeur d'instruction (RIP)
</details>

---

## ✅ Checklist de fin de chapitre

- [ ] Docker est installé et l'image `asm-x86` est construite
- [ ] Rosetta for Linux est activé dans Docker Desktop
- [ ] J'ai mon alias `asmx` configuré
- [ ] Hello World compile et s'exécute dans Docker
- [ ] Je connais les 3 étapes : assembler → linker → exécuter
- [ ] J'ai fait au moins 4 exercices sur 6
- [ ] La moulinette passe sans erreur pour mes exercices
- [ ] Je comprends les différences macOS vs Linux (même si je n'utilise pas la voie macOS)
- [ ] Je sais quoi faire si GDB ne marche pas dans Docker

---

## ➡️ Prochain chapitre

**Chapitre 1 — Comment fonctionne un ordinateur** : CPU, registres, RAM, cycle fetch-decode-execute, systèmes de numération. On va comprendre *pourquoi* les instructions qu'on a écrites fonctionnent.

---

> 🏅 **Badge débloqué : Bootstrapper** — Ton environnement est prêt, tu as exécuté ton premier programme assembleur. La route est longue, mais le premier pas est fait. Bravo !
