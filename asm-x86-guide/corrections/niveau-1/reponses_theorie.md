# Corrigé détaillé des exercices théoriques — Niveau 1

## Exercice 1 — Conversions décimales
1. **42** :
   - Binaire : `0010 1010` (32 + 8 + 2)
   - Hexa : `0x2A` (`0010` = 2, `1010` = A)
2. **100** :
   - Binaire : `0110 0100` (64 + 32 + 4)
   - Hexa : `0x64` (`0110` = 6, `0100` = 4)
3. **255** :
   - Binaire : `1111 1111`
   - Hexa : `0xFF`
4. **17** :
   - Binaire : `0001 0001` (16 + 1)
   - Hexa : `0x11`

---

## Exercice 2 — Décodage de masque hexadécimal
Soit `al = 0x3D` :
1. En binaire 8 bits : `0011 1101`.
2. Opération `al AND 0x0F` :
   ```
     0011 1101  (0x3D)
   & 0000 1111  (0x0F)
   ───────────
     0000 1101  = 0x0D (13 en décimal)
   ```
3. `AND 0x0F` isole le **quartette de poids faible** (les 4 bits les moins significatifs) et met à zéro le quartette supérieur. C'est un masque classique d'isolation de nibble.

---

## Exercice 3 — Le piège du complément à deux
1. Non signé : `0xFF` = $255$.
2. Signé : Le bit de poids fort est 1, c'est donc un négatif. Complément à 2 inverse :
   `1111 1111` -> `0000 0000` + 1 = `0000 0001` (1).
   Donc `0xFF` = **-1**.
3. Convertir `-42` sur 8 bits :
   - $+42$ en binaire : `0010 1010`
   - Inversion (NOT) : `1101 0101`
   - Ajouter 1 : `1101 0110`
   - En hexadécimal : `1101` = D, `0110` = 6 => **`0xD6`**.

---

## Exercice 4 — Simulation Little-Endian à la main
Valeur : `0x0123456789ABCDEF` stockée à partir de `0x4000` :
- `0x4000` : `0xEF` (Octet le plus faible)
- `0x4001` : `0xCD`
- `0x4002` : `0xAB`
- `0x4003` : `0x89`
- `0x4004` : `0x67`
- `0x4005` : `0x45`
- `0x4006` : `0x23`
- `0x4007` : `0x01` (Octet le plus fort)

---

## Exercice 5 — Tailles et noms des registres
- `rax` : 64 bits, **qword**
- `bx` : 16 bits, **word**
- `cl` : 8 bits, **byte**
- `edx` : 32 bits, **dword**
- `r12` : 64 bits, **qword**
- `r13b` : 8 bits, **byte** (le 'b' indique byte)
- `r14w` : 16 bits, **word** (le 'w' indique word)
- `r15d` : 32 bits, **dword** (le 'd' indique double word)

---

## Exercice 12 — Trouver le bug : Le débordement d'un octet
1. Code de retour affiché : **`44`**.
2. Explication : Le registre `al` fait 8 bits. La plage maximale d'un octet non signé est de 0 à 255.
   $200 + 100 = 300$.
   En binaire, $300 = 256 + 44 = \text{0x012C}$.
   Sur 8 bits, seul l'octet inférieur `0x2C` (soit 44) est conservé dans `al`. Le 1 de poids fort part dans le drapeau Carry Flag (CF).
3. Correction : Utiliser un registre de 16 bits (`ax`) ou 32 bits (`eax`) :
   ```asm
   mov ax, 200
   add ax, 100
   movzx rdi, ax
   mov rax, 60
   syscall
   ```
