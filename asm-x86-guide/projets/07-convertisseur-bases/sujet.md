# Sujet Officiel — Projet 7 : Convertisseur de Bases Universel

```
Projet            : my_base_converter
Durée estimée     : 6 à 8 heures
Rendu             : Makefile, my_base_converter.asm
Compilation       : nasm -f elf64 / ld (Liaison statique pure sans libc)
Code d'erreur     : 84 (Norme Epitech)
```

## 1. Description du Projet

Le programme prend trois arguments sur la ligne de commande :
```bash
./my_base_converter "VALEUR" "BASE_ENTREE" "BASE_SORTIE"
```
- Les bases supportées sont : `2` (binaire), `8` (octal), `10` (décimal), `16` (hexadécimal).
- Le programme convertit la valeur textuelle d'entrée en sa représentation dans la base de sortie, l'affiche sur `stdout` suivi d'un `\n`, et termine avec le code `0`.
- En cas d'argument invalide, de base non supportée ou de caractère illégal dans le nombre : afficher `Error\n` sur `stderr` et terminer avec le code de sortie `84`.

### Exemples :
```bash
./my_base_converter "42" "10" "16"   # Sortie : 2a
./my_base_converter "101010" "2" "10" # Sortie : 42
./my_base_converter "2A" "16" "2"    # Sortie : 101010
```
