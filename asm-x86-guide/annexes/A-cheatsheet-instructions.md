# Aide-Mémoire — Instructions Essentielles x86_64

## 1. Transfert de Données
- `mov dest, src` : Copie `src` vers `dest` (registre, mémoire, immédiat).
- `movzx dest, src` : Copie avec extension par zéro (non signé).
- `movsx dest, src` : Copie avec extension de signe (signé).
- `lea dest, [adresse]` : Calcule l'adresse sans aucun accès mémoire (arithmétique rapide).
- `xchg reg1, reg2` : Échange les valeurs de deux opérandes.
- `bswap reg` : Inverse l'ordre des octets (*Endianness swap*).

## 2. Arithmétique
- `add dest, src` : $\text{dest} = \text{dest} + \text{src}$
- `sub dest, src` : $\text{dest} = \text{dest} - \text{src}$
- `inc dest` / `dec dest` : Incrémente / décrémente de 1 (sans toucher à CF !).
- `neg dest` : Négation (complément à 2 : $\text{dest} = -\text{dest}$).
- `mul src` : Multiplication non signée $\rightarrow$ `RDX:RAX = RAX * src`.
- `imul dest, src` : Multiplication signée sur 64 bits.
- `div src` : Division non signée de `RDX:RAX / src` $\rightarrow$ quotient dans `RAX`, reste dans `RDX`.
- `idiv src` : Division signée (précédée de `cqo` pour étendre le signe).
- `cqo` : Étend le signe de `RAX` sur tout `RDX` (64 bits $\rightarrow$ 128 bits).

## 3. Logique & Décalages
- `and dest, src` : ET bit à bit.
- `or dest, src` : OU inclusif bit à bit.
- `xor dest, src` : OU exclusif bit à bit (`xor eax, eax` remet à zéro).
- `not dest` : Inverse tous les bits (complément à 1).
- `shl dest, count` : Décalage logique vers la gauche ($\times 2^{\text{count}}$).
- `shr dest, count` : Décalage logique vers la droite (non signé).
- `sar dest, count` : Décalage arithmétique vers la droite (conserve le bit de signe).
- `rol dest, count` / `ror dest, count` : Rotations de bits vers la gauche / droite.

## 4. Comparaisons & Sauts
- `cmp op1, op2` : Soustraction virtuelle (`op1 - op2`), met à jour RFLAGS.
- `test op1, op2` : AND logique virtuel (`op1 & op2`), teste nullité et signe.
- `jmp label` : Saut inconditionnel.
- `je` / `jz` : Saut si égal / si résultat nul (`ZF == 1`).
- `jne` / `jnz` : Saut si différent / non nul (`ZF == 0`).
- **Sauts signés** :
  - `jg` ($>$) / `jge` ($\ge$) / `jl` ($<$) / `jle` ($\le$)
- **Sauts non signés (adresses/tailles)** :
  - `ja` ($>$) / `jae` ($\ge$) / `jb` ($<$) / `jbe` ($\le$)
- `cmovcc dest, src` : Déplacement conditionnel sans saut.
- `setcc dest_8b` : Met à 1 si la condition est vraie, 0 sinon.

## 5. Pile & Fonctions
- `push src` : Décrémente `RSP` de 8 et empile.
- `pop dest` : Dépile dans `dest` et incrémente `RSP` de 8.
- `call label` : Empile `RIP` de retour et saute.
- `ret` : Dépile `RIP` et reprend l'exécution.
- `leave` : Équivaut à `mov rsp, rbp` puis `pop rbp`.

## 6. Chaînes Matérielles (avec RSI et RDI)
- `cld` / `std` : Incrémente (`cld`) ou décrémente (`std`) les pointeurs.
- `rep movsb` : Copie `RCX` octets de `[RSI]` vers `[RDI]` (`memcpy`).
- `rep stosb` : Remplit `RCX` octets de `[RDI]` avec `AL` (`memset`).
- `repne scasb` : Scanne `[RDI]` jusqu'à trouver l'octet `AL` (`strlen`).
