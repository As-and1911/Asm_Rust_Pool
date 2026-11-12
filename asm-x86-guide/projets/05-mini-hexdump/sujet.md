# Sujet Officiel — Projet 5 : L'Analyseur Binaire (`my_hexdump`)

```
Projet            : Visualisateur Hexadécimal (my_hexdump)
Durée estimée     : 6 à 10 heures
Rendu             : Makefile, my_hexdump.asm
Compilation       : nasm -f elf64 / ld (Liaison statique pure sans libc)
Code d'erreur     : 84 (Norme Epitech)
```

## 1. Description du Projet

L'objectif de ce projet est de concevoir un visualisateur hexadécimal de fichiers binaires en assembleur pur x86_64, capable de reproduire la sortie canonique de `hexdump -C`.

Le programme lit un fichier ou l'entrée standard par blocs de 16 octets et produit pour chaque bloc :
- L'offset en hexadécimal sur 8 caractères (ex: `00000000`, `00000010`...).
- Les octets formatés en 2 colonnes de 8 octets en hexadécimal.
- La colonne ASCII encadrée par `|...|` (caractères imprimables de 32 à 126, et un point `.` pour les autres).

---

## 2. Exemple de Sortie Attendue

Pour un fichier contenant `"Hello World!\n"` :
```
00000000  48 65 6c 6c 6f 20 57 6f  72 6c 64 21 0a           |Hello World!.|
0000000d
```
Note : La dernière ligne affiche l'offset final du fichier.
