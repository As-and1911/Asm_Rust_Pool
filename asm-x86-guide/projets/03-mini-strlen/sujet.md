# Sujet Officiel — Projet 3 : Les Fondations de la Minilibc (`strlen` & `strcmp`)

```
Projet            : mini-strlen & mini-strcmp (Minilibc Part 1)
Durée estimée     : 4 à 8 heures
Rendu             : Makefile, my_strlen.asm, my_strcmp.asm
Compilation       : nasm -f elf64 / gcc (test unitaire)
Conventions       : ABI System V AMD64 (Arguments dans RDI, RSI - Retour dans RAX)
```

## 1. Description du Projet

La **Minilibc** est le projet de référence d'Epitech pour maîtriser la programmation système en assembleur x86_64.
L'objectif de cette première étape est de reproduire le comportement strict des fonctions `strlen(3)` et `strcmp(3)` de la bibliothèque standard C (`<string.h>`).

Tes fonctions seront appelées directement depuis un programme de test en C et comparées point par point avec les vraies fonctions de la glibc.

---

## 2. Prototypes C Attendus

```c
#include <stddef.h>

size_t my_strlen(const char *s);
int    my_strcmp(const char *s1, const char *s2);
```

### Spécifications détaillées :

### `my_strlen`
- **Description** : Calcule la longueur de la chaîne pointée par `s`, sans compter l'octet nul final (`\0`).
- **Paramètre** : `rdi` = pointeur vers la chaîne `s`.
- **Valeur de retour** : `rax` = nombre d'octets de la chaîne.
- **Cas limites** : chaîne vide `""` $\rightarrow$ doit retourner `0`.

### `my_strcmp`
- **Description** : Compare les deux chaînes `s1` et `s2`.
- **Paramètres** : `rdi` = pointeur vers `s1`, `rsi` = pointeur vers `s2`.
- **Valeur de retour** : `rax` =
  - `0` si les deux chaînes sont identiques.
  - Entier négatif si `s1` est inférieure à `s2`.
  - Entier positif si `s1` est supérieure à `s2`.
- **Attention normative** : La comparaison s'effectue sur des `unsigned char`.

---

## 3. Makefile Attendu

- `all` : Compile la bibliothèque statique `libasm.a` et le binaire de test `test_minilibc`.
- `clean` : Nettoie les fichiers `.o`.
- `fclean` : Nettoie les `.o`, la bibliothèque et le binaire.
- `re` : Recompile tout.
