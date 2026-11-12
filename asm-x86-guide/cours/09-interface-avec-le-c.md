# Chapitre 9 — Interfaçage avec le C, Bibliothèques et la Minilibc Complète

## 🎯 Objectifs de ce chapitre

À la fin de ce chapitre, tu seras capable de :
- [ ] Appeler n'importe quelle fonction de la bibliothèque standard C (`printf`, `malloc`, `puts`, `time`...) depuis du code assembleur x86_64 sans jamais crasher.
- [ ] Maîtriser la règle secrète des fonctions C variadiques : **pourquoi `AL` doit être mis à zéro avant d'appeler `printf`** !
- [ ] Appeler des routines assembleur depuis un programme en C avec des prototypes stricts (`extern`).
- [ ] Comprendre pourquoi lier avec `gcc` est souvent indispensable par rapport à `ld` brut (initialisation du runtime C, `crt1.o`).
- [ ] Visualiser le rôle fondamental de la **PLT** (*Procedure Linkage Table*) et de la **GOT** (*Global Offset Table*) dans la résolution dynamique des symboles.
- [ ] Compiler une bibliothèque partagée dynamique (**`.so`**) en assembleur pur et l'injecter avec **`LD_PRELOAD`** pour intercepter les fonctions du système !
- [ ] Réaliser le chef-d'œuvre du cursus : **Projet 6 — La Minilibc Complète** (12 fonctions reines réimplémentées en assembleur pur).

## 📋 Prérequis
- Avoir complété le Niveau 3 (l'ABI System V AMD64, registres caller/callee-saved, alignement de pile 16 octets).

## ⏱️ Durée estimée : 10–12 heures (Théorie + 12 Exercices + Projet 6 Minilibc)

---

## 9.1 — Appeler la Bibliothèque C depuis l'Assembleur

En tant que développeur assembleur, tu n'as pas besoin de réinventer la roue pour les tâches complexes (allouer de la mémoire dynamique avec `malloc`, formater du texte complexe avec `printf`, ou calculer du temps avec `time`).

Tu peux appeler directement les fonctions de la **libc** en respectant les 3 règles d'or de l'ABI System V :

```
     1. ARGUMENTS      : RDI, RSI, RDX, RCX, R8, R9
     2. ALIGNEMENT     : RSP doit être un multiple de 16 AVANT le CALL
     3. VARIADIQUE     : Mettre AL = 0 avant le CALL si fonction à arguments variables
```

### 1. Exemple Fondamental : Appeler `puts`
```asm
default rel                     ; Active l'adressage RIP-relatif par défaut

section .rodata
    msg db "Hello depuis la libc !", 0

section .text
    global main                 ; Point d'entrée attendu par gcc
    extern puts                 ; Déclaration du symbole externe de la libc

main:
    push    rbp                 ; Aligne la pile à 16 octets !
    mov     rbp, rsp

    lea     rdi, [msg]          ; 1er argument = pointeur vers la chaîne
    call    puts wrt ..plt      ; Appel de puts via la PLT

    xor     eax, eax            ; return 0;
    pop     rbp
    ret
```

Compilation et exécution avec `gcc` :
```bash
nasm -f elf64 prog.asm -o prog.o
gcc prog.o -o prog
./prog
```

### 2. Le Mystère de `printf` et du Registre `AL`

Quand tu appelles une fonction C à nombre variable d'arguments comme `printf(format, ...)` :
> [!CRITICAL]
> **LE PIÈGE ABSOLU DE `PRINTF` :**
> L'ABI System V AMD64 impose que le registre **`AL` (8 bits de poids faible de `RAX`) contienne le nombre de registres vectoriels SSE (`XMM0` à `XMM7`) utilisés pour passer des arguments flottants (`float` ou `double`).
> Si tu n'affiches que des entiers et des chaînes de caractères, tu **DOIS IMPÉRATIVEMENT METTRE `AL` À ZÉRO (`xor eax, eax` ou `mov al, 0`)** avant d'appeler `printf` !
> Si tu oublies, `printf` va tenter de lire des registres flottants non initialisés et va crasher brutalement avec un *Segmentation Fault* !

```asm
section .rodata
    fmt db "Nombre: %d, Message: %s", 10, 0
    str db "Victoire", 0

section .text
    global main
    extern printf

main:
    push    rbp
    mov     rbp, rsp

    lea     rdi, [fmt]          ; 1er arg = chaîne de format
    mov     rsi, 42             ; 2ème arg = %d (entier 42)
    lea     rdx, [str]          ; 3ème arg = %s (chaîne "Victoire")
    xor     eax, eax            ; INDISPENSABLE : 0 argument flottant dans XMM !
    call    printf wrt ..plt

    xor     eax, eax
    pop     rbp
    ret
```

---

## 9.2 — Appeler de l'Assembleur depuis le C

L'un des cas d'usage les plus fréquents en entreprise est d'écrire une routine critique (crypto, traitement d'image, calcul matriciel) en assembleur x86_64 et de l'appeler depuis une application C ou C++.

### Côté Assembleur (`fast_math.asm`) :
```asm
section .text
    global my_fast_add          ; Rend le symbole public pour l'éditeur de liens

; long my_fast_add(long a, long b);
; rdi = a, rsi = b
my_fast_add:
    lea     rax, [rdi + rsi]    ; rax = a + b
    ret
```

### Côté C (`main.c`) :
```c
#include <stdio.h>

// Déclaration externe du prototype assembleur
extern long my_fast_add(long a, long b);

int main(void) {
    long resultat = my_fast_add(100, 42);
    printf("Résultat : %ld\n", resultat); // Affiche 142
    return 0;
}
```

Compilation mixte :
```bash
nasm -f elf64 fast_math.asm -o fast_math.o
gcc -Wall -Wextra main.c fast_math.o -o programme
./programme
```

---

## 9.3 — Comprendre la PLT et la GOT (Résolution Dynamique)

Quand ton programme utilise une bibliothèque partagée dynamique comme `libc.so.6`, les fonctions comme `printf` ne sont pas copiées dans ton binaire sur le disque.
Leur adresse réelle en mémoire change à chaque lancement (sécurité ASLR).

Pour résoudre ces adresses à la volée sans recompiler le binaire, Linux utilise deux tables :
- **La PLT (*Procedure Linkage Table*)** : Un petit trampoline de code exécutable dans la section `.text`.
- **La GOT (*Global Offset Table*)** : Une table de pointeurs mémoires dans la section `.data` modifiable.

```
       Ton Code
   ┌────────────────┐
   │  call printf   │
   └───────┬────────┘
           │
           ▼
   ┌────────────────────────────────────────────────────────┐
   │ Trampoline PLT (printf@plt)                            │
   │ 1. Consulte la case mémoire correspondante dans la GOT │
   └───────┬────────────────────────────────────────────────┘
           │
           ├── Premier appel (Liaison paresseuse / Lazy binding) :
           │   Saute vers le dynamic linker de Linux (ld-linux.so)
           │   qui trouve l'adresse réelle de printf dans libc.so
           │   et met à jour la case GOT !
           │
           └── Appels suivants :
               Saute DIRECTEMENT à l'adresse de printf dans la libc !
```

> [!TIP]
> En syntaxe NASM, quand tu appelles une fonction dynamique externe, écris toujours :
> `call fonction wrt ..plt` (*with respect to Procedure Linkage Table*).

---

## 9.4 — Créer une Bibliothèque Dynamique (`.so`) et le Pouvoir de `LD_PRELOAD`

À Epitech, le rendu final de la Minilibc n'est pas un exécutable, mais une **bibliothèque partagée dynamique nommée `libasm.so`**.

### 1. Création du fichier `.so` :
```bash
# 1. Compiler tous les fichiers .asm en position-indépendant (-f elf64)
nasm -f elf64 strlen.asm -o strlen.o
nasm -f elf64 strcmp.asm -o strcmp.o

# 2. Linker en bibliothèque partagée avec gcc
gcc -shared -fPIC strlen.o strcmp.o -o libasm.so
```

### 2. Le Super-Pouvoir de `LD_PRELOAD` :
Sous Linux, la variable d'environnement `LD_PRELOAD` permet d'imposer au chargeur dynamique de charger **ta propre bibliothèque avant la bibliothèque système standard**.

Si tu tapes :
```bash
LD_PRELOAD=./libasm.so ls -l
```
Chaque fois que la commande système `ls` appellera `strlen` ou `strcmp`, **ce sera TON code assembleur qui s'exécutera à la place de celui d'Intel et de la glibc** !
C'est le test suprême de robustesse d'Epitech : si ton code plante, toute la machine plante. S'il marche, tu as réécrit la libc du système !

---

## 9.5 — Les 12 Fonctions Canoniques de la Minilibc Epitech

Voici la liste officielle des 12 fonctions requises pour valider l'intégralité du module Minilibc :

| Fonction | Prototype C | Description |
|---|---|---|
| **`strlen`** | `size_t strlen(const char *s)` | Longueur d'une chaîne jusqu'au `\0` |
| **`strchr`** | `char *strchr(const char *s, int c)` | Recherche de la 1ère occurrence d'un caractère |
| **`strrchr`**| `char *strrchr(const char *s, int c)` | Recherche de la dernière occurrence d'un caractère |
| **`memset`** | `void *memset(void *s, int c, size_t n)` | Remplissage d'une zone mémoire |
| **`memcpy`** | `void *memcpy(void *dest, const void *src, size_t n)` | Copie mémoire (zones disjointes) |
| **`memmove`**| `void *memmove(void *dest, const void *src, size_t n)` | Copie mémoire avec gestion de **chevauchement (*overlap*)** |
| **`strcmp`** | `int strcmp(const char *s1, const char *s2)` | Comparaison de deux chaînes |
| **`strncmp`**| `int strncmp(const char *s1, const char *s2, size_t n)` | Comparaison sur $N$ caractères maximum |
| **`strcasecmp`**| `int strcasecmp(const char *s1, const char *s2)` | Comparaison insensible à la casse (A == a) |
| **`strstr`** | `char *strstr(const char *haystack, const char *needle)` | Recherche d'une sous-chaîne dans une chaîne |
| **`strpbrk`**| `char *strpbrk(const char *s, const char *accept)` | Recherche du premier caractère appartenant à un ensemble |
| **`strcspn`**| `size_t strcspn(const char *s, const char *reject)` | Nombre de caractères consécutifs n'appartenant pas à reject |

---

## 🎯 PROJET 6 (Style Epitech) — La Minilibc Complète (`libasm.so`)

```
================================================================================
                       ÉCOLE VIRTUELLE D'INGÉNIERIE SYSTÈME
                    Projet 6 : La Minilibc Complète (Chef-d'œuvre)
================================================================================
  Rendu             : Makefile, strlen.asm, strchr.asm, strrchr.asm, memset.asm,
                      memcpy.asm, memmove.asm, strcmp.asm, strncmp.asm,
                      strcasecmp.asm, strstr.asm, strpbrk.asm, strcspn.asm
  Binaire produit   : libasm.so (Bibliothèque partagée dynamique)
  Langage           : Assembleur x86_64 pur (NASM)
  Conventions       : ABI System V AMD64 stricte
  Contrainte        : Interdiction totale d'appeler d'autres fonctions ou syscalls
================================================================================
```

### 1. Spécificité Critique : Le Chevauchement dans `memmove`
La fonction `memcpy` part du principe que la source et la destination ne se chevauchent pas.
En revanche, **`memmove` doit fonctionner même si la mémoire se chevauche** !

```
Cas de chevauchement critique : dest > src
Zone source      : [ A ][ B ][ C ][ D ]
Zone destination :      [ A ][ B ][ C ][ D ]  (Offset de +1)

Si on copie de gauche à droite :
  dst[0] = src[0] ('A') écrase src[1] !
  dst[1] recevra 'A' au lieu de 'B' ! Tout est corrompu !

SOLUTION :
  Si dest > src : copier de DROITE À GAUCHE (en reculant avec 'std' ou pointeurs de fin) !
  Si dest <= src : copier de GAUCHE À DROITE (normalement avec 'cld') !
```

---

## 🧩 Mini-Quiz de fin de chapitre

1. Pourquoi doit-on mettre `AL` à zéro avant d'appeler `printf` ?
2. Quel est le rôle de la PLT lors de l'appel d'une fonction dynamique ?
3. Que permet de faire la variable d'environnement `LD_PRELOAD` ?
4. Quelle est la différence majeure entre `memcpy` et `memmove` ?
5. Dans quel registre se trouve le pointeur de retour d'une fonction comme `strchr` ou `malloc` ?

<details>
<summary>Réponses du quiz</summary>

1. `AL` indique à `printf` le nombre de registres vectoriels SIMD (`XMM0-XMM7`) contenant des arguments flottants. Sans flottants, `AL` doit valoir 0.
2. La PLT sert de relais de redirection dynamique (*trampoline*) pour appeler des fonctions partagées dont l'adresse finale n'est résolue qu'à l'exécution par la GOT.
3. Elle force le chargeur de l'OS à charger une bibliothèque spécifique en priorité absolue pour intercepter et surcharger les fonctions de la libc.
4. `memmove` gère correctement les zones de mémoire qui se chevauchent (*overlapping memory*) en choisissant le sens de copie adéquat (avant ou arrière).
5. Dans le registre `RAX`.
</details>

---

> 🏅 **Badge débloqué : Polyglotte** — Tu maîtrises le pont entre le C et l'assembleur. Passons à l'assemblage complet de la Minilibc dans le Projet 6 !
