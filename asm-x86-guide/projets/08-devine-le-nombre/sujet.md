# Sujet Officiel — Projet 8 : Jeu "Devine le Nombre" en Assembleur Pur

```
Projet            : guess_number
Durée estimée     : 6 à 8 heures
Rendu             : Makefile, guess_number.asm
Compilation       : nasm -f elf64 / ld (Liaison statique pure sans libc)
```

## 1. Description du Projet

L'objectif est d'implémenter un jeu interactif en terminal :
1. Le programme génère un nombre secret aléatoire compris entre **1 et 100**.
2. Il invite le joueur à deviner le nombre :
   ```
   Devine le nombre (entre 1 et 100) : 
   ```
3. L'utilisateur saisit sa proposition au clavier (`sys_read` sur `stdin`).
4. Le programme répond :
   - `Trop petit !\n` si la proposition est inférieure.
   - `Trop grand !\n` si la proposition est supérieure.
   - `Bravo ! Trouve en X essais !\n` quand le nombre secret est découvert, et termine avec le code de sortie `0`.

---

## 2. Génération Aléatoire en Assembleur Pur

Pour initialiser la graine aléatoire (*seed*) sans libc :
- Utilise le PID du processus courant via `sys_getpid` (syscall 39).
- Applique l'algorithme de hachage de bits **XORShift 64** pour obtenir un nombre pseudo-aléatoire.
- Réduis le résultat dans l'intervalle $[1, 100]$ avec un modulo 100 incrémenté de 1 (`div 100` $\rightarrow$ reste dans `rdx` $+ 1$).
