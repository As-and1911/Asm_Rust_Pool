# Chapitre 1 — Comment fonctionne un ordinateur (Fondations matérielles et numération)

## 🎯 Objectifs de ce chapitre

À la fin de ce chapitre, tu seras capable de :
- [ ] Visualiser précisément les interactions entre CPU, Bus, Mémoire RAM et Registres.
- [ ] Décortiquer le cycle interne d'une instruction (*Fetch, Decode, Execute*).
- [ ] Jongler instantanément entre Décimal, Binaire et Hexadécimal.
- [ ] Comprendre le format de représentation des entiers signés (**Complément à 2**) et détecter les débordements (*overflow*).
- [ ] Manipuler les unités de taille x86_64 : `byte`, `word`, `dword`, `qword`.
- [ ] Comprendre le stockage mémoire **Little-Endian** sans jamais te faire piéger.
- [ ] Maîtriser les opérations bit à bit (AND, OR, XOR, NOT, SHL, SHR, SAR) et les masques binaires.

## 📋 Prérequis
- Avoir complété le **Niveau 0** (environnement Docker opérationnel).
- Savoir éditer un fichier et lancer la moulinette.

## ⏱️ Durée estimée : 4–6 heures (Théorie + 15 Exercices pratiques)

---

## 1.1 — Anatomie d'un ordinateur : Ce qui se passe sous le capot

En programmation haut niveau (Python, JS, voire C), on manipule des abstractions : des variables, des objets, des fonctions. En assembleur, **ces abstractions n'existent pas**. 

Il n'y a que trois acteurs physiques majeurs reliés par des autoroutes électriques appelées des **bus** :

```
┌────────────────────────────────────────────────────────────────────────┐
│                        PROCESSEUR (CPU x86_64)                         │
│                                                                        │
│   ┌──────────────────────────────────────────────────────────────┐     │
│   │ REGISTRES (Mémoire ultra-rapide, ~0.5 cycle d'horloge)       │     │
│   │ [RAX] [RBX] [RCX] [RDX] [RSI] [RDI] [RBP] [RSP] [R8-R15]...  │     │
│   │ [RIP (Pointeur d'instruction)]   [RFLAGS (Drapeaux d'état)]  │     │
│   └──────────────────────────────┬───────────────────────────────┘     │
│                                  │                                     │
│   ┌──────────────────────────────┴───────────────────────────────┐     │
│   │ UNITÉ DE CONTRÔLE (CU)       │ ALU (Unité Arithmétique &     │     │
│   │ - Décode l'instruction       │      Logique)                 │     │
│   │ - Pilote le séquençage       │ - Effectue ADD, SUB, XOR...   │     │
│   └──────────────────────────────┴───────────────────────────────┘     │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │ BUS SYSTÈME (Données, Adresses, Contrôle)
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│                      MÉMOIRE CENTRALE (RAM)                            │
│  (Octets indexés par des adresses hexadécimales : 0x0000... à 0xFFFF...)│
│  Contient à la fois le CODE (.text) et les DONNÉES (.data, pile, tas)  │
└────────────────────────────────────────────────────────────────────────┘
```

### 1. Les Registres : Les tiroirs de l'artisan
Le CPU ne peut pas travailler directement sur les gigaoctets de ta RAM sans les charger d'abord. 
- Les **registres** sont des petites cases mémoires situées *directement* à l'intérieur de la puce silicium du processeur.
- Un registre x86_64 mesure **64 bits** (soit 8 octets).
- Leur accès est quasiment instantané (~1 nanoseconde).

### 2. L'ALU (Arithmetic Logic Unit) : La calculatrice
C'est le circuit électronique chargé d'effectuer les calculs mathématiques (`+`, `-`, `*`) et logiques (`ET`, `OU`, décalages de bits). L'ALU prend ses entrées dans les registres et y réécrit les résultats.

### 3. La RAM : Le grand hangar
La mémoire vive est une gigantesque grille linéaire de cases de **1 octet (8 bits)**, chacune possédant une adresse unique (comme un numéro de rue : `0x00400000`, `0x7ffd12a0`...).

---

## 1.2 — Le cycle fondamental : Fetch - Decode - Execute

Tant que ton ordinateur est allumé, le processeur exécute une seule boucle infinie, des milliards de fois par seconde (ta fréquence en GHz) :

```
       ┌────────────────────────┐
       │   1. FETCH (Chercher)  │ ──► Lit l'instruction pointée par RIP
       └───────────┬────────────┘     en RAM et avance RIP
                   │
                   ▼
       ┌────────────────────────┐
       │   2. DECODE (Traduire) │ ──► L'unité de contrôle analyse les opcodes
       └───────────┬────────────┘     (ex: 0x48 0x31 0xC0 = "xor rax, rax")
                   │
                   ▼
       ┌────────────────────────┐
       │  3. EXECUTE (Agir)     │ ──► L'ALU calcule ou le bus transfère
       └───────────┬────────────┘     Met à jour RFLAGS et registres
                   │
                   └────────────────── Boucle infinie
```

- **RIP (*Instruction Pointer*)** contient l'adresse mémoire de la prochaine instruction à exécuter.
- Si une instruction fait 3 octets, le CPU charge les 3 octets, augmente RIP de 3, puis exécute l'instruction.
- Un saut (*jump*) ou un appel de fonction (*call*) ne fait que modifier la valeur de RIP !

---

## 1.3 — Systèmes de numération : Parler la langue du silicium

Un fil électrique n'a que deux états physiques : tension haute (1) ou basse (0). C'est pourquoi tout en informatique est en **base 2 (binaire)**.

### Vocabulaire des tailles x86_64 (À graver dans ta mémoire)

| Terme x86 | Nom complet | Nombre de bits | Nombre d'octets | Plage non signée |
|-----------|-------------|----------------|-----------------|------------------|
| **Bit**   | Binary Digit| 1 bit          | 1/8             | 0 ou 1           |
| **Nibble**| Quartette   | 4 bits         | 1/2 octet       | 0 à 15 (1 chiffre hex) |
| **Byte**  | Octet       | 8 bits         | 1 octet         | 0 à 255          |
| **Word**  | Mot         | 16 bits        | 2 octets        | 0 à 65 535       |
| **Dword** | Double Word | 32 bits        | 4 octets        | 0 à 4 294 967 295 |
| **Qword** | Quad Word   | 64 bits        | 8 octets        | 0 à $2^{64}-1$ (~$1.84 \times 10^{19}$) |

> [!NOTE]
> En x86 historique (le 8086 des années 70), le processeur traitait 16 bits d'un coup : c'était le **Word**. Quand le 32 bits est arrivé, on l'a appelé **Double Word** (`dword`). En 64 bits, c'est devenu **Quad Word** (`qword`).

### Le pont Binaire ↔ Hexadécimal (La règle des paquets de 4)
L'hexadécimal (base 16) utilise 16 symboles : `0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A (10), B (11), C (12), D (13), E (14), F (15)`.

Puisque $2^4 = 16$, **exactement 4 bits binaires équivalent à 1 symbole hexadécimal**.

```
Binaire :   1 1 0 1   0 1 0 1   1 1 1 0   0 0 1 0
             │ │ │ │   │ │ │ │   │ │ │ │   │ │ │ │
Valeur  :      13         5        14         2
Hexa    :       D         5         E         2     ===> 0xD5E2
```

Table de conversion instantanée :
```
0000 = 0    0100 = 4    1000 = 8    1100 = C (12)
0001 = 1    0101 = 5    1001 = 9    1101 = D (13)
0010 = 2    0110 = 6    1010 = A    1110 = E (14)
0011 = 3    0111 = 7    1011 = B    1111 = F (15)
```

Un octet complet (8 bits) s'écrit donc avec **exactement 2 chiffres hexadécimaux** :
- `0xFF` = 255 (`1111 1111`)
- `0x00` = 0 (`0000 0000`)
- `0x7F` = 127 (`0111 1111`)

---

## 1.4 — Nombres signés et Complément à Deux

Comment stocker des nombres négatifs avec seulement des `0` et des `1` sans inventer un signe "-" magique ?
Les processeurs utilisent le **complément à deux**.

### La règle d'inversion :
Pour obtenir l'opposé d'un nombre ($-X$) sur $N$ bits :
1. Écrire la valeur absolue en binaire.
2. Inverser tous les bits (`0` devient `1`, `1` devient `0`).
3. Ajouter `1`.

#### Exemple sur 1 octet (8 bits) avec le nombre 5 :
```
+5 en binaire (8 bits)       : 0000 0101
1. Inverser tous les bits     : 1111 1010  (complément à un)
2. Ajouter 1                  : 1111 1011
-----------------------------------------
-5 en hexadécimal             : 0xFB
```

Vérifions par addition binaire que $(+5) + (-5) = 0$ :
```
    0000 0101  (+5)
  + 1111 1011  (-5)
  ───────────
  1 0000 0000  (Débordement jeté car limité à 8 bits => Reste 0000 0000 = 0 !)
```

### Le Bit de Poids Fort (MSB)
Sur un entier signé :
- Si le bit le plus à gauche vaut **`0`**, le nombre est **positif ou nul**.
- Si le bit le plus à gauche vaut **`1`**, le nombre est **négatif**.

Plages pour chaque taille :
- **Byte signé (8 bits)** : de $-128$ (`0x80`) à $+127$ (`0x7F`)
- **Word signé (16 bits)** : de $-32\,768$ (`0x8000`) à $+32\,767$ (`0x7FFF`)
- **Dword signé (32 bits)** : de $-2^{31}$ à $+2^{31}-1$ (environ $-2.14$ milliards à $+2.14$ milliards)
- **Qword signé (64 bits)** : de $-2^{63}$ à $+2^{63}-1$

---

## 1.5 — Endianness : Le grand casse-tête du Little-Endian

Quand une donnée prend plusieurs octets (comme un `qword` de 8 octets), dans quel ordre ses octets sont-ils écrits en RAM ?

L'architecture **x86_64 est STRICTEMENT Little-Endian** :
> **L'octet de poids faible (*Least Significant Byte*) est rangé à la plus petite adresse mémoire.**

Prenons le nombre 32 bits (`dword`) : `0x12345678`
- Octet de poids faible (LSB) : `0x78`
- Octet de poids fort (MSB) : `0x12`

Si on l'écrit à l'adresse mémoire `0x1000` :

```
Adresse mémoire :   0x1000    0x1001    0x1002    0x1003
Contenu en octet : [ 0x78 ]  [ 0x56 ]  [ 0x34 ]  [ 0x12 ]
                    ▲                              ▲
                    Octet de poids faible          Octet de poids fort
```

```
               Lecture humaine : 0x12345678
                       │   │   │   │
     Octet 3 (fort) ───┘   │   │   └─── Octet 0 (faible)
                           │   └─────── Octet 1
                           └─────────── Octet 2

     En mémoire x86_64 (adresses croissantes ->) :
     ┌──────────┬──────────┬──────────┬──────────┐
     │   0x78   │   0x56   │   0x34   │   0x12   │
     └──────────┴──────────┴──────────┴──────────┘
       Adresse    Adresse+1  Adresse+2  Adresse+3
```

> [!CAUTION]
> **Le piège classique de l'archéologue binaire :**
> Quand tu inspectes un binaire avec `xxd` ou `hexdump`, tu lis les octets dans l'ordre physique de la mémoire. Si tu vois les octets `ef be ad de`, c'est la constante `0xDEADBEEF` !
> **Dans les registres du CPU, tout est remis dans l'ordre naturel** : quand tu fais `mov eax, [0x1000]`, le registre `eax` contient `0x12345678`.

---

## 1.6 — Opérations bit à bit (Bitwise)

En assembleur, les opérations bit à bit sont des armes fondamentales pour calculer, tester, filtrer et optimiser.

```
 AND (&)           OR (|)            XOR (^)           NOT (~)
 0 AND 0 = 0      0 OR 0 = 0        0 XOR 0 = 0       NOT 0 = 1
 0 AND 1 = 0      0 OR 1 = 1        0 XOR 1 = 1       NOT 1 = 0
 1 AND 0 = 0      1 OR 0 = 1        1 XOR 0 = 1
 1 AND 1 = 1      1 OR 1 = 1        1 XOR 1 = 0
```

### 1. Masquage avec `AND` (Isoler des bits)
Exemple : vérifier si le 3ème bit est allumé :
```
  Valeur :   1 1 0 1  1 0 1 0
  Masque :   0 0 0 0  1 0 0 0  (0x08)
  ─────────────────────────────
  Résultat : 0 0 0 0  1 0 0 0  (Non nul => Le bit était à 1)
```

### 2. Forcer des bits à 1 avec `OR`
```
  Valeur :   1 1 0 1  0 0 1 0
  Masque :   0 0 0 0  0 1 0 1  (Active bits 0 et 2)
  ─────────────────────────────
  Résultat : 1 1 0 1  0 1 1 1
```

### 3. Inverser des bits / Remise à zéro avec `XOR`
- $A \oplus A = 0$ : N'importe quoi XOR lui-même vaut zéro. C'est l'idiome x86 par excellence :
  `xor eax, eax` remet le registre à zéro en seulement 2 octets d'instruction machine (plus rapide et plus compact que `mov eax, 0` qui prend 5 octets).

### 4. Décalages logiques et arithmétiques
- **`SHL` (Shift Left)** : Décale vers la gauche en insérant des 0. Équivaut à **multiplier par 2** par bit décalé.
  `0000 0011` (3) `SHL 1` = `0000 0110` (6).
- **`SHR` (Shift Right logique)** : Décale vers la droite en insérant des 0. Équivaut à une division non-signée par 2.
- **`SAR` (Shift Arithmetic Right)** : Décale vers la droite en **conservant le bit de signe**. Équivaut à une division entière signée par 2.
  `1111 1000` (-8) `SAR 1` = `1111 1100` (-4).

---

## 📝 Série d'exercices — Niveau 1 (15 exercices)

Ces exercices combinent calculs théoriques indispensables et petits programmes en assembleur à tester avec la moulinette.

### Exercice 1 — Conversions décimales vers binaire & hexadécimal ⭐
Donne l'équivalent binaire (sur 8 bits) et hexadécimal (sur 2 chiffres) des nombres décimaux suivants :
1. `42`
2. `100`
3. `255`
4. `17`

### Exercice 2 — Décodage de masque hexadécimal ⭐
Soit le registre `al = 0x3D`. 
1. Convertis-le en binaire 8 bits.
2. Si on applique l'opération `al AND 0x0F`, quelle est la valeur finale de `al` en hexadécimal ?
3. Que permet de faire un `AND 0x0F` de manière générale ?

### Exercice 3 — Le piège du complément à deux ⭐
Sur un octet (8 bits non signés vs signés) :
1. Quelle est la valeur décimale de `0xFF` s'il est considéré comme non-signé ?
2. Quelle est sa valeur décimale s'il est considéré comme signé ?
3. Convertis le nombre décimal négatif `-42` en hexadécimal sur 8 bits via la méthode du complément à 2.

### Exercice 4 — Simulation Little-Endian à la main ⭐⭐
On stocke le nombre 64 bits `0x0123456789ABCDEF` à l'adresse mémoire `0x4000`.
Remplis le tableau des 8 octets en mémoire :
- `0x4000` : `0x??`
- `0x4001` : `0x??`
- `0x4002` : `0x??`
- `0x4003` : `0x??`
- `0x4004` : `0x??`
- `0x4005` : `0x??`
- `0x4006` : `0x??`
- `0x4007` : `0x??`

### Exercice 5 — Trouver la taille des registres ⭐
Pour chacun des noms de registres suivants, indique sa taille en bits et son nom d'unité (`byte`, `word`, `dword`, `qword`) :
`rax`, `bx`, `cl`, `edx`, `r12`, `r13b`, `r14w`, `r15d`.

---

### Exercice 6 — Premier calcul binaire en asm : `ex06_bitwise_and.asm` ⭐
- **Fichier** : `exercices/niveau-1/ex06_bitwise_and.asm`
- **Objectif** : Initialiser `rdi` avec `0xF0`, faire un `AND` avec `0x3C`, et quitter avec le résultat comme code de retour (`exit(rdi)`).
- **Vérification attendue** : code de retour `$? == 48` (car `0xF0 & 0x3C = 0x30 = 48`).

### Exercice 7 — Décalage et multiplication : `ex07_shift_mul.asm` ⭐
- **Fichier** : `exercices/niveau-1/ex07_shift_mul.asm`
- **Consigne** : Place la valeur `5` dans `rdi`. Sans utiliser l'instruction de multiplication, utilise uniquement un décalage vers la gauche (`shl`) et des additions (`add`) pour multiplier ce nombre par 10. Quitte avec le résultat en code de sortie (`exit`).
- **Indice** : $X \times 10 = (X \times 8) + (X \times 2) = (X \ll 3) + (X \ll 1)$.
- **Code retour attendu** : `50`.

### Exercice 8 — Mettre à zéro sans `mov` : `ex08_zeroing.asm` ⭐
- **Fichier** : `exercices/niveau-1/ex08_zeroing.asm`
- **Consigne** : Écris un programme minimal qui met `rdi` à zéro en utilisant l'instruction `xor`, puis quitte avec `exit(rdi)`.
- **Code retour attendu** : `0`.

### Exercice 9 — L'astuce du swap sans variable temporaire ⭐⭐
- **Fichier** : `exercices/niveau-1/ex09_xor_swap.asm`
- **Consigne** :
  1. Mets la valeur `12` dans `rax`.
  2. Mets la valeur `30` dans `rbx`.
  3. Échange les valeurs de `rax` et `rbx` en utilisant **exclusivement 3 instructions `xor`** (aucun `mov`, aucun registre supplémentaire).
  4. Déplace `rax` dans `rdi` et quitte avec `exit`.
- **Code retour attendu** : `30`.

### Exercice 10 — Détection de parité avec un masque ⭐⭐
- **Fichier** : `exercices/niveau-1/ex10_parity.asm`
- **Consigne** :
  Un nombre entier est impair si et seulement si son bit de poids faible (bit 0) vaut 1.
  Mets le nombre `43` dans `rax`. Utilise `and` pour isoler son bit de parité dans `rdi` (qui vaudra donc 1 si impair, 0 si pair). Quitte avec `exit(rdi)`.
- **Code retour attendu** : `1`.

### Exercice 11 — Négation manuelle en asm ⭐⭐
- **Fichier** : `exercices/niveau-1/ex11_twos_complement.asm`
- **Consigne** :
  Prends la valeur `10` dans `rax`.
  Applique la formule du complément à deux à la main :
  1. Inverse tous les bits avec `not rax`.
  2. Ajoute 1 avec `inc rax` ou `add rax, 1`.
  3. Vérifie le résultat en utilisant l'instruction native `neg` sur un autre registre pour comparer.
  4. Quitte avec `exit`.

### Exercice 12 — Trouver le bug : Le débordement d'un octet ⭐⭐
Soit le code suivant :
```asm
section .text
    global _start
_start:
    mov al, 200
    add al, 100
    movzx rdi, al
    mov rax, 60
    syscall
```
1. Quel sera le code de retour affiché par `echo $?` ?
2. Pourquoi n'obtient-on pas 300 ?
3. Comment corriger le programme pour qu'il gère la valeur 300 ?

### Exercice 13 — Extraction d'octets Little-Endian ⭐⭐⭐
- **Fichier** : `exercices/niveau-1/ex13_extract_byte.asm`
- **Consigne** :
  Dans la section `.data`, déclare un entier 32 bits : `val dd 0x11223344`.
  Dans `.text`, charge uniquement le deuxième octet en partant de la droite (`0x33` en décimal = 51) dans le registre `dil` (partie 8 bits de `rdi`), puis appelle `exit`.
- **Code retour attendu** : `51`.

### Exercice 14 — Allumer et éteindre des permissions (Flags) ⭐⭐⭐
- **Fichier** : `exercices/niveau-1/ex14_permission_flags.asm`
- **Consigne** :
  Dans les systèmes Unix, les permissions d'un fichier sont codées sur des bits :
  - Bit 0 (`0x01`) = Exécution (X)
  - Bit 1 (`0x02`) = Écriture (W)
  - Bit 2 (`0x04`) = Lecture (R)
  1. Démarre avec un état `rdi = 0` (aucune permission).
  2. Active les permissions Lecture (R) et Exécution (X) via `or`.
  3. Désactive la permission Exécution en utilisant un masque inversé et `and`.
  4. Quitte avec `exit(rdi)`.
- **Code retour attendu** : `4` (Seule la lecture reste active).

### Exercice 15 — Le Défi : Nombre de bits à 1 (Hamming Weight) ⭐⭐⭐⭐
- **Fichier** : `exercices/niveau-1/ex15_popcount_manual.asm`
- **Consigne** :
  Sans boucle (puisqu'on n'a pas encore vu les sauts conditionnels), compte le nombre de bits à 1 dans l'octet `0b00101101` (`0x2D`, qui contient 4 bits à un).
  Additionne les résultats de chaque bit isolé et retourne la somme dans `rdi`.
- **Code retour attendu** : `4`.

---

## ⚠️ Pièges classiques du Niveau 1

1. **Confondre bits et octets** : Un `qword` fait 64 **bits**, soit 8 **octets** (diviser par 8).
2. **Penser en grand-boutien (Big-Endian)** : Écrire `0x1234` comme `0x12` puis `0x34` en mémoire. En x86, c'est `0x34` qui vient d'abord !
3. **Le piège du débordement d'un sous-registre** : Écrire dans `al` ne modifie que les 8 bits de poids faible de `rax`, mais écrire dans `eax` (32 bits) met **automatiquement à zéro** les 32 bits de poids fort de `rax` !
4. **La confusion `SHR` vs `SAR`** : Pour diviser un nombre négatif par 2, `shr` donnera un nombre gigantesque positif car il insère un 0 en bit de signe. Il faut impérativement utiliser `sar`.

---

## 🧩 Mini-Quiz de validation

1. Combien d'octets contient un `dword` ?
2. Quelle est la valeur binaire du chiffre hexadécimal `B` ?
3. Quelle instruction assembleur remet un registre à 0 de façon idiomatique ?
4. Si l'adresse `0x2000` contient l'octet `0xEF` et `0x2001` contient `0xBE`, quelle est la valeur du mot 16 bits lu à l'adresse `0x2000` ?
5. Quelle opération logique permet de tester si un bit précis est à 1 ?

<details>
<summary>Réponses du quiz</summary>

1. 4 octets (32 bits).
2. `1011` (B = 11 en décimal).
3. `xor reg, reg` (ex: `xor eax, eax`).
4. `0xBEEF` (Little-endian : octet faible à la petite adresse).
5. L'opération `AND` (ou l'instruction `test` qu'on verra au chapitre 5).
</details>

---

> 🏅 **Badge à débloquer : Numérologue** — Réussis la moulinette du Niveau 1 pour prouver que les bits, l'hexadécimal et l'architecture du CPU n'ont plus de secret pour toi !
