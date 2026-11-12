# Chapitre 7 — La Pile, les Fonctions et la Convention d'Appel System V AMD64

## 🎯 Objectifs de ce chapitre

À la fin de ce chapitre, tu seras capable de :
- [ ] Visualiser la pile mémoire (*Stack*) en mouvement lors des instructions `push`, `pop`, `call` et `ret`.
- [ ] Construire manuellement un cadre de pile (*Stack Frame*) standard avec son prologue et son épilogue (`leave; ret`).
- [ ] Allouer et manipuler des variables locales sur la pile via `[rbp - offset]`.
- [ ] Maîtriser sur le bout des doigts la **Convention d'Appel System V AMD64 ABI** (la norme universelle Linux/BSD/macOS).
- [ ] Distinguer immédiatement les registres **caller-saved** (volatils) et **callee-saved** (préservés).
- [ ] Comprendre et respecter la règle d'or de **l'alignement 16 octets de la pile** (responsable de 90% des crashs SSE/libc).
- [ ] Exploiter la **Red Zone** de 128 octets pour écrire des fonctions feuilles ultra-rapides sans toucher à `rsp`.
- [ ] Écrire des fonctions récursives robustes (Factorielle, Fibonacci).

## 📋 Prérequis
- Avoir complété le Niveau 2 (instructions de base, contrôle de flux, mémoire).

## ⏱️ Durée estimée : 8–10 heures (Théorie + 20 Exercices pratiques)

---

## 7.1 — La Pile en Profondeur : Fonctionnement Mécanique

En architecture x86_64, la pile (*Stack*) est une zone de mémoire vive gérée selon le principe **LIFO** (*Last In, First Out* : dernier entré, premier sorti).

### La Règle Fondamentale : La pile grandit vers le BAS
> **Sur x86_64, empiler une donnée DIMINUE la valeur du pointeur de pile `RSP`. Dépiler une donnée AUGMENTE `RSP`.**

```
     Adresses Hautes
          ▲
          │   [ ... Données précédentes ... ]
          │   ┌─────────────────────────────┐
          │   │      Donnée existante       │  <─── Adresse 0x7FFFFFFF8010
          │   ├─────────────────────────────┤
          │   │      Dernier élément        │  <─── RSP pointe ici (0x7FFFFFFF8008)
          │   ├─────────────────────────────┤
          │   │      Zone libre (vide)      │  <─── Prochaine case (0x7FFFFFFF8000)
          │   └─────────────────────────────┘
          ▼
     Adresses Basses (Vers où la pile grandit)
```

### 1. `PUSH opérande` (Empiler 8 octets)
L'instruction `push reg` équivaut exactement à ces deux actions matérielles :
1. Décrémenter le pointeur de pile de 8 octets : `sub rsp, 8`
2. Copier la valeur dans la case mémoire pointée : `mov [rsp], reg`

### 2. `POP destination` (Dépiler 8 octets)
L'instruction `pop reg` équivaut exactement à :
1. Lire la valeur au sommet de la pile : `mov reg, [rsp]`
2. Incrémenter le pointeur de pile de 8 octets : `add rsp, 8`

> [!NOTE]
> En mode 64 bits, `push` et `pop` manipulent par défaut des mots de **64 bits (8 octets)**. On peut aussi pousser des mots de 16 bits, mais jamais de 32 bits directs.

---

## 7.2 — Anatomie d'un Appel de Fonction : `CALL` et `RET`

Une fonction n'est rien d'autre qu'un bloc d'instructions situé à une adresse mémoire donnée, qui se termine par `ret`.

```
        PROGRAMME APPELANT                         FONCTION APPELÉE
     ┌───────────────────────┐                  ┌───────────────────────┐
     │  call my_function     │ ───────────────► │ my_function:          │
     │                       │  1. Empile RIP   │     ; Code...         │
     │  prochaine_instr:     │  2. Saute au     │     ret               │
     │  (adresse de retour)  │     label        │     1. Dépile dans RIP│
     │                       │ ◄─────────────── │     2. Saute au retour│
     └───────────────────────┘                  └───────────────────────┘
```

### Ce que fait `call label` en coulisses :
1. Le processeur pousse l'adresse de l'instruction qui suit immédiatement le `call` sur la pile (c'est l'**adresse de retour** / *Return Address*).
2. Il charge l'adresse du `label` dans `RIP` (saut).

### Ce que fait `ret` :
1. Le processeur dépile les 8 octets situés au sommet de `[rsp]` et les charge dans `RIP`.
2. L'exécution reprend immédiatement après l'instruction `call` de l'appelant !

> [!CAUTION]
> **LE CRASH DE LA PILE DÉSÉQUILIBRÉE :**
> Si tu fais un `push rax` à l'intérieur de ta fonction sans faire de `pop` avant le `ret`, l'instruction `ret` va prendre la valeur de `rax` comme si c'était une adresse de retour ! Le processeur va sauter n'importe où $\rightarrow$ **Segmentation Fault immédiat** !
> **Règle d'or : Tout `push` doit avoir son `pop` correspondant avant le `ret`.**

---

## 7.3 — Le Cadre de Pile (*Stack Frame*) et `RBP`

Quand une fonction devient complexe (avec plusieurs variables locales ou des appels imbriqués), la valeur de `RSP` ne cesse de bouger.
Pour retrouver facilement l'adresse des variables locales sans se perdre, on utilise un repère fixe : le **Pointeur de Base `RBP`** (*Base Pointer* ou *Frame Pointer*).

```
  Adresses Hautes
  ─────────────────────────────────────────────────────────────
  [ Paramètres 7, 8... passés sur la pile (si > 6 args) ]
  [ Adresse de retour (8 octets empilés par CALL)        ]  <── RBP + 8
  [ Ancien RBP sauvegardé par PUSH RBP                  ]  <── RBP pointe ici (Offset 0)
  ─────────────────────────────────────────────────────────────
  [ Variable locale 1 (ex: int x)                       ]  <── RBP - 8
  [ Variable locale 2 (ex: long y)                      ]  <── RBP - 16
  [ Tampon mémoire local (ex: char buf[32])             ]  <── RBP - 48
  ─────────────────────────────────────────────────────────────
  [ Sommet de pile courant                              ]  <── RSP
  Adresses Basses
```

### Le Prologue Standard :
Au début de toute fonction non triviale :
```asm
my_function:
    push    rbp                 ; 1. Sauvegarde l'ancien cadre de pile
    mov     rbp, rsp            ; 2. Établit le nouveau point de repère
    sub     rsp, 32             ; 3. Alloue 32 octets pour nos variables locales
```

### Accès aux variables locales :
- Première variable : `[rbp - 8]`
- Deuxième variable : `[rbp - 16]`

### L'Épilogue Standard :
À la fin de la fonction, avant de quitter :
```asm
    mov     rsp, rbp            ; 1. Libère toutes les variables locales d'un coup
    pop     rbp                 ; 2. Restaure l'ancien cadre de l'appelant
    ret                         ; 3. Retourne à l'appelant
```

> [!TIP]
> **L'instruction `leave` :**
> x86_64 fournit une instruction dédiée qui remplace exactement les deux lignes `mov rsp, rbp` et `pop rbp` :
> ```asm
> leave                           ; Équivaut à: mov rsp, rbp puis pop rbp
> ret
> ```

---

## 7.4 — La Convention d'Appel System V AMD64 ABI

Sur Linux, BSD et macOS, tous les compilateurs (GCC, Clang) et les bibliothèques partagent une convention de communication universelle : l'**ABI System V AMD64**.

Si tu ne respectes pas cette convention, ton code plantera dès qu'il interagira avec du C, la libc, ou d'autres fonctions !

### 1. Passage des Arguments Entiers et Pointeurs
Les 6 premiers arguments sont passés directement dans des registres matériels (dans cet ordre précis) :

| Argument | Registre 64 bits | Registre 32 bits | Registre 8 bits |
|---|---|---|---|
| **1er argument** | **`RDI`** | `EDI` | `DIL` |
| **2ème argument**| **`RSI`** | `ESI` | `SIL` |
| **3ème argument**| **`RDX`** | `EDX` | `DL` |
| **4ème argument**| **`RCX`** | `ECX` | `CL` |
| **5ème argument**| **`R8`**  | `R8D` | `R8B` |
| **6ème argument**| **`R9`**  | `R9D` | `R9B` |
| **Au-delà (7+)** | **Sur la Pile** (poussés de droite à gauche avant le call) | | |

### 2. Valeur de Retour
- Entier ou Pointeur (jusqu'à 64 bits) : placé dans **`RAX`**.
- Entier 128 bits : placé dans le couple **`RDX:RAX`**.
- Nombres à virgule flottante : placés dans **`XMM0`**.

---

## 7.5 — Registres Caller-Saved vs Callee-Saved (CRUCIAL)

C'est le contrat de confiance absolu entre fonctions :

```
┌────────────────────────────────────────────────────────────────────────┐
│                   CALLEE-SAVED (Préservés par la fonction)              │
│       RBX, RSP, RBP, R12, R13, R14, R15                                │
│  La fonction appelée DOIT restituer ces registres dans leur état exact │
│  d'origine avant de faire 'ret' (via push/pop).                        │
├────────────────────────────────────────────────────────────────────────┤
│                   CALLER-SAVED (Volatils / Temporaires)                │
│       RAX, RDI, RSI, RDX, RCX, R8, R9, R10, R11, RFLAGS, XMM0-15       │
│  La fonction appelée a le droit d'ÉCRASER ces registres sans prévenir. │
│  Si l'appelant en a besoin après le 'call', C'EST À LUI de les sauver. │
└────────────────────────────────────────────────────────────────────────┘
```

#### Exemple concret du piège :
```asm
; MAUVAIS CODE :
mov     r10, 42
call    printf              ; printf a le droit absolu d'écraser r10 (caller-saved) !
; r10 ne vaut plus forcément 42 ici !

; CODE CORRECT :
mov     r12, 42             ; R12 est callee-saved : printf est obligée de le préserver !
call    printf
; r12 vaut TOUJOURS 42 ici avec certitude !
```

---

## 7.6 — La Règle d'Or : L'Alignement 16 Octets de la Pile

C'est le piège numéro 1 des développeurs assembleur sur x86_64.

> [!CRITICAL]
> **LA RÈGLE DE L'ABI :**
> Juste **avant l'exécution d'une instruction `call`**, la valeur du pointeur de pile `RSP` doit être un **multiple exact de 16** ($RSP \pmod{16} == 0$).

### Pourquoi ce piège est vicieux :
1. L'appelant s'est arrangé pour que $RSP \pmod{16} == 0$.
2. L'instruction `call` s'exécute : elle empile l'adresse de retour (8 octets !).
3. **À l'entrée exacte de la fonction appelée**, $RSP \pmod{16} == 8$ !
4. Si la fonction appelée veut à son tour faire un `call` (vers `printf`, `malloc`, etc.), elle doit **obligatoirement réaligner la pile sur 16 octets** !

```
Avant le CALL chez l'appelant   : RSP = 0x...0 (aligné sur 16)
CALL pousse l'adresse de retour  : RSP = 0x...8 (désaligné !)
Entrée dans la fonction          :
    push rbp                     : RSP = 0x...0 (réaligné à 16 !)
    ; Si tu n'appelles aucune fonction, tu peux t'en moquer.
    ; Mais si tu alloues des variables locales :
    sub rsp, 8                   : RSP = 0x...8 (DÉSALIGNÉ !)
    call printf                  : 💥 CRASH "movaps" dans la libc !
    
    ; Correction :
    sub rsp, 16                  : RSP = 0x...0 (ALIGNÉ SUR 16 !)
    call printf                  : ✅ Fonctionne parfaitement !
```

> [!NOTE]
> Les fonctions de la libc utilisent des instructions vectorielles SIMD (`movaps`) pour optimiser les performances. Ces instructions provoquent un crash matériel instantané si l'adresse mémoire n'est pas alignée sur 16 octets.

---

## 7.7 — La Red Zone (128 octets gratuits)

L'ABI System V AMD64 garantit une spécificité majeure appelée la **Red Zone** :
> Une zone de **128 octets située immédiatement sous `RSP`** (`[rsp - 1]` à `[rsp - 128]`) est sanctuarisée. Aucun signal du noyau ni aucune interruption ne viendra écraser cette mémoire.

### À quoi ça sert ?
Pour une **fonction feuille** (*Leaf Function*, c'est-à-dire une fonction qui n'appelle aucune autre fonction) :
Tu n'as même pas besoin d'écrire de prologue ni d'ajuster `RSP` ! Tu peux utiliser directement `[rsp - 8]`, `[rsp - 16]` comme variables temporaires !

```asm
; Fonction feuille ultra-rapide sans overhead de pile
my_fast_leaf:
    mov     [rsp - 8], rdi      ; Utilise la Red Zone directement
    mov     [rsp - 16], rsi
    add     rdi, rsi
    mov     rax, rdi
    ret                         ; Zéro modification de RSP !
```

---

## 7.8 — La Récursivité en Assembleur

Une fonction récursive s'appelle elle-même. Chaque niveau d'appel crée son propre cadre de pile indépendant, stockant ses propres variables et adresses de retour.

### Exemple Canonique : Factorielle Récursive ($n!$)

```c
// Équivalent C :
long fact(long n) {
    if (n <= 1) return 1;
    return n * fact(n - 1);
}
```

```asm
; =============================================================================
; my_fact_rec — Factorielle récursive en assembleur
; Entrée  : rdi = n
; Sortie  : rax = n!
; =============================================================================
global my_fact_rec

my_fact_rec:
    cmp     rdi, 1
    jg      .recurse            ; Si n > 1, récursion
    mov     rax, 1              ; Cas de base : return 1
    ret

.recurse:
    push    rdi                 ; Sauvegarde notre 'n' sur la pile (callee-saved context)
    dec     rdi                 ; n - 1
    call    my_fact_rec         ; rax = fact(n - 1)
    pop     rdi                 ; Restaure notre 'n' d'origine
    imul    rax, rdi            ; rax = fact(n - 1) * n
    ret
```

Visualisation de la pile pour `fact(3)` :
```
  [ fact(3) : push 3 ] -> RSP décrémenté
    [ fact(2) : push 2 ] -> RSP décrémenté
      [ fact(1) : renvoie 1 ]
    [ fact(2) : pop 2, rax = 1 * 2 = 2 ]
  [ fact(3) : pop 3, rax = 2 * 3 = 6 ]
```

---

## 📝 20 Exercices Pratiques — Niveau 3

### Exercice 1 — Respect de l'ABI : Caller-saved vs Callee-saved ⭐
Indique pour chacun de ces registres s'il est **caller-saved** (la fonction peut l'écraser) ou **callee-saved** (la fonction doit le préserver) :
`rax`, `rbx`, `rcx`, `rdx`, `rsi`, `rdi`, `rbp`, `rsp`, `r12`, `r15`.

### Exercice 2 — Fonction Addition simple à 2 paramètres : `ex51_func_add.asm` ⭐
- **Fichier** : `exercices/niveau-3/ex51_func_add.asm`
- **Consigne** :
  Écris une fonction `add2(a, b)` respectant l'ABI :
  - Reçoit $a$ dans `rdi`, $b$ dans `rsi`
  - Renvoie la somme dans `rax`
  Appelle cette fonction depuis `_start` avec les valeurs 18 et 24, puis quitte avec le code de retour dans `rdi`.
- **Sortie attendue** : exit code = 42.

### Exercice 3 — Fonction à 4 paramètres : `ex52_func_linear.asm` ⭐
- **Fichier** : `exercices/niveau-3/ex52_func_linear.asm`
- **Consigne** :
  Implémente la fonction mathématique :
  $$f(a, b, c, d) = (a \times b) + (c \times d)$$
  Arguments reçus dans `rdi`, `rsi`, `rdx`, `rcx`.
  Teste avec $f(2, 3, 4, 5) = 6 + 20 = 26$.
- **Sortie attendue** : exit code = 26.

### Exercice 4 — Le Crash de l'alignement de pile : Trouver le bug ⭐⭐
Voici un code qui segfault dès qu'on appelle `puts` :
```asm
extern puts
global main
main:
    sub     rsp, 8
    mov     rdi, msg
    call    puts
    add     rsp, 8
    ret
```
Explique pourquoi ce code plante et corrige la valeur de soustraction de `rsp`.

### Exercice 5 — Fonction avec variables locales : `ex53_local_vars.asm` ⭐⭐
- **Fichier** : `exercices/niveau-3/ex53_local_vars.asm`
- **Consigne** :
  Crée une fonction utilisant un cadre de pile (`push rbp; mov rbp, rsp; sub rsp, 16`).
  Alloue deux variables locales :
  - `[rbp - 8] = 30`
  - `[rbp - 16] = 12`
  Calcule la somme de ces deux variables locales dans `rax`, nettoie le cadre avec `leave` et retourne.
- **Sortie attendue** : exit code = 42.

### Exercice 6 — Préservation obligatoire de registre : `ex54_preserve_rbx.asm` ⭐⭐
- **Fichier** : `exercices/niveau-3/ex54_preserve_rbx.asm`
- **Consigne** :
  Soit une fonction qui a absolument besoin d'utiliser `rbx`.
  Écris la fonction de sorte qu'elle sauvegarde `rbx` au début, effectue ses calculs avec `rbx`, puis restitue impérativement `rbx` intact avant le `ret`.

### Exercice 7 — Fonction à 8 paramètres (Dépassement de 6 registres) : `ex55_eight_args.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-3/ex55_eight_args.asm`
- **Consigne** :
  L'ABI impose de passer les arguments 7 et 8 sur la pile !
  Écris la fonction `sum8(a, b, c, d, e, f, g, h)` qui additionne ses 8 paramètres.
  Récupère les paramètres 7 et 8 depuis la pile (`[rbp + 16]` et `[rbp + 24]`).
  Appelle-la avec les nombres de 1 à 8 ($1+2+\dots+8 = 36$).
- **Sortie attendue** : exit code = 36.

### Exercice 8 — Factorielle récursive : `ex56_recursive_fact.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-3/ex56_recursive_fact.asm`
- **Consigne** :
  Implémente la fonction factorielle récursive vue en section 7.8.
  Calcule $5! = 120$ et retourne le résultat en exit code.
- **Sortie attendue** : exit code = 120.

### Exercice 9 — Fibonacci récursif : `ex57_recursive_fibo.asm` ⭐⭐⭐⭐
- **Fichier** : `exercices/niveau-3/ex57_recursive_fibo.asm`
- **Consigne** :
  Implémente la double récursion de Fibonacci :
  `fib(n) = fib(n-1) + fib(n-2)` avec cas de base `fib(0)=0, fib(1)=1`.
  Attention à bien sauvegarder l'état sur la pile entre les deux appels !
  Calcule $F_6 = 8$.
- **Sortie attendue** : exit code = 8.

### Exercice 10 — Fonction Swap par pointeurs : `ex58_swap_ptrs.asm` ⭐⭐
- **Fichier** : `exercices/niveau-3/ex58_swap_ptrs.asm`
- **Consigne** :
  Implémente `void swap(long *a, long *b)` qui échange les deux valeurs en mémoire.

### Exercice 11 — Exploitation de la Red Zone : `ex59_red_zone_leaf.asm` ⭐⭐
- **Fichier** : `exercices/niveau-3/ex59_red_zone_leaf.asm`
- **Consigne** :
  Écris une fonction feuille qui stocke 3 entiers temporaires dans la Red Zone (`[rsp - 8]`, `[rsp - 16]`, `[rsp - 24]`) sans jamais modifier `RSP`.

### Exercice 12 — Compteur d'appels statique : `ex60_static_counter.asm` ⭐⭐
- **Fichier** : `exercices/niveau-3/ex60_static_counter.asm`
- **Consigne** :
  Écris une fonction `get_id()` qui renvoie un identifiant unique auto-incrémenté à chaque appel (1 au 1er appel, 2 au 2ème, 3 au 3ème) en utilisant une variable persistante en `.data`.

### Exercice 13 — Somme récursive d'un tableau : `ex61_recursive_sum.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-3/ex61_recursive_sum.asm`
- **Consigne** :
  Écris une fonction récursive `sum_array(long *arr, size_t n)` qui additionne les éléments d'un tableau récursivement.

### Exercice 14 — Fonction Max à nombre variable de paramètres (Variadique simple) ⭐⭐⭐
- **Fichier** : `exercices/niveau-3/ex62_max_va.asm`
- **Consigne** :
  Écris une fonction `find_max_n(size_t count, ...)` qui prend le nombre d'éléments en premier paramètre, puis parcourt les arguments suivants.

### Exercice 15 — Tours de Hanoï : Comptage de coups récursifs ⭐⭐⭐⭐
- **Fichier** : `exercices/niveau-3/ex63_hanoi_count.asm`
- **Consigne** :
  Pour $N$ disques, le nombre minimal de mouvements est $H(N) = 2 \times H(N-1) + 1$ avec $H(1) = 1$.
  Implémente cette récursion pour $N = 5$ ($H(5) = 31$).
- **Sortie attendue** : exit code = 31.

### Exercice 16 — Structure en mémoire et Padding ⭐⭐
Soit la structure C :
```c
struct Person {
    char  initiale;  // 1 octet
    long  id;        // 8 octets
    short age;       // 2 octets
};
```
1. Quelle est la taille totale de cette structure en mémoire (avec alignement naturel) ?
2. À quels offsets se trouvent respectivement `initiale`, `id` et `age` ?

### Exercice 17 — Accès aux champs d'une structure : `ex64_struct_access.asm` ⭐⭐
- **Fichier** : `exercices/niveau-3/ex64_struct_access.asm`
- **Consigne** :
  Déclare une structure `Point` avec `x` (8 octets) et `y` (8 octets).
  Passe le pointeur de cette structure à une fonction `get_distance_sq(Point *p)` qui calcule $x^2 + y^2$.
  Pour $x = 3, y = 4$, la fonction renvoie 25.
- **Sortie attendue** : exit code = 25.

### Exercice 18 — Fonction Ackermann-Péter (L'épreuve de récursion profonde) ⭐⭐⭐⭐
- **Fichier** : `exercices/niveau-3/ex65_ackermann.asm`
- **Consigne** :
  $A(m, n)$ :
  - Si $m = 0 \rightarrow n + 1$
  - Si $m > 0$ et $n = 0 \rightarrow A(m - 1, 1)$
  - Si $m > 0$ et $n > 0 \rightarrow A(m - 1, A(m, n - 1))$
  Calcule $A(2, 2) = 7$.
- **Sortie attendue** : exit code = 7.

### Exercice 19 — Sauvegarder et restaurer le contexte complet (Pusha 64b) ⭐⭐⭐
- **Fichier** : `exercices/niveau-3/ex66_save_context.asm`
- **Consigne** :
  L'instruction 32 bits `pusha` (qui sauvait tous les registres) n'existe plus en 64 bits.
  Crée une macro `%macro PUSH_ALL 0` et `%macro POP_ALL 0` qui sauvegarde proprement l'ensemble des 14 registres généraux sur la pile et les restaure dans l'ordre inverse exact.

### Exercice 20 — Défi Ultime du Niveau 3 : L'Interprète de Bytecode de Pile ⭐⭐⭐⭐⭐
- **Fichier** : `exercices/niveau-3/ex67_stack_vm.asm`
- **Consigne** :
  Conçois une mini machine virtuelle à pile qui lit une suite d'octets d'instructions :
  - `0x01 VAL` : PUSH immédiat sur la pile d'exécution
  - `0x02` : ADD (dépile 2 valeurs, les additionne, empile le résultat)
  - `0x03` : MUL (dépile 2 valeurs, multiplie, empile le résultat)
  - `0xFF` : HALT (quitte et renvoie la valeur au sommet de la pile)
  Exécute le programme : `PUSH 5, PUSH 8, ADD, PUSH 2, MUL, HALT` $\rightarrow (5 + 8) \times 2 = 26$.
- **Sortie attendue** : exit code = 26.

---

## 🧩 Mini-Quiz de fin de chapitre

1. Quel registre sert de repère fixe (*Frame Pointer*) pour adresser les variables locales ?
2. Quels sont les 6 registres utilisés pour passer les 6 premiers arguments d'une fonction selon l'ABI System V ?
3. Quelle instruction combine `mov rsp, rbp` et `pop rbp` en une seule ligne ?
4. Pourquoi la pile doit-elle être impérativement alignée sur 16 octets avant un `call` vers la libc ?
5. Qu'est-ce que la Red Zone et quelle est sa taille ?

<details>
<summary>Réponses du quiz</summary>

1. Le registre `RBP`.
2. `RDI`, `RSI`, `RDX`, `RCX`, `R8`, `R9`.
3. L'instruction `leave`.
4. Parce que les fonctions internes de la libc utilisent des instructions vectorielles SIMD (`movaps`) qui lèvent une exception matérielle si la mémoire n'est pas alignée sur 16 octets.
5. C'est une zone de 128 octets réservée immédiatement sous `RSP` utilisable par les fonctions feuilles sans avoir à allouer d'espace sur la pile.
</details>

---

> 🏅 **Badge débloqué : Maître de la pile** — Tu possèdes désormais la compétence la plus respectée du développeur bas niveau : comprendre intimement la mécanique des fonctions et de la mémoire d'exécution.
> 
> ➡️ **Direction : NIVEAU 4 — Interface avec le Système et le C !**
