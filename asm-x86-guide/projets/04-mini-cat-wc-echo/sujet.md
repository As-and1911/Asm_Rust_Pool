# Sujet Officiel — Projet 4 : Utilitaires Système Unix (`my_echo`, `my_cat`, `my_wc`)

```
Projet            : Utilitaires Système Unix (my_echo, my_cat, my_wc)
Durée estimée     : 6 à 10 heures
Rendu             : Makefile, my_echo.asm, my_cat.asm, my_wc.asm
Compilation       : nasm -f elf64 / ld (Liaison statique pure sans libc)
Code d'erreur     : 84 (Norme Epitech)
```

## 1. Description du Projet

L'objectif de ce projet est de réécrire en assembleur x86_64 pur, sans aucune dépendance logicielle, les trois utilitaires indispensables de l'environnement Unix :
- **`my_echo`** : Affiche les arguments de la ligne de commande.
- **`my_cat`** : Concatène et affiche des flux de fichiers ou l'entrée standard.
- **`my_wc`** : Compte les lignes et les octets.

---

## 2. Spécifications Détaillées

### `my_echo`
- Récupère tous les arguments à partir de `argv[1]`.
- Les affiche sur la sortie standard (`stdout`), séparés par un espace unique `' '`.
- Termine par un retour à la ligne `\n`.
- Si aucun argument n'est fourni, affiche simplement `\n`.

### `my_cat`
- Si des fichiers sont passés en arguments (`argv[1]`, `argv[2]`...) :
  - Ouvre chaque fichier avec le syscall `open` (`O_RDONLY`).
  - Lit par blocs de 4096 octets avec `read` et écrit sur `stdout` avec `write`.
  - Ferme chaque fichier avec `close`.
  - Si un fichier ne peut être ouvert : affiche `my_cat: fichier: No such file or directory\n` sur `stderr` (FD 2) et retourne `84` à la fin.
- Si aucun argument n'est fourni : lit sur `stdin` (FD 0) et écrit sur `stdout` en continu jusqu'au signal EOF.

### `my_wc`
- Lit le fichier ou le flux d'entrée.
- Compte le nombre d'octets et de sauts de ligne (`\n`).
- Affiche les compteurs formatés.

---

## 3. Makefile Attendu

Le Makefile doit compiler les 3 binaires :
- `all` : Compile `my_echo`, `my_cat` et `my_wc`.
- `clean`, `fclean`, `re`.
