# Chapitre 3 — Premiers Pas en Assembleur x86_64 : Syntaxe, Registres et Instructions de Base

## 🎯 Objectifs de ce chapitre

À la fin de ce chapitre, tu seras capable de :
- [ ] Lire et traduire instinctivement entre syntaxe **Intel (NASM)** et syntaxe **AT&T** (utilisée par gdb et objdump par défaut).
- [ ] Découper mentalement n'importe quel registre 64 bits en ses composantes 32, 16 et 8 bits (`rax`, `eax`, `ax`, `al`, `ah`).
- [ ] Connaître par cœur les 16 registres généraux et leurs rôles traditionnels dans l'ABI System V.
- [ ] Maîtriser l'instruction de transfert `mov` et ses règles strictes (ce qui est légal et illégal au niveau processeur).
- [ ] Utiliser `movzx` (*Zero-Extend*) et `movsx` (*Sign-Extend*) pour convertir des données de petite taille sans écraser ni corrompre le signe.
- [ ] Respecter la norme de style et de lisibilité assembleur d'Epitech.
- [ ] Réussir ton premier projet officiel : **Projet 1 — Hello World et ses Variantes**.

## 📋 Prérequis
- Avoir complété le Niveau 0 et le Niveau 1 (tailles `byte/word/dword/qword`, Little-Endian, ELF).

## ⏱️ Durée estimée : 5–7 heures (Théorie + 12 Exercices + Projet 1)

---

## 3.1 — La Guerre des Syntaxes : Intel vs AT&T

Dans le monde x86, il existe deux manières d'écrire la même instruction machine :

| Caractéristique | Syntaxe Intel (NASM, MASM) | Syntaxe AT&T (GCC, GAS, objdump par défaut) |
|---|---|---|
| **Ordre des opérandes** | `INSTRUCTION destination, source` | `INSTRUCTION source, destination` |
| **Préfixe des registres** | Aucun (`rax`, `ebx`) | `%` (`%rax`, `%ebx`) |
| **Constantes (immédiats)** | `42`, `0x2A` | `$` (`$42`, `$0x2A`) |
| **Suffixe de taille** | Mots-clés (`byte`, `dword ptr`) | Lettres suffixes (`b`, `w`, `l`, `q`) |
| **Déréférencement mémoire** | `[rax]` ou `[rax + 8]` | `(%rax)` ou `8(%rax)` |

### Comparatif direct côte à côte :

```asm
; --- Syntaxe Intel (Ce que nous écrivons avec NASM) ---
mov     rax, 42             ; Mettre 42 dans rax (destination = rax, source = 42)
mov     rbx, rcx            ; Copier rcx vers rbx
mov     eax, [rdi]          ; Charger un dword depuis l'adresse pointée par rdi
mov     byte [rsi + 4], 0   ; Écrire 0 (1 octet) à l'adresse rsi + 4

# --- Syntaxe AT&T (Ce que tu verras souvent dans gdb ou des vieux manuels) ---
movq    $42, %rax           # Mettre 42 dans rax (source = 42, destination = rax)
movq    %rcx, %rbx          # Copier rcx vers rbx
movl    (%rdi), %eax        # Charger un dword (l = long)
movb    $0, 4(%rsi)         # Écrire 0 (b = byte) à l'adresse rsi + 4
```

> [!IMPORTANT]
> **Pourquoi choisir Intel ?**
> La syntaxe Intel se lit naturellement comme une affectation en programmation moderne :
> `mov destination, source` $\equiv$ `destination = source;`.
> C'est la syntaxe officielle documentée par Intel et AMD, et celle utilisée par NASM.
> Pour forcer `objdump` et `gdb` à parler en syntaxe Intel, nous avons déjà configuré les options `-M intel` dans ton environnement Docker.

---

## 3.2 — Anatomie Complète des Registres x86_64

Le processeur x86_64 dispose de **16 registres généraux** de 64 bits chacun. 

Pour maintenir la rétrocompatibilité avec les processeurs 32 bits (80386), 16 bits (8086) et 8 bits (8080), **chaque registre 64 bits peut être adressé sous forme de sous-registres** !

### 1. Les 8 registres historiques et leur découpage

Prenons le registre accumulateur `RAX` (64 bits) :

```
┌────────────────────────────────────────────────────────────────────────┐
│                              RAX (64 bits)                             │
├───────────────────────────────────┬────────────────────────────────────┤
│   Partie haute (bits 63 à 32)     │            EAX (32 bits)           │
│   (Non adressable directement)    ├─────────────────┬──────────────────┤
│                                   │ (bits 31 à 16)  │    AX (16 bits)  │
│                                   │                 ├────────┬─────────┤
│                                   │                 │AH (8b) │ AL (8b) │
└───────────────────────────────────┴─────────────────┴────────┴─────────┘
Bits: 63                          32 31             16 15      8 7       0
```

- **`RAX`** : Le registre entier (64 bits / 8 octets)
- **`EAX`** : Les 32 bits de poids faible (*Extended AX*)
- **`AX`**  : Les 16 bits de poids faible
- **`AL`**  : L'octet de poids faible (*AX Low*, bits 0 à 7)
- **`AH`**  : L'octet suivant (*AX High*, bits 8 à 15 — disponible uniquement sur RAX, RBX, RCX, RDX)

### Tableau complet des 16 Registres Généraux :

| Registre 64b | Sous-reg 32b | Sous-reg 16b | Sous-reg 8b (Low) | Rôle traditionnel dans l'ABI System V |
|---|---|---|---|---|
| **`RAX`** | `EAX` | `AX` | `AL` (et `AH`) | Accumulateur / Valeur de retour des fonctions / N° de syscall |
| **`RBX`** | `EBX` | `BX` | `BL` (et `BH`) | Base / Registre préservé (*callee-saved*) |
| **`RCX`** | `ECX` | `CX` | `CL` (et `CH`) | Compteur pour boucles et shifts / 4ème argument fonction |
| **`RDX`** | `EDX` | `DX` | `DL` (et `DH`) | Données pour mul/div / 3ème argument / Longueur d'I/O |
| **`RSI`** | `ESI` | `SI` | `SIL` | *Source Index* pour chaînes / 2ème argument fonction |
| **`RDI`** | `EDI` | `DI` | `DIL` | *Destination Index* pour chaînes / 1er argument fonction |
| **`RBP`** | `EBP` | `BP` | `BPL` | *Base Pointer* (Pointeur de cadre de pile / Stack Frame) |
| **`RSP`** | `ESP` | `SP` | `SPL` | *Stack Pointer* (Pointeur du sommet de la pile) |
| **`R8`**  | `R8D` | `R8W` | `R8B` | 5ème argument fonction |
| **`R9`**  | `R9D` | `R9W` | `R9B` | 6ème argument fonction |
| **`R10`** | `R10D`| `R10W`| `R10B`| Utilisé par le noyau pour les syscalls |
| **`R11`** | `R11D`| `R11W`| `R11B`| Registre temporaire / scratch |
| **`R12`** | `R12D`| `R12W`| `R12B`| Préservé (*callee-saved*) |
| **`R13`** | `R13D`| `R13W`| `R13B`| Préservé (*callee-saved*) |
| **`R14`** | `R14D`| `R14W`| `R14B`| Préservé (*callee-saved*) |
| **`R15`** | `R15D`| `R15W`| `R15B`| Préservé (*callee-saved*) |

> [!CAUTION]
> **RÈGLE CRITIQUE DU 32 BITS VERS 64 BITS (Zero-Extension automatique) :**
> - Si tu écris dans un sous-registre 8 bits ou 16 bits (ex: `mov al, 0xFF` ou `mov ax, 0xFFFF`), **le reste du registre RAX est INCHANGÉ**.
> - En revanche, si tu écris dans un sous-registre 32 bits (ex: `mov eax, 42`), **le processeur met AUTOMATIQUEMENT à zéro les 32 bits de poids fort de RAX** !
> Cette règle matérielle a été conçue pour accélérer l'exécution et éliminer les fausses dépendances de registres. Retiens-la bien !

---

## 3.3 — L'Instruction `MOV` : Règles et Subtilités

`mov destination, source` copie une valeur depuis `source` vers `destination`.

### Ce qui est LÉGAL :
```asm
mov rax, rbx            ; Registre vers Registre
mov rax, 42             ; Immédiat vers Registre
mov [rdi], rax          ; Registre vers Mémoire
mov rax, [rdi]          ; Mémoire vers Registre
mov dword [rdi], 100    ; Immédiat vers Mémoire (taille explicite obligatoire !)
```

### Ce qui est STRICTEMENT ILLÉGAL en x86_64 :

1. **Mémoire vers Mémoire INTERDIT** :
   ```asm
   mov [rsi], [rdi]     ; ❌ ERREUR ! Le CPU ne peut pas lire ET écrire en RAM en 1 instruction
   ```
   *Correction* : Passer par un registre intermédiaire :
   ```asm
   mov rax, [rdi]       ; ✅ 1. Charger en registre
   mov [rsi], rax       ; ✅ 2. Écrire en mémoire
   ```

2. **Mélange de tailles différentes INTERDIT** :
   ```asm
   mov rax, ecx         ; ❌ ERREUR ! 64 bits vs 32 bits
   mov al, bx           ; ❌ ERREUR ! 8 bits vs 16 bits
   ```

3. **Immédiat vers Mémoire sans spécifier la taille INTERDIT** :
   ```asm
   mov [rdi], 1         ; ❌ ERREUR ! NASM ne sait pas si c'est 1 byte, 1 word ou 1 qword !
   ```
   *Correction* : Utiliser un spécificateur de taille :
   ```asm
   mov byte [rdi], 1    ; ✅ Écrit 1 octet (0x01)
   mov dword [rdi], 1   ; ✅ Écrit 4 octets (0x00000001)
   mov qword [rdi], 1   ; ✅ Écrit 8 octets
   ```

4. **Modifier RIP directement INTERDIT** :
   `mov rip, 0x401000` est illégal. On modifie `RIP` via les instructions de saut (`jmp`, `call`, `ret`).

---

## 3.4 — Extension de Taille : `MOVZX` et `MOVSX`

Que faire quand tu veux transférer une valeur d'un petit registre (ex: un `byte` dans `al`) vers un grand registre (ex: un `qword` dans `rdi`) ?

### 1. `MOVZX` : Move with Zero-Extension (Non signé)
Remplit tous les bits supérieurs avec des **zéros**.

```asm
mov     al, 0x5A        ; al = 0101 1010b
movzx   rdi, al         ; rdi = 0x000000000000005A (valeur propre)
```

### 2. `MOVSX` : Move with Sign-Extension (Signé)
Recopie le **bit de signe** (le bit de poids fort) sur tous les bits supérieurs pour préserver la valeur mathématique négative !

```asm
mov     al, -5          ; al = 0xFB (en binaire : 1111 1011b, bit de signe = 1)
movsx   rdi, al         ; rdi = 0xFFFFFFFFFFFFFFFB (toujours -5 en 64 bits !)
; Si on avait fait movzx, rdi vaudrait 251 au lieu de -5 !
```

---

## 3.5 — Norme de Code Assembleur (Style Epitech)

À Epitech, le code n'est pas seulement fait pour marcher : il doit être **irréprochable de lisibilité**. En assembleur, où tout peut vite devenir un fouillis illisible, cette discipline est vitale.

### Les 6 Commandements du Style Epitech :

1. **En-tête de fichier standardisé** :
   ```asm
   ; =============================================================================
   ; Projet  : Minilibc
   ; Fichier : strlen.asm
   ; Auteur  : Login Epitech <prenom.nom@epitech.eu>
   ; =============================================================================
   ```

2. **Colonnes strictes et alignées (Tabulations de 8 ou 4 espaces)** :
   ```asm
   ; Label en colonne 0
   my_function:
       ; Instructions indentées
       mov     rax, rdi            ; Opérandes alignées proprement
       xor     rcx, rcx            ; Commentaires alignés à droite
   ```

3. **Une seule instruction par ligne**.

4. **Nommage explicite des labels** :
   - Fonction publique : `my_strlen:`, `print_error:`
   - Label local : `.loop:`, `.done:`, `.error:` (le point `.` rend le label local au symbole parent dans NASM).

5. **Commenter l'intention, pas la syntaxe** :
   - ❌ `add rax, 1      ; ajoute 1 à rax` (Commentaire inutile)
   - ✅ `inc rax         ; passe au caractère suivant dans la chaîne`

6. **Toujours documenter les registres d'entrée et de sortie d'une routine** :
   ```asm
   ; -----------------------------------------------------------------------------
   ; print_char — Affiche un caractère sur la sortie standard
   ; Entrée  : dil = caractère ASCII à afficher
   ; Sortie  : rax = nombre d'octets écrits (ou négatif si erreur)
   ; Détruit : rax, rdi, rsi, rdx
   ; -----------------------------------------------------------------------------
   ```

---

## 📝 12 Exercices Pratiques — Niveau 2 (Série Chapitre 3)

### Exercice 1 — Traduction Intel ↔ AT&T ⭐
Traduire les 4 instructions Intel suivantes en syntaxe AT&T :
1. `mov rax, 100`
2. `mov dword [rdi + 8], ebx`
3. `add rsi, [rcx]`
4. `xor edx, edx`

### Exercice 2 — Prédire l'état du registre RAX ⭐
Après l'exécution séquentielle de ces instructions, quelle est la valeur hexadécimale exacte de `rax` (sur 64 bits) ?
```asm
mov rax, 0x1122334455667788
mov al, 0xAA
mov ax, 0xBBCC
mov eax, 0x12345678
```

### Exercice 3 — Afficher un caractère unique : `ex01_putchar.asm` ⭐
- **Fichier** : `exercices/niveau-2/ex01_putchar.asm`
- **Consigne** :
  Sans définir de section `.data`, alloue 1 octet sur la pile ou stocke le caractère `'Z'` (`0x5A`) directement, et utilise le syscall `sys_write` (1) pour afficher la lettre `'Z'` sur stdout, suivi d'un `sys_exit(0)`.
- **Indice** : Tu peux pousser le caractère sur la pile avec `push 'Z'` ou utiliser un tampon mémoire en `.bss`.
- **Sortie attendue** : `Z`

### Exercice 4 — Prédire le comportement de `movzx` vs `movsx` ⭐⭐
Soit la valeur `0xFE` (-2 en signé, 254 en non signé).
Écris les valeurs 64 bits de `rax` après :
1. `mov al, 0xFE` suivi de `movzx rax, al`
2. `mov al, 0xFE` suivi de `movsx rax, al`

### Exercice 5 — Afficher le message d'erreur sur stderr : `ex02_putstr_err.asm` ⭐
- **Fichier** : `exercices/niveau-2/ex02_putstr_err.asm`
- **Consigne** :
  Déclare en `.data` la chaîne `"Erreur: fichier introuvable.\n"`.
  Affiche ce message **sur la sortie d'erreur standard (File Descriptor 2 = stderr)**, puis termine avec le code d'erreur `1`.
- **Test** : `./ex02_putstr_err 2> err.log && cat err.log` doit contenir le message.

### Exercice 6 — L'opération LEA vs MOV ⭐⭐
Explique la différence fondamentale entre :
```asm
mov rax, [rbx + 8]
```
et
```asm
lea rax, [rbx + 8]
```
Si `rbx = 0x1000` et que l'adresse `0x1008` contient la valeur `42`, quelles sont les valeurs de `rax` dans les deux cas ?

### Exercice 7 — Concaténation de registres : `ex03_reg_pack.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex03_reg_pack.asm`
- **Consigne** :
  On dispose de deux entiers 8 bits : `a = 0x12` et `b = 0x34`.
  Combine ces deux octets dans le registre 16 bits `ax` pour que `ax == 0x1234`.
  Quitte en retournant `al` (qui doit donc valoir `0x34` = 52 en décimal).
- **Sortie attendue** : code de retour = 52.

### Exercice 8 — Trouver le bug de compilation : `ex04_bad_mov.asm` ⭐⭐
Trouve les 4 erreurs dans le snippet suivant :
```asm
section .text
    global _start
_start:
    mov [var1], [var2]
    mov rax, ecx
    mov [rsp], 42
    mov rip, _start
```

### Exercice 9 — Afficher un compte à rebours statique : `ex05_countdown_static.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex05_countdown_static.asm`
- **Consigne** :
  Déclare les caractères `'3'`, `'2'`, `'1'`, `'0'`, `'\n'` dans une seule chaîne en `.data`.
  En utilisant **un seul syscall `write`**, affiche les chiffres séparés par des espaces : `"3 2 1 0\n"`. Quitte avec le code 0.

### Exercice 10 — Déplacement avec extension signée : `ex06_sign_extension.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex06_sign_extension.asm`
- **Consigne** :
  Place le nombre négatif `-15` (sur 8 bits) dans `al`.
  Utilise `movsx` pour étendre ce nombre dans `rdi` (64 bits).
  Appelle le syscall 60 (`exit`).
- **Sortie attendue** : Code de retour = 241 (car $-15 \pmod{256} = 241$).

### Exercice 11 — Calcul de longueur statique avec NASM : `ex07_str_len_equ.asm` ⭐⭐
- **Fichier** : `exercices/niveau-2/ex07_str_len_equ.asm`
- **Consigne** :
  Déclare une phrase arbitraire longue en `.data`. Utilise la directive `equ $ - label` pour calculer sa longueur. Affiche la chaîne via `sys_write` puis termine en retournant la longueur calculée de la chaîne comme code de sortie du programme (`exit`).

### Exercice 12 — Afficher son premier caractère dynamique calculé ⭐⭐⭐
- **Fichier** : `exercices/niveau-2/ex08_dynamic_char.asm`
- **Consigne** :
  En partant du caractère `'A'` (`0x41`), ajoute mathématiquement la valeur `3` dans un registre pour obtenir le caractère `'D'`, puis affiche ce caractère suivi d'un retour à la ligne sur stdout.
- **Sortie attendue** : `D\n`

---

## 🎯 PROJET 1 (Style Epitech) — Hello World et ses Variantes

```
================================================================================
                       ÉCOLE VIRTUELLE D'INGÉNIERIE SYSTÈME
                    Projet 1 : Hello World & Output Dispatcher
================================================================================
  Binaire attendu   : my_hello
  Fichiers de rendu : Makefile, my_hello.asm, include/hello.inc (si besoin)
  Langage           : Assembleur x86_64 (NASM)
  Fonctions autoris.: Syscalls Linux directs uniquement (write, exit)
  Liaison           : Statique (ld), AUCUNE LIBC AUTORISÉE
================================================================================
```

### 1. Cahier des Charges & Sujet

Tu dois réaliser un exécutable nommé **`my_hello`** qui gère différents modes d'affichage selon un argument de compilation ou une séquence d'instructions précise :

1. **Jalon 1 (Standard)** : Le programme sans argument doit afficher sur la sortie standard (stdout) :
   ```
   Hello, World!
   ```
   suivi d'un retour à la ligne, et retourner `0`.

2. **Jalon 2 (Erreur)** : Si une constante `ERROR_MODE` est définie, le programme doit afficher sur le canal stderr (FD 2) :
   ```
   [ERROR] Operation failed successfully.
   ```
   et quitter avec le code de sortie `84` (Le code d'erreur officiel d'Epitech !).

3. **Jalon 3 (Ascii Banner)** : Le programme doit être capable d'afficher une bannière ASCII d'au moins 4 lignes sans segfault.

### 2. Contraintes Techniques
- Binaire compilé via `nasm -f elf64` et linké via `ld`.
- Makefile obligatoire contenant au minimum les règles : `all`, `clean`, `fclean`, `re`.
- Interdiction stricte d'inclure des bibliothèques externes (`-lc`, `printf`, etc.).
- Le code doit respecter scrupuleusement la norme de style (en-têtes, alignement, labels clairs).

### 3. Barème de Notation (/100 points)
- **Compilation propre sans avertissement** : 10 pts
- **Présence du Makefile conforme** : 10 pts
- **Jalon 1 (Sortie stdout correcte + return 0)** : 40 pts
- **Jalon 2 (Sortie stderr correcte + return 84)** : 20 pts
- **Jalon 3 (Bannière multi-lignes)** : 10 pts
- **Norme et propreté du code** : 10 pts

---

## 🧩 Mini-Quiz de fin de chapitre

1. En syntaxe AT&T, quel est l'ordre des opérandes pour une affectation ?
2. Quelle est la particularité matérielle lorsqu'on écrit dans un registre 32 bits comme `eax` sur x86_64 ?
3. Pourquoi l'instruction `mov [rsi], [rdi]` est-elle rejetée par l'assembleur ?
4. Quelle instruction utiliser pour copier un entier 8 bits négatif dans un registre 64 bits sans corrompre son signe ?
5. Quel est le numéro de descripteur de fichier pour la sortie d'erreur (`stderr`) ?

<details>
<summary>Réponses du quiz</summary>

1. `source, destination` (l'inverse d'Intel !).
2. Les 32 bits de poids fort de `rax` sont automatiquement remis à zéro (*Zero-extended*).
3. L'architecture x86_64 interdit les transferts mémoire à mémoire en une seule instruction.
4. L'instruction `movsx` (*Move with Sign Extension*).
5. Le descripteur `2` (`0 = stdin`, `1 = stdout`, `2 = stderr`).
</details>

---

> 🏅 **Badge débloqué : Assembleur débutant** — Tu maîtrises les registres, les syntaxes et les instructions de base. Valide le Projet 1 pour passer aux calculs arithmétiques avancés du Chapitre 4 !
