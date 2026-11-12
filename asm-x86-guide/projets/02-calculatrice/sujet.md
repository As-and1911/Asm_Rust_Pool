# Sujet Officiel — Projet 2 : Calculatrice Arithmétique (`my_calculator`)

```
Projet            : my_calculator
Durée estimée     : 4 à 8 heures
Rendu             : Makefile, my_calculator.asm
Compilation       : nasm -f elf64 / ld
Langage           : Assembleur x86_64 pur
Code d'erreur     : 84 (Norme Epitech)
```

## 1. Description du Projet

L'objectif de ce projet est de concevoir un moteur de calcul arithmétique capable d'effectuer des opérations mathématiques entières (`+`, `-`, `*`, `/`, `%`) en assembleur x86_64 pur, sans aucune dépendance à la libc (`printf`, etc.).

Le programme doit également intégrer un convertisseur d'entier en chaîne ASCII (**`itoa`**) pour afficher les nombres sur la sortie standard, et gérer avec rigueur les erreurs critiques comme la **division par zéro**.

---

## 2. Spécifications Fonctionnelles

Le binaire s'exécute selon les variables passées dans le programme ou via arguments :
```bash
./my_calculator
```

### Comportement attendu :

1. **Addition (`+`)** :
   Exemple : $15 + 27 = 42$
   Sortie stdout : `42\n`
   Code retour   : `0`

2. **Soustraction (`-`)** :
   Exemple : $50 - 8 = 42$
   Sortie stdout : `42\n`
   Code retour   : `0`

3. **Multiplication (`*`)** :
   Exemple : $6 \times 7 = 42$
   Sortie stdout : `42\n`
   Code retour   : `0`

4. **Division Entière (`/`)** :
   Exemple : $85 / 2 = 42$
   Sortie stdout : `42\n`
   Code retour   : `0`

5. **Modulo (`%`)** :
   Exemple : $45 \% 10 = 5$
   Sortie stdout : `5\n`
   Code retour   : `0`

6. **Sécurité : Division par Zéro** :
   Si le diviseur vaut $0$ pour `/` ou `%` :
   Le programme **ne doit jamais crasher** en SIGFPE.
   Il écrit sur **`stderr` (FD 2)** :
   ```
   Error: Division by zero.
   ```
   suivi d'un retour à la ligne, et quitte immédiatement avec le code de sortie **`84`**.

---

## 3. Makefile Attendu

- `all` : Compile le binaire `my_calculator`
- `clean` : Nettoie les fichiers objets `.o`
- `fclean` : Nettoie les objets et le binaire
- `re` : Recompile complètement
