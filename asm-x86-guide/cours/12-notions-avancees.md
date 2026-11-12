# Chapitre 12 — Notions Avancées, Sécurité, SIMD et le Pont vers l'ARM64

## 🎯 Objectifs de ce chapitre

À la fin de ce chapitre, tu seras capable de :
- [ ] Comprendre le fonctionnement des instructions **SIMD** (*Single Instruction, Multiple Data*) via les jeux d'instructions **SSE** (128 bits) et **AVX** (256/512 bits).
- [ ] Visualiser les entrailles de la micro-architecture moderne : pipeline d'exécution superscalaire, *out-of-order execution*, hiérarchie de caches L1/L2/L3 et *branch prediction*.
- [ ] Comprendre les vulnérabilités de corruption mémoire (**Buffer Overflow**) et les 4 barrières de défense modernes : **NX/DEP**, **Stack Canaries**, **ASLR** et **PIE**.
- [ ] Lire et comprendre le code assembleur produit par un compilateur C moderne (`gcc -O0` vs `gcc -O2`).
- [ ] Faire le pont technologique avec ta propre machine physique : **comparer en détail l'architecture x86_64 (CISC) avec l'architecture ARM64 d'Apple Silicon (RISC)**.

## 📋 Prérequis
- Avoir complété l'ensemble des Niveaux 0 à 5.

## ⏱️ Durée estimée : 6–8 heures (Théorie + 10 Exercices de synthèse)

---

## 12.1 — Le Parallélisme Matériel : SSE et AVX (SIMD)

Jusqu'à présent, chaque instruction traitait une seule donnée à la fois (mode scalaire : `add rax, rbx`).
Les processeurs modernes intègrent des unités vectorielles capables de traiter **plusieurs données en parallèle en un seul cycle d'horloge** : c'est le principe **SIMD** (*Single Instruction, Multiple Data*).

```
Mode Scalaire (Classique) :
  Donnée A1 + Donnée B1 ===> Résultat 1   (1 opération)

Mode Vectoriel SIMD (SSE / AVX) :
  ┌──────────┬──────────┬──────────┬──────────┐
  │    A3    │    A2    │    A1    │    A0    │  (Registre XMM de 128 bits)
  └────┬─────┴────┬─────┴────┬─────┴────┬─────┘
     + │        + │        + │        + │        (Opération parallèle simultanée !)
  ┌────┴─────┬────┴─────┬────┴─────┬────┴─────┐
  │    B3    │    B2    │    B1    │    B0    │
  └────┬─────┴────┬─────┴────┬─────┴────┬─────┘
       ▼          ▼          ▼          ▼
  ┌──────────┬──────────┬──────────┬──────────┐
  │ A3 + B3  │ A2 + B2  │ A1 + B1  │ A0 + B0  │
  └──────────┴──────────┴──────────┴──────────┘
```

### Les Générations de Registres Vectoriels :
- **SSE** (Streaming SIMD Extensions) : 16 registres de **128 bits** nommés **`XMM0` à `XMM15`**.
  Peut contenir : 4 entiers de 32 bits, 2 entiers de 64 bits, ou 4 nombres flottants (`float`).
- **AVX** (Advanced Vector Extensions) : 16 registres de **256 bits** nommés **`YMM0` à `YMM15`** (les 128 bits de poids faible correspondent aux registres XMM).
- **AVX-512** : 32 registres de **512 bits** nommés **`ZMM0` à `ZMM31`**.

### Exemple Concret : Additionner 4 entiers d'un coup !
```asm
section .data
    align 16
    vec_a dd 10, 20, 30, 40
    vec_b dd 1,  2,  3,  4

section .bss
    align 16
    vec_res resd 4

section .text
    global _start

_start:
    ; Charge 128 bits (4 entiers 32b) d'un coup dans XMM0
    movdqa  xmm0, [vec_a]       ; movdqa = Move Aligned Double Quadword

    ; Additionne parallèlement les 4 paires d'entiers 32b
    paddd   xmm0, [vec_b]       ; paddd = Packed Add Dwords

    ; Stocke le résultat (11, 22, 33, 44) en mémoire
    movdqa  [vec_res], xmm0

    mov     rax, 60
    xor     rdi, rdi
    syscall
```

---

## 12.2 — Micro-Architecture : Ce qui se passe dans le Silicium

Un processeur moderne n'exécute plus les instructions de manière bête et séquentielle.

```
                  ┌───────────────────────────────┐
                  │ Front-End : Décodage x86      │
                  │ (Traduit x86_64 en micro-ops) │
                  └──────────────┬────────────────┘
                                 │
                                 ▼
                  ┌───────────────────────────────┐
                  │ Réordonnancement Out-of-Order │ (Exécute les instructions
                  │ & Prédiction de Branche       │  indépendantes en avance !)
                  └──────────────┬────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         ▼                       ▼                       ▼
    [ ALU Port 0 ]          [ ALU Port 1 ]          [ Load/Store Port ]
```

1. **Le Pipeline Superscalaire** : Le processeur décompose chaque instruction en plusieurs étapes (Fetch, Decode, Rename, Dispatch, Execute, Retire). Plusieurs instructions sont dans le pipeline en même temps à des stades différents.
2. **Exécution dans le Désordre (*Out-of-Order Execution*)** : Si une instruction doit attendre des données venant de la RAM, le CPU n'attend pas ! Il cherche les instructions suivantes qui ne dépendent pas de ce résultat et les exécute immédiatement.
3. **Hiérarchie des Caches Mémoires** :
   - **Registres** : ~0.5 nanoseconde.
   - **Cache L1** (32–64 Ko par cœur) : ~1 nanoseconde (4-5 cycles).
   - **Cache L2** (512 Ko – 1 Mo) : ~3 à 5 nanosecondes (12-14 cycles).
   - **Cache L3** (partagé, 16–64 Mo) : ~10 à 15 nanosecondes (40-60 cycles).
   - **RAM Principale** : ~60 à 100 nanosecondes (200 cycles d'attente !).
   > **Règle d'or de performance** : Accéder à la RAM coûte 200 fois plus cher que d'accéder à un registre. Structurer ses données pour qu'elles tiennent dans les caches L1/L2 est le secret des moteurs de jeux et des bases de données ultra-rapides.

---

## 12.3 — Sécurité Système : Vulnérabilités et Défenses

L'assembleur est le langage roi de la sécurité offensive et défensive.

### 1. L'Attaque Canonique : Le Dépassement de Tampon (*Buffer Overflow*)
Si une fonction alloue 64 octets sur la pile pour un buffer, mais que l'utilisateur en saisit 80 via une fonction non sécurisée :
```
  [ Buffer de 64 octets ] ──► Déborde !
  [ Ancien RBP (8 octets) ] ──► Écrasé par les 'A' (0x41414141...)
  [ Adresse de retour RIP ] ──► ÉCRASÉE PAR L'ATTAQUANT !
```
Quand la fonction exécute `ret`, le CPU saute à l'adresse injectée par l'attaquant !

### 2. Les 4 Barrières de Défense Modernes :

```
┌─────────────────┬─────────────────────────────────────────────────────────┐
│ Défense         │ Rôle et Fonctionnement                                  │
├─────────────────┼─────────────────────────────────────────────────────────┤
│ **NX / DEP**    │ *No-Execute* : La pile et le tas sont marqués non-      │
│                 │ exécutables. Impossible d'exécuter du code (*shellcode*)│
│                 │ injecté sur la pile !                                   │
├─────────────────┼─────────────────────────────────────────────────────────┤
│ **Stack Canary**│ Le compilateur place un nombre secret aléatoire juste   │
│                 │ avant l'adresse de retour. Si ce nombre a changé avant  │
│                 │ le 'ret', le programme s'arrête avec `__stack_chk_fail`.│
├─────────────────┼─────────────────────────────────────────────────────────┤
│ **ASLR**        │ *Address Space Layout Randomization* : La pile, le tas  │
│                 │ et les bibliothèques sont placés à des adresses         │
│                 │ aléatoires à chaque exécution.                          │
├─────────────────┼─────────────────────────────────────────────────────────┤
│ **PIE**         │ *Position Independent Executable* : Le code de          │
│                 │ l'exécutable lui-même est position-indépendant.         │
└─────────────────┴─────────────────────────────────────────────────────────┘
```

---

## 12.4 — Lire du Code Désassemblé : Comment Optimise GCC

Regardons ce que produit `gcc` sur cette simple fonction C :
```c
int sum_array(int *arr, int n) {
    int total = 0;
    for (int i = 0; i < n; i++)
        total += arr[i];
    return total;
}
```

### Sans optimisation (`gcc -O0`) :
Génère du code naïf qui recharge et réécrit sur la pile à chaque itération (très lent, 15 instructions par tour).

### Avec optimisation maximale (`gcc -O3`) :
Le compilateur applique la **vectorisation automatique** :
1. Il déroule la boucle (*Loop Unrolling*) 4 par 4 ou 8 par 8.
2. Il utilise des instructions vectorielles AVX (`vmovdqu`, `vpaddd`) pour additionner 8 entiers par cycle d'horloge.
3. Le parcours d'un million d'entiers s'exécute 10 à 20 fois plus vite !

---

## 12.5 — Le Pont vers ta Machine Réelle : x86_64 vs ARM64 (Apple Silicon)

Puisque tu travailles sur un **MacBook Pro M5**, voici la confrontation d'architecture entre le processeur réel sous ton clavier et l'architecture que tu viens de maîtriser :

```
┌───────────────────────────────────────┬───────────────────────────────────────┐
│       INTEL / AMD (x86_64)            │       APPLE SILICON (ARM64 / AArch64) │
├───────────────────────────────────────┼───────────────────────────────────────┤
│ **Philosophie : CISC**                │ **Philosophie : RISC**                │
│ Instructions complexes, puissantes,   │ Instructions simples, régulières,     │
│ microcodées par le matériel.          │ exécutées en 1 cycle.                 │
├───────────────────────────────────────┼───────────────────────────────────────┤
│ **Taille des instructions : Variable**│ **Taille des instructions : Fixe**    │
│ De 1 octet (ex: `ret`, `nop`)         │ **Exactement 4 octets (32 bits)**     │
│ jusqu'à 15 octets pour les plus folles│ pour TOUTES les instructions !        │
├───────────────────────────────────────┼───────────────────────────────────────┤
│ **Registres Généraux : 16**           │ **Registres Généraux : 31**           │
│ Noms historiques disparates :         │ Noms réguliers et numérotés :         │
│ `rax`, `rbx`, `rcx`... `r8` à `r15`   │ `x0` à `x30` (64 bits), `w0`-`w30` (32b)│
├───────────────────────────────────────┼───────────────────────────────────────┤
│ **Passage des arguments (ABI) :**     │ **Passage des arguments :**           │
│ `rdi, rsi, rdx, rcx, r8, r9`          │ `x0, x1, x2, x3, x4, x5, x6, x7`      │
│ (Retour dans `rax`)                   │ (Retour dans `x0`)                    │
├───────────────────────────────────────┼───────────────────────────────────────┤
│ **Appel Système Kernel :**            │ **Appel Système Kernel :**            │
│ Instruction `syscall`                 │ Instruction `svc #0` (Supervisor Call)│
│ Numéro de syscall dans `rax`          │ Numéro de syscall dans `x16` (ou `x8`)│
├───────────────────────────────────────┼───────────────────────────────────────┤
│ **Accès Mémoire :**                   │ **Architecture Load-Store pure :**    │
│ Les instructions arithmétiques        │ **Interdiction de calculer en RAM** : │
│ peuvent lire la RAM :                 │ On doit d'abord faire un `ldr`        │
│ `add rax, [rsi + 8]`                  │ puis `add x0, x0, x1` puis `str` !    │
└───────────────────────────────────────┴───────────────────────────────────────┘
```

### Exemple Comparatif : Une fonction d'addition simple
```asm
; --- Version x86_64 (NASM) ---
global add_two
add_two:
    lea     rax, [rdi + rsi]    ; rax = rdi + rsi
    ret

; --- Version ARM64 (Apple Silicon / Clang as) ---
.global _add_two
_add_two:
    add     x0, x0, x1          ; x0 = x0 + x1 (arguments dans x0 et x1)
    ret
```

Tu as maintenant compris les deux mondes ! L'assembleur x86_64 t'a appris à penser au plus près du matériel ; passer sur ARM64 sera désormais pour toi un simple changement de vocabulaire de registres.

---

## 📝 10 Exercices de Synthèse et d'Approfondissement

1. **Calcul SIMD** : Écris un snippet avec `movdqa` et `paddd` qui additionne deux vecteurs de 4 entiers 32 bits.
2. **Détection d'endianness** : Écris un programme minimal qui détermine à l'exécution si la machine hôte est Little-Endian ou Big-Endian.
3. **Inspection du désassemblage optimisé** : Compile une fonction factorielle avec `gcc -O0` puis `gcc -O2`. Compare le nombre d'instructions générées.
4. **Analyse de Stack Canary** : Désassemble une fonction C compilée avec `-fstack-protector` et repère la lecture du segment `fs:0x28`.
5. **Comptage de cycles d'horloge** : Utilise l'instruction `rdtsc` (*Read Time-Stamp Counter*) pour mesurer le nombre exact de cycles CPU pris par une boucle.
6. **Traduction vers ARM64** : Prends ta fonction `my_strlen` du Niveau 2 et traduis-la mentalement avec les registres `x0`, `x1` et l'instruction `ldrb`.
7. **Vectorisation d'un `memset`** : Implémente un `memset` de 64 octets en utilisant des écritures vectorielles de 16 octets avec `movdqu`.
8. **Test de la protection NX** : Alloue de la mémoire avec `mmap` sans le flag `PROT_EXEC` et tente d'y exécuter un `ret`. Observe le crash SIGSEGV.
9. **Déroulage de boucle (*Loop Unrolling*)** : Réécris une boucle de calcul en traitant 4 éléments par itération pour réduire le coût des sauts conditionnels.
10. **Défi du Sage** : Écris un quine en assembleur (un programme qui affiche son propre code source ou ses propres opcodes machines) !

---

> 🏅 **Badge Ultime Débloqué : Sage de l'Assembleur**  
> Tu as complété l'intégralité du cursus théorique et pratique de l'assembleur x86_64.  
> Tu comprends le silicium, la mémoire, le noyau, la sécurité et les compilateurs. Tu es désormais armé pour le reverse engineering, l'optimisation de performance et le développement bas niveau !
