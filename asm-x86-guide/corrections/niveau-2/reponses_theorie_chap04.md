# Corrigé des Exercices Théoriques — Chapitre 4

## Exercice 1 — Prédire les drapeaux RFLAGS
Après initialisation avec `al = 0` :

1. `add al, 10` :
   - Résultat = `10`
   - `ZF = 0` (non nul)
   - `SF = 0` (positif)
   - `CF = 0` (pas de retenue)

2. `sub al, 10` (à partir de 0) :
   - Résultat = `-10` (`0xF6` sur 8 bits)
   - `ZF = 0`
   - `SF = 1` (bit 7 = 1, négatif)
   - `CF = 1` (emprunt / retenue car $0 < 10$ en non-signé !)

3. `xor al, al` :
   - Résultat = `0`
   - `ZF = 1` (vaut zéro)
   - `SF = 0`
   - `CF = 0` (les opérations logiques XOR, AND, OR mettent toujours CF et OF à zéro)

4. `sub al, 1` (avec al = 0) :
   - Résultat = `0xFF` (255 non signé, -1 signé)
   - `ZF = 0`
   - `SF = 1`
   - `CF = 1`

---

## Exercice 7 — Détection d'Overflow Signé (OF)
Code :
```asm
mov al, 100
add al, 50
```
- Explication : `al` est un registre 8 bits signé dont la plage va de $-128$ à $+127$.
- $100 + 50 = 150$.
- $150$ dépasse $+127$. En hexadécimal, $150 = \text{0x96} = \text{0b10010110}$.
- En interprétation signée, le bit de poids fort vaut `1`, donc `0x96` représente le nombre négatif $-106$ !
- L'addition de deux nombres positifs ($+100$ et $+50$) a donné un nombre négatif ($-106$). C'est une aberration mathématique due au dépassement de capacité signé. Le processeur allume donc immédiatement **`OF = 1`** (*Overflow Flag*).
