# Chapitre 2 — Du Code Source au Binaire : Compilation, ELF et Mémoire

## 🎯 Objectifs de ce chapitre

À la fin de ce chapitre, tu seras capable de :
- [ ] Décrire les 4 étapes de la fabrication d'un exécutable (*Préprocesseur, Assembleur, Linker, Loader*).
- [ ] Comprendre en profondeur la structure d'un binaire **ELF** (*Executable and Linkable Format*) et ses sections fondamentales (`.text`, `.data`, `.rodata`, `.bss`).
- [ ] Connaître les différences structurelles avec le format **Mach-O** d'Apple.
- [ ] Visualiser la cartographie complète de la **mémoire virtuelle** d'un processus Linux x86_64.
- [ ] Différencier précisément le rôle et le fonctionnement de la **Pile (*Stack*)** et du **Tas (*Heap*)**.
- [ ] Utiliser couramment les outils d'inspection système : `readelf`, `objdump`, `nm`, `strings`, `xxd`.

## 📋 Prérequis
- Avoir assimilé le Chapitre 1 (notions d'adresses, Little-Endian, octets et registres).

## ⏱️ Durée estimée : 3–4 heures

---

## 2.1 — Le Pipeline de Traduction : De la source au processus en mémoire

Quand tu écris un programme, que ce soit en C ou en Assembleur, il traverse une chaîne de transformation rigoureuse avant de pouvoir être exécuté par le silicium :

```
             ┌────────────────────────┐
             │ Fichier Source (.asm)  │
             └───────────┬────────────┘
                         │ 
                         │ NASM (Assemblage)
                         ▼
             ┌────────────────────────┐
             │ Fichier Objet (.o)     │ ─── Opcodes machines + Table des symboles
             └───────────┬────────────┘     (adresses relatives non résolues)
                         │ 
                         │ LD (Éditeur de liens / Linker)
                         ▼
             ┌────────────────────────┐
             │  Binaire ELF (.exe)    │ ─── Exécutable complet sur disque
             └───────────┬────────────┘
                         │ 
                         │ execve() / OS Loader
                         ▼
             ┌────────────────────────┐
             │ Processus en Mémoire   │ ─── Pages de RAM mappées,
             │         (RAM)          │     registres initialisés, saut à _start
             └────────────────────────┘
```

### 1. L'Assembleur (`nasm`)
Il prend ton fichier texte `.asm` et traduit chaque mnémonique (`mov`, `add`, `syscall`) en son équivalent binaire strict : les **opcodes** (codes opérations).
Il produit un fichier **objet** (`.o`). Dans ce fichier, le code machine est déjà présent, mais les adresses absolues des fonctions ou des variables ne sont pas encore définitivement fixées.

### 2. L'Éditeur de Liens (`ld`)
Le *linker* rassemble un ou plusieurs fichiers objets, fusionne leurs sections identiques (tous les `.text` ensemble, tous les `.data` ensemble), résout les références croisées (symboles `extern` et `global`) et écrit l'en-tête de l'exécutable final.

### 3. Le Chargeur de Système (*OS Loader*)
Quand tu tapes `./mon_programme` dans ton terminal :
1. Le shell appelle le système d'exploitation via le syscall `execve`.
2. Le noyau Linux lit les en-têtes du fichier binaire ELF.
3. Il réserve un **espace d'adressage virtuel** pour le nouveau processus.
4. Il mappe les segments de l'exécutable dans la mémoire RAM.
5. Il initialise la pile (avec `argc`, `argv`, `envp`).
6. Il configure le pointeur d'instruction `RIP` sur l'adresse du point d'entrée (`_start`).
7. Le processeur commence à exécuter ton code !

---

## 2.2 — Anatomie d'un binaire ELF (x86_64 Linux)

Le format **ELF** (*Executable and Linkable Format*) est le standard universel sous Linux, BSD et Solaris pour les binaires, bibliothèques partagées (`.so`) et fichiers objets (`.o`).

```
┌─────────────────────────────────────────────────────────┐
│                     ELF HEADER                          │
│ - Nombre magique (0x7F 'E' 'L' 'F')                     │
│ - Architecture (64-bit, x86_64, Little-Endian)          │
│ - Point d'entrée (Adresse de _start, ex: 0x401000)      │
│ - Position des tables de Headers                        │
├─────────────────────────────────────────────────────────┤
│               PROGRAM HEADER TABLE (Segments)           │
│ Décrit au noyau comment charger le binaire en RAM       │
├─────────────────────────────────────────────────────────┤
│                     SECTIONS                            │
│                                                         │
│  .text    ──► Code machine exécutable (Lecture + Exec) │
│                                                         │
│  .rodata  ──► Données constantes en lecture seule       │
│                                                         │
│  .data    ──► Variables initialisées (Lecture + Écrit) │
│                                                         │
│  .bss     ──► Variables NON-initialisées (taille rés.)  │
│                                                         │
│  .symtab  ──► Table des symboles (noms de fonctions...) │
│  .strtab  ──► Table des chaînes de caractères (noms)    │
├─────────────────────────────────────────────────────────┤
│               SECTION HEADER TABLE                      │
│ Décrit la position et la taille de chaque section       │
└─────────────────────────────────────────────────────────┘
```

### Les 4 Sections Essentielles à Connaître :

| Section | Rôle | Permissions | Exemple typique |
|---------|------|-------------|-----------------|
| **`.text`** | Les instructions machine exécutées par le CPU | **R-X** (Read + Exec) | `mov rax, 1; syscall` |
| **`.rodata`** | *Read-Only Data* : Données constantes | **R--** (Read only) | Formats de chaînes `printf("Hello %s\n")` |
| **`.data`** | Données globales/statiques initialisées | **RW-** (Read + Write) | `msg db "Hello", 10` ou un compteur initialisé à `10` |
| **`.bss`** | Données globales réservées mais **non initialisées** | **RW-** (Read + Write) | `buffer resb 4096` |

> [!TIP]
> **Pourquoi la section `.bss` est-elle magique ?**
> La section `.bss` (*Block Started by Symbol*) **ne prend presque aucune place dans le fichier sur disque** !
> Si tu réserves un tampon de 10 mégaoctets avec `buffer resb 10485760` en `.bss`, ton binaire sur le disque ne grossit que de quelques octets (juste une ligne dans la table des sections disant *"réserve 10 Mo à l'exécution et remplis de zéros"*). Si tu faisais la même chose en `.data` avec des zéros explicites, ton fichier binaire ferait 10 Mo sur ton disque dur !

---

## 2.3 — Le format Mach-O (macOS) en comparaison

Sur macOS, Apple n'utilise pas le format ELF mais le format **Mach-O** (*Mach Object*).

```
┌───────────────────────────────────┬───────────────────────────────────┐
│           LINUX (ELF)             │           macOS (Mach-O)          │
├───────────────────────────────────┼───────────────────────────────────┤
│ Nombre magique : 0x7F 'E' 'L' 'F' │ Nombre magique : 0xFEEDFACF (64b) │
│ Format plat en Sections           │ Structure hiérarchique :          │
│                                   │ Segments (__TEXT, __DATA)         │
│                                   │ divisés en Sections (__text, ...) │
│ Section de code : `.text`         │ Section : `__TEXT,__text`         │
│ Section de données : `.data`      │ Section : `__DATA,__data`         │
│ Linker par défaut : `ld` (GNU)    │ Linker : `ld` (Apple / LLVM)      │
│ Exécutables statiques supportés   │ Exécutables statiques interdits   │
└───────────────────────────────────┴───────────────────────────────────┘
```

---

## 2.4 — Layout Mémoire d'un Processus en Exécution

Lorsque le programme est chargé en mémoire vive, l'OS lui attribue une mémoire virtuelle isolée de 64 bits (en pratique, sur x86_64, les adresses utilisent 48 bits, soit un espace gigantesque de 256 Téraoctets par processus).

Voici la cartographie standard de la mémoire d'un processus Linux x86_64 :

```
  Adresses Hautes
  0x7FFFFFFFFFFF ┌──────────────────────────────────────────────┐
                 │          ESPACE NOYAU (Kernel Space)         │ (Inaccessible directement)
  0x7FFF00000000 ├──────────────────────────────────────────────┤
                 │ ENVIRONNEMENT & ARGUMENTS (argc, argv, envp) │
                 ├──────────────────────────────────────────────┤
                 │             LA PILE (STACK)                  │
                 │              │                               │
                 │              ▼  Grandit vers le BAS          │
                 │                                              │
                 │                      ▲                       │
                 │                      │  Grandit vers le HAUT │
                 │             LE TAS (HEAP)                    │
                 ├──────────────────────────────────────────────┤
                 │    .bss (Variables non-initialisées = 0)     │
                 ├──────────────────────────────────────────────┤
                 │    .data (Variables globales initialisées)   │
                 ├──────────────────────────────────────────────┤
                 │    .text (Code machine du programme)         │
  0x000000400000 ├──────────────────────────────────────────────┤
                 │             Zone Réservée / Nulle            │ (Provoque Segfault si accès)
  0x000000000000 └──────────────────────────────────────────────┘
  Adresses Basses
```

---

## 2.5 — Pile (*Stack*) vs Tas (*Heap*) : Les Deux Mondes

| Critère | La Pile (*Stack*) | Le Tas (*Heap*) |
|---------|-------------------|-----------------|
| **Analogie** | Une pile d'assiettes bien ordonnée | Un gigantesque entrepôt de stockage |
| **Sens de croissance** | **Vers le bas** (vers les adresses décroissantes) | **Vers le haut** (adresses croissantes) |
| **Gestion** | Automatique par le CPU (`push`, `pop`, `rsp`) | Manuelle par le développeur (`malloc`/`free` ou syscall `brk`/`mmap`) |
| **Vitesse** | Ultra rapide (simple déplacement du registre `rsp`) | Plus lent (recherche de blocs libres) |
| **Durée de vie** | Liée à la fonction en cours | Persiste tant qu'on ne la libère pas |
| **Taille typique** | Limitée (souvent 8 Mo par défaut sous Linux) | Limitée uniquement par la RAM disponible |

---

## 2.6 — La Boîte à Outils de l'Archéologue Binaire

Tout bon ingénieur système doit savoir ausculter un binaire sans avoir accès au code source. Voici tes 5 commandes reines :

### 1. `file` : La carte d'identité
```bash
file mon_programme
# Sortie : ELF 64-bit LSB executable, x86-64, dynamically linked, not stripped
```

### 2. `readelf` : Le scanner médical ELF
```bash
# Lire le Header ELF principal
readelf -h mon_programme

# Lister toutes les sections et leurs adresses mémoires
readelf -S mon_programme
```

### 3. `objdump` : Le désassembleur
```bash
# Désassembler la section .text en syntaxe Intel
objdump -d -M intel mon_programme

# Afficher le contenu complet avec le code machine en hexadécimal
objdump -s -j .data mon_programme
```

### 4. `nm` : L'annuaire des symboles
```bash
# Lister les fonctions et variables exportées ou importées
nm mon_programme
```

### 5. `strings` et `xxd` : L'analyse brute
```bash
# Trouver toutes les chaînes de texte imprimables dans le binaire
strings mon_programme

# Dump hexadécimal des 64 premiers octets
xxd -l 64 mon_programme
```

---

## 📝 10 Exercices Pratiques d'Inspection Binaire

Ces exercices s'effectuent en ligne de commande dans ton conteneur Docker en utilisant le binaire `hello` généré au Niveau 0.

### Exercice 1 — Identification du nombre magique ELF ⭐
- Commande : `xxd -l 4 hello` ou `head -c 4 hello | xxd`
- **Question** : Quels sont les 4 premiers octets exacts en hexadécimal et que représentent-ils en ASCII ?

### Exercice 2 — Trouver l'adresse du point d'entrée (`Entry Point`) ⭐
- Commande : `readelf -h hello | grep "Entry point"`
- **Question** : À quelle adresse mémoire exacte l'OS sautera-t-il au démarrage du programme ?

### Exercice 3 — Inspection des sections ⭐
- Commande : `readelf -S hello`
- **Question** :
  1. Combien de sections compte ce binaire ?
  2. Quelles sont les adresses de départ de la section `.text` et de la section `.data` ?

### Exercice 4 — Comparaison de taille : .data vs .bss ⭐⭐
Crée deux programmes minimaux :
1. `prog_data.asm` qui déclare `tab times 1000000 db 1` en `.data`.
2. `prog_bss.asm` qui déclare `tab resb 1000000` en `.bss`.
Assemble et linke les deux. Compare leur taille avec `ls -lh`.
- **Question** : Quelle est la différence de taille sur le disque ? Explique pourquoi.

### Exercice 5 — Décodage des Opcodes à la main ⭐⭐
Désassemble ton programme avec `objdump -d -M intel hello`.
Regarde la ligne correspondant à :
`mov rax, 1` ou `mov rax, 60`.
- **Question** : Quels sont les octets machines qui composent cette instruction ?

### Exercice 6 — Extraction de chaîne avec `strings` ⭐
- Commande : `strings hello`
- **Question** : Retrouve la chaîne `"Hello, World!"`. Pourquoi la voit-on en clair dans le binaire ?

### Exercice 7 — Le mystère des symboles stripped ⭐⭐
- Commande : Compare `nm hello` puis exécute `strip hello` et refais `nm hello`.
- **Question** : Que fait la commande `strip` et pourquoi est-elle utilisée en production ? Le programme fonctionne-t-il encore après ?

### Exercice 8 — Visualiser l'alignement des sections ⭐⭐
Dans la sortie de `readelf -S hello`, observe la colonne `Align` (ou `Alignement`).
- **Question** : Pourquoi les sections sont-elles souvent alignées sur des multiples de 16 ou de 4096 octets (tailles de pages mémoires) ?

### Exercice 9 — Retrouver la table des syscalls dans le binaire ⭐⭐⭐
- Commande : Utilise `objdump -d -M intel hello | grep -B2 syscall`
- **Question** : Identifie les valeurs placées dans `rax` juste avant chaque instruction `syscall`.

### Exercice 10 — Défi : Patcher un binaire avec `sed` ou un éditeur hexadécimal ⭐⭐⭐⭐
Fais une copie de ton binaire : `cp hello hello_patched`.
Modifie l'octet correspondant à la lettre `'H'` (`0x48`) dans la chaîne `"Hello"` pour le remplacer par `'J'` (`0x4A`).
Lance `./hello_patched`.
- **Résultat attendu** : Le programme affiche `"Jello, World!"` sans avoir été recompilé !

---

## 🧩 Mini-Quiz de validation

1. Quelle commande système le noyau exécute-t-il pour charger un binaire ?
2. Quelle est la différence majeure entre `.data` et `.rodata` en termes de droits mémoire ?
3. Dans quel sens grandit la pile (*stack*) sur x86_64 ?
4. Quel outil en ligne de commande permet de voir toutes les sections d'un binaire ELF ?
5. Que contient l'adresse mémoire `0x0000000000000000` sous Linux ?

<details>
<summary>Réponses du quiz</summary>

1. Le syscall `execve`.
2. `.data` est accessible en lecture et écriture (RW-), tandis que `.rodata` est en lecture seule (R--). Écrire dans `.rodata` déclenche un crash immédiat (*Segmentation Fault*).
3. Vers le bas (vers les adresses mémoire décroissantes).
4. `readelf -S` (ou `objdump -h`).
5. Rien d'accessible : c'est la page nulle (*NULL pointer*). Toute tentative de lecture ou écriture à cette adresse déclenche une faute de segmentation matérielle (*Segfault*).
</details>

---

> 🏅 **Badge débloqué : Archéologue binaire** — Tu comprends désormais exactement comment tes fichiers sources se métamorphosent en structures mémoires vivantes. Tu es prêt à attaquer le **Niveau 2 : Le Langage Assembleur** !
