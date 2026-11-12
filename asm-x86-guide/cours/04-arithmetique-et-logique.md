# Chapitre 4 — Arithmétique Machine, Registre RFLAGS et l'Art du Calcul

## 🎯 Objectifs de ce chapitre

À la fin de ce chapitre, tu seras capable de :
- [ ] Réaliser sans hésitation des opérations arithmétiques 64 bits (`add`, `sub`, `inc`, `dec`, `neg`).
- [ ] Maîtriser la multiplication x86_64 (`mul` et `imul`) et comprendre pourquoi le résultat s'étale sur la paire de registres `rdx:rax` (128 bits !).
- [ ] Effectuer des divisions sans planter (`div` et `idiv`), en préparant correctement le registre supérieur avec `cqo` et `cdq`.
- [ ] Décoder les 5 drapeaux fondamentaux de **`RFLAGS`** : `ZF` (*Zero Flag*), `CF` (*Carry Flag*), `SF` (*Sign Flag*), `OF` (*Overflow Flag*), `PF` (*Parity Flag*).
- [ ] Utiliser l'instruction **`lea`** (*Load Effective Address*) comme une super-calculatrice matérielle en 1 seul cycle.
- [ ] Réaliser le **Projet 2 : La Calculatrice Simple** (avec gestion de division par zéro et du modulo).

## 📋 Prérequis
- Avoir complété le Chapitre 3 (registres x86_64, `mov`, `movsx`, syntaxe Intel).

## ⏱️ Durée estimée : 6–8 heures (Théorie + 15 Exercices + Projet 2)

---

## 4.1 — Arithmétique de Base : `add`, `sub`, `inc`, `dec`, `neg`

### 1. `add` et `sub`
Syntaxe : `add destination, source` ($\text{dest} = \text{dest} + \text{source}$)  
Syntaxe : `sub destination, source` ($\text{dest} = \text{dest} - \text{source}$)

```asm
mov     rax, 10
add     rax, 5          ; rax = 15
sub     rax, 8          ; rax = 7
```

### 2. `inc` et `dec` : Incrémentation et Décrémentation
Ajoute ou soustrait 1.
```asm
inc     rax             ; rax = rax + 1
dec     rbx             ; rbx = rbx - 1
```

> [!IMPORTANT]
> **Subtilité majeure d'architecture :**
> `inc` et `dec` modifient `ZF`, `SF`, `OF`, mais **ne touchent JAMAIS au drapeau `CF` (Carry Flag)**. 
> Si tu écris une boucle multi-précision où `CF` doit être conservé, utilise `inc` plutôt que `add reg, 1` !

### 3. `neg` : Négation mathématique
Effectue un complément à deux sur la valeur ($\text{dest} = -\text{dest} = \text{NOT}(\text{dest}) + 1$).
```asm
mov     rax, 42
neg     rax             ; rax = -42 (0xFFFFFFFFFFFFFFD6)
neg     rax             ; rax = 42
```

---

## 4.2 — La Multiplication : `mul` vs `imul`

En mathématiques, multiplier deux nombres à $N$ chiffres peut produire un résultat à $2N$ chiffres.
Par exemple, en 64 bits :
$$2^{64} \times 2^{64} = 2^{128}$$
Le processeur x86_64 a résolu ce problème en utilisant **deux registres associés pour le résultat : `RDX:RAX`** !

```
┌────────────────────────────────────────────────────────┐
│             RÉSULTAT SUR 128 BITS (RDX:RAX)            │
├────────────────────────────┬───────────────────────────┤
│    RDX (64 bits de fort)   │    RAX (64 bits de faible)│
└────────────────────────────┴───────────────────────────┘
```

### 1. Multiplication Non Signée : `mul`
Syntaxe : `mul source` (L'autre opérande est **implicitement `RAX`**)
- Si `mul rbx` : `RDX:RAX = RAX * RBX`

```asm
mov     rax, 1000000000     ; 1 milliard
mov     rbx, 2000000000     ; 2 milliards
mul     rbx                 ; RDX:RAX = 2 * 10^18 (Déborde de 64 bits !)
; rax contient les 64 bits de poids faible
; rdx contient les 64 bits de poids fort
```

### 2. Multiplication Signée : `imul` (Beaucoup plus souple !)
Contrairement à `mul`, `imul` existe sous **3 formes syntaxiques** :

```asm
; Forme 1 opérande (Classique, résultat sur RDX:RAX)
imul    rbx                 ; RDX:RAX = RAX * rbx (signé)

; Forme 2 opérandes (Très courante, résultat tronqué sur 64 bits dans dest)
imul    rax, rbx            ; rax = rax * rbx

; Forme 3 opérandes (dest = registre * immédiat)
imul    rax, rbx, 10        ; rax = rbx * 10 (Génial pour calculer en 1 ligne !)
```

---

## 4.3 — La Division : `div` et `idiv`

La division est l'opération la plus complexe du processeur. Elle calcule **simultanément le quotient et le reste (modulo)** !

```
Dividende (128 bits) : RDX:RAX
Diviseur  (64 bits)  : Registre passé en paramètre
-------------------------------------------------
Quotient  (64 bits)  : Placé dans RAX
Reste / Modulo (64b) : Placé dans RDX
```

```
               [  RDX  :  RAX  ]  <--- Dividende (128 bits)
             ÷ [   Diviseur    ]  <--- Registre (64 bits)
             ═══════════════════
        Quotient dans  ===>  RAX
        Reste (modulo) ===>  RDX
```

### 1. Division Non Signée : `div`
Avant d'appeler `div`, **il faut impérativement mettre `RDX` à zéro**, sinon `RDX` sera considéré comme les 64 bits de poids fort de ton dividende !

```asm
; Diviser 42 par 5 (Quotient = 8, Reste = 2)
mov     rax, 42             ; Dividende
xor     rdx, rdx            ; INDISPENSABLE : RDX = 0
mov     rbx, 5              ; Diviseur
div     rbx                 ; rax = 8 (quotient), rdx = 2 (reste)
```

### 2. Division Signée : `idiv` et l'instruction `cqo`
Pour diviser des nombres signés négatifs, mettre `rdx` à zéro corromprait le signe !
Il faut répliquer le bit de signe de `rax` sur tout `rdx`. x86_64 fournit une instruction dédiée pour cela : **`cqo`** (*Convert Quadword to Octoword*).

```asm
; Diviser -42 par 5 (Quotient = -8, Reste = -2)
mov     rax, -42
cqo                         ; Étend le bit de signe de RAX dans RDX automatiquement !
mov     rbx, 5
idiv    rbx                 ; rax = -8, rdx = -2
```

> [!CAUTION]
> **LE CRASH DE DIVISION PAR ZÉRO :**
> Si le diviseur vaut `0`, le processeur déclenche une exception matérielle d'interruption n°0 (`#DE : Divide Error`). Sous Linux, le noyau intercepte cela et envoie immédiatement le signal **`SIGFPE` (Floating Point Exception)** qui tue ton processus avec un crash brutal (`Floating point exception (core dumped)`).
> **Tu dois TOUJOURS vérifier que le diviseur n'est pas nul avant d'exécuter `div` ou `idiv` !**

---

## 4.4 — Le Registre RFLAGS : Les Yeux et les Oreilles du CPU

Le registre **`RFLAGS`** est un registre spécial de 64 bits mis à jour automatiquement par l'ALU après presque chaque opération mathématique ou logique.

```
┌──────────────────────────────────────────────────────────────┐
│                    REGISTRE RFLAGS (Extraits)                │
├──────┬──────┬──────┬──────┬──────┬──────┬──────┬──────┬──────┤
│ ...  │  OF  │  DF  │  IF  │  TF  │  SF  │  ZF  │  AF  │  CF  │
└──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┘
  Bit:    11     10      9      8      7      6      4      0
```

### Les 5 Drapeaux Indispensables :

| Drapeau | Nom complet | Règle de déclenchement (Passe à 1 si...) |
|---|---|---|
| **`ZF`** | **Zero Flag** | Le résultat de l'opération vaut **exactement 0**. |
| **`SF`** | **Sign Flag** | Le résultat est **négatif** (le bit de poids fort vaut 1). |
| **`CF`** | **Carry Flag** | Débordement sur une opération **non signée** (retenue sortante). |
| **`OF`** | **Overflow Flag**| Débordement sur une opération **signée** (ex: Positif + Positif = Négatif). |
| **`PF`** | **Parity Flag** | Le nombre de bits à 1 dans l'octet de poids faible est **pair**. |

### Démonstrations concrètes :

```asm
; 1. Déclenchement de ZF (Zero Flag)
mov     rax, 5
sub     rax, 5          ; Résultat = 0  ===> ZF = 1, SF = 0

; 2. Déclenchement de SF (Sign Flag)
mov     rax, 3
sub     rax, 5          ; Résultat = -2 ===> ZF = 0, SF = 1

; 3. Déclenchement de CF (Carry Flag - non signé)
mov     al, 255
add     al, 1           ; al déborde à 0 ===> CF = 1, ZF = 1

; 4. Déclenchement de OF (Overflow Flag - signé)
mov     al, 127         ; Plus grand entier signé sur 8 bits (+127)
add     al, 1           ; al devient 0x80 (-128 en signé !) ===> OF = 1, SF = 1
```

---

## 4.5 — L'Instruction Magique : `LEA` (Load Effective Address)

`lea` a été créée à l'origine pour calculer l'adresse d'un tableau :  
`lea destination, [base + index * echelle + deplacement]`

Mais les développeurs système et les compilateurs ont vite compris que **c'est la calculatrice arithmétique la plus rapide du processeur** !

### Pourquoi `lea` est magique :
1. Elle fait une addition et une multiplication en **1 seule instruction**.
2. Elle **ne modifie AUCUN drapeau dans RFLAGS** (ZF, CF, SF restent intacts !).
3. Elle permet de stocker le résultat dans un registre **différent** des opérandes (contrairement à `add rax, rbx` qui écrase `rax`).

### Astuces de calcul avec `lea` :
```asm
; Multiplier par 2, 4 ou 8 en 1 cycle (l'échelle ne peut être que 1, 2, 4 ou 8)
lea     rax, [rbx * 2]          ; rax = rbx * 2
lea     rax, [rbx * 4]          ; rax = rbx * 4
lea     rax, [rbx * 8]          ; rax = rbx * 8

; Multiplier par des constantes courantes en une ligne :
lea     rax, [rbx + rbx * 2]    ; rax = rbx + 2*rbx = rbx * 3 !
lea     rax, [rbx + rbx * 4]    ; rax = rbx * 5 !
lea     rax, [rbx + rbx * 8]    ; rax = rbx * 9 !

; Calcul complexe en un cycle : rax = (rcx * 4) + rdx + 15
lea     rax, [rdx + rcx * 4 + 15]
```

---

## 📝 15 Exercices Pratiques — Niveau 2 (Série Chapitre 4)

### Exercice 1 — Prédire les drapeaux RFLAGS ⭐
Pour chacune des instructions suivantes exécutées après `mov al, 0`, donne l'état de `ZF`, `SF`, `CF` (0 ou 1) :
1. `add al, 10`
2. `sub al, 10`
3. `xor al, al`
4. `sub al, 1`

### Exercice 2 — Multiplication et Récupération du résultat : `ex09_mul_simple.asm` ⭐
- **Fichier** : `exercices/niveau-2/ex09_mul_simple.asm`
- **Consigne** :
  Multiplie `rax = 6` par `rbx = 7` avec l'instruction `mul`.
  Déplace le résultat dans `rdi` et quitte avec `exit`.
- **Sortie attendue** : code de retour = 42.

### Exercice 3 — Division et Modulo : `ex10_div_mod.asm` ⭐
- **Fichier** : `exercices/niveau-2/ex10_div_mod.asm`
- **Consigne** :
  Divise 100 par 7.
  Récupère le **reste** (modulo) et renvoie-le comme code de sortie de ton programme.
- **Sortie attendue** : code de retour = 2 (car $100 = 7 \times 14 + 2$).

### Exercice 4 — Calcul de polynôme avec `lea` : `ex11_lea_math.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex11_lea_math.asm`
- **Consigne** :
  Soit $x = 5$ stocké dans `rdi`.
  En utilisant **exclusivement des instructions `lea`** (aucun `add`, aucun `mul`), calcule :
  $$y = 9x + 7$$
  Quitte en retournant $y$ dans `rdi`.
- **Indice** : $9x = x + 8x$.
- **Sortie attendue** : code de retour = 52 ($9 \times 5 + 7 = 52$).

### Exercice 5 — Division signée avec `cqo` : `ex12_idiv_signed.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex12_idiv_signed.asm`
- **Consigne** :
  Divise $-50$ par $4$ en utilisant `idiv` et `cqo`.
  Retourne le quotient dans `rdi`.
- **Sortie attendue** : $-12$ (en code de retour 8 bits non signé : $256 - 12 = 244$).

### Exercice 6 — Moyenne entière de 3 nombres : `ex13_average.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex13_average.asm`
- **Consigne** :
  Soit 3 entiers dans `.data` : `a = 15`, `b = 25`, `c = 35`.
  Calcule la moyenne entière $\frac{a + b + c}{3}$ et retourne-la dans `rdi`.
- **Sortie attendue** : code de retour = 25.

### Exercice 7 — Détection d'Overflow signé ⭐⭐
Explique pourquoi le code suivant allume le drapeau `OF` (Overflow Flag) :
```asm
mov al, 100
add al, 50
```
Quelle est la valeur hexadécimale dans `al` et comment est-elle interprétée en entier signé ?

### Exercice 8 — Rotation de bits avec `rol` et `ror` : `ex14_rotations.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex14_rotations.asm`
- **Consigne** :
  Soit `al = 0b10000001` (`0x81`).
  Applique une rotation de 1 bit vers la gauche (`rol al, 1`).
  Quelle est la nouvelle valeur ? Quitte avec `exit(rdi)`.
- **Sortie attendue** : code de retour = 3 (`0b00000011`).

### Exercice 9 — Multiplier par 15 en 2 cycles d'horloge ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex15_fast_mul15.asm`
- **Consigne** :
  Soit $x = 4$ dans `rax`.
  Calcule $x \times 15$ sans instruction `mul` ni `imul`, en utilisant uniquement un `shl` (ou `lea`) et un `sub` !
  (Astuce mathématique : $15x = 16x - x$).
- **Sortie attendue** : code de retour = 60.

### Exercice 10 — Conversion chiffre ASCII vers entier ⭐⭐
- **Fichier** : `exercices/niveau-2/ex16_ascii_to_digit.asm`
- **Consigne** :
  En ASCII, le caractère `'0'` a pour code `48` (`0x30`), `'1'` vaut `49`, ..., `'9'` vaut `57`.
  Soit le caractère `'7'` stocké dans `al`. Transforme-le en sa valeur numérique réelle `7` par une seule soustraction, puis quitte avec ce code de retour.
- **Sortie attendue** : code de retour = 7.

### Exercice 11 — Conversion entier vers caractère ASCII ⭐⭐
- **Fichier** : `exercices/niveau-2/ex17_digit_to_ascii.asm`
- **Consigne** :
  Fais l'opération inverse : prends la valeur numérique `4` dans `al`, transforme-la en son code ASCII (`'4'`), stocke-la en mémoire et affiche-la sur `stdout`.

### Exercice 12 — Vérifier si un nombre est une puissance de 2 ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex18_power_of_two.asm`
- **Consigne** :
  Astuce de hacker binaire : un nombre entier positif $N$ est une puissance de 2 si et seulement si :
  $$N \text{ AND } (N - 1) == 0$$
  Soit $N = 16$ dans `rax`. Applique cette formule. Si le résultat est 0, mets `rdi = 1` (vrai, c'est une puissance de 2). Quitte avec `exit(rdi)`.
- **Sortie attendue** : code de retour = 1.

### Exercice 13 — Somme des $N$ premiers entiers (Formule de Gauss) ⭐⭐
- **Fichier** : `exercices/niveau-2/ex19_gauss_sum.asm`
- **Consigne** :
  La somme $1 + 2 + 3 + \dots + n$ vaut $\frac{n(n+1)}{2}$.
  Pour $n = 10$, calcule cette somme en assembleur sans boucle et retourne le résultat.
- **Sortie attendue** : code de retour = 55.

### Exercice 14 — Détection de signe sans branchement ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex20_sign_extract.asm`
- **Consigne** :
  Soit un entier signé 64 bits dans `rax` (ex: `-100`).
  Isole son bit de signe dans `rdi` de sorte que `rdi == 1` si négatif, et `rdi == 0` si positif ou nul. (Indice : `shr rax, 63`).
- **Sortie attendue** : code de retour = 1.

### Exercice 15 — Défi Arithmétique : Multi-précision 128 bits ⭐⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex21_add128.asm`
- **Consigne** :
  Additionner deux nombres de 128 bits stockés chacun sur deux registres 64 bits (`rsi:rdi` et `rdx:rcx`).
  Utilise l'instruction `add` pour les 64 bits de poids faible, puis l'instruction **`adc`** (*Add with Carry*) pour propager la retenue sur les 64 bits de poids fort !

---

## 🎯 PROJET 2 (Style Epitech) — La Calculatrice Arithmétique (`my_calculator`)

```
================================================================================
                       ÉCOLE VIRTUELLE D'INGÉNIERIE SYSTÈME
                    Projet 2 : Calculatrice en Assembleur Pur
================================================================================
  Binaire attendu   : my_calculator
  Fichiers de rendu : Makefile, my_calculator.asm
  Langage           : Assembleur x86_64 (NASM)
  Fonctions autoris.: Syscalls Linux directs uniquement (write, exit)
================================================================================
```

### 1. Cahier des Charges & Sujet

Tu dois concevoir un moteur arithmétique capable d'effectuer les 5 opérations mathématiques fondamentales entre deux entiers positifs :
- Addition (`+`)
- Soustraction (`-`)
- Multiplication (`*`)
- Division entière (`/`)
- Reste / Modulo (`%`)

### 2. Spécifications Fonctionnelles
Le binaire traite deux opérandes entières $A$ et $B$ et un opérateur :

1. **Jalon 1 (Opérations Standard)** :
   - `$A + B$` $\rightarrow$ Affiche le résultat et quitte avec le code `0`.
   - `$A - B$` $\rightarrow$ Affiche le résultat et quitte avec le code `0`.
   - `$A \times B$` $\rightarrow$ Affiche le résultat et quitte avec le code `0`.
   - `$A / B$` $\rightarrow$ Affiche le quotient entier.
   - `$A \% B$` $\rightarrow$ Affiche le reste.

2. **Jalon 2 (Sécurité & Division par zéro)** :
   Si $B == 0$ lors d'une division (`/`) ou d'un modulo (`%`), le programme **ne doit surtout pas planter en Floating Point Exception** !
   Il doit intercepter l'erreur avant l'instruction `div`, afficher sur `stderr` (FD 2) :
   ```
   Error: Division by zero.
   ```
   et terminer immédiatement avec le code de sortie officiel **`84`**.

3. **Jalon 3 (Formatage de sortie)** :
   Le programme convertit le résultat numérique en chaîne de caractères ASCII (implémentation minimale d'`itoa`) pour l'afficher sur le terminal suivi d'un saut de ligne.

---

## 🧩 Mini-Quiz de fin de chapitre

1. Pourquoi faut-il impérativement mettre `rdx` à zéro avant d'appeler `div rbx` ?
2. Quelle instruction étend automatiquement le bit de signe de `rax` dans `rdx` avant un `idiv` ?
3. Quel drapeau de RFLAGS s'allume lors d'un dépassement de capacité sur une opération signée ?
4. Comment calculer $rax = rbx \times 9$ en une seule instruction sans modifier les drapeaux ?
5. Que se passe-t-il si un programme exécute `div rbx` alors que `rbx == 0` ?

<details>
<summary>Réponses du quiz</summary>

1. Parce que `div` divise le couple de 128 bits `RDX:RAX`. Si `rdx` contient des résidus, le nombre divisé sera astronomiquement faux ou déclenchera un dépassement de capacité (*Divide Error*).
2. L'instruction `cqo` (*Convert Quadword to Octoword*).
3. Le drapeau `OF` (*Overflow Flag*).
4. `lea rax, [rbx + rbx * 8]`.
5. Le processeur déclenche une exception matérielle d'interruption n°0 (#DE), le noyau Linux tue le processus avec le signal SIGFPE (*Floating point exception*).
</details>

---

> 🏅 **Badge débloqué : Calculateur** — Tu maîtrises la totalité de l'arithmétique du processeur x86_64 et le registre RFLAGS. Prépare-toi pour le **Chapitre 5 : Le Contrôle de Flux (CMP, Jumps et Boucles)** !
