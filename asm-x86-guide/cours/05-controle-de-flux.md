# Chapitre 5 — Le Contrôle de Flux : Comparaisons, Sauts, Boucles et Structures de Contrôle

## 🎯 Objectifs de ce chapitre

À la fin de ce chapitre, tu seras capable de :
- [ ] Différencier précisément l'instruction `cmp` et l'instruction `test` (et savoir laquelle choisir selon le contexte).
- [ ] Connaître par cœur la table des sauts conditionnels (`jcc`) et ne plus **JAMAIS** confondre les sauts signés (`jg`, `jl`) et non signés (`ja`, `jb`).
- [ ] Traduire de manière mécanique et systématique n'importe quelle structure de contrôle C (`if/else`, `while`, `for`, `do-while`) en assembleur x86_64.
- [ ] Remplacer les branchements par des instructions sans saut : **`cmov`** (*Conditional Move*) et **`setcc`** pour éliminer les pénalités de *branch prediction*.
- [ ] Comprendre pourquoi l'instruction historique `loop` ne doit plus jamais être utilisée dans du code moderne.
- [ ] Concevoir une **Jump Table** (table de sauts indexée) pour implémenter un `switch/case` ultra-performant en $O(1)$.

## 📋 Prérequis
- Avoir complété le Chapitre 4 (le registre `RFLAGS` : `ZF`, `CF`, `SF`, `OF`).

## ⏱️ Durée estimée : 6–8 heures (Théorie + 18 Exercices pratiques)

---

## 5.1 — Comparer sans Modifier : `CMP` et `TEST`

En assembleur, un saut conditionnel ne s'exécute jamais « dans le vide » : il lit obligatoirement l'état des drapeaux dans le registre **`RFLAGS`**.

Pour positionner ces drapeaux sans modifier les données contenues dans tes registres, le processeur fournit deux instructions soeurs :

### 1. L'instruction `CMP` (Compare)
Syntaxe : `cmp opérande1, opérande2`
- **Mécanisme interne** : `cmp` effectue une **soustraction virtuelle** :
  $$\text{opérande1} - \text{opérande2}$$
- **La valeur de `opérande1` N'EST PAS MODIFIÉE**.
- Seuls les drapeaux de `RFLAGS` (`ZF`, `SF`, `CF`, `OF`) sont mis à jour !

```asm
cmp     rax, 42
; Si rax == 42 : rax - 42 = 0  ===> ZF = 1
; Si rax < 42  : rax - 42 < 0  ===> SF = 1 (en signé) ou CF = 1 (en non-signé)
; Si rax > 42  : rax - 42 > 0  ===> ZF = 0, SF = 0
```

### 2. L'instruction `TEST` (Test logique)
Syntaxe : `test opérande1, opérande2`
- **Mécanisme interne** : `test` effectue un **`AND` logique virtuel** :
  $$\text{opérande1} \text{ AND } \text{opérande2}$$
- **Aucun registre n'est modifié**.
- Met à jour `ZF`, `SF`, `PF` (et remet `CF` et `OF` à zéro).

**L'idiome incontournable de `TEST` : tester si un registre est nul ou son signe**
```asm
test    rax, rax        ; Calcule rax AND rax
; Si rax == 0 : ZF = 1 (Zero Flag)
; Si rax < 0  : SF = 1 (Sign Flag, bit 63 à 1)
; C'est plus compact et plus rapide que "cmp rax, 0" !
```

---

## 5.2 — La Table Complète des Sauts Conditionnels (`Jcc`)

Le processeur dispose d'un saut inconditionnel (**`jmp label`**, équivalent du `goto`) et d'une panoplie de sauts conditionnels basés sur les drapeaux.

```
                  ┌──────────────────────┐
                  │   CMP / TEST / ALU   │
                  └──────────┬───────────┘
                             │ Met à jour RFLAGS
                             ▼
                  ┌──────────────────────┐
                  │   SAUT CONDITIONNEL  │
                  └──────────┬───────────┘
               Drapeau vérifié ?
               ├── OUI ──► Modifie RIP (Saut vers le Label)
               └── NON ──► Continue à l'instruction suivante
```

### Le Grand Tableau de Référence (À imprimer ou mémoriser)

| Instruction | Signification | Condition RFLAGS | Utilisé pour |
|---|---|---|---|
| **Égalité & Zéro** | | | |
| **`je`** / **`jz`** | *Jump if Equal* / *Jump if Zero* | `ZF == 1` | Égalité ($A == B$) ou résultat nul |
| **`jne`** / **`jnz`**| *Jump if Not Equal* / *Not Zero* | `ZF == 0` | Différence ($A \ne B$) ou non-nul |
| **Comparaisons SIGNÉES (Nombres relatifs : négatifs et positifs)** | | | |
| **`jg`** | *Jump if Greater* ($A > B$) | `ZF == 0` et `SF == OF` | Strictement supérieur |
| **`jge`**| *Jump if Greater or Equal* ($A \ge B$)| `SF == OF` | Supérieur ou égal |
| **`jl`** | *Jump if Less* ($A < B$) | `SF != OF` | Strictement inférieur |
| **`jle`**| *Jump if Less or Equal* ($A \le B$) | `ZF == 1` ou `SF != OF` | Inférieur ou égal |
| **Comparaisons NON SIGNÉES (Adresses mémoire, tailles, compteurs)** | | | |
| **`ja`** | *Jump if Above* ($A > B$) | `CF == 0` et `ZF == 0` | Strictement supérieur |
| **`jae`**| *Jump if Above or Equal* ($A \ge B$)| `CF == 0` | Supérieur ou égal |
| **`jb`** | *Jump if Below* ($A < B$) | `CF == 1` | Strictement inférieur |
| **`jbe`**| *Jump if Below or Equal* ($A \le B$) | `CF == 1` ou `ZF == 1` | Inférieur ou égal |
| **Drapeaux Individuels** | | | |
| **`js`** / **`jns`** | *Jump if Sign* / *Not Sign* | `SF == 1` / `SF == 0` | Si négatif / Si positif |
| **`jc`** / **`jnc`** | *Jump if Carry* / *Not Carry*| `CF == 1` / `CF == 0` | Si retenue / Pas de retenue |
| **`jo`** / **`jno`** | *Jump if Overflow* / *Not Over*| `OF == 1` / `OF == 0` | Si débordement signé |

> [!CAUTION]
> **LE PIÈGE HISTORIQUE : SIGNÉ VS NON SIGNÉ !**
> - Pour des entiers signés (`int`, `long` négatifs possibles) : utilise **`G`** et **`L`** (*Greater / Less*).
> - Pour des entiers non signés (`unsigned int`, pointeurs mémoires) : utilise **`A`** et **`B`** (*Above / Below*).
> Si tu compares l'adresse mémoire `0xFFFFFFFF80000000` et `0x0000000000001000` avec `jl` au lieu de `jb`, le processeur considérera l'adresse comme un nombre négatif et inversera complètement ta logique !

---

## 5.3 — Traduction Mécanique : Du C vers l'Assembleur

En assembleur, on pense souvent avec la **condition inverse**. Pour sauter par-dessus un bloc `if`, on teste la négation de la condition !

### 1. La Structure `if (a == b)`

```c
// Code C
if (a == b) {
    do_something();
}
```

```asm
; Équivalent Assembleur
    cmp     rax, rbx
    jne     .skip_if            ; Si FAUX (non égal), on saute par-dessus !
    ; --- Corps du if (do_something) ---
    ...
.skip_if:
```

### 2. La Structure `if / else`

```c
// Code C
if (a > b) {
    x = 1;
} else {
    x = 2;
}
```

```asm
; Équivalent Assembleur
    cmp     rax, rbx
    jle     .else_branch        ; Si a <= b (condition inverse), aller dans else

    ; --- Branche IF (a > b) ---
    mov     rcx, 1
    jmp     .end_if             ; INDISPENSABLE : sauter par-dessus le else !

.else_branch:
    ; --- Branche ELSE ---
    mov     rcx, 2

.end_if:
```

### 3. La Boucle `while (condition)`

```c
// Code C
while (rax < 10) {
    rax++;
}
```

```asm
; Modèle canonique de boucle while
.loop_start:
    cmp     rax, 10
    jge     .loop_end           ; Condition de sortie au début

    ; --- Corps de la boucle ---
    inc     rax

    jmp     .loop_start         ; Reboucler

.loop_end:
```

### 4. La Boucle `for (int i = 0; i < n; i++)`

```c
// Code C
int sum = 0;
for (int i = 0; i < 10; i++) {
    sum += i;
}
```

```asm
; Équivalent Assembleur
    xor     rax, rax            ; sum = 0
    xor     rcx, rcx            ; i = 0 (RCX sert traditionnellement d'indice)

.for_loop:
    cmp     rcx, 10             ; Test de fin : i < 10 ?
    jge     .for_end            ; Si i >= 10, sortir

    add     rax, rcx            ; sum += i

    inc     rcx                 ; i++
    jmp     .for_loop

.for_end:
```

---

## 5.4 — Coder sans Saut : `CMOV` et `SETcc`

Les processeurs modernes disposent de longs *pipelines* d'exécution et prédisent à l'avance les branches des sauts (*Branch Predictor*). Quand un saut est imprévisible, le processeur se trompe, vide tout son pipeline et perd **15 à 20 cycles d'horloge** !

Pour éliminer ce problème, x86_64 offre des instructions conditionnelles qui ne provoquent **aucun saut**.

### 1. `SETcc` : Convertir un drapeau en 0 ou 1
`setcc destination_8bits` met le registre 8 bits à `1` si la condition est vraie, ou à `0` si elle est fausse.

```asm
; Calculer : rdi = (rax == 42) ? 1 : 0
cmp     rax, 42
sete    dil                 ; dil = 1 si égal, 0 sinon
movzx   rdi, dil            ; zérote le reste de rdi
; Zéro saut, zéro branchement, exécution ultra-linéaire !
```

### 2. `CMOVcc` : Conditional Move
Syntaxe : `cmovcc destination, source`
Copie la source dans la destination **uniquement si la condition est remplie**.

```asm
; Calculer le maximum : rdi = (rax > rbx) ? rax : rbx
cmp     rax, rbx
mov     rdi, rbx            ; Par défaut, max = rbx
cmovg   rdi, rax            ; Si rax > rbx (signé), rdi reçoit rax !
```

---

## 5.5 — Pourquoi l'instruction `LOOP` est bannie

Il existe en x86 une instruction historique nommée `loop label`. Elle décrémente `rcx` et saute au label si `rcx != 0`.

> [!WARNING]
> **Ne jamais utiliser `LOOP` dans du code moderne !**
> Sur les processeurs modernes (Intel Core, AMD Ryzen, et même sous émulation Rosetta), l'instruction `loop` est microcodée et s'exécute beaucoup plus lentement que le couple standard :
> ```asm
> dec rcx
> jnz .loop
> ```
> Tous les compilateurs modernes (`gcc -O2`, `clang`) génèrent systématiquement `dec + jnz`. Bannis `loop` de ton arsenal.

---

## 5.6 — Le `switch/case` et les Jump Tables

Quand un `switch` comporte de nombreux cas consécutifs, faire une succession de `cmp/je` devient inefficace ($O(n)$). Les compilateurs créent alors une **table de pointeurs de saut** (*Jump Table*) en mémoire pour sauter directement au bon bloc en $O(1)$ !

```asm
section .rodata
    ; Table de pointeurs 64 bits vers nos labels
    align 8
    jump_table:
        dq .case_0
        dq .case_1
        dq .case_2
        dq .case_3

section .text
    ; rax contient notre valeur à tester (0, 1, 2 ou 3)
    cmp     rax, 3
    ja      .default_case       ; Si au-delà de 3, cas par défaut

    ; Saut indirect indexé via la table !
    jmp     [jump_table + rax * 8]

.case_0:
    ; Traitement cas 0
    jmp     .end_switch
.case_1:
    ; Traitement cas 1
    jmp     .end_switch
.case_2:
    ; Traitement cas 2
    jmp     .end_switch
.case_3:
    ; Traitement cas 3
    jmp     .end_switch
.default_case:
    ; Traitement par défaut
.end_switch:
```

---

## 📝 18 Exercices Pratiques — Niveau 2 (Série Chapitre 5)

### Exercice 1 — Choix du bon saut conditionnel ⭐
Pour chaque cas en C, indique l'instruction de saut conditionnel x86_64 appropriée :
1. `if (a == b)`
2. `if (count != 0)`
3. `if (temperature < -5)` (signé)
4. `if (ptr_adresse > 0x7FFF0000)` (non signé)
5. `if (taille <= 100)` (non signé)

### Exercice 2 — Valeur absolue sans branchement : `ex22_abs_cmov.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex22_abs_cmov.asm`
- **Consigne** :
  Soit $x = -42$ dans `rax`.
  Calcule la valeur absolue $|x|$ en utilisant `neg` et `cmovs` (ou `cmovl`), sans aucun saut `jmp` !
  Retourne le résultat dans `rdi`.
- **Sortie attendue** : exit code = 42.

### Exercice 3 — Maximum de 3 entiers : `ex23_max3.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex23_max3.asm`
- **Consigne** :
  Soit 3 entiers signés : $a = 12$, $b = 45$, $c = 28$.
  Trouve le plus grand des trois et retourne-le dans `rdi`.
- **Sortie attendue** : exit code = 45.

### Exercice 4 — Boucle de décompte : `ex24_countdown_loop.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex24_countdown_loop.asm`
- **Consigne** :
  Pars de `rcx = 10`. À chaque itération, décrémente `rcx`.
  La boucle s'arrête quand `rcx == 0`.
  Retourne le nombre d'itérations effectuées dans `rdi`.
- **Sortie attendue** : exit code = 10.

### Exercice 5 — Somme itérative : `ex25_sum_loop.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex25_sum_loop.asm`
- **Consigne** :
  Calcule la somme des entiers de 1 à 10 avec une boucle `for` ($1 + 2 + \dots + 10 = 55$).
  Quitte avec la somme dans `rdi`.
- **Sortie attendue** : exit code = 55.

### Exercice 6 — Factorielle itérative : `ex26_factorial_iter.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex26_factorial_iter.asm`
- **Consigne** :
  Calcule $5! = 5 \times 4 \times 3 \times 2 \times 1 = 120$ via une boucle.
  Retourne le résultat dans `rdi`.
- **Sortie attendue** : exit code = 120.

### Exercice 7 — Suite de Fibonacci itérative : `ex27_fibonacci_iter.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex27_fibonacci_iter.asm`
- **Consigne** :
  Rappel : $F_0 = 0, F_1 = 1, F_n = F_{n-1} + F_{n-2}$.
  Calcule le 7ème terme ($F_7 = 13$) avec une boucle.
  Retourne le résultat dans `rdi`.
- **Sortie attendue** : exit code = 13.

### Exercice 8 — Le Grand Classique : FizzBuzz en Asm ! : `ex28_fizzbuzz.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex28_fizzbuzz.asm`
- **Consigne** :
  Pour un entier $N = 15$ :
  - Si divisible par 3 et 5 $\rightarrow$ Afficher `"FizzBuzz\n"`
  - Si divisible par 3 $\rightarrow$ Afficher `"Fizz\n"`
  - Si divisible par 5 $\rightarrow$ Afficher `"Buzz\n"`
  - Sinon $\rightarrow$ Afficher le chiffre
  Pour $N = 15$, le programme doit afficher `"FizzBuzz\n"` et quitter avec 0.

### Exercice 9 — Test de Primalité (Nombre Premier) : `ex29_is_prime.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex29_is_prime.asm`
- **Consigne** :
  Soit $N = 29$.
  Vérifie par divisions successives (de $2$ à $\sqrt{N}$ ou $N/2$) si $N$ est premier.
  Si oui $\rightarrow$ `rdi = 1`. Si non $\rightarrow$ `rdi = 0`. Quitte avec `exit(rdi)`.
- **Sortie attendue** : exit code = 1.

### Exercice 10 — Plus Grand Commun Diviseur (Algorithme d'Euclide) : `ex30_gcd.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex30_gcd.asm`
- **Consigne** :
  Calcule le PGCD de $a = 48$ et $b = 18$ avec l'algorithme d'Euclide :
  `tant que b != 0 { r = a % b; a = b; b = r; } return a;`
- **Sortie attendue** : exit code = 6.

### Exercice 11 — Inversion d'un tableau en mémoire : `ex31_reverse_array.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex31_reverse_array.asm`
- **Consigne** :
  Soit un tableau de 5 octets en `.data` : `tab db 1, 2, 3, 4, 5`.
  En utilisant deux pointeurs (un au début, un à la fin) et une boucle, inverse les éléments en mémoire pour obtenir `5, 4, 3, 2, 1`.
  Retourne le premier élément (`tab[0] = 5`) dans `rdi`.
- **Sortie attendue** : exit code = 5.

### Exercice 12 — Recherche linéaire du Maximum : `ex32_find_max.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex32_find_max.asm`
- **Consigne** :
  Soit un tableau : `nums db 12, 85, 42, 99, 7, 63`.
  Parcours le tableau et trouve la valeur maximale.
- **Sortie attendue** : exit code = 99.

### Exercice 13 — Tri à Bulles (Bubble Sort) : `ex33_bubble_sort.asm` ⭐⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex33_bubble_sort.asm`
- **Consigne** :
  Trie le tableau `arr db 5, 1, 4, 2, 8` par ordre croissant en utilisant un double parcours de boucle (tri à bulles).
  Retourne l'élément médian trié (`arr[2] = 4`) dans `rdi`.
- **Sortie attendue** : exit code = 4.

### Exercice 14 — Implémentation d'une Jump Table : `ex34_jump_table.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex34_jump_table.asm`
- **Consigne** :
  Implémente un `switch (choix)` avec une table de sauts pour 4 cas (0, 1, 2, 3) qui affecte à `rdi` respectivement les valeurs 100, 200, 300, 400.
  Pour `choix = 2`, le programme doit quitter avec le code `300` (soit $300 \pmod{256} = 44$).
- **Sortie attendue** : exit code = 44.

### Exercice 15 — Palindrome Détecteur : `ex35_is_palindrome.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex35_is_palindrome.asm`
- **Consigne** :
  Soit la chaîne `"radar"`. Vérifie si c'est un palindrome en comparant les caractères deux à deux depuis les extrémités.
  Si oui $\rightarrow$ `rdi = 1`, sinon `rdi = 0`.
- **Sortie attendue** : exit code = 1.

### Exercice 16 — Puissance entière $X^Y$ itérative : `ex36_power.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex36_power.asm`
- **Consigne** :
  Calcule $2^6 = 64$ via une boucle de multiplications successives.
- **Sortie attendue** : exit code = 64.

### Exercice 17 — Compter les voyelles d'une chaîne : `ex37_count_vowels.asm` ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex37_count_vowels.asm`
- **Consigne** :
  Dans la chaîne `"assembleur"`, compte le nombre de voyelles (a, e, i, o, u, y).
- **Sortie attendue** : exit code = 4 (a, e, e, u).

### Exercice 18 — Trouver le bug : La boucle infinie fatale ⭐⭐
Explique pourquoi ce code ne s'arrête jamais :
```asm
section .text
    global _start
_start:
    mov     al, 0
.loop:
    inc     al
    cmp     al, 300
    jne     .loop
    mov     rax, 60
    xor     rdi, rdi
    syscall
```

---

## 🧩 Mini-Quiz de fin de chapitre

1. Quelle instruction permet de comparer deux registres sans modifier leur contenu ?
2. Quel saut conditionnel utiliser pour tester si un entier signé $A$ est strictement supérieur à $B$ ?
3. Quel saut conditionnel utiliser pour tester si une adresse mémoire $A$ est supérieure à $B$ ?
4. Pourquoi `test rax, rax` est-il préférable à `cmp rax, 0` ?
5. Quel avantage procure l'instruction `cmov` par rapport à un bloc `cmp + jne + mov` ?

<details>
<summary>Réponses du quiz</summary>

1. `cmp opérande1, opérande2`.
2. `jg` (*Jump if Greater*).
3. `ja` (*Jump if Above* — comparaisons non signées pour les adresses).
4. `test rax, rax` génère un opcode plus court (2 octets contre 3 ou 4 octets) et teste la nullité ou le signe sans charger d'immédiat.
5. `cmov` évite les branchements conditionnels et supprime tout risque d'erreur de prédiction de branche (*Branch misprediction penalty*).
</details>

---

> 🏅 **Badge débloqué : Contrôleur de flux** — Tu maîtrises la totalité des structures de contrôle. Passons immédiatement au **Chapitre 6 : Modes d'adressage complexes, Chaînes et Projet 3 (Mini-strlen & Mini-strcmp)** !
