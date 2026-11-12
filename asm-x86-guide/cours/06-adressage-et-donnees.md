# Chapitre 6 — Adressage Avancé, Directives NASM, Chaînes et Projet 3

## 🎯 Objectifs de ce chapitre

À la fin de ce chapitre, tu seras capable de :
- [ ] Maîtriser la formule universelle d'adressage mémoire x86_64 : `[Base + Index * Échelle + Déplacement]`.
- [ ] Comprendre en profondeur l'**adressage RIP-relatif** (`[rel symbole]`), indispensable pour le code moderne position-indépendant (PIE) et sous macOS.
- [ ] Utiliser toutes les directives de données NASM (`db`, `dw`, `dd`, `dq`, `resb`, `resq`, `times`, `$`, `$$`, `%macro`).
- [ ] Manipuler les chaînes de caractères terminées par un octet nul (`\0`) selon la norme C.
- [ ] Exploiter la puissance des instructions de traitement de chaînes du processeur : `movsb`, `stosb`, `scasb`, `cmpsb` couplées aux préfixes `rep`, `repe`, `repne`.
- [ ] Inverser l'ordre des octets (*Endianness Swap*) en un seul cycle avec `bswap`.
- [ ] Réussir le **Projet 3 : Mini-strlen & Mini-strcmp** (le coup d'envoi de ta minilibc !).

## 📋 Prérequis
- Avoir complété le Chapitre 5 (boucles, comparaisons et contrôle de flux).

## ⏱️ Durée estimée : 6–8 heures (Théorie + 15 Exercices + Projet 3)

---

## 6.1 — La Formule Universelle d'Adressage x86_64

Sur x86_64, le calcul d'adresse d'un opérande mémoire est géré directement par le matériel selon la formule mathématique suivante :

$$ \text{Adresse Effective} = \mathbf{Base} + (\mathbf{Index} \times \mathbf{Échelle}) + \mathbf{Déplacement} $$

```
   ┌───────────────────────────────────────────────────────────────┐
   │         [ BASE  +  (INDEX * ÉCHELLE)  +  DÉPLACEMENT ]        │
   └───────┬──────────────┬──────────┬──────────────┬──────────────┘
           │              │          │              │
           ▼              ▼          ▼              ▼
       Registre 64b   Registre 64b  1, 2, 4 ou 8   Constante (offset)
      (ex: RDI, RBX)   (ex: RCX)     (taille type)   (ex: +16, -8)
```

### Exemples d'application concrets :

```asm
; 1. Adressage indirect simple : pointeur direct
mov     rax, [rdi]                  ; Lit à l'adresse rdi

; 2. Pointeur + Déplacement (Accès à un champ de structure)
mov     rax, [rdi + 16]             ; Lit le champ situé 16 octets après rdi

; 3. Base + Index (Parcours de tableau d'octets)
mov     al, [rdi + rcx]             ; Lit l'octet tab[rcx]

; 4. Formule complète (Tableau d'entiers 64 bits avec offset)
mov     rax, [rdi + rcx * 8 + 32]   ; Lit tab[rcx] où chaque élément fait 8 octets
```

---

## 6.2 — L'Adressage RIP-Relatif (PIE : Position Independent Executable)

Par défaut sur les systèmes d'exploitation modernes (Linux moderne avec ASLR activé, et **STRICTEMENT obligatoire sous macOS**), le noyau charge les exécutables à des adresses mémoires aléatoires pour empêcher les attaques par corruption mémoire.

Dans ce contexte, une adresse absolue comme `mov rsi, msg` est bannie car l'adresse de `msg` n'est pas connue à la compilation.
On utilise alors l'**adressage relatif au pointeur d'instruction (RIP)** :

```asm
; Syntaxe NASM explicite
lea     rsi, [rel msg]              ; Calcule : adresse_courante_de_RIP + offset_vers_msg

; Ou encore mieux : directive NASM globale en haut de fichier
default rel                         ; Tous les accès mémoires deviennent RIP-relatifs par défaut !
```

---

## 6.3 — Directives NASM : Réserver et Initialiser la Donnée

NASM propose un jeu riche de directives pour déclarer des données :

### 1. En section `.data` (Données initialisées)
- **`db`** : *Define Byte* (8 bits / 1 octet) $\rightarrow$ `db 'A'`, `db 10`, `db "Hello", 0`
- **`dw`** : *Define Word* (16 bits / 2 octets) $\rightarrow$ `dw 1000`
- **`dd`** : *Define Doubleword* (32 bits / 4 octets) $\rightarrow$ `dd 0x12345678`
- **`dq`** : *Define Quadword* (64 bits / 8 octets) $\rightarrow$ `dq 0x0123456789ABCDEF`

### 2. En section `.bss` (Mémoire réservée, initialisée à zéro)
- **`resb N`** : Réserve $N$ octets
- **`resw N`** : Réserve $N$ words (mots de 2 octets)
- **`resd N`** : Réserve $N$ doublewords
- **`resq N`** : Réserve $N$ quadwords (mots de 8 octets)

### 3. Les Opérateurs Spéciaux `$` et `$$`
- **`$`** représente l'**adresse courante** de la ligne d'assemblage.
- **`$$`** représente l'**adresse du début de la section courante**.

Calcul automatique de longueur d'une chaîne :
```asm
msg     db "Ceci est une longue chaîne de test", 10
msg_len equ $ - msg     ; $ (adresse courante) - msg (début) = longueur exacte !
```

Répétition avec `times` :
```asm
buffer  times 64 db 0   ; Remplit 64 octets de zéros en .data
```

### 4. Macros NASM (`%macro`)
Permet de créer des motifs de code réutilisables sans overhead d'appel de fonction :

```asm
; Macro d'affichage d'un caractère (prend 1 argument)
%macro PUTCHAR 1
    push    %1
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, rsp
    mov     rdx, 1
    syscall
    pop     rax
%endmacro

; Utilisation dans le code :
PUTCHAR 'A'
PUTCHAR 'B'
```

---

## 6.4 — Les Instructions de Chaînes Matérielles : `REP`, `MOVS`, `STOS`, `SCAS`

Le processeur x86_64 intègre dans son silicium des instructions dédiées pour manipuler la mémoire à la vitesse maximale du bus (microcodées).

Elles utilisent des registres implicites stricts :
- **`RSI`** : Pointeur Source (*Source Index*)
- **`RDI`** : Pointeur Destination (*Destination Index*)
- **`RCX`** : Compteur d'éléments
- **`RAX` / `AL`** : Valeur recherchée ou à écrire
- **Direction Flag (`DF`)** dans RFLAGS : détermine si les pointeurs avancent (`cld` : Clear Direction Flag $\rightarrow$ incrémente) ou reculent (`std`). **Toujours s'assurer d'exécuter `cld` !**

```
┌────────────────────────────────────────────────────────────────────────┐
│                        INSTRUCTIONS DE CHAÎNES                         │
├──────────┬─────────────────────────────────────┬───────────────────────┤
│ Mnémon.  │ Description                         │ Registres impliqués   │
├──────────┼─────────────────────────────────────┼───────────────────────┤
│ `movsb`  │ Copie 1 octet de [RSI] vers [RDI]   │ RSI++, RDI++          │
│ `movsq`  │ Copie 8 octets de [RSI] vers [RDI]  │ RSI += 8, RDI += 8    │
│ `stosb`  │ Écrit AL à l'adresse [RDI] (memset) │ RDI++                 │
│ `stosq`  │ Écrit RAX à l'adresse [RDI]         │ RDI += 8              │
│ `scasb`  │ Compare AL avec [RDI] (recherche)   │ RDI++, met à jour ZF  │
│ `cmpsb`  │ Compare [RSI] avec [RDI] (strcmp)   │ RSI++, RDI++, flags   │
└──────────┴─────────────────────────────────────┴───────────────────────┘
```

### Le Préfixe Magique `REP`
Répète l'instruction `RCX` fois tant qu'une condition est vraie :

- **`rep stosb`** : L'équivalent matériel de `memset(rdi, al, rcx)` !
- **`rep movsb`** : L'équivalent matériel de `memcpy(rdi, rsi, rcx)` !
- **`repne scasb`** : Scanne la mémoire jusqu'à trouver l'octet `AL` (idéal pour trouver le `\0` d'une chaîne $\rightarrow$ `strlen` !).

#### Exemple : Un `memset` en 3 lignes !
```asm
; Remplir un buffer de 1024 octets avec le caractère 'X'
mov     rdi, buffer         ; Destination
mov     al, 'X'             ; Octet à écrire
mov     rcx, 1024           ; Nombre d'octets
cld                         ; S'assurer qu'on avance vers les adresses croissantes
rep     stosb               ; Remplit 1024 fois 'X' à vitesse maximale !
```

---

## 6.5 — L'Instruction `BSWAP` : Inversion d'Endianness

Quand tu écris du code réseau (où les adresses IP et ports doivent être en *Big-Endian* / Network Byte Order) ou que tu parses des formats de fichiers, tu dois souvent inverser l'ordre des octets.

`bswap registre_32_ou_64` inverse l'intégralité des octets d'un registre en **1 cycle d'horloge** :

```asm
mov     rax, 0x1122334455667788
bswap   rax                 ; rax devient : 0x8877665544332211 !
```

---

## 📝 15 Exercices Pratiques — Niveau 2 (Série Chapitre 6)

### Exercice 1 — Adressage par décalage d'échelle ⭐
Écris l'instruction unique `mov` qui charge dans `rax` le 4ème entier 64 bits d'un tableau pointé par `rsi` (les indices commençant à 0).

### Exercice 2 — Implémentation manuelle de `strlen` : `ex38_manual_strlen.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex38_manual_strlen.asm`
- **Consigne** :
  Soit la chaîne terminée par un zéro : `str db "Assembleur x86", 0`.
  Parcours la chaîne caractère par caractère avec un pointeur et une boucle `cmp byte [rdi], 0`.
  Compte le nombre de caractères (hors zéro final) et quitte avec la longueur dans `rdi`.
- **Sortie attendue** : exit code = 14.

### Exercice 3 — `strlen` ultra-rapide avec `scasb` : `ex39_repne_strlen.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex39_repne_strlen.asm`
- **Consigne** :
  Implémente `strlen` sur la chaîne `"42 Born2Code"` en utilisant `cld`, `xor al, al`, `mov rcx, -1`, `repne scasb`.
  Calcule la longueur exacte à partir de la valeur finale de `rcx`.
- **Sortie attendue** : exit code = 12.

### Exercice 4 — Implémentation manuelle de `memset` : `ex40_manual_memset.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex40_manual_memset.asm`
- **Consigne** :
  Alloue un buffer de 10 octets en `.bss`.
  Remplis chaque octet avec le chiffre `7` en utilisant une boucle.
  Retourne la valeur du 5ème octet (`buffer[4]`) dans `rdi`.
- **Sortie attendue** : exit code = 7.

### Exercice 5 — `memset` matériel avec `rep stosb` : `ex41_rep_memset.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex41_rep_memset.asm`
- **Consigne** :
  Remplis un buffer de 64 octets avec la valeur `42` en utilisant `rep stosb`.
  Retourne le dernier octet dans `rdi`.
- **Sortie attendue** : exit code = 42.

### Exercice 6 — Implémentation manuelle de `memcpy` : `ex42_manual_memcpy.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex42_manual_memcpy.asm`
- **Consigne** :
  Copie la chaîne `"EPITECH"` (7 octets) depuis `src` vers `dst` en mémoire.
  Retourne le premier octet de `dst` dans `rdi`.
- **Sortie attendue** : exit code = 69 (Code ASCII de 'E').

### Exercice 7 — `memcpy` matériel avec `rep movsb` : `ex43_rep_memcpy.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex43_rep_memcpy.asm`
- **Consigne** :
  Copie 16 octets d'un tableau à un autre avec `cld` et `rep movsb`.
  Retourne le 3ème octet de la destination dans `rdi`.

### Exercice 8 — Implémentation de `strcmp` basique : `ex44_manual_strcmp.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex44_manual_strcmp.asm`
- **Consigne** :
  Compare deux chaînes terminées par `\0` : `s1 = "abc"` et `s2 = "abd"`.
  Retourne la différence du premier caractère divergent (`'c' - 'd' = 99 - 100 = -1`).
- **Sortie attendue** : exit code = 255 (-1 mod 256).

### Exercice 9 — Recherche de caractère (`strchr`) : `ex45_manual_strchr.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex45_manual_strchr.asm`
- **Consigne** :
  Dans la chaîne `"Hello World"`, recherche la première occurrence du caractère `'W'`.
  Retourne l'indice (0-indexé) de sa position dans la chaîne (ici : indice 6).
- **Sortie attendue** : exit code = 6.

### Exercice 10 — Remplacement de caractères (*In-place string transform*) : `ex46_str_replace.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex46_str_replace.asm`
- **Consigne** :
  Dans la chaîne `"banana"`, remplace tous les caractères `'a'` par `'o'` directement en mémoire.
  Affiche la chaîne résultante (`"bonono\n"`).

### Exercice 11 — Inversion d'Endianness réseau avec `bswap` : `ex47_bswap_net.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex47_bswap_net.asm`
- **Consigne** :
  Soit le port réseau 8080 en notation hexadécimale 16 bits : `0x1F90` (Little-Endian sur x86).
  Convertis-le en Big-Endian (Network Byte Order) avec rotation ou bswap pour obtenir `0x901F`.
  Retourne l'octet de poids fort dans `rdi`.
- **Sortie attendue** : exit code = 144 (`0x90`).

### Exercice 12 — Vérification de chaîne vide ⭐
Écris le snippet minimal (en 2 instructions) qui vérifie si une chaîne pointée par `rdi` est vide (commence par `\0`).

### Exercice 13 — Conversion majuscule vers minuscule (`tolower`) : `ex48_tolower.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex48_tolower.asm`
- **Consigne** :
  En ASCII, les majuscules vont de 65 ('A') à 90 ('Z') et les minuscules de 97 ('a') à 122 ('z').
  La différence est exactement de `32` (`0x20`, soit le bit 5 !).
  Transforme une lettre majuscule `'G'` en minuscule `'g'` en utilisant un simple `or al, 0x20`.
- **Sortie attendue** : exit code = 103 (ASCII de 'g').

### Exercice 14 — Détection de sous-chaîne (`strstr` naïf) ⭐⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex49_strstr_naive.asm`
- **Consigne** :
  Recherche si la sous-chaîne `"key"` existe dans `"my_secret_key_123"`.
  Si trouvée $\rightarrow$ retourne `1` dans `rdi`, sinon `0`.
- **Sortie attendue** : exit code = 1.

### Exercice 15 — Concaténation manuelle (`strcat`) : `ex50_strcat.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex50_strcat.asm`
- **Consigne** :
  Soit un buffer contenant `"Hello "` (assez grand pour contenir la suite).
  Trouve la fin de `"Hello "` et copie à la suite `"World!"` avec son `\0`.
  Affiche le résultat complet (`"Hello World!\n"`).

---

## 🎯 PROJET 3 (Style Epitech) — Les Piliers de la Minilibc : `my_strlen` & `my_strcmp`

```
================================================================================
                       ÉCOLE VIRTUELLE D'INGÉNIERIE SYSTÈME
                    Projet 3 : Les Fondations de la Minilibc
================================================================================
  Binaire attendu   : test_minilibc (binaire de test) + minilibc.a (bibliothèque)
  Fichiers de rendu : Makefile, my_strlen.asm, my_strcmp.asm
  Langage           : Assembleur x86_64 pur (NASM)
  Conventions ABI   : System V AMD64 (Arguments dans RDI, RSI - Retour dans RAX)
================================================================================
```

### 1. Cahier des Charges & Sujet

Tu commences ici la construction de ta **Minilibc**, l'un des projets les plus emblématiques du cursus système d'Epitech.
Tu dois réimplémenter en assembleur x86_64 pur les deux fonctions canoniques de la bibliothèque C standard :

```c
size_t my_strlen(const char *s);
int    my_strcmp(const char *s1, const char *s2);
```

### 2. Spécifications Rigoureuses

#### `my_strlen` :
- Entrée : `rdi` = pointeur sur la chaîne de caractères terminée par `\0`.
- Sortie : `rax` = nombre de caractères avant le `\0` final.
- Le pointeur `rdi` ne doit pas être corrompu si la fonction appelante en a besoin.

#### `my_strcmp` :
- Entrée : `rdi` = pointeur sur la chaîne `s1`, `rsi` = pointeur sur la chaîne `s2`.
- Sortie : `rax` =
  - `< 0` (négatif) si `s1 < s2`
  - `0` si `s1 == s2`
  - `> 0` (positif) si `s1 > s2`
- La comparaison s'effectue sur des **caractères non signés** (`unsigned char`) selon la norme POSIX !

---

## 🧩 Mini-Quiz de fin de chapitre

1. Dans la formule `[Base + Index * Échelle + Déplacement]`, quelles sont les 4 valeurs autorisées pour l'échelle ?
2. Pourquoi l'adressage `[rel symbole]` est-il obligatoire sous macOS et pour les exécutables PIE ?
3. Que contient le registre `RCX` avant l'exécution de `rep movsb` ?
4. Quelle instruction permet de trouver le caractère nul de fin de chaîne en utilisant le coprocesseur de chaînes ?
5. Quelle directive NASM permet de réserver 256 octets non-initialisés en section `.bss` ?

<details>
<summary>Réponses du quiz</summary>

1. `1`, `2`, `4` ou `8` (correspondant aux tailles `byte`, `word`, `dword`, `qword`).
2. Parce que l'adresse absolue des données n'est pas connue à la compilation lorsque le programme est chargé à une adresse virtuelle aléatoire (ASLR).
3. Le nombre exact d'octets à copier.
4. `repne scasb` avec `al = 0`.
5. `resb 256`.
</details>

---

> 🏅 **Badge débloqué : Dompteur de mémoire** — Tu as franchi le Niveau 2 avec brio ! Tu maîtrises les syntaxes, les registres, les drapeaux, les calculs, le contrôle de flux et la mémoire.
> 
> ➡️ **Direction : NIVEAU 3 — La Pile, les Fonctions et l'ABI System V AMD64 !**
