# Sujet Officiel — Projet 9 : Le Mini-Shell Unix (`my_sh`)

```
Projet            : my_sh
Durée estimée     : 15 à 20 heures
Rendu             : Makefile, my_sh.asm
Compilation       : nasm -f elf64 / ld (Liaison statique pure sans libc)
Code d'erreur     : 84 (Norme Epitech)
```

## 1. Description du Projet

L'objectif de ce projet est de concevoir un interpréteur de commandes interactif en assembleur x86_64 pur, sans aucune dépendance à la libc :

1. **Le Prompt** : Affiche `my_sh$ ` et attend une saisie utilisateur.
2. **Lecture & Parsing** : Lit la ligne saisie au clavier (`sys_read`), découpe les mots délimités par des espaces ou tabulations, et construit le tableau de pointeurs `argv` terminé par un pointeur `NULL`.
3. **Built-in `exit`** : Si l'utilisateur tape `exit`, le shell se ferme proprement en retournant `0`.
4. **Exécution des Commandes** :
   - Clone le processus via le syscall `fork` (57).
   - Le processus fils exécute le binaire demandé via le syscall `execve` (59).
   - Le processus parent attend la fin de l'exécution du fils via le syscall `wait4` (61), puis réaffiche le prompt dans une boucle infinie.
5. **Gestion de la fin de fichier (EOF / Ctrl+D)** : Quitte proprement sans boucle infinie.
